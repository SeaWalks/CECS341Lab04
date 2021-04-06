`timescale 1ns / 1ps


module SignExtend(
 
    input [15:0] Instruction,
    output reg [31:0] SignExtended
    );
    always @(*) begin
        assign SignExtended = {{16{Instruction[15]}}, Instruction[15:0]};
    end
endmodule
