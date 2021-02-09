`include "header.v"

module word_to_byte
(	input wire									i_clk,
	input wire [4*pDATA_WIDTH-1:0]				i_word,
	input wire [2*$clog2(pDEPTH_RAM)+1:0]			i_adress,			//data from FIFO; digits shall be changed later
	input wire									i_FIFO_empty,			//1, 2 or 3;		
	output reg[pDATA_WIDTH-1:0]					o_byte,
	output wire									o_FIFO_read,
	output reg 									o_RAM_read,
	output wire [$clog2(pDEPTH_RAM)-1:0]			o_read_adress,
	output reg 									o_TX_data_valid,
	output reg 									o_TX_finish,
	output wire [1:0]							o_state
);
	
	localparam [1:0] lpWAIT			= 2'b00,
					lpFORM_REQUEST  =  2'b01,     
					lpRAM_READ 		=  2'b10,
					lpLAST_WORD		=  2'b11;
					
	reg									r_FIFO_read='0;
	reg	[$clog2(pDEPTH_RAM)-1:0]		r_read_adress;
	reg	[$clog2(pDEPTH_RAM)-1:0]		r_EoF;

	reg [1:0]							r_state_reg = lpWAIT;
	reg [1:0]							r_state_next= lpFORM_REQUEST;
	
	reg 	[2:0]							r_adress_wait = '0;
	reg [1:0]							r_count_to_3 = '0;
	
	reg  [1:0]							r_extra_bytes;
	reg [3:0]							r_intergap =0;
	reg [1:0]							r_round;
	
	assign  o_read_adress = r_read_adress;
	assign o_FIFO_read = r_FIFO_read;
	assign o_state = r_state_reg;
	
	always @* begin
            case(r_state_reg)
		lpWAIT:     				r_state_next <= lpFORM_REQUEST;
		lpFORM_REQUEST:     	r_state_next <= lpRAM_READ;
		lpRAM_READ:      		r_state_next <= lpLAST_WORD;
		lpLAST_WORD: 		r_state_next <= lpWAIT;
            endcase  
        end

	always @(posedge i_clk) begin
	case (r_state_reg)
		(lpWAIT): begin
					o_byte <= 8'd0;// It may influence frequency
					o_TX_finish <= 1'b0;
					o_TX_data_valid <= 1'b0;
					if (r_intergap < 4'd11) 
						r_intergap <= r_intergap + 1'b1;
					else if (~i_FIFO_empty) begin
						r_FIFO_read <= 1'b1;
						r_state_reg <= r_state_next;
						r_intergap <= 4'd0;
						r_adress_wait <= 3'd0;
					end
				end
		(lpFORM_REQUEST):
				begin
					r_FIFO_read <= 1'b0;
					r_adress_wait <= r_adress_wait + 1;
					case (r_adress_wait)
					3'd2: begin
							if (r_adress_wait == 3'd2) begin
							r_read_adress 	<= 			i_adress [$clog2(pDEPTH_RAM)-1:0];
							r_EoF 			<= 			i_adress [2*$clog2(pDEPTH_RAM)-1:$clog2(pDEPTH_RAM)];
							r_extra_bytes	<= 			i_adress [2*$clog2(pDEPTH_RAM)+1:2*$clog2(pDEPTH_RAM)];
							o_RAM_read <= 1'b1;
							o_TX_data_valid <= 1'b1;
						end
						end
					3'd3: 	begin
							if (r_read_adress > r_EoF) begin
								if (r_read_adress < 13'd1535 )
								r_round <= 2'd1;
									else if (r_read_adress < 13'd3071)
										r_round <= 2'd2;
										else r_round <= 2'd3;
							end
							else r_round <= 2'd0;
							end
					3'd4: 	r_state_reg <= r_state_next;
						
					
					/*if (r_adress_wait == 3'd2) begin
						r_read_adress 	<= 			i_adress [$clog2(pDEPTH_RAM)-1:0];
						r_EoF 			<= 			i_adress [2*$clog2(pDEPTH_RAM)-1:$clog2(pDEPTH_RAM)];
						r_extra_bytes	 <= 			i_adress [2*$clog2(pDEPTH_RAM)+1:2*$clog2(pDEPTH_RAM)];
						o_RAM_read <= 1'b1;
						o_TX_data_valid <= 1'b1;
					end
					else if (r_adress_wait == 3'd4) 
						r_state_reg <= r_state_next;*/
					endcase
				end
		(lpRAM_READ): begin						//Use r_round
					r_count_to_3 <= r_count_to_3 + 1;
					case (r_count_to_3)
					(2'd0):	o_byte <= i_word [31:24];
					(2'd1):	begin
							o_byte <= i_word [23:16];
							case (r_round)
							2'd0:	r_read_adress <= r_read_adress + 'b1;
							2'd1:	begin
									if (r_read_adress == 13'd1534)
									r_read_adress <= 13'd0;
									else r_read_adress <= r_read_adress + 'b1;
									end
							2'd2:	begin
									if (r_read_adress == 13'd3070)
									r_read_adress <= 13'd1535;
									else r_read_adress <= r_read_adress + 'b1;
									end
							2'd3:	begin
									if (r_read_adress == 13'd4607)
									r_read_adress <= 13'd3071;
									else r_read_adress <= r_read_adress + 'b1;
									end
							endcase
							end
					(2'd2):	o_byte <= i_word [15:8];
					(2'd3):	begin
							o_byte <= i_word [7:0];
							if (r_read_adress == r_EoF)
								r_state_reg <= r_state_next;
							end
					endcase
				end
		(lpLAST_WORD):	begin
						r_count_to_3 <= r_count_to_3 + 1;
						case (r_extra_bytes)
						(2'd0): begin
								case (r_count_to_3)
								(2'd0):o_byte <= i_word [31:24];
								(2'd1):o_byte <= i_word [23:16];
								(2'd2):o_byte <= i_word [15:8];
								(2'd3):begin
										o_byte <= i_word [7:0];
										o_RAM_read <= 1'b0;
										r_state_reg <= r_state_next;
										o_TX_finish <= 1'b1;
									end
								endcase
								end
						(2'd1):begin
								case (r_count_to_3)
								(2'd0):o_byte <= i_word [23:16];
								(2'd1):o_byte <= i_word [15:8];
								(2'd2): begin
										o_byte <= i_word [7:0];
										o_RAM_read <= 1'b0;
										r_state_reg <= r_state_next;
										r_count_to_3 <= 2'd0;
										o_TX_finish <= 1'b1;
									end
								endcase
								end				
						(2'd2):begin
								case (r_count_to_3)
								(2'd0):o_byte <= i_word [15:8];
								(2'd1):begin
										o_byte <= i_word [7:0];
										o_RAM_read <= 1'b0;
										r_state_reg <= r_state_next;
										r_count_to_3 <= 2'd0;
										o_TX_finish <= 1'b1;
									end
								endcase
								end
						(2'd3):begin
								o_byte <= i_word [7:0];
								o_RAM_read <= 1'b0;
								r_state_reg <= r_state_next;
								r_count_to_3 <= 2'd0;
								o_TX_finish <= 1'b1;
							end
						endcase
						end
	endcase
	end
	
	endmodule