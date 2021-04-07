`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//CECS341 Lab 04
//3/16/21
//////////////////////////////////////////////////////////////////////////////////

module control(
    input [5:0] Op,
    input [5:0] Func,
    output reg RegWrite,
    output reg [3:0] ALUCntl, 
    output reg RegDst,
    output reg [1:0] Branch,
    output reg MemRead,
    output reg MemWrite,
    output reg MemtoReg,
    output reg ALUSrc
    );
    
    always@(*) begin
        if (Op == 6'b0) begin
            RegWrite = 1'b1;
            RegDst = 1'b1;
            Branch = 2'b0;
            MemRead = 1'b0;
            MemWrite = 1'b0;
            MemtoReg = 1'b0;
            ALUSrc = 1'b0;
            
            case (Func)
                6'h20: ALUCntl = 4'b1010;
                6'h21: ALUCntl = 4'b0010;
                6'h22: ALUCntl = 4'b1110;
                6'h23: ALUCntl = 4'b0110;
                6'h24: ALUCntl = 4'b0000;
                6'h25: ALUCntl = 4'b0001;
                6'h26: ALUCntl = 4'b0011;
                6'h27: ALUCntl = 4'b1100;
                6'h2A: ALUCntl = 4'b0101; //Slt
                6'h2B: ALUCntl = 4'b1111; //Slt unsigned
                default: ALUCntl = 4'b0000; 
            endcase
        end
        else begin  
            case(Op)
                6'h08: begin                    // Add immediate  
                        ALUCntl = 4'b1010;      // Addi ALU Control
                        RegWrite   = 1'b1;      // Write back to register file
                        RegDst     = 1'b0;      // Inst[20:16] is write back address
                        Branch     = 2'b00;     // No branching in addi
                        MemRead    = 1'b0;      // only occurs during loadword operation
                        MemWrite   = 1'b0;      // only occurs during storeword operation
                        MemtoReg   = 1'b0;      // this is 0 when the result of the operation is written back into the register file
                        ALUSrc     = 1'b1;      // only when the second operand is SE Immed. instead of rt. False for all R type instructions?
                        end 
                6'h09: begin                    // Add Immediate Unsigned
                        ALUCntl = 4'b0010;      // AddiU ALU Control
                        RegWrite   = 1'b1;      //  
                        RegDst     = 1'b0;      // 
                        Branch     = 2'b00;     // 
                        MemRead    = 1'b0;      // only occurs during loadword operation
                        MemWrite   = 1'b0;      // only occurs during storeword operation
                        MemtoReg   = 1'b0;      // 
                        ALUSrc     = 1'b1;      //
                        end
                6'h0C: begin                    // And Immediate
                        ALUCntl = 4'b0000;      // Andi ALU Control
                        RegWrite   = 1'b1;     
                        RegDst     = 1'b0;     
                        Branch     = 2'b00;      
                        MemRead    = 1'b0;      
                        MemWrite   = 1'b0;       
                        MemtoReg   = 1'b0;      
                        ALUSrc     = 1'b1;      //NOT SURE
                       end        
                6'h0D: begin                    // Or Immediate
                        ALUCntl = 4'b0001;      // Ori ALU Control
                        RegWrite   = 1'b0;      
                        RegDst     = 1'b0;       
                        Branch     = 2'b00;      
                        MemRead    = 1'b0;      
                        MemWrite   = 1'b0;       
                        MemtoReg   = 1'b0;      
                        ALUSrc     = 1'b0;      
                       end
                6'h23: begin                    // Loadword
                        ALUCntl = 4'b0010;   // Lw ALU Control
                        RegWrite   = 1'b1;      
                        RegDst     = 1'b0;      
                        Branch     = 2'b00;       
                        MemRead    = 1'b1;       
                        MemWrite   = 1'b0;       
                        MemtoReg   = 1'b1;      
                        ALUSrc     = 1'b1;      
                        end  
                6'h2B: begin                    // Storeword
                        ALUCntl = 4'b0010;      // Sw ALU Control
                        RegWrite   = 1'b0;      
                        RegDst     = 1'b0;       
                        Branch     = 2'b00;      
                        MemRead    = 1'b0;       
                        MemWrite   = 1'b1;       
                        MemtoReg   = 1'b0;      
                        ALUSrc     = 1'b1;      
                       end
                6'h04: begin                    // Branch on Equal
                        ALUCntl = 4'b1110;      // Beq ALU Control
                        RegWrite   = 1'b0;      
                        RegDst     = 1'b0;      
                        Branch     = 2'b01;      
                        MemRead    = 1'b0;       
                        MemWrite   = 1'b0;       
                        MemtoReg   = 1'b0;      
                        ALUSrc     = 1'b0;      
                        end
                6'h05: begin                    // Branch On Not Equal
                        ALUCntl = 4'b1110;      // Bne ALU Control
                        RegWrite   = 1'b0;       
                        RegDst     = 1'b0;       
                        Branch     = 2'b10;     
                        MemRead    = 1'b0;       
                        MemWrite   = 1'b0;      
                        MemtoReg   = 1'b0;      
                        ALUSrc     = 1'b0;      
                        end           
                6'h0A: begin //Set less than immediate
                        RegWrite = 1'b1;   //Write back to register file
                        ALUCntl = 4'b1111; //SLT signed, must match your ALU control #                                   
                        RegDst = 1'b0;     //All I type instructions write back to [20;16]  
                        Branch = 2'b00;    //Not a branch                                  
                        MemRead = 1'b0;    //Only True for Load Word operation              
                        MemWrite = 1'b0;   //Only True for Store Word Operation             
                        MemtoReg = 1'b0;   //Writeback data comes from ALU (only 1 for LW i think)
                        ALUSrc = 1'b1;     //Uses SignExtendImm on the greensheet
                        end
                6'h0B: begin //Set less than imm unsigned
                        RegWrite = 1'b1;   //Write back to register file ( R[rt]= on the greensheet)
                        ALUCntl = 4'b0101; //SLT unsigned must match your ALU control #                                   
                        RegDst = 1'b0;     //All I type instructions write back to [20;16]  
                        Branch = 2'b00;    //Not a branch                                  
                        MemRead = 1'b0;    //Only True for Load Word operation              
                        MemWrite = 1'b0;   //Only True for Store Word Operation             
                        MemtoReg = 1'b0;   //Writeback data comes from ALU (only 1 for LW i think)
                        ALUSrc = 1'b1;     //Uses SignExtendImm on the greensheet
                        end
                default: begin
                        RegWrite = 1'bx;   
                        ALUCntl = 4'bxxxx; 
                        RegDst = 1'bx;     
                        Branch = 2'bx;     
                        MemRead = 1'bx;    
                        MemWrite = 1'bx;   
                        MemtoReg = 1'bx;  
                        ALUSrc = 1'bx;    
                        end
          
        endcase
        end
    end
endmodule
