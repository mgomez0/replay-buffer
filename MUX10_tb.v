module MUX10_tb;
reg[15:0]  d0, d1, d2, d3, d4, d5, d6, d7, d8, d9;
reg[3:0]   s;
wire[15:0] y;

mux10 u1 (d0, d1, d2, d3, d4, d5, d6, d7, d8, d9, s, y);
initial 
    begin
        d0 = 16'h000A;
        d1 = 16'h000B;
        d2 = 16'h000C;
        d3 = 16'h000D;
        d4 = 16'h000E
        d5 = 16'h000F;
        d6 = 16'h0001;
        d7 = 16'h0002;
        d8 = 16'h0003;
        d9 = 16'h0004;
        s = 4'h0;
        #5 s = 4'h1;
        #5 s = 4'h2;
        #5 s = 4'h3;
        #5 s = 4'h4;
        #5 s = 4'h5;
        #5 s = 4'h6;
        #5 s = 4'h7;
        #5 s = 4'h8;
        #5 s = 4'h9;
    end

initial 
    begin
		$dumpfile("MUX10.vcd");
		$dumpvars(0, MUX10_tb);
	end
endmodule

