module Datapath(
    input clk,
    input reset,
    output [31:0] Dout
    );
    wire [31:0] pcAddOut, pcROut, iMemOut, rs, rt;
    wire [5:0] op, func;
    wire [3:0] ALUCntl;
    wire RegWrite, Negative, Carry, Overflow, Zero;
    
    //Declare new Wires 
    wire [31:0] SignExtended, ShiftTwo, BranchAdd, DataMem_out;
    wire [1:0] Branch;
    wire RegDst, MemtoReg, MemRead, MemWrite, ALUSrc;
    //Output Wire for muxes
    wire [4:0] RegDst_Mux;
    wire [31:0] ALUSrc_Mux, MemtoReg_Mux, Branch_Mux;
    //Mux Logic
    assign RegDst_Mux = (RegDst == 1) ? iMemOut[15:11] : iMemOut[20:16];
    assign ALUSrc_Mux = (ALUSrc == 1) ? SignExtended : rt;
    assign MemtoReg_Mux = (MemtoReg == 1) ? DataMem_out : Dout;
    // Branch Mux: if(Branch&&Zero)||(Branch&&!Zero) simplifies to if(branch)
    assign Branch_Mux = ((Branch[0]&&Zero)||((Branch[1]&&(!Zero)))) ? BranchAdd : pcAddOut;
    
    //Building Datapath
    
    PCRegister PC(
        .clk(clk), 
        .reset(reset), 
        .Din(Branch_Mux), //PC Now takes input from Branch_Mux instead of pcAddOut 
        .PC_out(pcROut));
        
    PCADD PCadd(
        .Din(pcROut), 
        .PC_add_out(pcAddOut));
        
    Instruction_Memory im(
        .Addr(pcROut),
        .Inst_out(iMemOut));
        
    control cnt(
        .Op(iMemOut[31:26]), 
        .Func(iMemOut[5:0]), 
        .RegWrite(RegWrite), 
        .ALUCntl(ALUCntl), 
        .RegDst(RegDst),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc));
                
    regfile32 rf(
        .clk(clk), 
        .reset(reset), 
        .D_En(RegWrite), 
        .D_Addr(RegDst_Mux), 
        .S_Addr(iMemOut[25:21]), 
        .T_Addr(iMemOut[20:16]), 
        .D(MemtoReg_Mux), //Now takes input from MemtoReg_Mux
        .S(rs), 
        .T(rt));
    
    SignExtend Extender(
        .Instruction(iMemOut[15:0]), 
        .SignExtended(SignExtended)); 
    
    ShiftLeft2 Shifter(
        .SignExtended(SignExtended), 
        .Shifted(ShiftTwo));
    
    BranchAdd BranchAdder(
        .ShiftLeft2(ShiftTwo), 
        .PCAdd(pcAddOut), 
        .BranchAddOut(BranchAdd));
        
    alu v(
        .A(rs), 
        .B(ALUSrc_Mux), //Now takes in input from MUX instead of RT; either RT or SignExtend output
        .ALUCntl(ALUCntl),
        .ALU_Out(Dout), 
        .C(Carry), 
        .V(Overflow), 
        .N(Negative), 
        .Z(Zero));
        
    DataMem DataMemory(
        .clk(clk),               
        .mem_wr(MemWrite),
        .mem_rd(MemRead),
        .addr(Dout),
        .wr_data(rt), // "result from register file will be stored into the data memory" -> output of ALU is Dout
        .rd_data(DataMem_out));
        
endmodule
