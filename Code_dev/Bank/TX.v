`include "header.v"

module TX 
(	input wire 						i_clk,
	input wire						i_TX_data_valid,
	input wire 						i_TX_finish,
	input wire [pDATA_WIDTH-1:0]		i_data_TX,
	input wire [1:0]					i_state,
	output reg						o_dv_TX,
	output reg						o_er_TX,
	output reg [pDATA_WIDTH-1:0]		o_data_TX,
	output wire						o_clk
		);
		
		
`include "functions.sv"
	
	 localparam [1:0] 	lpWAIT  =  2'b00,     // No data
						lpPRE =  2'b01,     // Preambula
						lpDATA =  2'b10;     // Delimiter
						
	reg [1:0]						r_state_reg = lpWAIT;
	reg [1:0]						r_state_next = lpPRE;
	
	reg [2:0]						r_PRE_count='0;
	
	reg [5:0][7:0]  					r_TX_buffer = 40'b0;
	reg [5:0]						r_finish_buffer = '0;
	reg [5:0]						r_valid_buffer = '0;	
	
	int 								i;
	
	assign o_clk = i_clk;
	
	always @* begin
            case(r_state_reg)
		lpWAIT:     			r_state_next <= lpPRE;
		lpPRE:     			r_state_next <= lpDATA;
		lpDATA:      			r_state_next <= lpWAIT;
            endcase  
        end
						
	always @(posedge i_clk) begin
	for (i = 0; i < 5; i = i +1 ) begin
		r_TX_buffer[i+1]  			<= r_TX_buffer[i]; 			//5 clocks for DATA
		r_finish_buffer [i+1]		<= r_finish_buffer [i];		// 6 clocks for FINISH
		r_valid_buffer [i+1]			<= r_valid_buffer [i];
	end
	r_TX_buffer[0] <= i_data_TX;
	r_finish_buffer [0] <= i_TX_finish;
	r_valid_buffer [0] <= i_TX_data_valid;
	case (r_state_reg)
	lpWAIT:	begin
			if (i_TX_data_valid)	begin
				o_data_TX 	<= 8'h55;
				o_dv_TX 		<= 1'b1; 
				r_state_reg 	<= r_state_next;
			end
			else o_data_TX <= 8'd0;
			end
	lpPRE: 	begin
			if (r_PRE_count==3'd6) begin
				r_state_reg 	<= r_state_next;
				o_data_TX 	<= 8'hd5;
				r_PRE_count <= 3'd0;
			end
			else r_PRE_count <= r_PRE_count + 1'b1;
			end
	lpDATA:	begin
			if (r_finish_buffer[5] )
			begin
				r_state_reg 	<= r_state_next;
				o_data_TX <= r_TX_buffer [4];
				o_dv_TX <= 1'b0;
			end
			else o_data_TX <= r_TX_buffer[4];
			end
	endcase
	end
	
	// Check CRC
	reg [31:0] rcrc_new = '0;
	
	always @(posedge i_clk) begin		
		if ((r_valid_buffer[2]) &(i_TX_data_valid)) 	begin			// may be optimised											//Calculate CRC
			rcrc_new <=  eth_crc32_8d(rcrc_new, i_data_TX);
			o_er_TX <= 1'b0;
			end
		else if ((~i_TX_data_valid)|(i_state == 2'b00)) begin					//i_state = lpWAIT
			if ((((rcrc_new != 32'hC704DD7B )&(rcrc_new != 32'h0000_0000))))
				o_er_TX <= 1'b1;
			end
		else if ((~i_TX_data_valid)|(i_state == 2'b01)) begin						//i_state = lpFORM_REQUEST
			rcrc_new <= '1;
			o_er_TX <= 1'b0;
		end
	end
	
endmodule