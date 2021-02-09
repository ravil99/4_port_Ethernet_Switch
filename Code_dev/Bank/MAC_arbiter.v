`include "header.v"

module MAC_arbiter

    (
	input wire                              						iclk,
	input wire [2*pPORT_WIDTH-1:0] 									i_newSA_and_DA,        //Приходит с 4 приёмников, когда считан SA пакета, DA приходит с RAM
	input wire [2*pPORT_WIDTH-1:0] [pMAC_MEM_DEPTH_W-1:0] 			i_SA_and_DA ,
	input wire [2*pPORT_WIDTH-1:0] [pDATA_WIDTH-1:0]				i_check_byte ,
	output reg [$clog2(pPORT_WIDTH)-1:0]      		o_port_num,
	output reg [pMAC_MEM_DEPTH_W-1:0]			o_MAC_SA,
	output reg [pMAC_MEM_DEPTH_W-1:0]			o_MAC_DA,
	output reg [pDATA_WIDTH-1:0]					o_check_byte_SA,
	output reg [pDATA_WIDTH-1:0]					o_check_byte_DA,
	output reg                              						o_write_en,      //Разрешение на запись в МАК-таблицу
	output reg									o_read_en,
	output reg									o_decrement
    );
	
	reg [5:0]								r_access_counter=6'd0;

	bit [pMAC_MEM_DEPTH_W-1:0]         			r_adresses 		[2*pPORT_WIDTH-1:0] = '{default: 'b0} /* synthesis ramstyle = "logic" */;
	bit [pDATA_WIDTH-1:0]  					r_check_byte  	[2*pPORT_WIDTH-1:0] = '{default: 'b0} /* synthesis ramstyle = "logic" */;
	bit                     								r_enable  		[2*pPORT_WIDTH-1:0] = '{default: 'b0} /* synthesis ramstyle = "logic" */;
	//bit                     rdone [0:pPATHS-1] = '{default: 'b0} /* synthesis ramstyle = "logic" */;

    always @(posedge iclk) begin
	
	for (int i=0; i < (2*pPORT_WIDTH); i = i + 1)
	begin
			r_adresses[i] <= i_SA_and_DA[i];
			r_check_byte[i]   <= i_check_byte  [i];
			r_enable[i] <= i_newSA_and_DA[i];
	end
	
	if (r_access_counter==6'd53)
		r_access_counter <= 6'd0;
	else
		r_access_counter<=r_access_counter+1'b1;
	
	case (r_access_counter) 
		6'd0: 		begin
						o_write_en <= r_enable[0];
						o_MAC_SA <= r_adresses[0];
						o_check_byte_SA <= r_check_byte [0];
						o_port_num <= 2'b00;
						o_decrement <= 1'b0;
					end
		6'd6: 		begin
						o_write_en <= r_enable[1];
						o_MAC_SA <= r_adresses[1];
						o_check_byte_SA <= r_check_byte [1];
						o_port_num <= 2'b01;
					end
		6'd12: 		begin
						o_write_en <= r_enable[2];
						o_MAC_SA <= r_adresses[2];
						o_check_byte_SA <= r_check_byte [2];
						o_port_num <= 2'b10;
					end
		6'd18: 		begin
						o_write_en <= r_enable[3];
						o_MAC_SA <= r_adresses[3];
						o_check_byte_SA <= r_check_byte [3];
						o_port_num <= 2'b11;
					end
		6'd24: 		begin
						o_write_en <= 1'b0;
						o_read_en <= r_enable[4];
						o_MAC_DA <= r_adresses[4];
						o_check_byte_DA <= r_check_byte [4];
						o_port_num <= 2'b00;
					end
		6'd30: 		begin
						o_read_en <= r_enable[5];
						o_MAC_DA <= r_adresses[5];
						o_check_byte_DA <= r_check_byte [5];
						o_port_num <= 2'b01;
					end
		6'd36: 		begin
						o_read_en <= r_enable[6];
						o_MAC_DA <= r_adresses[6];
						o_check_byte_DA <= r_check_byte [6];
						o_port_num <= 2'b10;
					end
		6'd42: 		begin
						o_read_en <= r_enable[7];
						o_MAC_DA <= r_adresses[7];
						o_check_byte_DA <= r_check_byte [7];
						o_port_num <= 2'b11;
					end
		6'd48: 		begin
					o_read_en <= 1'b0;								//DECREMENT
					o_decrement <= 1'b1;
					end
	endcase
end	
	
 endmodule
    