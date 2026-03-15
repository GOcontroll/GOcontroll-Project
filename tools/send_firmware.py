#!/usr/bin/env python3
"""
GOcontroll-IoT — BLE firmware transfer utility.
Sends a .srec (or any binary) file to the GOcontroll-IoT ESP32 via BLE.

Usage:
    python send_firmware.py <path/to/firmware.srec>

Requirements:
    pip install bleak
"""

import asyncio
import sys
import time
from pathlib import Path

try:
    from bleak import BleakClient, BleakScanner
except ImportError:
    print("bleak is not installed. Run: pip install bleak")
    sys.exit(1)


# ── BLE configuration ──────────────────────────────────────────────────────────
DEVICE_NAME   = "GOcontroll-IoT"
CHR_DATA_UUID = "f0001001-1234-5678-9abc-def012345678"   # Write / Write-No-Rsp
CHR_CTRL_UUID = "f0001002-1234-5678-9abc-def012345678"   # Write
CHR_STAT_UUID = "f0001003-1234-5678-9abc-def012345678"   # Read / Notify

# Control commands (written to CONTROL characteristic)
CTRL_START = bytes([0x01])
CTRL_END   = bytes([0x02])
CTRL_ABORT = bytes([0x03])

# Status bytes (received via STATUS notifications)
STATUS_IDLE     = 0x00
STATUS_READY    = 0x01
STATUS_COMPLETE = 0x03
STATUS_ERROR    = 0xFF

# Bytes per write — keep ≤ ATT_MTU - 3.
# ESP32 default ATT_MTU is 256 → max payload 253.
# Lower this value if you see "Characteristic write failed" errors.
CHUNK_SIZE = 244


# ── Device discovery ───────────────────────────────────────────────────────────
async def find_device():
    print(f"Scanning for '{DEVICE_NAME}' ...")
    device = await BleakScanner.find_device_by_name(DEVICE_NAME, timeout=10.0)
    if device is None:
        print(f"  Device not found — is the ESP32 powered and advertising?")
        sys.exit(1)
    print(f"  Found: {device.name}  [{device.address}]")
    return device


# ── Transfer ───────────────────────────────────────────────────────────────────
async def send_firmware(file_path: Path):
    payload = file_path.read_bytes()
    total   = len(payload)

    print(f"File : {file_path.name}")
    print(f"Size : {total} bytes  ({total / 1024:.1f} KB)")
    print()

    device = await find_device()

    # asyncio.Queue to synchronise on STATUS characteristic notifications.
    # Queue never loses a notification that arrived during a preceding await.
    status_queue = asyncio.Queue()

    STATUS_NAMES = {
        STATUS_IDLE:     "IDLE",
        STATUS_READY:    "READY",
        STATUS_COMPLETE: "COMPLETE",
        STATUS_ERROR:    "ERROR",
    }

    def on_status(sender, data: bytearray):
        code = data[0] if data else None
        label = STATUS_NAMES.get(code, f"0x{code:02X}")
        print(f"\n  ← STATUS: {label}")
        status_queue.put_nowait(code)

    async def wait_for_status(expected: int, timeout: float = 10.0):
        """Block until the expected STATUS notification arrives."""
        try:
            code = await asyncio.wait_for(status_queue.get(), timeout=timeout)
        except asyncio.TimeoutError:
            raise TimeoutError(
                f"Timeout waiting for STATUS 0x{expected:02X} "
                f"after {timeout:.0f} s"
            )
        if code == STATUS_ERROR:
            raise RuntimeError("ESP32 reported STATUS ERROR (buffer full or protocol fault)")
        if code != expected:
            raise RuntimeError(
                f"Unexpected STATUS 0x{code:02X} "
                f"(expected 0x{expected:02X})"
            )

    async with BleakClient(device) as client:
        print(f"Connected.\n")

        await client.start_notify(CHR_STAT_UUID, on_status)

        # 1. Send START — ESP32 clears its buffer and replies READY
        print("→ CTRL START")
        await client.write_gatt_char(CHR_CTRL_UUID, CTRL_START, response=True)
        await wait_for_status(STATUS_READY)

        # 2. Send file in chunks
        print(f"→ DATA  ({CHUNK_SIZE} bytes/chunk)")
        sent    = 0
        t_start = time.monotonic()

        while sent < total:
            chunk  = payload[sent : sent + CHUNK_SIZE]
            await client.write_gatt_char(CHR_DATA_UUID, bytes(chunk), response=True)
            sent  += len(chunk)
            pct    = sent * 100 // total
            elapsed = max(time.monotonic() - t_start, 0.001)
            rate   = sent / elapsed / 1024
            print(f"  {sent:6d} / {total}  ({pct:3d}%)  {rate:5.1f} KB/s", end="\r")

        elapsed = time.monotonic() - t_start
        print(f"  {total} / {total}  (100%)  {total / elapsed / 1024:.1f} KB/s")
        print(f"  Completed in {elapsed:.1f} s\n")

        # 3. Send END — ESP32 invokes the transfer-done callback and replies COMPLETE
        print("→ CTRL END")
        await client.write_gatt_char(CHR_CTRL_UUID, CTRL_END, response=True)
        await wait_for_status(STATUS_COMPLETE, timeout=15.0)

        await client.stop_notify(CHR_STAT_UUID)

    print("\nTransfer complete.")


# ── Entry point ────────────────────────────────────────────────────────────────
def main():
    if len(sys.argv) != 2:
        name = Path(sys.argv[0]).name
        print(f"Usage: python {name} <firmware.srec>")
        sys.exit(1)

    path = Path(sys.argv[1])
    if not path.exists():
        print(f"File not found: {path}")
        sys.exit(1)

    try:
        asyncio.run(send_firmware(path))
    except (TimeoutError, RuntimeError) as exc:
        print(f"\nERROR: {exc}")
        sys.exit(1)
    except KeyboardInterrupt:
        print("\nAborted.")
        sys.exit(1)


if __name__ == "__main__":
    main()
