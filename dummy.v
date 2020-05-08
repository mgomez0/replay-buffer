module replay_buffer(clk,reset_n,ack_nak,seq,timeout,we,din,ready,dout);
input clk,reset_n,timeout,we;
input [11:0] seq;
input [1:0] ack_nak;
input [63:0] din;
output reg ready;
output reg [63:0] dout;
reg [63:0] packet_holder [1024];

integer count_write,count_read;

always@(posedge clk,negedge reset_n)
begin
    if(!reset_n)// resetting the device
        begin
            dout<=0;
            // ready=1;
            count_read=0;count_write=0;
        end
    else if(timeout)// check for ack timeout
    begin
        dout=0;
    // ready=1;
    end

else
    begin
        if(ack_nak == 01 || ack_nak == 10)// ack recieved and working
        begin
            if(!we&&!(count_write==0))// only read is aviable after ack/ hence read i dont know about it this is what i think it would work as
                begin
                    dout=packet_holder[seq[9:0]];
                    count_read=count_read+1;
                    if(count_write==1024)
                    count_write=0;
                end
                else
                    dout=0;
                end
    
        else// no acknowledge for DLLP
        begin
            if(we&&!(count_write==1024))// writing with overidd space
                begin
                    packet_holder[seq[9:0]]=din;
                    count_write=count_write+1;
                    if(count_read==1024)
                        count_read=0;
                end
            else
                dout=0;
        end
    end
    end

always@(posedge clk,negedge reset_n)// logic for output ready
begin
if(!reset_n || timeout)// asking for ready at reset and timeout
begin
ready=1;
end
if(count_read==1024)//
ready=0;
end
endmodule