module mux10(d0, d1, d2, d3, d4, d5, d6, d7, d8, d9, s, y);
input[15:0]  d0, d1, d2, d3, d4, d5, d6, d7, d8, d9;
input[3:0]   s;
output[15:0] y;
reg[15:0]    y;

always @(d0 or d1 or d2 or d3 or d4 or d5 or d6 or d7 or d8 or d9 or s)
begin
  case(s)
  4'b0000: y = d0;
  4'b0001: y = d1;
  4'b0010: y = d2;
  4'b0011: y = d3;
  4'b0100: y = d4;
  4'b0101: y = d5;
  4'b0110: y = d6;
  4'b0111: y = d7;
  4'b1000: y = d8;
  4'b1001: y = d9;

  default: y = d0;
 endcase
end
endmodule