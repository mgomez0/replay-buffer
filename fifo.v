`timescale 1ns / 1ps

module fifo( Clk, 
                    
                   dataIn, 

                   RD, 

                   WR, 

                   EN, 

                   dataOut, 

                   Rst,

                   EMPTY, 

                   FULL 

                   ); 

input  Clk, 

       RD, 

       WR, 

       EN, 

       Rst;

output  EMPTY, 

        FULL;

input   [15:0]    dataIn;

output reg [15:0] dataOut; // internal registers 

reg [11:0]  Count = 0; 

reg [15:0] FIFO [0:4095]; 

reg [11:0]  readCounter = 0, 

           writeCounter = 0; 

assign EMPTY = (Count==0)? 1'b1:1'b0; 

assign FULL = (Count==4096)? 1'b1:1'b0; 

always @ (posedge Clk) 

begin 

 if (EN==0); 

 else begin 

  if (Rst) begin 

   readCounter = 0; 

   writeCounter = 0; 

  end 

  else if (RD ==1'b1 && Count!=0) begin 

   dataOut  = FIFO[readCounter]; 

   readCounter = readCounter+1; 

  end 

  else if (WR==1'b1 && Count<8) begin
   FIFO[writeCounter]  = dataIn; 

   writeCounter  = writeCounter+1; 

  end 

  else; 

 end 

 if (writeCounter==4096) 

  writeCounter=0; 

 else if (readCounter==4096) 

  readCounter=0; 

 else;

 if (readCounter > writeCounter) begin 

  Count=readCounter-writeCounter; 

 end 

 else if (writeCounter > readCounter) 

  Count=writeCounter-readCounter; 

 else;

end 

endmodule