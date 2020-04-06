// This module creates a 31 bit lfsr_31
// The hex it is being encrypted with is 0 4 C 1 1 D B 7.
// Once lcrc_31 is called, it takes the inputted paacket, creates a crc, then it outputs the inputted packet plus the crc added onto the end

module lcrc_31 (in, reset, clk, final_out);
 
	parameter WIDTH = 8;					// The number of bits in the passed in packet
    input [(WIDTH-1):0] in;					// The register to hold the inputted packet
    input reset, clk;						// Input signals reset to disable the crc and clk to keep in running with the clock
    output reg [(WIDTH+31):0] final_out;				// The register to hold the inputted packet plus the CRC added on in the end
    reg [(WIDTH+31):0] out;				// The register to hold the inputted packet plus the CRC added on in the end
	reg [(WIDTH-1):0] buffer;				// The register to hold the inputted packet othat has been formatted for processing in the CRC
	reg [31:0] crc = 0;						// The temporary CRC buffer that crc_cycle uses and eventually the result
 
 
    initial begin
		// If the user does not want a crc to be generatted, this returns the original inputted packet
        if (reset) begin
            final_out <= in;						// Sets output to 0, effectively negating the CRC generation outright, as well as resetting the input
 
		// Else the lcrc_31 generates a 31-bit CRC code
        end 
        else begin
			input_primer(in, buffer);		// Primes the inputted packet for use in the CRC and places it in the buffer register
			generate_crc(buffer, crc);	// Takes the buffer register value and sends it for CRC creation
			final_out <= {in, crc};				// Concatenates the original inputted packet with the CRC and sends it out
        end
    end
	
	
	// This task primes the input for the generate_crc task by reversing the in bits every 8 bits for the length of the in packet
	task input_primer;
		input [(WIDTH-1):0] in;				// This register holds a copy of the inputted packet
		output [(WIDTH-1):0] primed;	    // This register holds the a new version of the inputted packet that is ready for the crc
		parameter TIMES = WIDTH/8;          // This parameter is the number of groups of 8 there are in the provided packet  
		reg [9:0] counter;		            // This counter holds the position of the reversing process
		integer i;                          // This integer 'i' is for couting in the for loop

		
        for (i = 0; i < TIMES; i = i + 8) begin         // This loop reverses the bits in groups of 8 for the entirety of the packet
	        primed[i + 0] = in[i + 7];
	        primed[i + 1] = in[i + 6];
	        primed[i + 2] = in[i + 5];
	        primed[i + 3] = in[i + 4];
	        primed[i + 4] = in[i + 3];
	        primed[i + 5] = in[i + 2];
	        primed[i + 6] = in[i + 1];
	        primed[i + 7] = in[i + 0];
		end
	endtask
	
	
	// This task takes the primed input and creates a crc code, which it returns
	task generate_crc;
		input [(WIDTH-1):0] primed_in;
		output [31:0] temp2;
		reg [31:0] temp;
		reg [9:0] counter;
		
		begin
		    counter = WIDTH-1;
		    temp = 0;
			repeat (WIDTH) begin
				temp[0] <= (temp[31] ^ primed_in[counter]); 
				temp[1] <= (temp[31] ^ primed_in[counter]) ^ temp[0];
				temp[2] <= (temp[31] ^ primed_in[counter]) ^ temp[1];
				temp[3] <= temp[2];
				temp[4] <= (temp[31] ^ primed_in[counter]) ^ temp[3];
				temp[5] <= (temp[31] ^ primed_in[counter]) ^ temp[4];
				temp[6] <= temp[5];
				temp[7] <= (temp[31] ^ primed_in[counter]) ^ temp[6];
				temp[8] <= (temp[31] ^ primed_in[counter]) ^ temp[7];
				temp[9] <= temp[8];
				temp[10] <= (temp[31] ^ primed_in[counter]) ^ temp[9];
				temp[11] <= (temp[31] ^ primed_in[counter]) ^ temp[10];
				temp[12] <= (temp[31] ^ primed_in[counter]) ^ temp[11];
				temp[13] <= temp[12];
				temp[14] <= temp[13];
				temp[15] <= temp[14];
				temp[16] <= (temp[31] ^ primed_in[counter]) ^ temp[15];
				temp[17] <= temp[16];
				temp[18] <= temp[17];
				temp[19] <= temp[18];
				temp[20] <= temp[19];
				temp[21] <= temp[20];
				temp[22] <= (temp[31] ^ primed_in[counter]) ^ temp[21];
				temp[23] <= (temp[31] ^ primed_in[counter]) ^ temp[22];
				temp[24] <= temp[23];
				temp[25] <= temp[24];
				temp[26] <= (temp[31] ^ primed_in[counter]) ^ temp[25];
				temp[27] <= temp[26];
				temp[28] <= temp[27];
				temp[29] <= temp[28];
				temp[30] <= temp[29];
				temp[31] <= temp[30];
				
				counter <= counter - 1;
			end
			temp2 <= temp;
		end
	endtask	
	
	
endmodule    // End of module





// // This is the testbench for the above lcrc
// module lcrc_31_tb;
//     parameter WIDTH = 8;
//     reg [(WIDTH-1):0] in_t;
//     reg reset_t, clk_t;
//     wire [(WIDTH+31):0] final_out_t = 0;
//     integer i;
        
//     lcrc_31 pepsi(in_t, reset_t, clk_t, final_out_t);
    
//     initial begin
//         in_t = 85;      // This is the same as "01010101", a randomly chosen number
//         reset_t = 0;    // We do not need to reset
//         clk_t = 0;      // Initializing the clk
        
//         $monitor($time, " ns \nreset = %b \nclk = %b \nin_t = %b \nfinal_out (binary) = %b \nfinal_out(integer) = %d\n\n", reset_t, clk_t, in_t, final_out_t, final_out_t);
//         for (i = 0; i < (WIDTH-1); i++) begin
//             #5 clk_t = ~clk_t;
//         end
//          // Dump all waveforms to d_latch.vcd
//         initial
//         begin
//             $dumpfile("lcrc_31.vcd");
// 	        $dumpvars(0, lcrc_31_tb);	 
//         end // initial begin
//     end
// endmodule