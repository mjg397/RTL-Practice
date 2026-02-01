/*
------------------------------------------------------------------------------
Serial Packet Header Detector

Description:
    This module implements a finite state machine (FSM) that detects a specific
    8-bit packet header in a serial bit stream.

    The target header pattern is:
        HEADER = 8'b1011_0110

    The input bit stream is sampled one bit per clock cycle, MSB first.

Requirements:
    - Assert `header_detected` for exactly one clock cycle when the full header
      pattern is observed.
    - The design must support overlapping header patterns.
    - After detection, the FSM should immediately continue searching for the
      next header (no dead cycles).
    - The FSM must be synchronous to `clk`.
    - Reset (`rst`) is active-high and synchronous.

Interface:
    Inputs:
        clk     - System clock
        rst     - Active-high synchronous reset
        in_bit  - Serial input bit stream (1 bit per cycle)

    Outputs:
        header_detected - One-cycle pulse asserted when the header is detected

------------------------------------------------------------------------------
*/

module header_fsm (
    input  logic clk,
    input  logic rst,
    input  logic in_bit,
    output logic header_detected
);

logic [2:0] state, state_next;

localparam START = 3'b000;
localparam FIRST = 3'b001;
localparam SECOND = 3'b010;
localparam THIRD = 3'b011;
localparam FOURTH = 3'b100;
localparam FIFTH = 3'b101;
localparam SIXTH = 3'b110;
localparam SEVENTH = 3'b111;
// when at seventh this is when there are a possible output


always_comb begin
    case ( state )
        START : state_next = (in_bit) ? FIRST : START;
        FIRST : state_next = (in_bit) ? FIRST : SECOND;
        SECOND : state_next = (in_bit) ? THIRD : START;
        THIRD : state_next = (in_bit) ? FOURTH : SECOND;
        FOURTH : state_next = (in_bit) ? FIRST : FIFTH;
        FIFTH : state_next = (in_bit) ? SIXTH : START;
        SIXTH : state_next = (in_bit) ? SEVENTH : SECOND;
        SEVENTH : state_next = (in_bit) ? FIRST : FIFTH;
        default: state_next = START;
    endcase

    if (state == SEVENTH && !in_bit)
        header_detected = 1'b1;
    else 
        header_detected = 1'b0;
end



always_ff @(posedge clk) begin
    if (rst) begin
        state <= START;
    end
    else begin
        state <= state_next;
    end
end

endmodule