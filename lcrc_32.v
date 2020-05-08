// This program is written by Maksim Repko
// Date: 04/11/2020
// Description: This program takes an inputted packet, inverts the individual bits in each byte of a copy of the inputted packet, 
// generates a crc code from the copy, then inverts the bytes of the generated crc, attaches the finished crc
`timescale 1ns / 1ns
module lcrc_32 (in, reset, clk, final_out);
 
	parameter PACKET_SIZE = 128;				// The number of bits in the passed in packet
    input [(PACKET_SIZE-1):0] in;				// The register to hold the inputted packet
    input reset, clk;							// Input signals reset to disable the crc and clk to keep in running with the clock
    output reg [(PACKET_SIZE+31):0] final_out;	// The register to hold the inputted packet plus the CRC added on in the end
	reg [(PACKET_SIZE-1):0] buffer;				// The register to hold the inputted packet that has been formatted for processing in the CRC
	reg [31:0] crc;				    			// The temporary CRC buffer that crc_cycle uses and eventually the result
	
	initial begin
		bit_inverter(in, buffer);				// Inverts the inputted packet for use in the CRC and places it in the buffer register
		generate_crc(buffer, crc);				// Takes the buffer register value and sends it for CRC creation
		bit_inverter(crc, buffer);				// Sends the CRC to get inverted, as it should
		crc = buffer[31:0];						// Takes the CRC out of the buffer, as the other PACKET_SIZE - 32 bits are not needed
		final_out <= {in, crc};					// Concatenates the original inputted packet with the CRC and sends it out
	end
	
	
	// This task primes the input for the generate_crc task by reversing the in bits every 8 bits for the length of the in packet
	task bit_inverter;
		input [(PACKET_SIZE-1):0] in;			// This register holds a copy of the inputted packet
		output [(PACKET_SIZE-1):0] primed;	    // This register holds the a new version of the inputted packet that is ready for the crc
		integer i;                          	// This integer 'i' is for counting in the for loop
		
		begin
 			for (i = 0; i < PACKET_SIZE; i = i + 8) begin  // This loop reverses the bits in groups of 8 for the entirety of the packet
				primed[i + 0] = in[i + 7];
				primed[i + 1] = in[i + 6];
				primed[i + 2] = in[i + 5];
				primed[i + 3] = in[i + 4];
				primed[i + 4] = in[i + 3];
				primed[i + 5] = in[i + 2];
				primed[i + 6] = in[i + 1];
				primed[i + 7] = in[i + 0];
			end
			end
		endtask
	
	
	// This task takes the primed input and creates a crc code, which it returns
	task generate_crc;
		input [(PACKET_SIZE-1):0] primed_in;
		output reg [31:0] temp;
		integer j;
		
		begin
		    temp = 0;
			// This is the encrypting part of the crc, following the lcrc code: 0 4 C 1 1 D B 7
			for (j = PACKET_SIZE - 1; j >= 0; j = j - 1) begin
				temp[0] = (temp[31] ^ primed_in[j]); 
				temp[1] = (temp[31] ^ primed_in[j]) ^ temp[0];
				temp[2] = (temp[31] ^ primed_in[j]) ^ temp[1];
				temp[3] = temp[2];
				temp[4] = (temp[31] ^ primed_in[j]) ^ temp[3];
				temp[5] = (temp[31] ^ primed_in[j]) ^ temp[4];	
				temp[6] = temp[5];
				temp[7] = (temp[31] ^ primed_in[j]) ^ temp[6];
				temp[8] = (temp[31] ^ primed_in[j]) ^ temp[7];
				temp[9] = temp[8];
				temp[10] = (temp[31] ^ primed_in[j]) ^ temp[9];
				temp[11] = (temp[31] ^ primed_in[j]) ^ temp[10];
				temp[12] = (temp[31] ^ primed_in[j]) ^ temp[11];
				temp[13] = temp[12];
				temp[14] = temp[13];
				temp[15] = temp[14];
				temp[16] = (temp[31] ^ primed_in[j]) ^ temp[15];
				temp[17] = temp[16];
				temp[18] = temp[17];
				temp[19] = temp[18];
				temp[20] = temp[19];
				temp[21] = temp[20];
				temp[22] = (temp[31] ^ primed_in[j]) ^ temp[21];
				temp[23] = (temp[31] ^ primed_in[j]) ^ temp[22];
				temp[24] = temp[23];
				temp[25] = temp[24];
				temp[26] = (temp[31] ^ primed_in[j]) ^ temp[25];
				temp[27] = temp[26];
				temp[28] = temp[27];
				temp[29] = temp[28];
				temp[30] = temp[29];
				temp[31] = temp[30];
			end
		end
	endtask	
endmodule	
