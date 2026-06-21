//---------------------------------------------------------------
// periodic_pulse_generator.sv
//
// Purpose:
// Generate a periodic timing event.
//
// This module serves as a scheduler for downstream modules
// that require a slower update rate than the FPGA system clock.
//
// Current Usage:
//
// HC-SR04 measurement scheduler
//
// System Architecture:
//
// periodic_pulse_generator.sv
//     ↓
// single_pulse
//     ↓
// HC-SR04 trigger
//     ↓
// echo_timer
//     ↓
// UART
//     ↓
// Python
//
// Notes:
// - Current implementation: 1 Hz update rate.
// - Assumes a 100 MHz Basys 3 clock.
// - Future version may become a parameterized periodic timer.
//---------------------------------------------------------------

module periodic_pulse_generator #(
    parameter int CLOCK_HZ  = 100_000_000,
    parameter int PERIOD_MS = 1000 
)(
    input wire clk,
    input wire rst, 
    output reg pulse_out
);

    localparam int COUNT_MAX = (CLOCK_HZ * PERIOD_MS / 1000) - 1;

    reg [31:0] counter;

    always @ (posedge clk) begin
        if (rst) begin
            counter     <= 0;
            pulse_out   <= 0;
        end

        else if (counter == COUNT_MAX) begin
            counter     <= 0;
            pulse_out   <= ~pulse_out;
        end

        else begin
            counter     <= counter + 1;
        end
    end
endmodule


