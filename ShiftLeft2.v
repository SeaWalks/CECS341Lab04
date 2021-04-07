`timescale 1ns / 1ps


module ShiftLeft2(
    input [31:0] SignExtended,
    output reg [31:0] Shifted
    );
    always @(*) begin
        assign Shifted = SignExtended<<2;
    end
endmodule
