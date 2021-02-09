`timescale 1ns/1ps

module pause_cost_TB_0
#( parameter long = 1400)
( 
output reg clk,
output reg er,
output reg dv,
output reg [7:0] data
);

//localparam      long = 1400; //байт


reg [7:0] frame [0:long-1] ;
reg [7:0] new_frame [0:long-1];

reg [1:0] port_num=2'b01; //формирование фрейма
reg [1:0] next_port_num;
reg [7:0] num_frame ='0;
reg [31:0] rcrc_new='1;

reg [$clog2(long-1):0] adr_byte='0; //отправка
reg stayt;
reg [3:0]stop_chet='0;

//Ethernet CRC32
wire [3:0][7:0] wcrc;
genvar j,k;

generate for (j=0; j < 4; j++)
begin : crc32_mirror_and_xor
    for (k=0; k < 8; k++)
    begin
        assign wcrc[j][k] = ~rcrc_new[31-j*8-k];
    end
end
endgenerate


initial
    begin
 #0   clk=1'b0;
       er=1'b0;
       dv=1'b0;
       data = '0;
       stayt=1'b0;
    end

always 
    begin
#4 clk=~clk;
    end

always @ (posedge clk)
    begin
    if (stayt==1'b1)
        begin
        data<=frame[adr_byte];
        dv=1'b1;
        if ((long-4>adr_byte)&&(adr_byte>11'b111))
        rcrc_new<= eth_crc32_8d(rcrc_new, new_frame[adr_byte]);       
        if (adr_byte==long-1'b1)
        begin
            adr_byte<='0;
            stayt<=1'b0;
            num_frame<=num_frame+1'b1;
            port_num<=next_port_num;
        end
        else
        adr_byte<=adr_byte+1'b1;
        end

    if (stayt==1'b0)
        begin
        stop;
        new_frame [long-4]<=wcrc[0];
        new_frame [long-3]<=wcrc[1];
        new_frame [long-2]<=wcrc[2];
        new_frame [long-1]<=wcrc[3];
        if (stop_chet==4'd11)
        begin
            stop_chet<='0;
            stayt<=1'b1;
            frame<=new_frame;
//            num_frame<=num_frame+1'b1;
//            port_num<=port_num+1'b1;
            rcrc_new<='1;
            make(num_frame); 
        end
        else stop_chet<=stop_chet+1'b1;
        end

    case (port_num) // 
        2'b01: next_port_num<=2'b10;
        2'b10: next_port_num<=2'b11;
        2'b11: next_port_num<=2'b01;
    endcase
    end   

task make;
	input [7:0] num_frame;
//    output ;
	begin	
    new_frame[0]<=8'h55; //преамбула
    new_frame[1]<=8'h55;
    new_frame[2]<=8'h55;
    new_frame[3]<=8'h55;
    new_frame[4]<=8'h55;
    new_frame[5]<=8'h55;
    new_frame[6]<=8'h55;
	new_frame[7]<=8'hD5; //делимитр
    new_frame[8]<=port_num; // DA
    new_frame[9]<=port_num;
    new_frame[10]<='0;
    new_frame[11]<='0;
    new_frame[12]<='0;
    new_frame[13]<='0; //номер порта
	new_frame[14]<='0; //SA
    new_frame[15]<='0;
    new_frame[16]<='0;
    new_frame[17]<='0;
    new_frame[18]<='0;
    new_frame[19]<='0; //номер порта
    for (int i=20;i<(long-5);i++) new_frame[i] = '0;
    new_frame[long-5]<=num_frame; //дата последний байт
	end
endtask

task stop;
	begin	
#0    er=1'b0;
#0    data = '0;
#0    dv=1'b0;	
	end
endtask

function integer eth_crc32_8d(input integer crc32, input logic [7:0] data);
    	bit [ 7:0] d;
	bit [31:0] c;
	bit [31:0] newcrc;
	begin
		for (int i=0;i<8;i++) d[i] = data[7-i];         //Разворот данных

            c = crc32;                                      //Каждый такт значение crc32 будет равно предыдущему выходу функции
            newcrc[0] = d[6] ^ d[0] ^ c[24] ^ c[30];
            newcrc[1] = d[7] ^ d[6] ^ d[1] ^ d[0] ^ c[24] ^ c[25] ^ c[30] ^ c[31];
            newcrc[2] = d[7] ^ d[6] ^ d[2] ^ d[1] ^ d[0] ^ c[24] ^ c[25] ^ c[26] ^ c[30] ^ c[31];
            newcrc[3] = d[7] ^ d[3] ^ d[2] ^ d[1] ^ c[25] ^ c[26] ^ c[27] ^ c[31];
            newcrc[4] = d[6] ^ d[4] ^ d[3] ^ d[2] ^ d[0] ^ c[24] ^ c[26] ^ c[27] ^ c[28] ^ c[30];
            newcrc[5] = d[7] ^ d[6] ^ d[5] ^ d[4] ^ d[3] ^ d[1] ^ d[0] ^ c[24] ^ c[25] ^ c[27] ^ c[28] ^ c[29] ^ c[30] ^ c[31];
            newcrc[6] = d[7] ^ d[6] ^ d[5] ^ d[4] ^ d[2] ^ d[1] ^ c[25] ^ c[26] ^ c[28] ^ c[29] ^ c[30] ^ c[31];
            newcrc[7] = d[7] ^ d[5] ^ d[3] ^ d[2] ^ d[0] ^ c[24] ^ c[26] ^ c[27] ^ c[29] ^ c[31];
            newcrc[8] = d[4] ^ d[3] ^ d[1] ^ d[0] ^ c[0] ^ c[24] ^ c[25] ^ c[27] ^ c[28];
            newcrc[9] = d[5] ^ d[4] ^ d[2] ^ d[1] ^ c[1] ^ c[25] ^ c[26] ^ c[28] ^ c[29];
            newcrc[10] = d[5] ^ d[3] ^ d[2] ^ d[0] ^ c[2] ^ c[24] ^ c[26] ^ c[27] ^ c[29];
            newcrc[11] = d[4] ^ d[3] ^ d[1] ^ d[0] ^ c[3] ^ c[24] ^ c[25] ^ c[27] ^ c[28];
            newcrc[12] = d[6] ^ d[5] ^ d[4] ^ d[2] ^ d[1] ^ d[0] ^ c[4] ^ c[24] ^ c[25] ^ c[26] ^ c[28] ^ c[29] ^ c[30];
            newcrc[13] = d[7] ^ d[6] ^ d[5] ^ d[3] ^ d[2] ^ d[1] ^ c[5] ^ c[25] ^ c[26] ^ c[27] ^ c[29] ^ c[30] ^ c[31];
            newcrc[14] = d[7] ^ d[6] ^ d[4] ^ d[3] ^ d[2] ^ c[6] ^ c[26] ^ c[27] ^ c[28] ^ c[30] ^ c[31];
            newcrc[15] = d[7] ^ d[5] ^ d[4] ^ d[3] ^ c[7] ^ c[27] ^ c[28] ^ c[29] ^ c[31];
            newcrc[16] = d[5] ^ d[4] ^ d[0] ^ c[8] ^ c[24] ^ c[28] ^ c[29];
            newcrc[17] = d[6] ^ d[5] ^ d[1] ^ c[9] ^ c[25] ^ c[29] ^ c[30];
            newcrc[18] = d[7] ^ d[6] ^ d[2] ^ c[10] ^ c[26] ^ c[30] ^ c[31];
            newcrc[19] = d[7] ^ d[3] ^ c[11] ^ c[27] ^ c[31];
            newcrc[20] = d[4] ^ c[12] ^ c[28];
            newcrc[21] = d[5] ^ c[13] ^ c[29];
            newcrc[22] = d[0] ^ c[14] ^ c[24];
            newcrc[23] = d[6] ^ d[1] ^ d[0] ^ c[15] ^ c[24] ^ c[25] ^ c[30];
            newcrc[24] = d[7] ^ d[2] ^ d[1] ^ c[16] ^ c[25] ^ c[26] ^ c[31];
            newcrc[25] = d[3] ^ d[2] ^ c[17] ^ c[26] ^ c[27];
            newcrc[26] = d[6] ^ d[4] ^ d[3] ^ d[0] ^ c[18] ^ c[24] ^ c[27] ^ c[28] ^ c[30];
            newcrc[27] = d[7] ^ d[5] ^ d[4] ^ d[1] ^ c[19] ^ c[25] ^ c[28] ^ c[29] ^ c[31];
            newcrc[28] = d[6] ^ d[5] ^ d[2] ^ c[20] ^ c[26] ^ c[29] ^ c[30];
            newcrc[29] = d[7] ^ d[6] ^ d[3] ^ c[21] ^ c[27] ^ c[30] ^ c[31];
            newcrc[30] = d[7] ^ d[4] ^ c[22] ^ c[28] ^ c[31];
            newcrc[31] = d[5] ^ c[23] ^ c[29];
            eth_crc32_8d = newcrc;
        end
    endfunction

endmodule