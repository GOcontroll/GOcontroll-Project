/**************************************************************************************
 * \file   main.c
 * \brief  Blink the status LED at 1 Hz (500 ms on / 500 ms off).
 *
 *         This file is the starting point for your application. It supports two
 *         platforms, selected at compile time via a preprocessor define:
 *
 *           - GOCONTROLL_LINUX  : Moduline IV / Mini / Display (Linux, bare loop)
 *           - GOCONTROLL_IOT    : Moduline IOT (STM32H573, FreeRTOS)
 *
 *         Select the target in VS Code using the Linux or IoT button in the
 *         status bar before building.
 **************************************************************************************/

#include <stdint.h>
#include "GO_board.h"
#include "print.h"

/* ============================================================================
 * Linux — Moduline IV / Mini / Display
 * ============================================================================
 *
 * The application runs as a regular Linux process. Timing is done with
 * usleep(). The GO_board_exit_program() callback is called when the process
 * receives a termination signal (e.g. SIGTERM), allowing a clean shutdown.
 * ========================================================================= */
#ifdef GOCONTROLL_LINUX

#include <unistd.h>

/* Called on SIGTERM / SIGINT — turn off outputs and release the hardware. */
static void app_terminate(void)
{
	info("Application terminating\n");

	GO_board_controller_power_stop_adc_thread();
	GO_board_status_leds_led_control(1, LED_COLOR_BLUE, 0);
	GO_board_controller_power_controller_active(0);
}

int main(void)
{
	info("GOcontroll blink example starting\n");

	GO_board_get_hardware_version();
	GO_board_controller_power_start_adc_thread(100); /* Start ADC monitoring at 100 ms interval */
	GO_board_status_leds_initialize();
	GO_board_exit_program(app_terminate);            /* Register shutdown callback */

	uint8_t led_state = 0;
	int     cycle     = 0;

	while (1) {
		if (++cycle >= 50) {          /* 50 × 10 ms = 500 ms */
			cycle     = 0;
			led_state = !led_state;
			GO_board_status_leds_led_control(1, LED_COLOR_BLUE, led_state * 100);
		}

		usleep(10000);                /* 10 ms cycle */
	}

	return 0;
}

/* ============================================================================
 * IoT — Moduline IOT (STM32H573, FreeRTOS)
 * ============================================================================
 *
 * The application runs under FreeRTOS. main() initialises the hardware and
 * creates the application threads, then hands control to the RTOS scheduler
 * via osKernelStart(). After that point main() never returns.
 *
 * Two threads are required by the GOcontroll platform (GO_board.c uses the
 * thread handles for stack-usage monitoring):
 *
 *   model_step_thread — main application logic, runs at normal priority.
 *                        Put your application code in model_step_func().
 *   xcp_thread        — XCP calibration/measurement interface. Replace the
 *                        stub below with GO_xcp_thread_can() when XCP is needed.
 * ========================================================================= */
#elif defined(GOCONTROLL_IOT)

#include "GO_iot_initialize.h"
#include "cmsis_os2.h"

/* Thread handles — GO_board.c reads these to report stack usage. */
osThreadId_t model_step_thread;
osThreadId_t xcp_thread;

/* --------------------------------------------------------------------------
 * model_step_func — main application task
 *
 * This is where your application logic goes. The function is called once by
 * FreeRTOS and must never return — keep the infinite loop in place.
 * -------------------------------------------------------------------------- */
static void model_step_func(void *argument)
{
	(void)argument;
	GO_board_get_hardware_version();
	GO_board_status_leds_initialize();

	uint8_t led_state = 0;
	int     cycle     = 0;

	while (1) {
		if (++cycle >= 50) {          /* 50 × 10 ms = 500 ms */
			cycle     = 0;
			led_state = !led_state;
			GO_board_status_leds_led_control(1, LED_COLOR_RED, led_state * 100);
		}

		osDelay(10);                  /* 10 ms — yields to other tasks while waiting */
	}
}

/* --------------------------------------------------------------------------
 * xcp_func — XCP calibration thread (stub)
 *
 * Replace osDelay(1000) with GO_xcp_thread_can() when XCP over CAN is needed.
 * -------------------------------------------------------------------------- */
static void xcp_func(void *argument)
{
	(void)argument;

	while (1) {
		osDelay(1000);
	}
}

int main(void)
{
	/* Initialise clocks, peripherals, SEGGER RTT and the FreeRTOS kernel.
	 * osKernelInitialize() is called inside GO_iot_initialize(). */
	GO_iot_initialize();

	/* Thread configuration — stack size in bytes, priority relative to other tasks. */
	static const osThreadAttr_t model_step_attrs = {
		.name       = "model_step",
		.stack_size = 512 * 4,        /* 2 KB — increase if stack overflow occurs */
		.priority   = (osPriority_t)osPriorityNormal,
	};

	static const osThreadAttr_t xcp_attrs = {
		.name       = "xcp",
		.stack_size = 128 * 4,        /* 512 B — sufficient for the stub */
		.priority   = (osPriority_t)osPriorityLow,
	};

	/* Create threads — must happen after osKernelInitialize() and before osKernelStart(). */
	model_step_thread = osThreadNew(model_step_func, NULL, &model_step_attrs);
	xcp_thread        = osThreadNew(xcp_func,        NULL, &xcp_attrs);

	/* Start the FreeRTOS scheduler — this call never returns. */
	osKernelStart();

	while (1) {}  /* Should never reach here */

	return 0;
}

#endif /* GOCONTROLL_LINUX / GOCONTROLL_IOT */
