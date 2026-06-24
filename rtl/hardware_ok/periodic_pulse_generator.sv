//---------------------------------------------------------------
// periodic_pulse_generator.sv
//
// Purpose:
// Generate a periodic one-clock timing pulse.
//
// This module acts as a measurement scheduler and produces a
// single-clock 'tick' at a programmable interval.
//
// Current Usage:
// Initiates a new HC-SR04 distance measurement.
//
// periodic_pulse_generator
//            ↓
//     measurement_tick
//            ↓
//       single_pulse
//            ↓
//    10 µs trigger pulse
//            ↓
//           JA1
//            ↓
//         HC-SR04
//            ↓
//       echo_timer
//            ↓
//     echo_uart_bridge
//            ↓
//           UART
//            ↓
//          Python
//
// Parameters:
// - CLOCK_HZ : FPGA system clock frequency
// - PERIOD_MS: Time between measurements
//
// Notes:
// - Outputs a one-clock pulse, not a toggle.
// - Current system clock: 100 MHz (Basys 3).
// - Reusable for any periodic scheduling task.
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
            counter     <= 32'd0;
            pulse_out   <= 1'b0;
        
        end else begin

        pulse_out   <= 1'b0; // default low
        
        if (counter == COUNT_MAX) begin
            counter     <= 32'd0;
            pulse_out   <= 1'b1; // high for one clock only
        end

        else begin
            counter     <= counter + 1;
        end
     end
    end
endmodule


