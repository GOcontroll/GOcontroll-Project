/**************************************************************************************
 * \file   main.c
 * \brief  Blink the green status LED at 1 Hz (500 ms on / 500 ms off).
 **************************************************************************************/

#include <stdint.h>
#include <unistd.h>

#include "GO_board.h"
#include "print.h"

static void app_terminate(void)
{
	info("Application terminating\n");

	GO_board_controller_power_stop_adc_thread();
	GO_board_status_leds_led_control(1, LED_COLOR_GREEN, 0);
	GO_board_controller_power_controller_active(0);
}

int main(void)
{
	info("GOcontroll blink example starting\n");

	GO_board_get_hardware_version();
	GO_board_controller_power_start_adc_thread(100);
	GO_board_status_leds_initialize();
	GO_board_exit_program(app_terminate);

	uint8_t led_state = 0;
	int     cycle     = 0;

	while (1) {
		if (++cycle >= 50) {          /* 50 × 10 ms = 500 ms */
			cycle     = 0;
			led_state = !led_state;
			GO_board_status_leds_led_control(1, LED_COLOR_RED, led_state*100);
		}

		usleep(10000);                /* 10 ms cycle */
	}

	return 0;
}
