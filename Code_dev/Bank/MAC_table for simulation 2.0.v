`include "header.v"

module MAC_table
    (
	input wire                                 						iclk,
	input wire                                  					i_write_enable,
	input wire [$clog2(pPORT_WIDTH)-1:0]          					i_port_num,
	input wire [$clog2(pMAC_MEM_DEPTH)-1:0]     					i_MAC_SA,
	input wire                                  					i_read_enable,
	input wire [$clog2(pMAC_MEM_DEPTH)-1:0]     					i_MAC_DA,       
	input wire [pDATA_WIDTH-1:0]                					i_check_byte_DA,
	input wire [pDATA_WIDTH-1:0]                					i_check_byte_SA,
	input															i_decrement, 
	output reg [$clog2(pPORT_WIDTH)-1:0]         					o_port_num_MAC [pPORT_WIDTH-1:0],
	output reg [pPORT_WIDTH-1:0]									o_tr_e
    );

reg                                  							r_block_0_wr_en= '0;
reg                                  							r_block_1_wr_en= '0;
reg                                  							r_block_2_wr_en= '0;
reg                                  							r_block_3_wr_en= '0;
reg [$clog2(pMAC_MEM_DEPTH)-1:0]     			r_write_adress;
reg                                  							r_read_enable;
reg [$clog2(pMAC_MEM_DEPTH)-1:0]     			r_read_adress;

reg [$clog2(pMAC_MEM_DEPTH)-1:0]				r_write_adress_time;
reg [$clog2(pMAC_MEM_DEPTH)-1:0]				r_read_adress_time;
reg                                  							r_write_enable_time_0 = '0;
reg                                  							r_write_enable_time_1= '0;
reg                                  							r_write_enable_time_2= '0;
reg                                  							r_write_enable_time_3= '0;

reg [pDATA_WIDTH-1:0] 						r_check_byte_block_0;
reg [pDATA_WIDTH-1:0] 						r_check_byte_block_1;
reg [pDATA_WIDTH-1:0] 						r_check_byte_block_2;
reg [pDATA_WIDTH-1:0] 						r_check_byte_block_3;
reg											r_match_0;
reg											r_match_1;
reg											r_match_2;
reg											r_match_3;
reg [pTIME-1:0]								r_timer_0;
reg [pTIME-1:0]								r_timer_1;
reg [pTIME-1:0]								r_timer_2;
reg [pTIME-1:0]								r_timer_3;

//reg [pTIME-1:0]								r_decremented_timer = 9'd299;
reg [pTIME-1:0]								r_time_block_0;
reg [pTIME-1:0]								r_time_block_1;
reg [pTIME-1:0]								r_time_block_2;
reg [pTIME-1:0]								r_time_block_3;
reg 											r_full_0;
reg 											r_full_1;
reg 											r_full_2;

reg											r_check_byte_all='b0;
reg											r_not_empty_all ='b0;

reg [$clog2(pPORT_WIDTH)-1:0]				r_data_exit_0;
reg [$clog2(pPORT_WIDTH)-1:0]				r_data_exit_1;
reg [$clog2(pPORT_WIDTH)-1:0]				r_data_exit_2;
reg [$clog2(pPORT_WIDTH)-1:0]				r_data_exit_3;

reg [pPORT_WIDTH-1:0]                                  		r_new_adress;

bit r_empty_all = 'b0;

reg r_match_DA_0;
reg r_match_DA_1;
reg r_match_DA_2;
reg r_match_DA_3;
	
wire [3:0] w_match_all;
wire [2:0] w_not_empty_wire;
wire [3:0] w_match_DA; // For DA

    


//Registers for counters
reg [2:0]									r_count_to_5='0;
reg [$clog2(pMAC_MEM_DEPTH)-1:0]    			r_d_counter = '0; 
//reg [$clog2(pONE_SECOND)-1:0]      				r_FBC = '0;



	ram_dual				//PORT_NUM_0 					
		#(	.WIDTH          		(2),
			.WORDS          		(pMAC_MEM_DEPTH),
			.ADDR_WIDTH    	(14),
			.USE_EAB        		(1),
			.USE_RD_ENA     	(1),
			.USE_ALTSYNC    	(0)
		)
		port_num_block_0		/* synthesis noprune*/				
		(	.odata       		(r_data_exit_0),
			.oval        		(),
			.idata       		(i_port_num),
			.iaddr_in    		(r_write_adress),
			.iaddr_out   		(r_read_adress),
			.iwr_ena     		(r_block_0_wr_en),
			.ird_ena     		(r_read_enable),
			.iclk			(iclk)			
		);
		
	ram_dual				//PORT_NUM_1 
		#(	.WIDTH          		(2),
			.WORDS          		(pMAC_MEM_DEPTH),
			.ADDR_WIDTH    	(14),
			.USE_EAB        		(1),
			.USE_RD_ENA     	(1),
			.USE_ALTSYNC    	(0)
		)
		port_num_block_1		/* synthesis noprune*/		
		(	.odata       		(r_data_exit_1),
			.oval        		(),
			.idata       		(i_port_num),
			.iaddr_in    		(r_write_adress),
			.iaddr_out   		(r_read_adress),
			.iwr_ena     		(r_block_1_wr_en),
			.ird_ena     		(r_read_enable),
			.iclk			(iclk)			
		);
		
	ram_dual 				//PORT_NUM_2
		#(	.WIDTH          		(2),
			.WORDS          		(pMAC_MEM_DEPTH),
			.ADDR_WIDTH    	(14),
			.USE_EAB        		(1),
			.USE_RD_ENA     	(1),
			.USE_ALTSYNC    	(0)
		)
		port_num_block_2		/* synthesis noprune*/		
		(	.odata       		(r_data_exit_2),
			.oval        		(),
			.idata       		(i_port_num),
			.iaddr_in    		(r_write_adress),
			.iaddr_out   		(r_read_adress),
			.iwr_ena     		(r_block_2_wr_en),
			.ird_ena     		(r_read_enable),
			.iclk			(iclk)			
		);
		
	ram_dual 			//PORT_NUM_3
		#(	.WIDTH          		(2),
			.WORDS          		(pMAC_MEM_DEPTH),
			.ADDR_WIDTH    	(14),
			.USE_EAB        		(1),
			.USE_RD_ENA     	(1),
			.USE_ALTSYNC    	(0)
		)
		port_num_block_3		/* synthesis noprune*/	
		(	.odata       		(r_data_exit_3),
			.oval        		(),
			.idata       		(i_port_num),
			.iaddr_in    		(r_write_adress),
			.iaddr_out   		(r_read_adress),
			.iwr_ena     		(r_block_3_wr_en),
			.ird_ena     		(r_read_enable),
			.iclk			(iclk)			
		);
		
	ram_dual				//Timer_0 
		#(	.WIDTH          		(pTIME),
			.WORDS          		(pMAC_MEM_DEPTH),
			.ADDR_WIDTH    	(14),
			.USE_EAB        		(1),
			.USE_RD_ENA     	(1),
			.USE_ALTSYNC    	(0)
		)
		timer_0					/* synthesis noprune*/				
		(	.odata       		(r_time_block_0),
			.oval        		(),
			.idata       		(r_timer_0),
			.iaddr_in    		(r_write_adress_time),
			.iaddr_out   		(r_read_adress_time),
			.iwr_ena     		(r_write_enable_time_0),
			.ird_ena     		(r_read_enable),
			.iclk			(iclk)			
		);
		
	ram_dual				//Timer_1 
		#(	.WIDTH          		(pTIME),
			.WORDS          		(pMAC_MEM_DEPTH),
			.ADDR_WIDTH    	(14),
			.USE_EAB        		(1),
			.USE_RD_ENA     	(1),
			.USE_ALTSYNC    	(0)
		)
		timer_1					/* synthesis noprune*/			
		(	.odata       		(r_time_block_1),
			.oval        		(),
			.idata       		(r_timer_1),
			.iaddr_in    		(r_write_adress_time),
			.iaddr_out   		(r_read_adress_time),
			.iwr_ena     		(r_write_enable_time_1),
			.ird_ena     		(r_read_enable),
			.iclk			(iclk)			
		);
		
	ram_dual				//Timer_2 
		#(	.WIDTH          		(pTIME),
			.WORDS          		(pMAC_MEM_DEPTH),
			.ADDR_WIDTH    	(14),
			.USE_EAB        		(1),
			.USE_RD_ENA     	(1),
			.USE_ALTSYNC    	(0)
		)
		timer_2					/* synthesis noprune*/			
		(	.odata       		(r_time_block_2),
			.oval        		(),
			.idata       		(r_timer_2),
			.iaddr_in    		(r_write_adress_time),
			.iaddr_out   		(r_read_adress_time),
			.iwr_ena     		(r_write_enable_time_2),
			.ird_ena     		(r_read_enable),
			.iclk			(iclk)			
		);
		
	ram_dual				//Timer_3 
		#(	.WIDTH          		(pTIME),
			.WORDS          		(pMAC_MEM_DEPTH),
			.ADDR_WIDTH    	(14),
			.USE_EAB        		(1),
			.USE_RD_ENA     	(1),
			.USE_ALTSYNC    	(0)
		)
		timer_3					/* synthesis noprune*/			
		(	.odata       		(r_time_block_3),
			.oval        		(),
			.idata       		(r_timer_3),
			.iaddr_in    		(r_write_adress_time),
			.iaddr_out   		(r_read_adress_time),
			.iwr_ena     		(r_write_enable_time_3),
			.ird_ena     		(r_read_enable),
			.iclk			(iclk)			
		);
		
	ram_dual				//Check_byte_0 
		#(	.WIDTH          		(pDATA_WIDTH),
			.WORDS          		(pMAC_MEM_DEPTH),
			.ADDR_WIDTH    	(14),
			.USE_EAB        		(1),
			.USE_RD_ENA     	(1),
			.USE_ALTSYNC    	(0)
		)
		check_byte_0			/* synthesis noprune*/		
		(	.odata       		(r_check_byte_block_0),
			.oval        		(),
			.idata       		(i_check_byte_SA),
			.iaddr_in    		(r_write_adress),
			.iaddr_out   		(r_read_adress),
			.iwr_ena     		(r_block_0_wr_en),
			.ird_ena     		(r_read_enable),
			.iclk			(iclk)			
		);
		
	ram_dual				//Check_byte_1 
		#(	.WIDTH          		(pDATA_WIDTH),
			.WORDS          		(pMAC_MEM_DEPTH),
			.ADDR_WIDTH    	(14),
			.USE_EAB        		(1),
			.USE_RD_ENA     	(1),
			.USE_ALTSYNC    	(0)
		)
		check_byte_1			/* synthesis noprune*/		
		(	.odata       		(r_check_byte_block_1),
			.oval        		(),
			.idata       		(i_check_byte_SA),
			.iaddr_in    		(r_write_adress),
			.iaddr_out   		(r_read_adress),
			.iwr_ena     		(r_block_1_wr_en),
			.ird_ena     		(r_read_enable),
			.iclk			(iclk)			
		);
		
	ram_dual				//Check_byte_2 
		#(	.WIDTH          		(pDATA_WIDTH),
			.WORDS          		(pMAC_MEM_DEPTH),
			.ADDR_WIDTH    	(14),
			.USE_EAB        		(1),
			.USE_RD_ENA     	(1),
			.USE_ALTSYNC    	(0)
		)
		check_byte_2			/* synthesis noprune*/		
		(	.odata       		(r_check_byte_block_2),
			.oval        		(),
			.idata       		(i_check_byte_SA),
			.iaddr_in    		(r_write_adress),
			.iaddr_out   		(r_read_adress),
			.iwr_ena     		(r_block_2_wr_en),
			.ird_ena     		(r_read_enable),
			.iclk			(iclk)			
		);
		
	ram_dual				//Check_byte_3 
		#(	.WIDTH          		(pDATA_WIDTH),
			.WORDS          		(pMAC_MEM_DEPTH),
			.ADDR_WIDTH    	(14),
			.USE_EAB        		(1),
			.USE_RD_ENA     	(1),
			.USE_ALTSYNC    	(0)
		)
		check_byte_3			/* synthesis noprune*/		
		(	.odata       		(r_check_byte_block_3),
			.oval        		(),
			.idata       		(i_check_byte_SA),
			.iaddr_in    		(r_write_adress),
			.iaddr_out   		(r_read_adress),
			.iwr_ena     		(r_block_3_wr_en),
			.ird_ena     		(r_read_enable),
			.iclk			(iclk)			
		);
  

       assign w_match_all = {r_match_0, r_match_1, r_match_2, r_match_3};
    assign w_not_empty_wire = {r_full_0, r_full_1, r_full_2};


    assign w_match_DA = {r_match_DA_0, r_match_DA_1, r_match_DA_2, r_match_DA_3}; // For DA

    always @(posedge iclk) begin		
	r_read_enable <= 1'b1;
	if (i_write_enable)														
		begin
		r_write_adress 		<= i_MAC_SA;
		r_write_adress_time	<= i_MAC_SA;
		r_read_adress		<= i_MAC_SA;							
		r_read_adress_time	<= i_MAC_SA;		
		r_not_empty_all 		<= ((r_time_block_0 != 9'd0) | (r_time_block_1 != 9'b0) | (r_time_block_2 != 9'b0) | (r_time_block_3 != 9'b0));
		r_check_byte_all     	<= ((r_check_byte_block_0 == i_check_byte_SA) | (r_check_byte_block_1 == i_check_byte_SA) | (r_check_byte_block_2 == i_check_byte_SA) | (r_check_byte_block_3 ==i_check_byte_SA));       
		r_match_0        		<= (r_check_byte_block_0 == i_check_byte_SA);
		r_match_1        		<= (r_check_byte_block_1 == i_check_byte_SA);
		r_match_2        		<= (r_check_byte_block_2 == i_check_byte_SA);
		r_match_3       		<= (r_check_byte_block_3 == i_check_byte_SA);
		r_full_0			<= (r_time_block_0 != 9'b0);
		r_full_1			<= (r_time_block_1 != 9'b0);
		r_full_2			<= (r_time_block_2 != 9'b0);
		r_timer_0 				<= 9'd300;
		r_timer_1				<= 9'd300;
		r_timer_2				<= 9'd300;
		r_timer_3				<= 9'd300;			

		if (r_count_to_5 == 3'd5) begin
			if (r_not_empty_all) //Если есть хоть 1 заполненный
			begin
				if (r_check_byte_all)   //Если совпадает, то перезапись 
				begin
					case (w_match_all) 
					(4'b1000):  begin                                           //Перезапись 0
						r_block_0_wr_en <= 1'b1;
						r_write_enable_time_0 <= 1'b1;
					end
					(4'b0100):  begin                                           //Перезапись 1
						r_block_1_wr_en <= 1'b1;
						r_write_enable_time_1 <= 1'b1;
					end
					(4'b0010):  begin                                           //Перезапись 2
						r_block_2_wr_en <= 1'b1;
						r_write_enable_time_2 <= 1'b1;				
					end
					(4'b0001):  begin                                           //Перезапись 3
						r_block_3_wr_en <= 1'b1;
						r_write_enable_time_3 <= 1'b1;
					end
					endcase
				end
				else  begin                        					//ЧекБайт не совпал - нужно записать в пустую ячейку, кроме 0
					case (w_not_empty_wire)
					(3'b100):   begin                              //Первая запись 1
						r_block_1_wr_en <= 1'b1;
						r_write_enable_time_1 <= 1'b1;
					end 
					(3'b110):   begin                              //Первая запись 2
						r_block_2_wr_en <= 1'b1;
						r_write_enable_time_2 <= 1'b1;
					end 
					(3'b111):   begin                              //Первая запись 3
						r_block_3_wr_en <= 1'b1;
						r_write_enable_time_3 <= 1'b1;
					end 
					endcase
				end
			end
			else begin						//Всё пусто 
				r_block_0_wr_en <= 1'b1;		//Первая запись 0
				r_write_enable_time_0 <= 1'b1;     			
			end
		end
		else if (r_count_to_5 == 3'd0) begin				// Default situation - no enable to write		
			r_block_0_wr_en <= 1'b0;
			r_block_1_wr_en <= 1'b0;
			r_block_2_wr_en <= 1'b0;
			r_block_3_wr_en <= 1'b0;
			r_write_enable_time_0 <= 1'b0;    
			r_write_enable_time_1 <= 1'b0;
			r_write_enable_time_2 <= 1'b0;
			r_write_enable_time_3 <= 1'b0;
		end
         end
	else if (i_read_enable) 					//Чтение
	begin
		r_read_adress		<= i_MAC_DA;					
		r_read_adress_time	<= i_MAC_DA;
		r_empty_all 			<= ((r_time_block_0 == 9'd0) & (r_time_block_1 == 9'd0) & (r_time_block_2 == 9'd0) & (r_time_block_3 == 9'd0));
		
		r_match_DA_0 <= (r_check_byte_block_0 == i_check_byte_DA);
		r_match_DA_1 <= (r_check_byte_block_1 == i_check_byte_DA);
		r_match_DA_2 <= (r_check_byte_block_2 == i_check_byte_DA);
		r_match_DA_3 <= (r_check_byte_block_3 == i_check_byte_DA);
		
		if (r_count_to_5 == 3'd5) begin
			if (r_empty_all)    
				r_new_adress [i_port_num] <= 1;  // Значит пакет должен отправиться на всё порты
			else begin  
				r_new_adress [i_port_num] <= 0;
				case (w_match_DA)  // Выбор, из какой ячейки должен быть считан # порта
				(4'b1000):      begin 
							o_port_num_MAC [i_port_num] <= r_data_exit_0;
							o_tr_e [i_port_num] <= 1'b1;
							end
				(4'b0100):      begin 
							o_port_num_MAC [i_port_num] <= r_data_exit_1;
							o_tr_e [i_port_num] <= 1'b1;
							end
				(4'b0010):      begin 
							o_port_num_MAC [i_port_num] <= r_data_exit_2;
							o_tr_e [i_port_num] <= 1'b1;
							end
				(4'b0001):      begin 
							o_port_num_MAC [i_port_num] <= r_data_exit_3;
							o_tr_e [i_port_num] <= 1'b1;
							end
				endcase
			end
		end
		else if (r_count_to_5 == 3'd3) begin
			o_tr_e [0] <= 1'b0;
			o_tr_e [1] <= 1'b0;
			o_tr_e [2] <= 1'b0;
			o_tr_e [3] <= 1'b0;
		end
	end
	else if (i_decrement == 1)   							//Decrement				
		begin												// Kostyl', time for i_decrement should be increased
		r_read_adress_time 		<= 	r_d_counter;			// 0,7% from 1 second
		r_write_adress_time		<= 	r_d_counter;
		if (r_count_to_5 == 3'd3) begin
			o_tr_e [0] <= 1'b0;
			o_tr_e [1] <= 1'b0;
			o_tr_e [2] <= 1'b0;
			o_tr_e [3] <= 1'b0;
		end
		else if (r_count_to_5 == 3'd4) begin
			if (r_time_block_0 !=9'b0)	
				r_timer_0 <= r_time_block_0 - 1'b1;
			if (r_time_block_1 !=9'b0)
				r_timer_1 <= r_time_block_1 - 1'b1;
			if (r_time_block_2 !=9'b0)
				r_timer_2 <= r_time_block_2 - 1'b1;
			if (r_time_block_3 !=9'b0)
				r_timer_3 <= r_time_block_3 - 1'b1;
		end
		else if (r_count_to_5 == 3'd5) begin
			if (r_time_block_0 !=9'b0)
				r_write_enable_time_0 <= 1;
			if (r_time_block_1 !=9'b0)
				r_write_enable_time_1 <= 1;
			if (r_time_block_2 !=9'b0)
				r_write_enable_time_2 <= 1;
			if (r_time_block_3 !=9'b0)
				r_write_enable_time_3 <= 1;
		end
		else if (r_count_to_5 == 3'd0) begin
			r_write_enable_time_0 <= 1'b0;    
			r_write_enable_time_1 <= 1'b0;
			r_write_enable_time_2 <= 1'b0;
			r_write_enable_time_3 <= 1'b0;
			r_d_counter <= r_d_counter + 1'b1;
		end
		/*if (r_count_to_5 == 3'd5) begin
			if (r_time_block_0 !=1'b0)					
				r_write_enable_time_0 <= 1;
			if (r_time_block_1 !=1'b0)					
				r_write_enable_time_1 <= 1;
			if (r_time_block_2 !=1'b0)					
				r_write_enable_time_1 <= 1;
			if (r_time_block_3 !=1'b0)					
				r_write_enable_time_1 <= 1;
			r_d_counter <= r_d_counter + 1'b1;
		end				
		else if (r_count_to_5 == 3'd0) begin
			r_write_enable_time_0 <= 1'b0;    
			r_write_enable_time_1 <= 1'b0;
			r_write_enable_time_2 <= 1'b0;
			r_write_enable_time_3 <= 1'b0;
		end
		else if (r_count_to_5 == 3'd3)begin
			o_tr_e [0] <= 1'b0;
			o_tr_e [1] <= 1'b0;
			o_tr_e [2] <= 1'b0;
			o_tr_e [3] <= 1'b0;
		end*/
    end
	if (r_count_to_5 == 3'd5) 						
			r_count_to_5 <= 3'd0;
	else 	r_count_to_5 <= r_count_to_5 + 1'b1;
        end

endmodule