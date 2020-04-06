// This is the testbench for the above lcrc
module lcrc_32_tb;
    parameter WIDTH = 8;
    reg [(WIDTH-1):0] in_t;
    reg reset_t, clk_t;
    wire [(WIDTH+31):0] final_out_t = 0;
    integer i;
        
    lcrc_32 pepsi(in_t, reset_t, clk_t, final_out_t);
    
    initial begin
        in_t = 85;      // This is the same as "01010101", a randomly chosen number
        reset_t = 0;    // We do not need to reset
        clk_t = 0;      // Initializing the clk

        always #5 clk_t = ~clk_t;

        initial #500 $finish;
        
        initial
            $monitor($time, " ns \nreset = %b \nclk = %b \nin_t = %b \nfinal_out (binary) = %b \nfinal_out(integer) = %d\n\n", reset_t, clk_t, in_t, final_out_t, final_out_t);

         // Dump all waveforms to d_latch.vcd
        initial
        begin
            $dumpfile("lcrc_32.vcd");
	        $dumpvars(0, lcrc_32_tb);	 
        end // initial begin
    end
endmodule