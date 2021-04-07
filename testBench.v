module DataPath_tb();
    reg clk;
    reg reset;
    wire [31:0]Dout;
    integer i;

    Datapath uut(.clk(clk), .reset(reset), .Dout(Dout));

    always
        #10 clk = ~clk;
    initial begin
        clk = 0;
        reset = 0; 
    end

    task Dump_Datamem; begin
        $timeformat(-9, -1, " ns", 9);
        for(i = 24; i<48; i=i+4) begin
            @(posedge clk)
            $display("t=%t rf[%0d]: %h", $time, i, 
            {uut.DataMemory.dmem[i],
            uut.DataMemory.dmem[i+1],
            uut.DataMemory.dmem[i+2],
            uut.DataMemory.dmem[i+3]});
       end
    end
    endtask

    initial begin
        
        $readmemh("imem.dat", uut.im.imem);
        $readmemh("DataMem.dat", uut.DataMemory.dmem);
        reset = 1; #20
        reset = 0; #600
        Dump_Datamem;
        $finish;

    end
endmodule
