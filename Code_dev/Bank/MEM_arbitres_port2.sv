`include "header.v"

module MEM_arbitres_port2 (

        input wire                           i_clk,
        input wire                           i_reset,

        input wire [2:0]                     i_en_port, //0-1порт, 1-2порт, 2-3порт
        input wire [31:0]                    i_data_port1,
        input wire [31:0]                    i_data_port2,
        input wire [31:0]                    i_data_port3,
        input wire [1:0]                     i_info_port1, // начало/конец фрейма
        input wire [1:0]                     i_info_port2,
        input wire [1:0]                     i_info_port3,
        input wire [1:0]                     i_extra_byte1,
        input wire [1:0]                     i_extra_byte2,
        input wire [1:0]                     i_extra_byte3,
        output reg [31:0]                    o_data,
        output reg [$clog2(pPORT_WIDTH)-1:0] o_port_num,
        output reg                           o_en_mem,
        output reg [1:0]                     o_info_port,
        output reg [1:0]                     o_extra_byte
);

    reg [$clog2(pPORT_WIDTH)-1:0] r_look_port =2'b11;

    always @ (posedge i_clk)

        begin
        
        if ((i_en_port[0]==1'b1) && (r_look_port==2'b00))
            begin
                o_data<=i_data_port1;
                o_port_num<=r_look_port;
                o_en_mem<=1'b1;
                o_info_port<=i_info_port1;
                o_extra_byte<=i_extra_byte1;
            end

        else if ((i_en_port[1]==1'b1) && (r_look_port==2'b10))
            begin
                o_data<=i_data_port2;
                o_port_num<=r_look_port;
                o_en_mem<=1'b1;
                o_info_port<=i_info_port2;
                o_extra_byte<=i_extra_byte2;
            end

        else if (i_en_port[2]==1'b1 && r_look_port==2'b11)
            begin
            o_data<=i_data_port3;
            o_port_num<=r_look_port;
            o_en_mem<=1'b1;
            o_info_port<=i_info_port3;
            o_extra_byte<=i_extra_byte3;
            end

        else o_en_mem<=1'b0;
        
        r_look_port<=r_look_port+1'b1;

        end
endmodule 