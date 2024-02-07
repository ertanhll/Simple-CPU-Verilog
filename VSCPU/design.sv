module VSCPU (clk, rst, data_fromRAM, wrEn, addr_toRAM, data_toRAM);
  input clk, rst;
  output reg wrEn;
  input [31:0] data_fromRAM;
  output reg [31:0] data_toRAM;
  output reg [13:0] addr_toRAM;
  
  reg [2:0] st, stN;
  reg [13:0] PC, PCN;
  reg [31:0] IW, IWN;
  reg [31:0] R1, R1N;
  
  
  always @(posedge clk) begin
    st <= stN;
    PC <= PCN;
    IW <= IWN;
    R1 <= R1N;
  end
  
  always @ * begin
   if (rst) begin
     stN = 3'd0;
     PCN = 14'd0;
  end
    
   else begin
     wrEn = 1'b0;
     PCN = PC;
     IWN = IW;
     stN = 3'dx;
     addr_toRAM= 14'hX;
     data_toRAM= 32'hX;
     R1N= 32'hX;
     
    

     case (st) 
     3'd0: begin // S0: Fetch State
       addr_toRAM = PC;
       stN = 3'd1;
     end
       
       
     3'd1: begin // S1: Decode State
       IWN = data_fromRAM;
       
       if(data_fromRAM[31:29] == 3'b000  || // ADD or ADDi
          data_fromRAM[31:29] == 3'b001  || // NAND or NANDi
          data_fromRAM[31:29] == 3'b010  || // SRL or SRLi
          data_fromRAM[31:29] == 3'b011  || // LT or LTi
          data_fromRAM[31:29] == 3'b111  || // MUL or MULi 
          data_fromRAM[31:28] == 4'b1011 || // CPIi
          data_fromRAM[31:29] == 3'b110)    // BZJ or BZJi
       begin
         addr_toRAM = data_fromRAM[27:14];
         stN = 3'd2;
       end
      
       if(data_fromRAM[31:28] == 4'b1000 || // CP
          data_fromRAM[31:28] == 4'b1010)   // CPI
       begin
         addr_toRAM = data_fromRAM[13:0];
         stN = 3'd2;
       end
       
       if(data_fromRAM[31:28] == 4'b1001) // CPi
       begin
         stN = 3'd2;
       end
      
     end
          
     3'd2: begin // S2: Decode/Execute State
       
       if (IW[31:28]==4'b0000 || IW[31:28]==4'b0010 || // ADD or NAND
           IW[31:28]==4'b0100 || IW[31:28]==4'b0110 || // SRL or LT
           IW[31:28]==4'b1110 || IW[31:28]==4'b1011 || // MUL or CPIi
           IW[31:28]==4'b1100) // BZJ
       begin 
		 R1N=data_fromRAM;
         addr_toRAM = IW[13:0];
         stN = 3'd3;
       end
       
       if (IW[31:28]==4'b0001) begin // ADDi
         wrEn = 1'b1;
         addr_toRAM = IW[27:14];
         data_toRAM = data_fromRAM + IW[13:0];
         PCN = PC + 14'd1;
         stN = 3'd0;
       end
      
       if (IW[31:28]==4'b0011) begin // NANDi
         wrEn = 1'b1;
         addr_toRAM = IW[27:14];
         data_toRAM = ~(data_fromRAM & IW[13:0]);
         PCN = PC + 14'd1;
         stN = 3'd0;
       end
      
       if (IW[31:28]==4'b0101) begin // SRLi
         wrEn = 1'b1;
         addr_toRAM = IW[27:14];
         data_toRAM = (IW[13:0] < 32) ? (data_fromRAM >> IW[13:0]):
         (data_fromRAM << (IW[13:0]-32));
         PCN = PC + 14'd1;
         stN = 3'd0;
       end
       
       if (IW[31:28]==4'b0111) begin // LTi
         wrEn = 1'b1;
         addr_toRAM = IW[27:14];
         data_toRAM =  (data_fromRAM < IW[13:0]) ? 1 : 0;
         PCN = PC + 14'd1;
         stN = 3'd0; 
       end
       
       if (IW[31:28]==4'b1111) begin // MULi
         wrEn = 1'b1;
         addr_toRAM = IW[27:14];
         data_toRAM = data_fromRAM * IW[13:0];
         PCN = PC + 14'd1;
         stN = 3'd0;
       end
       
       if (IW[31:28]==4'b1000) begin // CP
         wrEn = 1'b1;
         addr_toRAM = IW[27:14];
         data_toRAM = data_fromRAM;
         PCN = PC + 14'd1;
         stN = 3'd0;
       end
       
       if (IW[31:28]==4'b1001) begin // CPi
         wrEn = 1'b1;
         addr_toRAM = IW[27:14];
         data_toRAM = IW[13:0];
         PCN = PC + 14'd1;
         stN = 3'd0;
       end
       
       if (IW[31:28]==4'b1010) begin // CPI
         addr_toRAM = data_fromRAM;
         stN = 3'd3;
       end
     
       if (IW[31:28]==4'b1101) begin // BZJi
         PCN = (data_fromRAM + IW[13:0]);
         stN = 3'd0;
       end
       
     end
       
     3'd3: begin // S3: Execute State
       if (IW[31:28]==4'b0000) begin // ADD
         wrEn = 1'b1;
         addr_toRAM = IW[27:14];
         data_toRAM = R1 + data_fromRAM;
         PCN = PC + 14'd1;
         stN = 3'd0;
       end
       
       if (IW[31:28]==4'b0010) begin // NAND
         wrEn = 1'b1;
         addr_toRAM = IW[27:14];
         data_toRAM = ~(R1 & data_fromRAM);
         PCN = PC + 14'd1;
         stN = 3'd0;
       end
       
       if (IW[31:28]==4'b0100) begin // SRL
         wrEn = 1'b1;
         addr_toRAM = IW[27:14];
         data_toRAM = (data_fromRAM < 32) ? (R1 >> data_fromRAM) : 
         (R1 << (data_fromRAM-32));
         PCN = PC + 14'd1;
         stN = 3'd0;
       end
       
       if (IW[31:28]==4'b0110) begin // LT
         wrEn = 1'b1;
         addr_toRAM = IW[27:14];
         data_toRAM = (R1 < data_fromRAM) ? 1 : 0;
         PCN = PC + 14'd1;
         stN = 3'd0;
       end
       
       if (IW[31:28]==4'b1110) begin // MUL
         wrEn = 1'b1;
         addr_toRAM = IW[27:14];
         data_toRAM = R1 * data_fromRAM;
         PCN = PC + 14'd1;
         stN = 3'd0;
       end
       
       if (IW[31:28]==4'b1010) begin // CPI
         wrEn = 1'b1;
         addr_toRAM = IW[27:14];
         data_toRAM = data_fromRAM;
         PCN = PC + 14'd1;
         stN = 3'd0;
       end 
        
       if (IW[31:28]==4'b1011) begin // CPIi
         wrEn = 1'b1;
         addr_toRAM = R1;
         data_toRAM = data_fromRAM;
         PCN = PC + 14'd1;
         stN = 3'd0;
       end  
       
       if (IW[31:28]==4'b1100) begin // BZJ
         PCN = (data_fromRAM == 0) ? R1 : (PC + 1);
         stN = 3'd0;
       end
     end
     endcase
   end // else
 end // always 	
endmodule

module blram(clk, rst, we, addr, din, dout);
  parameter SIZE = 14, DEPTH = 2**SIZE;

  input clk;
  input rst;
  input we;
  input [SIZE-1:0] addr;
  input [31:0] din;
  output reg [31:0] dout;

  reg [31:0] mem [DEPTH-1:0];

  always @(posedge clk) begin
    dout <= #1 mem[addr[SIZE-1:0]];
    if (we)
      mem[addr[SIZE-1:0]] <= #1 din;
  end 
endmodule

