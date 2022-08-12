module Ethernet_rx_frame            //Таких приёмников будет 4
    (
        input wire          				i_rx_clk,    // GMII
        input wire          				i_rx_dv,     // GMII
        input wire          				i_rx_er,     // GMII
        input wire  [7:0]   				i_rx_d,      // GMII
		input wire							i_DA_ok,
        output wire [2:0]   				o_fsm_state,
    
        output wire         				o_rx_dv_4cd,
        output wire         				o_rx_er_4cd,
        output wire [7:0]   				o_rx_d4cd,
		output reg  [13:0]  				oda,             //Либо хэшированной МАК
        output reg          				onewda,          //Загорается, когда пакет готов. Триггерит запрос пакета
        output reg  [7:0]   				o_check_byte_DA,
        output reg  [13:0]  				osa,             
        output reg          				onewsa,          //Загорается, когда пакет готов. Триггерит запрос пакета
        output reg  [7:0]   				o_check_byte_SA
    );
    
    localparam [2:0] lpND  =  3'b000,     // No data
                     lpPRE =  3'b001,     // Preambula
                     lpSFD =  3'b010,     // Delimiter
                     lpDA  =  3'b011,     // Destination Adress
                     lpSA  =  3'b100,     // Source Adress
                     lpDATA = 3'b101,     // Data
                     lpCRC  = 3'b110;     // CRC     

