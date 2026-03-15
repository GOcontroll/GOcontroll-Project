# =============================================================================
# GOcontroll Linux Application Makefile
#
# Usage:
#   make                          Build the application (native)
#   make <example>                Build an example, e.g. make led_blink
#   make CC=aarch64-linux-gnu-gcc Cross-compile for ARM64
#   make DEBUG=1                  Build with debug output enabled
#   make clean                    Remove build directory
# =============================================================================

# --- Toolchain ---------------------------------------------------------------
CC ?= gcc

# --- Directories -------------------------------------------------------------
CODEBASE := GOcontroll-CodeBase
APP_DIR  := application
EXAMPLES := $(CODEBASE)/examples
BUILD    ?= build

# --- Target ------------------------------------------------------------------
TARGET := $(BUILD)/app.elf

# --- Upload ------------------------------------------------------------------
IP   ?= 192.168.1.19
PORT ?= 8001

# --- Flags -------------------------------------------------------------------
CFLAGS := -Wall -Wextra -DGOCONTROLL_LINUX -D_GNU_SOURCE
CFLAGS += -DDEBUG=$(if $(filter 1,$(DEBUG)),1,0)
CFLAGS += -I$(CODEBASE)/code -I$(CODEBASE)/code/modules -I$(APP_DIR)
CFLAGS += -I$(CODEBASE)/lib/IIO -I$(CODEBASE)/lib/JSON-C -I$(CODEBASE)/lib/OAES

LIB_DIR := $(CODEBASE)/lib
LDFLAGS := -lpthread -lrt \
	$(LIB_DIR)/IIO/libiio.a \
	$(LIB_DIR)/JSON-C/libjson-c.a \
	$(LIB_DIR)/OAES/liboaes_lib.a

# --- GOcontroll-CodeBase sources (Linux, ESP excluded) -----------------------
CODEBASE_SRCS := \
	$(CODEBASE)/code/GO_board.c \
	$(CODEBASE)/code/GO_communication_can.c \
	$(CODEBASE)/code/GO_communication_lin.c \
	$(CODEBASE)/code/GO_communication_modules.c \
	$(CODEBASE)/code/GO_controller_info.c \
	$(CODEBASE)/code/GO_fault.c \
	$(CODEBASE)/code/GO_gps.c \
	$(CODEBASE)/code/GO_memory.c \
	$(CODEBASE)/code/GO_xcp.c \
	$(CODEBASE)/code/XcpStack.c \
	$(CODEBASE)/code/print.c \
	$(CODEBASE)/code/modules/GO_module_bridge.c \
	$(CODEBASE)/code/modules/GO_module_input.c \
	$(CODEBASE)/code/modules/GO_module_input_420ma.c \
	$(CODEBASE)/code/modules/GO_module_output.c

CODEBASE_OBJS := $(patsubst %.c,$(BUILD)/%.o,$(CODEBASE_SRCS))

# --- Application sources -----------------------------------------------------
APP_OBJ := $(BUILD)/$(APP_DIR)/main.o

# =============================================================================
.PHONY: all clean upload led_blink read_supply_voltages input_module_10ch input_module_10ch_selftest

all: $(TARGET)

# Link default application
$(TARGET): $(CODEBASE_OBJS) $(APP_OBJ)
	$(CC) $^ -o $@ $(LDFLAGS)
	@echo "Built: $@"

# --- Examples ----------------------------------------------------------------
led_blink: $(CODEBASE_OBJS) $(BUILD)/$(EXAMPLES)/led_blink.o
	$(CC) $^ -o $(TARGET) $(LDFLAGS)
	@echo "Built: $(TARGET)"

read_supply_voltages: $(CODEBASE_OBJS) $(BUILD)/$(EXAMPLES)/read_supply_voltages.o
	$(CC) $^ -o $(TARGET) $(LDFLAGS)
	@echo "Built: $(TARGET)"

input_module_10ch: $(CODEBASE_OBJS) $(BUILD)/$(EXAMPLES)/input_module_10ch.o
	$(CC) $^ -o $(TARGET) $(LDFLAGS)
	@echo "Built: $(TARGET)"

input_module_10ch_selftest: $(CODEBASE_OBJS) $(BUILD)/$(EXAMPLES)/input_module_10ch_selftest.o
	$(CC) $^ -o $(TARGET) $(LDFLAGS)
	@echo "Built: $(TARGET)"

# --- Compile — create subdirectory before building ---------------------------
$(BUILD)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

upload: $(TARGET)
	curl --connect-timeout 2 -i -X POST \
		-H "Content-Type: multipart/form-data" \
		-F "elfFile=@$(TARGET)" \
		http://$(IP):$(PORT)/upload
	@echo "Uploaded: $(TARGET) to $(IP):$(PORT)"

clean:
	rm -rf $(BUILD)
	@echo "Cleaned build directory"
