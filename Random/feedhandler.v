// -----------------------------------------------------------------------------
// Module: feedhandler
//
// Description:
//   Newest-wins feed handler for timestamped input data. The module accepts
//   input packets consisting of a data word and an associated timestamp.
//   Only packets with strictly newer timestamps than the previously accepted
//   packet are retained.
//
// Behavior:
//   - Input packets are considered only when in_valid is asserted.
//   - The first valid packet after reset is always accepted.
//   - Subsequent packets are accepted only if in_ts > prev_accepted_ts.
//   - Rejected packets do not modify internal state.
//   - out_data holds the most recently accepted packet.
//   - out_valid pulses high for one cycle when a new packet is accepted.
//
// Reset:
//   - Synchronous reset.
//   - Clears stored data and timestamp.
//   - Deasserts out_valid.
//   - Prepares module to accept the first valid packet unconditionally.
//
// Notes:
//   - Single clock domain.
//   - No backpressure or buffering beyond one stored value.
//   - Timestamp wraparound is not handled.
// -----------------------------------------------------------------------------


module feedhandler (
    input  logic        clk, reset,
    input  logic        in_valid,
    input  logic [31:0] in_data,
    input  logic [15:0] in_ts, 
    output logic        out_valid, 
    output logic [31:0] out_data
);

logic [15:0] prev_accepted_ts;
logic        is_first_value;

always_ff @(posedge clk) begin
    if (reset) begin
        prev_accepted_ts <= 0;
        out_valid <= 0;
        out_data <= 0;
        is_first_value <= 1;
    end
    else begin
        if (((in_ts > prev_accepted_ts) || is_first_value) && in_valid) begin
            out_valid <= 1;
            out_data <= in_data;
            prev_accepted_ts <= in_ts;
            is_first_value <= 0;
        end
        else begin
            out_valid <= 0;
        end

        
        
    end
end

endmodule