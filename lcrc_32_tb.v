module lcrc_32_tb;

	parameter WIDTH = 32;
	reg [(WIDTH-1):0] in_t;
	reg reset_t, clk_t;
	//wire [(WIDTH+31):0] final_out_t = 0;
	wire [(WIDTH+31):0] final_out_t;
	integer i;

	lcrc_32 pepsi(.in(in_t), .reset(reset_t), .clk(clk_t), .final_out(final_out_t));



	initial begin
        in_t = 32'hC3C3C3C3;   // Should be 1100 0011 1100 0011 1100 0011 1100 0011
        reset_t = 0;    		// We do not need to reset
        clk_t = 0;      		// Initializing the clk
		
	end

	always #5 clk_t = ~clk_t;

	initial #500 $finish;
	
	initial $display("initial value = %h\nfinal value = %h", in_t, final_out_t);
	
	initial $monitor($time, " ns \nreset = %b \nclk = %b \nin_t = %b \nfinal_out (binary) = %b \n\n", reset_t, clk_t, in_t, final_out_t);
		
	 // Dump all waveforms to d_latch.vcd
	initial begin
		$dumpfile("lcrc_32.vcd");
		$dumpvars(0, lcrc_32_tb);
	end
endmodule