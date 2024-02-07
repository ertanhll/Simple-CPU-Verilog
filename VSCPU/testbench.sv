
module tb_VSCPU;
  parameter SIZE = 14, DEPTH = 2**SIZE;
  reg clk, rst;
  wire wrEn;
  wire [SIZE-1:0] addr_toRAM;
  wire [31:0] data_toRAM, data_fromRAM;

  VSCPU uut (clk, rst, data_fromRAM, wrEn,  addr_toRAM, data_toRAM);

  blram #(SIZE, DEPTH) inst_bram (
clk, rst, wrEn, addr_toRAM, data_toRAM, data_fromRAM);

  initial begin
    clk = 1;
    forever
      #5 clk = ~clk;
  end

  initial begin
    rst = 1;
    repeat (10) @(posedge clk);
    rst <= #1 0;
    repeat (600) @(posedge clk);
    $finish;
  end
  
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
   
    blram.mem[0] = 32'h190065;		// ADD 100 101
    blram.mem[1] = 32'h10190003;	// ADDi 100 3
    blram.mem[2] = 32'h40190066;	// SRL 100 102
    blram.mem[3] = 32'h20190067;	// NAND 100 103
    blram.mem[4] = 32'h5019001d;	// SRLi 100 29
    blram.mem[5] = 32'he0190065;	// MUL 100 101
    blram.mem[6] = 32'h60190066;	// LT 100 102
    blram.mem[7] = 32'hf0190019;	// MULi 100 25
    blram.mem[8] = 32'h7019002d;	// LTi 100 45
    blram.mem[9] = 32'h80194064;	// CP 101 100
    blram.mem[10] = 32'h90198007;	// CPi 102 7
    blram.mem[11] = 32'hf0198009;	// MULi 102 9
    blram.mem[12] = 32'h3019ffff;	// NANDi 103 16383
    blram.mem[13] = 32'ha019c03f;	// CPI 103 63
    blram.mem[14] = 32'hb019c03f;	// CPIi 103 63
    blram.mem[15] = 32'hc01a0069; 	// BZJ 104 105
    blram.mem[16] = 32'h1019c00a;	// ADDi 103 10
    blram.mem[17] = 32'h19c066;		// ADD 103 102
    blram.mem[18] = 32'hd01a0005;	// BZJi 104 5
    blram.mem[23] = 32'hf01a0002;	// MULi 104 2
    blram.mem[40] = 32'h4b;			// 75
    blram.mem[63] = 32'h28;			// 40
    blram.mem[100] = 32'h5;			// 5
    blram.mem[101] = 32'ha;			// 10
    blram.mem[102] = 32'h3d;		// 61
    blram.mem[103] = 32'hffffffff;  // 4294967295
    blram.mem[104] = 32'h12;		// 18
    blram.mem[105] = 32'h0;			// 0 

  end
endmodule