`include "functions.sv"
	
	reg          						r_fsm_state_changed = 1'b0;
	
    reg [2:0]       					r_state_reg = lpND;
    reg [2:0]       					r_state_next = lpPRE;               
    reg [4:0][7:0]  					r_data_buffer = 32'b0;
    reg [4:0]       					r_rx_er_buffer = 5'b0;
    reg [4:0]       					r_rx_dv_buffer = 5'b0;
    reg [10:0]      					counter = 11'd0;
    int             						i = 0;
    reg 								toggle = 1'b0;
    
    reg [13:0]      					rSA = 14'b0;
	reg [13:0]							rDA = 14'b0;
    reg             					r_NEW_SA_indicator='0;
	   reg             					r_NEW_DA_indicator='0;
    reg [7:0]       					r_check_byte_SA ;
	reg [7:0]       					r_check_byte_DA ;
	
reg [5:0]						r_DA_counter = '0;
reg [5:0]						r_SA_counter = '0;

// regs for HASH
reg [13:0] 						r_new_key_SA = '1;
reg [13:0] 						r_new_key_DA = '1;

    always @(posedge i_rx_clk) begin 
        if (i_rx_dv && !i_rx_er) 
        begin
            case(r_state_reg)
                (lpND): begin
				if (r_data_buffer[3] == 8'h55) begin
					r_state_reg <= r_state_next;
					r_fsm_state_changed 	<= 1;
				end    
			end
                (lpPRE): begin          
				if (r_fsm_state_changed == 1) begin
					r_fsm_state_changed 	<= 0;
					counter 				<= 11'd7;
			end    
				else if (r_data_buffer[3] == 8'hd5) begin
					r_state_reg			 <= r_state_next;
					r_fsm_state_changed 	<= 1;
				end
				else if (counter == 11'd0) begin  // reset
					r_state_reg          		<= lpND;
					r_data_buffer    		<= 32'b0;
					r_rx_dv_buffer 		<= 5'b0;
					r_rx_er_buffer 		<= 5'b0;
				end
			counter <= counter - 11'b1;
			end
                (lpSFD): begin           
				r_state_reg 				<= r_state_next;
				counter 					<= 11'd5;
			end
                (lpDA): begin           							//6 clocks
					case (counter)									// from 5 to 0
				11'd0:	begin
							r_state_reg 			<= r_state_next;
							r_fsm_state_changed 	<= 1;
							counter 				<= 11'd5;
							rDA [7:0]					<= 	r_data_buffer [4];
							//r_new_key_DA 			<= hash_14 (r_new_key_DA, o_rx_d4cd );
							r_check_byte_DA [7] 	<= r_data_buffer [4] [0];
						end
				11'd1:	begin
							r_check_byte_DA [6] 	<= r_data_buffer [4] [0];
							rDA [13:8]					<= 	r_data_buffer [4] [5:0];
							//r_new_key_DA 		<= hash_14 (r_new_key_DA, o_rx_d4cd );
							counter 				<= counter - 11'b1;
						end
				11'd2:	begin
							r_check_byte_DA [5] 	<= r_data_buffer [4] [0];
							//r_new_key_DA 		<= hash_14 (r_new_key_DA, o_rx_d4cd );
							counter 				<= counter - 11'b1;
						end
				11'd3:	begin
							r_check_byte_DA [4] 	<= r_data_buffer [4] [0];
							//r_new_key_DA 		<= hash_14 (r_new_key_DA, o_rx_d4cd );
							counter 				<= counter - 11'b1;
						end
				11'd4:	begin
							r_check_byte_DA [3] 	<= r_data_buffer [4] [0];
							//r_new_key_DA 		<= hash_14 (r_new_key_DA, o_rx_d4cd );
							counter 				<= counter - 11'b1;
						end
				11'd5: begin
						r_fsm_state_changed 	<=0;
						counter 				<= counter - 11'b1;
						//r_new_key_DA 		<= hash_14 (r_new_key_DA, o_rx_d4cd );
						r_check_byte_DA [2:0] 	<= r_data_buffer [4] [2:0];
						end	
					endcase	
					end
				/*if (r_fsm_state_changed == 1) begin
					r_fsm_state_changed 	<=0;
					counter 				<= counter - 11'b1;
					r_new_key_DA 		<= hash_14 (r_new_key_DA, o_rx_d4cd );
					r_check_byte_DA [2:0] 	<= r_data_buffer [2:0] [4];
				end    
				else if (counter == 11'd0) begin
					r_state_reg 			<= r_state_next;
					r_fsm_state_changed 	<= 1;
					counter 				<= 11'd5;
					r_new_key_DA 		<= hash_14 (r_new_key_DA, o_rx_d4cd );
					r_NEW_DA_indicator     <= 1'b1;
					r_check_byte_DA [0] 	<= r_data_buffer[4];
				end    
				else begin
					counter 			<= counter - 11'b1;
					r_new_key_DA 		<= hash_14 (r_new_key_DA, o_rx_d4cd );
			end
			end*/
                (lpSA): begin           								// 6 clocks
					case (counter)									// from 5 to 0
				11'd0:	begin
							r_state_reg 			<= r_state_next;
							r_fsm_state_changed 	<= 1;
							counter 				<= 11'd1500;
							//r_new_key_SA 			<= hash_14 (r_new_key_SA, o_rx_d4cd );
							rSA [7:0] 				<= r_data_buffer [4] ;
							r_check_byte_SA [7] 	<= r_data_buffer [4] [0];
						end
				11'd1:	begin
							r_check_byte_SA [6] 	<= r_data_buffer [4] [0];
							rSA [13:8] 				<= r_data_buffer [4] [5:0] ;
							//r_new_key_SA 		<= hash_14 (r_new_key_SA, o_rx_d4cd ); 
							counter 				<= counter - 11'b1;
						end
				11'd2:	begin
							r_check_byte_SA [5] 	<= r_data_buffer [4] [0];
							//r_new_key_SA 		<= hash_14 (r_new_key_SA, o_rx_d4cd ); 							
							counter 				<= counter - 11'b1;
						end
				11'd3:	begin
							r_check_byte_SA [4] 	<= r_data_buffer [4] [0];	
							//r_new_key_SA 		<= hash_14 (r_new_key_SA, o_rx_d4cd ); 
							counter 				<= counter - 11'b1;
						end
				11'd4:	begin
							r_check_byte_SA [3] 	<= r_data_buffer [4] [0];
							//r_new_key_SA 		<= hash_14 (r_new_key_SA, o_rx_d4cd ); 
							counter 				<= counter - 11'b1;
						end
				11'd5: begin
						r_fsm_state_changed 	<=0;
						r_NEW_DA_indicator      <= 1'b1;
						counter 				<= counter - 11'b1;
						//r_new_key_SA 		<= hash_14 (r_new_key_SA, o_rx_d4cd ); 	
						r_check_byte_SA [2:0] 	<= r_data_buffer [4] [2:0];
						//rDA <= r_new_key_DA;
						//r_new_key_DA <= '1;
						end	
					endcase	
					end
				/*if (r_fsm_state_changed == 1) begin
					r_fsm_state_changed 	<=0;
					rDA <= r_new_key_DA;
					r_NEW_DA_indicator     <= 1'b1;
					r_new_key_DA <= '1;
					r_check_byte_DA[1] <= r_check_byte_DA [0];
					counter 				<= counter - 11'b1;
					r_new_key_SA 		<= hash_14 (r_new_key_SA, o_rx_d4cd );                                                               
				end 
				else if (counter == 11'd0) begin
					r_state_reg 			<= r_state_next;
					r_fsm_state_changed 	<= 1;

					r_new_key_SA 		<= hash_14 (r_new_key_SA, o_rx_d4cd );  
					r_check_byte_SA[0] 		<=r_data_buffer[4];
				end    
				else begin counter 		<= counter - 11'b1;
					r_new_key_SA 		<= hash_14 (r_new_key_SA, o_rx_d4cd );   
				end
			end*/
                (lpDATA): begin          
				if (r_fsm_state_changed == 1) begin
					r_fsm_state_changed 	<=0;
					r_NEW_SA_indicator	<=1;
					//rSA <= r_new_key_SA;
					counter 				<= counter - 11'b1;
				end 
				else if (counter == 11'd1499) begin
					counter 				<= counter - 11'b1;
					r_new_key_SA			<='1;
				end
				else if (counter == 11'd0) begin  // reset
					r_state_reg    		<= lpND;
					r_data_buffer  		<= 32'b0;
					r_rx_dv_buffer 		<= 5'b0;
					r_rx_er_buffer 		<= 5'b0;
				end  
				else counter 			<= counter - 11'b1;
                end
            endcase   
        end
        if (i_rx_dv && i_rx_er) begin   // reset
		r_state_reg    	<= lpND;
		r_data_buffer  	<= 32'b0;
		r_rx_dv_buffer 	<= 'b0;
		r_rx_er_buffer 	<= 'b0; 
        end
        if (!i_rx_dv && !i_rx_er) begin // CRC out and reset
		if (r_state_reg == lpDATA) begin 
			r_state_reg 			<= r_state_next;
			r_fsm_state_changed 	<= 1'b1;
		end
		else if(r_state_reg == lpCRC) begin
			if (r_fsm_state_changed == 1) begin
				r_fsm_state_changed 	<=0;
				counter 				<= 11'b000_0000_0010;
			end
		else if (counter == 11'd0) begin
			r_state_reg    	<= lpND;
			r_data_buffer  	<= 32'b0;
			r_rx_dv_buffer 	<= 5'b0;
			r_rx_er_buffer 	<= 5'b0;
		end
		else counter <= counter - 11'b1;
         end
         else begin
		r_state_reg    	<= lpND;
		r_data_buffer  	<= 32'b0;
		r_rx_dv_buffer 	<= 5'b0;
		r_rx_er_buffer 	<= 5'b0;
        end
        end

        // Shift inputs and data  
        for (i = 0; i < 4; i = i +1 ) begin
		r_data_buffer[i+1]  			<= r_data_buffer[i];
		r_rx_dv_buffer[i+1] 			<= r_rx_dv_buffer[i];
		if(toggle) r_rx_er_buffer[4] <= 1'b1;
		else r_rx_er_buffer[i+1] 	<= r_rx_er_buffer[i];    
        end
        r_data_buffer[0]  	<=    i_rx_d;
        r_rx_dv_buffer[0] 	<=    i_rx_dv;
        r_rx_er_buffer[0] 	<=    i_rx_er;
		
	if (i_DA_ok) begin									// Может быть оптимизированно
		r_NEW_DA_indicator <= 1'd0;
		r_DA_counter <= 6'd0;					
	end
	else 	if (r_NEW_DA_indicator) begin				//DA indicator control											
			r_DA_counter <= r_DA_counter +1;
			if (r_DA_counter == 6'd63)begin				// Можно убрать
				r_DA_counter <= 6'd0;
				r_NEW_DA_indicator <= 1'd0;
			end
		end
		if (r_NEW_SA_indicator) begin				//SA indicator control
			r_SA_counter <= r_SA_counter +1;
			if (r_SA_counter == 6'd63)begin
				r_SA_counter <= 6'd0;
				r_NEW_SA_indicator <= 1'd0;
			end
		end
	end
		
    
        // Combinational logic
        always @* begin
            case(r_state_reg)
                lpND:     	r_state_next <= lpPRE;
                lpPRE:     	r_state_next <= lpSFD;
                lpSFD:      	r_state_next <= lpDA;
                lpDA:       	r_state_next <= lpSA;
                lpSA:       	r_state_next <= lpDATA;
                lpDATA:     	r_state_next <= lpCRC;
                lpCRC:      	r_state_next <= lpND;
            endcase  
        end
        
        assign  o_rx_d4cd = r_data_buffer[4];
        assign  o_rx_er_4cd = (r_rx_er_buffer[4]|toggle);
        assign  o_rx_dv_4cd = r_rx_dv_buffer[4];
        assign  o_fsm_state = r_state_reg;

	reg [31:0] rcrc_new = 'b0;

    always @(posedge i_rx_clk) begin 
        case(r_state_reg) 
            lpPRE: toggle <= 1'b0;
            lpSFD: rcrc_new <= '1;
            lpDA, lpSA, lpDATA, lpCRC: rcrc_new <= eth_crc32_8d(rcrc_new, o_rx_d4cd);
            lpND: begin 
                if ((rcrc_new != 32'hC704DD7B )&(rcrc_new != 32'h0000_0000)) begin 
                    toggle <= 1'b1;
                end
            end    
        endcase    
    end

    // Showing SA to out                                                               
    always @(posedge i_rx_clk) begin                                                    
		if (r_NEW_SA_indicator==1) begin
			osa <= rSA;
			o_check_byte_SA<=r_check_byte_SA; 
			onewsa<=1;
		end
		else  onewsa<=0;
		if (r_NEW_DA_indicator ==1) begin
			oda 		<= rDA;
			o_check_byte_DA<=r_check_byte_DA; 
			onewda	<=1;
		end
		else onewda 	<= 0;
			
            end

endmodule
