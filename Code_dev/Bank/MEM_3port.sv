`include "header.v"

module MEM2 (

    input wire                              i_clk,
    input wire                              i_reset,
    input wire [pPORT_WIDTH-2:0]            i_del,
    input wire [31:0]                       i_data,
    input wire [$clog2(pPORT_WIDTH)-1:0]    i_port_num,
	input wire [$clog2(pDEPTH_RAM)-1:0]	    i_adr_out,
    input wire                              i_en_read, // разрешение чтения
    input wire                              i_en_mem, // разрешение записи
    input wire [1:0]                        i_info_port, // начало-[0]/конец-[1] фрейма 
    input wire [1:0]                        i_extra_byte,
    output wire [31:0]                      o_data,
    output reg [2*$clog2(pDEPTH_RAM)+1:0]   o_FIFO,
    output reg                              o_en_FIFO);

    reg [$clog2(pDEPTH_RAM)-1:0]           r_countr1='0; // счетчики адресов
    reg [$clog2(pDEPTH_RAM)-1:0]           r_countr2='d1535;
    reg [$clog2(pDEPTH_RAM)-1:0]           r_countr3='d3071;

    reg [$clog2(pDEPTH_RAM)-1:0]           r_adr_start1; // начало адреса
    reg [$clog2(pDEPTH_RAM)-1:0]           r_adr_start2;
    reg [$clog2(pDEPTH_RAM)-1:0]           r_adr_start3;

    reg [$clog2(pDEPTH_RAM)-1:0]          rWr_ptr_now;
    reg                                    write;
    reg                                    read;
    reg [$clog2(pDEPTH_RAM)-1:0]                             r_adr_out;
	reg[31:0]							r_data;

    sram                                                            // SRAM Module
    #(                                                              // ===========
        .DATA_WIDTH             	(4*pDATA_WIDTH),                      // Memory module. Input packets are saved in
        .DEPTH                  	(pDEPTH_RAM)                        // it.
    ) ram_for_packets
    (
        .i_clk                  	(i_clk),      //такт
        .i_addr_wr              	(rWr_ptr_now), //адрес записи
        .i_addr_r               	(r_adr_out), //адрес чтения
        .i_write                	(write), // команда начала записи
        .i_read                     (read),
        .i_data                 	(r_data), // дата
        .o_data                 	(o_data)        //выход
    );

    always @ (posedge i_clk)
    begin
    if (|i_del)
        begin
            if (i_del[0]==1'b1)
                r_countr1<=r_adr_start1;
            if (i_del[1]==1'b1)
                r_countr2<=r_adr_start2;
            if (i_del[2]==1'b1)
                r_countr3<=r_adr_start3;
        end

    if (i_en_mem)
        begin
        
        case (i_port_num)
        'd0:        begin
                    if (i_del[0]==1'b0)
                        begin
                        write<=1'b1;
                        rWr_ptr_now<=r_countr1;
                        if (r_countr1=='d1534) r_countr1<='0;
                        else r_countr1<=r_countr1+1'b1;

                        if (i_info_port[0]==1'b1) r_adr_start1<=r_countr1;

                        if (i_info_port[1]==1'b1) 
                            begin
                            o_FIFO<={i_extra_byte,r_countr1,r_adr_start1};
                            o_en_FIFO<=1'b1;
                            end
                        else o_en_FIFO<=1'b0;
                        end
                        else begin
                            write<=1'b0;
                        end
                    end

        'd1:        begin
                    if (i_del[1]==1'b0)
                        begin
                        write<=1'b1;
                        rWr_ptr_now<=r_countr2;
                        if (r_countr2=='d3070) r_countr2<='d1535;
                        else r_countr2<=r_countr2+1'b1; 

                        if (i_info_port[0]==1'b1) r_adr_start2<=r_countr2;

                        if (i_info_port[1]==1'b1) 
                            begin
                            o_FIFO<={i_extra_byte,r_countr2,r_adr_start2};
                            o_en_FIFO<=1'b1;
                            end  
                        else o_en_FIFO<=1'b0;                   
                        end
                        else begin
                            write<=1'b0;
                        end
                    end

        'd3:        begin
                    if (i_del[2]==1'b0)
                        begin
                        write<=1'b1;
                        rWr_ptr_now<=r_countr3;
                        if (r_countr3==pDEPTH_RAM-1'b1) r_countr3<='d3071;
                        else r_countr3<=r_countr3+1'b1;

                        if (i_info_port[0]==1'b1) r_adr_start3<=r_countr3;

                        if (i_info_port[1]==1'b1) 
                            begin
                            o_FIFO<={i_extra_byte,r_countr3,r_adr_start3};
                            o_en_FIFO<=1'b1;
                            end
                        else o_en_FIFO<=1'b0;
                        end
                        else begin
                            write<=1'b0;
                        end
                    end
        endcase
        end

    else begin
        write<=1'b0;
        o_en_FIFO<=1'b0;
        end

	read<=i_en_read;
    r_adr_out<=i_adr_out;
	r_data<=i_data;
	
    end
endmodule