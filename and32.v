`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//Eric Chhour * Dante Secundino
//CECS341 Lab 04
//3/16/21
//////////////////////////////////////////////////////////////////////////////////
module alu(
           input [31:0] A,B,  // ALU 32-bit Inputs                 
           input [3:0] ALUCntl,// ALU Selection
           output reg [31:0] ALU_Out, // ALU 32-bit Output           
           output reg C, // Carry Out Flag
           output reg V, // Overflow Flag
           output reg N, // Negative Flag
           output Z  // Zero Flag
    );
    
    reg signed [31:0] A_s, B_s;
    assign Z = (ALU_Out == 0) ? 1'b1 :1'b0; //If any output is 0 set Zero flag to 0.. i think.
    
    always @(*) begin
        A_s = A;
        B_s = B;
        case(ALUCntl)
            4'b0000: begin//AND 
                  ALU_Out = A & B;
                  C = 1'bx; //Set to X because it doesnt matter
                  V = 1'bx;
                  N = ALU_Out[31];  //Set equal to the most significant bit
            end
            
            4'b0001: begin // OR
                 ALU_Out = (A | B);
                 C = 1'bx;
                 V = 1'bx;
                 N = ALU_Out[31];
            end
            
            4'b0010: begin //ADD UNSIGNED
                {C, ALU_Out} = A + B;
                V = C; //For unsigned, overflow and carryout flags are the same
                N = 0; //Operations with unsigned numbers cannot be negative
            end
            
            4'b0011: begin// XOR
                 ALU_Out = A ^ B;
                 C = 1'bx;
                 V = 1'bx;
                 N = ALU_Out[31];
            end  
            
            4'b0110: begin //SUBTRACT UNSIGNED 
                 {C, ALU_Out} = A - B;
                 V = C; //For unsigned, overflow and carryout flags are the same
                 N = 0; //Operations with unsigned numbers cannot be negative
            end
                 
              
            4'b1100: begin// NOR
                 ALU_Out = ~(A | B);
                 C = 1'bx;
                 V = 1'bx;
                 N = ALU_Out[31];
            end
                  
            4'b0111: begin// NOT
                 ALU_Out = ~(A & B);
                 C = 1'bx;
                 V = 1'bx;
                 N = ALU_Out[31];
            end
                         
            4'b1101: begin// SHIFT LEFT
                ALU_Out = A<<1;
                C = A[31];
                N = ALU_Out[31];
                V = 1'bx;
               
               end
               
            4'b1010: begin//  ADD Signed
                {C, ALU_Out} = A + B;
                N = ALU_Out[31];
                if((A[31] & B[31] & ~ALU_Out [31])||(~A[31] & ~B[31] & ALU_Out[31]))
                    V = 1'b1;
                else
                    V = 1'b0; 
            end
               
            4'b1110: begin//  SUBTRACT Signed
               {C, ALU_Out} = A - B;
               N = ALU_Out[31];
               if((~A[31] & B[31] & ALU_Out [31])||(A[31] & ~B[31] & ~ALU_Out[31]))
                    V = 1'b1;
               else
                    V = 1'b0;
               end
            
            4'b1111: begin //Set Less Than Signed
                C = 1'bx;
               
                V = 1'bx;
                if($signed(A) < $signed(B))
                    ALU_Out = 32'b1;
                else
                    ALU_Out = 32'b0;
                N = ALU_Out[31];
                end
            
            4'b0101: begin //Set less than Unsigned
                
                C = 1'bx;
                V = 1'bx;
                if(A < B)
                    ALU_Out = 32'b1;
                else
                    ALU_Out = 32'b0;
                N = ALU_Out[31];
                end
                
               
               
            default: begin
                ALU_Out = 31'bx;
                {C, V, N} = 3'bxxx;
            end
            
       endcase
    end

endmodule
