`include "header.v"

// i_tr_e goes the same direction, as i_port_num

module transform_3    
    (
	input wire          								i_clk,    	
	input wire          								i_rx_dv,     	//Не используется, можно убрать	
	input wire          								i_rx_er,     	
	input wire  [pDATA_WIDTH-1:0]   					i_rx_d,     	
	input wire [pFSM_BUS_WIDHT-1:0]   					i_fsm_state,	
	input wire [$clog2(pPORT_WIDTH)-1:0]				i_port_num,
	input wire 											i_tr_e,				// Когда узнали номер порта, загорается этот разрешающий сигнал
	output reg [2:0][4*pDATA_WIDTH-1:0]         		o_32_bit_data,		//Packed array
	output reg [2:0]									o_valid,
	output reg  [2:0]									o_delete,
	output reg [2:0] [$clog2(pPORT_WIDTH)-1:0]			o_extra_bytes,
	output reg [2:0] [1:0]								o_info_bits			//0 - start; 1- end
    );
	
	// i_tr_e - приходит только тогда, когда мы узнаём номер порта и он не "ШИРОКОВЕЩАТЕЛЬНЫЙ"
	// Когда будет обеспечен реальный поток данных с 4 портов, то i_tr_e будет зажигаться на 4 такта 
	bit [pPORT_WIDTH-1:0] [pDATA_WIDTH-1:0]         			r_inner_buffer  /* synthesis ramstyle = "logic" */;
	
	reg [2:0]							r_count_to_4='0;	//Counter for round-robin
	reg [1:0]							r_CRC_counter = '0;
	reg [2:0]							r_turn_off = '0;
	
	localparam [1:0] 	lpWAIT  	=  2'b00,
						lpF_W		=  2'b01,
						lpWORK 		=  2'b10,     
						lpTURN_OFF	=  2'b11;
	
	reg [1:0]							r_state_reg	 	= lpWAIT;
	reg [1:0]							r_state_next	= lpF_W;
	
	int i;
	int j;
					
	always @* begin
            case(r_state_reg)
                lpWAIT:     		r_state_next <= lpF_W;
	       		lpF_W:			r_state_next <= lpWORK;
                lpWORK:     		r_state_next <= lpTURN_OFF;
                lpTURN_OFF:      	r_state_next <= lpWAIT;
            endcase  
        end

    reg [5:0][7:0]  					r_data_buffer = '0;
    reg [5:0]       					r_rx_er_buffer = '0;
    reg [5:0]       					r_rx_dv_buffer = '0;
	reg [5:0][pFSM_BUS_WIDHT-1:0]   	r_fsm_state_buffer = '0;

	always @(posedge i_clk) begin

	for (j = 0; j < 5; j = j +1 ) begin
		r_data_buffer[j+1]  			<= r_data_buffer[j];
		r_rx_dv_buffer[j+1] 			<= r_rx_dv_buffer[j];
		r_rx_er_buffer[j+1]				<= r_rx_er_buffer [j];
		r_fsm_state_buffer [j+1]		<= r_fsm_state_buffer [j];
    end
  	r_data_buffer[0]  		<=    i_rx_d;
    r_rx_dv_buffer[0] 		<=    i_rx_dv;
    r_rx_er_buffer[0] 		<=    i_rx_er;
	r_fsm_state_buffer[0]  	<= 	  i_fsm_state;
	

	case(r_state_reg)
		(lpWAIT):	begin
					if (r_fsm_state_buffer[4] == lpSFD) begin
						r_state_reg <= r_state_next;
						o_delete [0] <= 1'b0;
						o_delete [1] <= 1'b0;
						o_delete [2] <= 1'b0;
					end
					end
		(lpF_W):	begin
					for (i = 0; i < 3; i = i +1 ) 
							r_inner_buffer[i+1]  			<= r_inner_buffer[i];
						r_inner_buffer[0] <= r_data_buffer[4];
					if (r_count_to_4 == 3'd4)
							begin 
							o_32_bit_data [0] <= {r_inner_buffer[3],r_inner_buffer[2],r_inner_buffer[1],r_inner_buffer[0]};
							o_32_bit_data [1] <= {r_inner_buffer[3],r_inner_buffer[2],r_inner_buffer[1],r_inner_buffer[0]};
							o_32_bit_data [2] <= {r_inner_buffer[3],r_inner_buffer[2],r_inner_buffer[1],r_inner_buffer[0]};
							o_valid [0] <= 1'b1;
							o_valid [1] <= 1'b1;
							o_valid [2] <= 1'b1;
							r_count_to_4 <= 3'b1;
							r_state_reg <= r_state_next;
							o_info_bits [0] <= 2'b01;
							o_info_bits [1] <= 2'b01;
							o_info_bits [2] <= 2'b01;
						end
					else r_count_to_4 <= r_count_to_4 + 1'b1;
					end
		(lpWORK):	begin
					if (i_rx_er) begin
						o_delete [0] <= 1'b1;
						o_delete [1] <= 1'b1;
						o_delete [2] <= 1'b1;
						o_valid [0] <= 0;
						o_valid [1] <= 0;
						o_valid [2] <= 0;
						r_state_reg <= lpWAIT;
					end					
					else begin 
						for (i = 0; i < 3; i = i +1 ) 
							r_inner_buffer[i+1]  			<= r_inner_buffer[i];
						r_inner_buffer[0] <= r_data_buffer[4];
						if (r_count_to_4 == 3'd4)
							begin 
							o_32_bit_data [0] <= {r_inner_buffer[3],r_inner_buffer[2],r_inner_buffer[1],r_inner_buffer[0]};
							o_32_bit_data [1] <= {r_inner_buffer[3],r_inner_buffer[2],r_inner_buffer[1],r_inner_buffer[0]};
							o_32_bit_data [2] <= {r_inner_buffer[3],r_inner_buffer[2],r_inner_buffer[1],r_inner_buffer[0]};
							r_count_to_4 <= 3'd1;
							o_info_bits [0] <= 2'b00;
							o_info_bits [1] <= 2'b00;
							o_info_bits [2] <= 2'b00;
						end
						else begin	
						r_count_to_4 <= r_count_to_4 + 1'b1;
						if (i_tr_e) begin			
							case (i_port_num)
							(2'd0):	begin
									o_delete[1] <= 1'b1;
									o_delete[2] <= 1'b1;
									o_valid [1] <= 1'b0;
									o_valid [2] <= 1'b0;
									end
							(2'd1):	begin
									o_delete[0] <= 1'b1;
									o_delete[2] <= 1'b1;
									o_valid [0] <= 1'b0;
									o_valid [2] <= 1'b0;
									end
							(2'd2):	begin
									o_delete[0] <= 1'b1;
									o_delete[1] <= 1'b1;
									o_valid [1] <= 1'b0;
									o_valid [0] <= 1'b0;									
									end
							endcase 
						end 
						end
					end
					if (r_CRC_counter == 2'b11) begin
						r_state_reg <= r_state_next;
						end	
					end					
		(lpTURN_OFF):begin
						if (i_rx_er == 1) begin
							o_delete [0] <= 1'b1;
							o_delete [1] <= 1'b1;
							o_delete [2] <= 1'b1;
							o_valid [0] <= 0;
							o_valid [1] <= 0;
							o_valid [2] <= 0;
							r_state_reg <= r_state_next;
						end
						else case (r_count_to_4)
							3'd1: begin 
									r_turn_off <= r_turn_off +1'b1;
									if (r_turn_off==3'd3) begin
										o_32_bit_data [0] <= {8'd0,8'd0,8'd0,r_inner_buffer[0]};
										o_32_bit_data [1] <= {8'd0,8'd0,8'd0,r_inner_buffer[0]};
										o_32_bit_data [2] <= {8'd0,8'd0,8'd0,r_inner_buffer[0]};
										o_extra_bytes [0] <= 2'd3;
										o_extra_bytes [1] <= 2'd3;
										o_extra_bytes [2] <= 2'd3;
										o_info_bits [0] <= 2'b10;
										o_info_bits [1] <= 2'b10;
										o_info_bits [2] <= 2'b10;
									end
									if (r_turn_off==3'd7) begin
										o_valid [0] <= 0;
										o_valid [1] <= 0;
										o_valid [2] <= 0;
										o_info_bits [0] <= 2'b00;
										o_info_bits [1] <= 2'b00;
										o_info_bits [2] <= 2'b00;
										r_state_reg <= r_state_next;
										r_turn_off <= '0;
										r_count_to_4 <= 3'b0;
									end
								end
							3'd2:begin 
									r_turn_off <= r_turn_off +1'b1;
									if (r_turn_off==3'd2) begin
										o_32_bit_data [0] <= {8'd0,8'd0,r_inner_buffer[1],r_inner_buffer[0]};
										o_32_bit_data [1] <= {8'd0,8'd0,r_inner_buffer[1],r_inner_buffer[0]};
										o_32_bit_data [2] <= {8'd0,8'd0,r_inner_buffer[1],r_inner_buffer[0]};
										o_extra_bytes [0] <= 2'd2;
										o_extra_bytes [1] <= 2'd2;
										o_extra_bytes [2] <= 2'd2;
										o_info_bits [0] <= 2'b10;
										o_info_bits [1] <= 2'b10;
										o_info_bits [2] <= 2'b10;
									end
									if (r_turn_off==3'd6) begin
										o_valid [0] <= 0;
										o_valid [1] <= 0;
										o_valid [2] <= 0;
										o_info_bits [0] <= 2'b00;
										o_info_bits [1] <= 2'b00;
										o_info_bits [2] <= 2'b00;
										r_state_reg <= r_state_next;
										r_count_to_4 <= 3'b0;
										r_turn_off <= '0;
									end
								end
							3'd3:begin 
									r_turn_off <= r_turn_off +1'b1;
									if (r_turn_off == 3'd1) begin
										o_32_bit_data [0] <= {8'd0,r_inner_buffer[2],r_inner_buffer[1],r_inner_buffer[0]};
										o_32_bit_data [1] <= {8'd0,r_inner_buffer[2],r_inner_buffer[1],r_inner_buffer[0]};
										o_32_bit_data [2] <= {8'd0,r_inner_buffer[2],r_inner_buffer[1],r_inner_buffer[0]};
										o_extra_bytes [0] <= 2'd1;
										o_extra_bytes [1] <= 2'd1;
										o_extra_bytes [2] <= 2'd1;
										o_info_bits [0] <= 2'b10;
										o_info_bits [1] <= 2'b10;
										o_info_bits [2] <= 2'b10;
									end
									if (r_turn_off==3'd5) begin
										o_valid [0] <= 0;
										o_valid [1] <= 0;
										o_valid [2] <= 0;
										o_info_bits [0] <= 2'b00;
										o_info_bits [1] <= 2'b00;
										o_info_bits [2] <= 2'b00;
										r_state_reg <= r_state_next;
										r_count_to_4 <= 3'b0;
										r_turn_off <= '0;
									end
								end
							3'd4:begin
									r_turn_off <= r_turn_off +1'b1;
									if (r_turn_off == 3'd0) begin
										o_32_bit_data [0] <= {r_inner_buffer[3],r_inner_buffer[2],r_inner_buffer[1],r_inner_buffer[0]};
										o_32_bit_data [1] <= {r_inner_buffer[3],r_inner_buffer[2],r_inner_buffer[1],r_inner_buffer[0]};
										o_32_bit_data [2] <= {r_inner_buffer[3],r_inner_buffer[2],r_inner_buffer[1],r_inner_buffer[0]};
										o_extra_bytes [0] <= 2'd0;
										o_extra_bytes [1] <= 2'd0;
										o_extra_bytes [2] <= 2'd0;
										o_info_bits [0] <= 2'b10;
										o_info_bits [1] <= 2'b10;
										o_info_bits [2] <= 2'b10;
									end
										if (r_turn_off==3'd4) begin
											o_valid [0] <= 0;
											o_valid [1] <= 0;
											o_valid [2] <= 0;
											o_info_bits [0] <= 2'b00;
											o_info_bits [1] <= 2'b00;
											o_info_bits [2] <= 2'b00;
											r_state_reg <= r_state_next;
											r_count_to_4 <= 3'b0;
											r_turn_off <= '0;
									end
								end
						endcase
					end					
		endcase
		
	if (r_fsm_state_buffer[4] == lpCRC)
		r_CRC_counter <= r_CRC_counter+1'b1;
				
    end
endmodule
	
	