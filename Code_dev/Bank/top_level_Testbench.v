// This is top level module for Quartus
//For successfull synthesis in MAC_table:
//1) USE_ALTSYNC should be = 1; 
`timescale 1ns/1ps
`include "header.v"

module top_level_TB;
       
	reg 									i_clk;
	reg 									i_clk_rx0;
	reg 									i_clk_rx1;
	reg 									i_clk_rx2;
	reg 									i_clk_rx3;

	reg 									i_RESET='0;
	
	// for frame receivers    
		reg                         			rrx_er0='0;
		reg                         			rrx_er1='0;
		reg                         			rrx_er2='0;
		reg                         			rrx_er3='0;

		//for pcap2GMII
		wire [7:0]                  		wgmii_data_0;
		wire                        			wgmii_rx_val_0;
		wire [7:0]                  		wgmii_data_1;
		wire                        			wgmii_rx_val_1;
		wire [7:0]                  		wgmii_data_2;
		wire                        			wgmii_rx_val_2;
		wire [7:0]                  		wgmii_data_3;
		wire                        			wgmii_rx_val_3;
		
	 
	wire         					o_rx_dv_0;     // GMII0
	wire          				o_rx_er_0;     // GMII0 
	wire [7:0]   				o_rx_d_0;      // GMII0

	wire         					o_rx_dv_1;     // GMII1
	wire          				o_rx_er_1;     // GMII1 
	wire [7:0]   				o_rx_d_1;      // GMII1

	wire         					o_rx_dv_2;     // GMII2
	wire          				o_rx_er_2;     // GMII2 
	wire [7:0]   				o_rx_d_2;     // GMII2

	wire         					o_rx_dv_3;     // GMII3
	wire          				o_rx_er_3;     // GMII3 
	wire [7:0]   				o_rx_d_3;      // GMII3

	
	/*pcap2gmii
    #(
        .pPCAP_FILENAME     ("Micran_network.pcap") 			
    ) 
        genpack_0
    (
        .iclk           			(i_clk_rx0),                     // CON
        .ipause         			(1'b0),
        .oval           			(wgmii_rx_val_0),             // CON
        .odata          			(wgmii_data_0),               // CON
        .opkt_cnt       			()
    );*/



		wire [7:0]                  		fifo_data_0;
		wire                        			fifo_rx_en_0;
		wire                        			fifo_rx_er_0;

		wire [$clog2(pPORT_WIDTH)-1:0]      		w_port_num_MAC [pPORT_WIDTH-1:0];
		wire [pPORT_WIDTH-1:0]					w_tr_e;
	
	
		fifo_rx fifo_rx_0
	
	(.i_clk_rx					(i_clk_rx0),
	 .i_clk_tx					(i_clk),
	 .ireset						(i_RESET),
	 .ien							(wgmii_rx_val_0),
	 .iw_data					(wgmii_data_0),
	 .o_error					(fifo_rx_er_0),
	 .o_en						(fifo_rx_en_0),
	 .or_data					(fifo_data_0)
	 );
	
	wire [2:0]   				w_fsm_state_0;
	wire         					w_rx_dv_4cd_0;
	wire         					w_rx_er_4cd_0;
	wire [7:0]   				w_rx_d4cd_0;
	wire [13:0]				w_DA_0;
	wire 					wnewDA_0;
	wire [7:0]				w_check_byte_DA_0;
	wire [13:0]				w_SA_0;
	wire 					wnewSA_0;
	wire [7:0]				w_check_byte_SA_0;
	
        Ethernet_rx_frame GMII0 
    (
	.i_rx_clk               			(i_clk),                     	
	.i_rx_dv                			(fifo_rx_en_0),	      
	.i_rx_er                			(fifo_rx_er_0),           	       
	.i_rx_d                 			(fifo_data_0), 
	.i_DA_ok							(w_tr_e[0]),   	       
	.o_fsm_state            		(w_fsm_state_0),  	       
	.o_rx_dv_4cd            		(w_rx_dv_4cd_0),
	.o_rx_er_4cd            		(w_rx_er_4cd_0),
	.o_rx_d4cd              			(w_rx_d4cd_0),
	.oda  					(w_DA_0),
	.onewda					(wnewDA_0),
	.o_check_byte_DA		(w_check_byte_DA_0),
	.osa                    				(w_SA_0),
	.onewsa                 			(wnewSA_0),
	.o_check_byte_SA          	(w_check_byte_SA_0)
    );
	
		pcap2gmii
    #(
        .pPCAP_FILENAME     ("test.pcap") 			
    ) 
        genpack_1
    (
        .iclk           			(i_clk_rx1),                     		
        .ipause         			(1'b0),
        .oval           			(wgmii_rx_val_1),       
        .odata          			(wgmii_data_1),            
        .opkt_cnt       			()
    );
	
	
		wire [7:0]                  		fifo_data_1;
		wire                        			fifo_rx_en_1;
		wire                        			fifo_rx_er_1;

	fifo_rx fifo_rx_1
	
	(.i_clk_rx					(i_clk_rx1),
	 .i_clk_tx					(i_clk),
	 .ireset						(i_RESET),
	 .ien							(wgmii_rx_val_1),
	 .iw_data					(wgmii_data_1),
	 .o_error					(fifo_rx_er_1),
	 .o_en						(fifo_rx_en_1),
	 .or_data					(fifo_data_1)
	 );
	
	wire [2:0]   				w_fsm_state_1;
	wire         				w_rx_dv_4cd_1;
	wire         				w_rx_er_4cd_1;
	wire [7:0]   				w_rx_d4cd_1;
	wire [13:0]				w_DA_1;
	wire 					wnewDA_1;
	wire [7:0]				w_check_byte_DA_1;
	wire [13:0]				w_SA_1;
	wire 					wnewSA_1;
	wire [7:0]				w_check_byte_SA_1;
	
	 Ethernet_rx_frame GMII1 
    (
	.i_rx_clk               			(i_clk),                     
	.i_rx_dv                			(fifo_rx_en_1),         
	.i_rx_er                			(fifo_rx_er_1),           	           
	.i_rx_d                 			(fifo_data_1),
	.i_DA_ok							(w_tr_e[1]),
	.o_fsm_state            		(w_fsm_state_1),  
	.o_rx_dv_4cd            		(w_rx_dv_4cd_1),
	.o_rx_er_4cd            		(w_rx_er_4cd_1),
	.o_rx_d4cd              			(w_rx_d4cd_1),
	.oda  					(w_DA_1),
	.onewda					(wnewDA_1),
	.o_check_byte_DA		(w_check_byte_DA_1),
        .osa                    				(w_SA_1),
        .onewsa                 			(wnewSA_1),
        .o_check_byte_SA          		(w_check_byte_SA_1)
    );
	
	pcap2gmii
    #(
        .pPCAP_FILENAME     ("wireless.pcap") 
    ) 
        genpack_2
    (
        .iclk           			(i_clk_rx2),                     		
        .ipause         			(1'b0),
        .oval           			(wgmii_rx_val_2),       
        .odata          			(wgmii_data_2),            
        .opkt_cnt       			()
    );
	
	wire [7:0]                  		fifo_data_2;
	wire                        			fifo_rx_en_2;
	wire                        			fifo_rx_er_2;

	fifo_rx fifo_rx_2
	
	(.i_clk_rx					(i_clk_rx2),
	 .i_clk_tx					(i_clk),
	 .ireset						(i_RESET),
	 .ien							(wgmii_rx_val_2),
	 .iw_data					(wgmii_data_2),
	 .o_error					(fifo_rx_er_2),
	 .o_en						(fifo_rx_en_2),
	 .or_data					(fifo_data_2)
	 );
	
	wire [2:0]   				w_fsm_state_2;
	wire         				w_rx_dv_4cd_2;
	wire         				w_rx_er_4cd_2;
	wire [7:0]   				w_rx_d4cd_2;
	wire [13:0]				w_DA_2;
	wire 					wnewDA_2;
	wire [7:0]				w_check_byte_DA_2;
	wire [13:0]				w_SA_2;
	wire 					wnewSA_2;
	wire [7:0]				w_check_byte_SA_2;
	
	 Ethernet_rx_frame GMII2 
    (
	.i_rx_clk               			(i_clk),                     
	.i_rx_dv                			(fifo_rx_en_2),           
	.i_rx_er                			(fifo_rx_er_2),           	                  
	.i_rx_d                 			(fifo_data_2), 
	.i_DA_ok							(w_tr_e[2]),              
	.o_fsm_state            		(w_fsm_state_2),         
	.o_rx_dv_4cd            		(w_rx_dv_4cd_2),
	.o_rx_er_4cd            		(w_rx_er_4cd_2),
	.o_rx_d4cd              			(w_rx_d4cd_2),
	.oda  					(w_DA_2),
	.onewda					(wnewDA_2),
	.o_check_byte_DA		(w_check_byte_DA_2),
        .osa                    				(w_SA_2),
        .onewsa                 			(wnewSA_2),
        .o_check_byte_SA          		(w_check_byte_SA_2)
    );
	
	pcap2gmii
    #(
        .pPCAP_FILENAME     ("from_Egor_2.pcap") 
    ) 
        genpack_3
    (
        .iclk           			(i_clk_rx3),                    			
        .ipause         			(1'b0),
        .oval           			(wgmii_rx_val_3),             	
        .odata          			(wgmii_data_3),               	
        .opkt_cnt       			()
    );
	
		wire [7:0]                  		fifo_data_3;
		wire                        			fifo_rx_en_3;
		wire                        			fifo_rx_er_3;
	
	fifo_rx fifo_rx_3
	
	(.i_clk_rx					(i_clk_rx3),
	 .i_clk_tx					(i_clk),
	 .ireset						(i_RESET),
	 .ien							(wgmii_rx_val_3),
	 .iw_data					(wgmii_data_3),
	 .o_error					(fifo_rx_er_3),
	 .o_en						(fifo_rx_en_3),
	 .or_data					(fifo_data_3)
	 );
	
	wire [2:0]   				w_fsm_state_3;
	wire         				w_rx_dv_4cd_3;
	wire         				w_rx_er_4cd_3;
	wire [7:0]   				w_rx_d4cd_3;
	wire [13:0]				w_DA_3;
	wire 					wnewDA_3;
	wire [7:0]				w_check_byte_DA_3;
	wire [13:0]				w_SA_3;
	wire 					wnewSA_3;
	wire [7:0]				w_check_byte_SA_3;
	
	 Ethernet_rx_frame GMII3
    (
	.i_rx_clk               			(i_clk),                     	
	.i_rx_dv                			(fifo_rx_en_3), 	  
	.i_rx_er                			(fifo_rx_er_3),           	   	       
	.i_rx_d                 			(fifo_data_3),
	.i_DA_ok							(w_tr_e[3]),     	 
	.o_fsm_state            		(w_fsm_state_3),  	       
	.o_rx_dv_4cd            		(w_rx_dv_4cd_3),
	.o_rx_er_4cd            		(w_rx_er_4cd_3),
	.o_rx_d4cd              			(w_rx_d4cd_3),
	.oda  					(w_DA_3),
	.onewda					(wnewDA_3),
	.o_check_byte_DA		(w_check_byte_DA_3),
        .osa                    				(w_SA_3),
        .onewsa                 			(wnewSA_3),
        .o_check_byte_SA          		(w_check_byte_SA_3)
    );
	
	wire [$clog2(pPORT_WIDTH)-1:0]                        		wport_num;
	wire                                                					wwr_en;
	wire[pMAC_MEM_DEPTH_W-1:0]					w_MAC_SA;
	wire[pMAC_MEM_DEPTH_W-1:0]					w_MAC_DA;
	wire [pDATA_WIDTH-1:0]						w_check_byte_out_SA;
	wire [pDATA_WIDTH-1:0]						w_check_byte_out_DA;
	wire 										w_read_en;
	wire 										w_decrement;

    MAC_arbiter sa_arbiter
    (
	.iclk                   		(i_clk),             
	.i_newSA_and_DA           ({wnewDA_3,wnewDA_2,wnewDA_1,wnewDA_0,wnewSA_3,wnewDA_2,wnewDA_1, wnewSA_0}),
	.i_SA_and_DA		({w_DA_3,w_DA_2,w_DA_1,w_DA_0,w_SA_3,w_SA_2,w_SA_1, w_SA_0}),
	.i_check_byte        	({w_check_byte_DA_3,w_check_byte_DA_2,w_check_byte_DA_1,w_check_byte_DA_0,w_check_byte_SA_3,w_check_byte_SA_2,w_check_byte_SA_1,w_check_byte_SA_0}),
	.o_port_num             	(wport_num),
	.o_MAC_SA              		(w_MAC_SA),
	.o_MAC_DA              		(w_MAC_DA),
	.o_check_byte_SA	(w_check_byte_out_SA),
	.o_check_byte_DA	(w_check_byte_out_DA),
	.o_write_en           		(wwr_en),
	.o_read_en			(w_read_en),
	.o_decrement		(w_decrement)
    );

	
       MAC_table 	MAC_table
    (
        .iclk                   		(i_clk),
        .i_write_enable        	(wwr_en),
        .i_port_num             		(wport_num),
        .i_MAC_SA	            	(w_MAC_SA),
        .i_read_enable          	(w_read_en),
        .i_MAC_DA              		(w_MAC_DA),
        .i_check_byte_DA        	(w_check_byte_out_DA),
        .i_check_byte_SA           	(w_check_byte_out_SA),
        .i_decrement			(w_decrement),
        .o_port_num_MAC      	(w_port_num_MAC),
	.o_tr_e				(w_tr_e)
    );
	
	wire [2:0][31:0]								w_32_bit_data_0;
	wire [2:0]									w_valid_0;
	wire [2:0]									w_delete_0;
	wire [2:0][1:0] 								w_extra_bytes_0;
	wire [2:0][1:0]								w_info_bits_0;
	
	transform_0 block_0
	(	.i_clk               		(i_clk),                     	
		.i_rx_dv                		(w_rx_dv_4cd_0),             
		.i_rx_er                		(w_rx_er_4cd_0),                  
		.i_rx_d                 		(w_rx_d4cd_0),               
		.i_fsm_state            	(w_fsm_state_0),  
		.i_port_num			(w_port_num_MAC[0]),
		.i_tr_e				(w_tr_e[0]),
		.o_32_bit_data		(w_32_bit_data_0),
		.o_valid			(w_valid_0),
		.o_delete			(w_delete_0),
		.o_extra_bytes		(w_extra_bytes_0),
		.o_info_bits		(w_info_bits_0)
	);
	
	wire [2:0][31:0]								w_32_bit_data_1;
	wire [2:0]									w_valid_1;
	wire [2:0]									w_delete_1;
	wire [2:0][1:0] 								w_extra_bytes_1;
	wire [2:0][1:0]								w_info_bits_1;
	
	transform_1 block_1
	(	.i_clk               		(i_clk),                     	
		.i_rx_dv                		(w_rx_dv_4cd_1),             
		.i_rx_er                		(w_rx_er_4cd_1),                  
		.i_rx_d                 		(w_rx_d4cd_1),               
		.i_fsm_state            	(w_fsm_state_1),  
		.i_port_num			(w_port_num_MAC[1]),
		.i_tr_e				(w_tr_e[1]),
		.o_32_bit_data		(w_32_bit_data_1),
		.o_valid			(w_valid_1),
		.o_delete			(w_delete_1),
		.o_extra_bytes		(w_extra_bytes_1),
		.o_info_bits		(w_info_bits_1)
	);
	
	wire [2:0][31:0]								w_32_bit_data_2;
	wire [2:0]									w_valid_2;
	wire [2:0]									w_delete_2;
	wire [2:0][1:0] 								w_extra_bytes_2;
	wire [2:0][1:0]								w_info_bits_2;
	
	transform_2 block_2
	(	.i_clk               		(i_clk),                     	
		.i_rx_dv                		(w_rx_dv_4cd_2),             
		.i_rx_er                		(w_rx_er_4cd_2),                  
		.i_rx_d                 		(w_rx_d4cd_2),               
		.i_fsm_state            	(w_fsm_state_2),  
		.i_port_num			(w_port_num_MAC[2]),
		.i_tr_e				(w_tr_e[2]),
		.o_32_bit_data		(w_32_bit_data_2),
		.o_valid			(w_valid_2),
		.o_delete			(w_delete_2),
		.o_extra_bytes		(w_extra_bytes_2),
		.o_info_bits		(w_info_bits_2)
	);
	
	wire [2:0][31:0]								w_32_bit_data_3;
	wire [2:0]									w_valid_3;
	wire [2:0]									w_delete_3;
	wire [2:0][1:0] 								w_extra_bytes_3;
	wire [2:0][1:0]								w_info_bits_3;
	
	
	transform_3 block_3
	(	.i_clk               		(i_clk),                     	
		.i_rx_dv                		(w_rx_dv_4cd_3),             
		.i_rx_er                		(w_rx_er_4cd_3),                  
		.i_rx_d                 		(w_rx_d4cd_3),               
		.i_fsm_state            	(w_fsm_state_3),  
		.i_port_num			(w_port_num_MAC[3]),
		.i_tr_e				(w_tr_e[3]),
		.o_32_bit_data		(w_32_bit_data_3),
		.o_valid			(w_valid_3),
		.o_delete			(w_delete_3),
		.o_extra_bytes		(w_extra_bytes_3),
		.o_info_bits		(w_info_bits_3)
	);
	
	wire [31:0]					w_data_exit_0;
	wire 						w_en_mem_0;
	wire [1:0]					w_port_num_exit_0;
	wire [1:0]					w_extra_byte_mem_0;
	wire [1:0]					w_info_port_mem_0;
	
	
	
	MEM_arbitres_port1	 		for_memory_0
		
	(	.i_clk               						(i_clk),                     	
		.i_reset							(i_RESET),
		.i_en_port 							({w_valid_3[0],w_valid_2[0],w_valid_1[0]}),
		.i_data_port1						(w_32_bit_data_1[0]),
		.i_data_port2						(w_32_bit_data_2[0]),
		.i_data_port3						(w_32_bit_data_3[0]),
		.i_info_port1       					(w_info_bits_1[0]),
		.i_info_port2       					(w_info_bits_2[0]),
		.i_info_port3       					(w_info_bits_3[0]),
		.i_extra_byte1      					(w_extra_bytes_1[0]),
		.i_extra_byte2      					(w_extra_bytes_2[0]),
		.i_extra_byte3      					(w_extra_bytes_3[0]),
		.o_data								(w_data_exit_0), 
		.o_port_num							(w_port_num_exit_0),
		.o_en_mem							(w_en_mem_0),
		.o_info_port      		  				(w_info_port_mem_0),
		.o_extra_byte		      				(w_extra_byte_mem_0)

	);
	
	wire [31:0]										o_out_mem_data_0;
	 wire							  				en_FIFO0;
	 wire[2*$clog2(pDEPTH_RAM)+1:0]					data_FIFO0;
	 wire											empty_FIFO0;
	 wire											full_FIFO0;
	 wire[2*$clog2(pDEPTH_RAM)+1:0]					out_FIFO0;
	 
	  wire								w_FIFO_0_read;
	 wire								w_RAM_0_read;
	 wire [7:0]							w_TX_data_0;
	 wire [12:0]							w_RAM_0_adress;
	 wire								w_TX_DV_0;
	 wire								w_TX_finish_0;
	 wire [1:0]							w_state_0;
	
	
		MEM0                     MEM0

    (  			 .i_clk              				(i_clk),
			.i_reset          				 (i_RESET),
			.i_del              				({w_delete_3[0],w_delete_2[0],w_delete_1[0]}),
			.i_data       		 			(w_data_exit_0),
			.i_port_num         				(w_port_num_exit_0),
			.i_adr_out			 		(w_RAM_0_adress),
			.i_en_read					(w_RAM_0_read),
			.i_en_mem           				(w_en_mem_0),
			.i_info_port        				(w_info_port_mem_0),
			.i_extra_byte       			(w_extra_byte_mem_0),
			.o_data             				(o_out_mem_data_0),
			.o_FIFO             				(data_FIFO0),
			.o_en_FIFO          				(en_FIFO0)
    );
	 
	 fifo							  
		#	(.pBITS			(pFIFO_WIDTH),
			.pWIDTH			(pFIFO_DEPTH)
		)
	 
	 FIFO0
	 
	 (		.iclk						(i_clk),
			.ireset						(i_RESET),
			.ird						(w_FIFO_0_read),
			.iwr						(en_FIFO0),
			.iw_data					(data_FIFO0),
			.oempty						(empty_FIFO0),
			.ofull						(full_FIFO0),
			.or_data					(out_FIFO0)
	 );
	
	 
	 
	 word_to_byte						to8_0
	 
(			.i_clk						(i_clk),
			.i_word						(o_out_mem_data_0),
			.i_adress					(out_FIFO0),			
			.i_FIFO_empty				(empty_FIFO0),
			.o_byte						(w_TX_data_0),
			.o_FIFO_read				(w_FIFO_0_read),
			.o_RAM_read					(w_RAM_0_read),				
			.o_read_adress				(w_RAM_0_adress),
			.o_TX_data_valid			(w_TX_DV_0),
			.o_TX_finish				(w_TX_finish_0),
			.o_state					(w_state_0)
);

 TX 									TX_0
 
(			.i_clk						(i_clk),
			.i_TX_data_valid			(w_TX_DV_0),
			.i_TX_finish				(w_TX_finish_0),
			.i_data_TX					(w_TX_data_0),
			.i_state					(w_state_0),
			.o_dv_TX					(o_rx_dv_0),
			.o_er_TX					(o_rx_er_0),
			.o_data_TX					(o_rx_d_0)
		);
	 
	wire [31:0]								w_data_exit_1;
	wire 									w_en_mem_1;
	wire [1:0]								w_port_num_exit_1;
	wire [1:0]								w_extra_byte_mem_1;
	wire [1:0]								w_info_port_mem_1;
	 
	 MEM_arbitres_port2	 					for_memory_1
		
	(	.i_clk               							(i_clk),                     	
		.i_reset								(i_RESET),
		.i_en_port 								({w_valid_3[1],w_valid_2[1],w_valid_0[0]}),
		.i_data_port1							(w_32_bit_data_0[0]),
		.i_data_port2							(w_32_bit_data_2[1]),
		.i_data_port3							(w_32_bit_data_3[1]),
		.i_info_port1       						(w_info_bits_0[0]),
		.i_info_port2       						(w_info_bits_2[1]),
		.i_info_port3       						(w_info_bits_3[1]),
		.i_extra_byte1      						(w_extra_bytes_0[0]),
		.i_extra_byte2      						(w_extra_bytes_2[1]),
		.i_extra_byte3      						(w_extra_bytes_3[1]),
		.o_data									(w_data_exit_1), 
		.o_port_num								(w_port_num_exit_1),
		.o_en_mem								(w_en_mem_1),
		.o_info_port      		  					(w_info_port_mem_1),
		.o_extra_byte		      					(w_extra_byte_mem_1)

	);
	
	 wire [31:0]										o_out_mem_data_1;
	 wire							  				en_FIFO1;
	 wire[2*$clog2(pDEPTH_RAM)+1:0]					data_FIFO1;
	 wire											empty_FIFO1;
	 wire											full_FIFO1;
	 wire[2*$clog2(pDEPTH_RAM)+1:0]					out_FIFO1;
	 
	 wire								w_FIFO_1_read;
	 wire								w_RAM_1_read;
	 wire [7:0]							w_TX_data_1;
	 wire [12:0]							w_RAM_1_adress;
	 wire								w_TX_DV_1;
	 wire								w_TX_finish_1;
	 wire [1:0]							w_state_1;
	 
    MEM1                				     MEM1

    (   .i_clk          					    (i_clk),
        .i_reset         					   (i_RESET),
        .i_del           					   ({w_delete_3[1],w_delete_2[1],w_delete_0[0]}),
        .i_data       				             (w_data_exit_1),
        .i_port_num      				   (w_port_num_exit_1),
	.i_adr_out					  (w_RAM_1_adress),
	.i_en_read					(w_RAM_1_read),
        .i_en_mem         				  (w_en_mem_1),
        .i_info_port 					  ( w_info_port_mem_1),
        .i_extra_byte  				    (w_extra_byte_mem_1),
        .o_data       					      (o_out_mem_data_1),
        .o_FIFO      					      (data_FIFO1),
        .o_en_FIFO    					      (en_FIFO1)
    );

	 
	 fifo							  
								  
	#(	.pBITS			(pFIFO_WIDTH),
		.pWIDTH			(pFIFO_DEPTH)
		)
	 
	 FIFO1
	 
	 (		.iclk						(i_clk),
			.ireset						(i_RESET),
			.ird						(w_FIFO_1_read),
			.iwr						(en_FIFO1),
			.iw_data					(data_FIFO1),
			.oempty						(empty_FIFO1),
			.ofull						(full_FIFO1),
			.or_data					(out_FIFO1)
	 );
	 
	 
	 word_to_byte						to8_1
	 
(			.i_clk						(i_clk),
			.i_word						(o_out_mem_data_1),
			.i_adress					(out_FIFO1),			
			.i_FIFO_empty				(empty_FIFO1),
			.o_byte						(w_TX_data_1),
			.o_FIFO_read				(w_FIFO_1_read),
			.o_RAM_read					(w_RAM_1_read),				//Useless pin
			.o_read_adress				(w_RAM_1_adress),
			.o_TX_data_valid			(w_TX_DV_1),
			.o_TX_finish				(w_TX_finish_1),
			.o_state					(w_state_1)
);

 TX 									TX_1
 
(			.i_clk						(i_clk),
			.i_TX_data_valid			(w_TX_DV_1),
			.i_TX_finish				(w_TX_finish_1),
			.i_data_TX					(w_TX_data_1),
			.i_state					(w_state_1),
			.o_dv_TX					(o_rx_dv_1),
			.o_er_TX					(o_rx_er_1),
			.o_data_TX					(o_rx_d_1)
		);
	 
	wire [31:0]					w_data_exit_2;
	wire 						w_en_mem_2;
	wire [1:0]					w_port_num_exit_2;
	wire [1:0]					w_extra_byte_mem_2;
	wire [1:0]					w_info_port_mem_2;
	 
	  MEM_arbitres_port3	 		for_memory_2
		
	(	.i_clk               						(i_clk),                     	
		.i_reset							(i_RESET),
		.i_en_port 							({w_valid_3[2],w_valid_1[1],w_valid_0[1]}),
		.i_data_port1						(w_32_bit_data_0[1]),
		.i_data_port2						(w_32_bit_data_1[1]),
		.i_data_port3						(w_32_bit_data_3[2]),
		.i_info_port1       					(w_info_bits_0[1]),
		.i_info_port2       					(w_info_bits_1[1]),
		.i_info_port3       					(w_info_bits_3[2]),
		.i_extra_byte1      					(w_extra_bytes_0[1]),
		.i_extra_byte2      					(w_extra_bytes_1[1]),
		.i_extra_byte3      					(w_extra_bytes_3[1]),
		.o_data								(w_data_exit_2), 
		.o_port_num							(w_port_num_exit_2),
		.o_en_mem							(w_en_mem_2),
		.o_info_port      					  	(w_info_port_mem_2),
		.o_extra_byte			     		 	(w_extra_byte_mem_2)

	);
	
	wire [31:0]										o_out_mem_data_2;
	 wire							  				en_FIFO2;
	 wire[2*$clog2(pDEPTH_RAM)+1:0]					data_FIFO2;
	 wire											empty_FIFO2;
	 wire											full_FIFO2;
	 wire[2*$clog2(pDEPTH_RAM)+1:0]					out_FIFO2;
	 
	 	
	 wire								w_FIFO_2_read;
	 wire								w_RAM_2_read;
	 wire [7:0]							w_TX_data_2;
	 wire [12:0]							w_RAM_2_adress;
	 wire								w_TX_DV_2;
	 wire								w_TX_finish_2;
	 wire [1:0]							w_state_2;
	 
    MEM2                     						MEM2

    (   .i_clk           							(i_clk),
        .i_reset								(i_RESET),
        .i_del								({w_delete_3[2],w_delete_1[1],w_delete_0[1]}),
        .i_data								(w_data_exit_2),
        .i_port_num 							(w_port_num_exit_2),
		.i_adr_out							(w_RAM_2_adress),
	.i_en_read							(w_RAM_2_read),
        .i_en_mem 							(w_en_mem_2),
        .i_info_port							(w_info_port_mem_2),
        .i_extra_byte						(w_extra_byte_mem_2),
        .o_data								(o_out_mem_data_2),
        .o_FIFO								(data_FIFO2),
        .o_en_FIFO							(en_FIFO2)
    );
	
	 
	 fifo					
	 
	 #	(.pBITS			(pFIFO_WIDTH),
			.pWIDTH			(pFIFO_DEPTH)
		)
	 
	 FIFO2
	 
	 (		.iclk						(i_clk),
			.ireset						(i_RESET),
			.ird						(w_FIFO_2_read),
			.iwr						(en_FIFO2),
			.iw_data					(data_FIFO2),
			.oempty						(empty_FIFO2),
			.ofull						(full_FIFO2),
			.or_data					(out_FIFO2)
	 );	 
	 
	 word_to_byte						to8_2
	 
(			.i_clk						(i_clk),
			.i_word						(o_out_mem_data_2),
			.i_adress					(out_FIFO2),			
			.i_FIFO_empty				(empty_FIFO2),
			.o_byte						(w_TX_data_2),
			.o_FIFO_read				(w_FIFO_2_read),
			.o_RAM_read					(w_RAM_2_read),				//Useless pin
			.o_read_adress				(w_RAM_2_adress),
			.o_TX_data_valid			(w_TX_DV_2),
			.o_TX_finish				(w_TX_finish_2),
			.o_state					(w_state_2)
);

 TX 									TX_2
 
(			.i_clk						(i_clk),
			.i_TX_data_valid			(w_TX_DV_2),
			.i_TX_finish				(w_TX_finish_2),
			.i_data_TX					(w_TX_data_2),
			.i_state					(w_state_2),
			.o_dv_TX					(o_rx_dv_2),
			.o_er_TX					(o_rx_er_2),
			.o_data_TX					(o_rx_d_2)
		);
	 
	wire [31:0]					w_data_exit_3;
	wire 						w_en_mem_3;
	wire [1:0]					w_port_num_exit_3;
	wire [1:0]					w_extra_byte_mem_3;
	wire [1:0]					w_info_port_mem_3;
	 
	  MEM_arbitres	 		for_memory_3
		
	(	.i_clk               						(i_clk),                     	
		.i_reset							(i_RESET),
		.i_en_port 							({w_valid_2[2],w_valid_1[2],w_valid_0[2]}),
		.i_data_port1						(w_32_bit_data_0[2]),
		.i_data_port2						(w_32_bit_data_1[2]),
		.i_data_port3						(w_32_bit_data_2[2]),
		.i_info_port1       					(w_info_bits_0[2]),
		.i_info_port2       					(w_info_bits_1[2]),
		.i_info_port3       					(w_info_bits_2[2]),
		.i_extra_byte1      					(w_extra_bytes_0[2]),
		.i_extra_byte2      					(w_extra_bytes_1[2]),
		.i_extra_byte3      					(w_extra_bytes_2[2]),
		.o_data								(w_data_exit_3), 
		.o_port_num							(w_port_num_exit_3),
		.o_en_mem							(w_en_mem_3),
		.o_info_port      		  				(w_info_port_mem_3),
		.o_extra_byte		      				(w_extra_byte_mem_3)

	);
	
	 wire [31:0]										o_out_mem_data_3;
	 wire							  				en_FIFO3;
	 wire[2*$clog2(pDEPTH_RAM)+1:0]					data_FIFO3;
	 wire											empty_FIFO3;
	 wire											full_FIFO3;
	 wire[2*$clog2(pDEPTH_RAM)+1:0]					out_FIFO3;
	 
	 wire								w_FIFO_3_read;
	 wire								w_RAM_3_read;
	 wire [7:0]							w_TX_data_3;
	 wire [12:0]							w_RAM_3_adress;
	 wire								w_TX_DV_3;
	 wire								w_TX_finish_3;
	 wire [1:0]							w_state_3;
	 
    MEM3                     						MEM3

    (   .i_clk           							(i_clk),
        .i_reset								(i_RESET),
        .i_del								({w_delete_2[2],w_delete_1[2],w_delete_0[2]}),
        .i_data								(w_data_exit_3),
        .i_port_num 							(w_port_num_exit_3),
	.i_adr_out							(w_RAM_3_adress),
	.i_en_read							(w_RAM_3_read),
        .i_en_mem 							(w_en_mem_3),
        .i_info_port							(w_info_port_mem_3),
        .i_extra_byte						(w_extra_byte_mem_3),
        .o_data								(o_out_mem_data_3),
        .o_FIFO								(data_FIFO3),
        .o_en_FIFO							(en_FIFO3)
    );
	 	 
	 fifo							  	
	 	 
	 #	(.pBITS			(pFIFO_WIDTH),
			.pWIDTH			(pFIFO_DEPTH)
		)
	 
	 
	 FIFO4
	 
	 (		.iclk						(i_clk),
			.ireset						(i_RESET),
			.ird						(w_FIFO_3_read),
			.iwr						(en_FIFO3),
			.iw_data					(data_FIFO3),
			.oempty						(empty_FIFO3),
			.ofull						(full_FIFO3),
			.or_data					(out_FIFO3)
	 ); 
	 
	 word_to_byte						to8_3
	 
(			.i_clk						(i_clk),
			.i_word						(o_out_mem_data_3),
			.i_adress					(out_FIFO3),			
			.i_FIFO_empty				(empty_FIFO3),
			.o_byte						(w_TX_data_3),
			.o_FIFO_read				(w_FIFO_3_read),
			.o_RAM_read					(w_RAM_3_read),				//Useless pin
			.o_read_adress				(w_RAM_3_adress),
			.o_TX_data_valid			(w_TX_DV_3),
			.o_TX_finish				(w_TX_finish_3),
			.o_state					(w_state_3)
);

 TX 									TX_3
 
(			.i_clk						(i_clk),
			.i_TX_data_valid			(w_TX_DV_3),
			.i_TX_finish				(w_TX_finish_3),
			.i_data_TX					(w_TX_data_3),
			.i_state					(w_state_3),
			.o_dv_TX					(o_rx_dv_3),
			.o_er_TX					(o_rx_er_3),
			.o_data_TX					(o_rx_d_3)
		);
	
	always 
    begin
#4        i_clk = ~i_clk;
    end

	always 
    begin
#3.999        i_clk_rx0 = ~i_clk_rx0;
    end

		always 
    begin
#4.002        i_clk_rx1 = ~i_clk_rx1;
    end

	always 
    begin
#4.004        i_clk_rx2 = ~i_clk_rx2;
    end

	always 
    begin
#3.998        i_clk_rx3 = ~i_clk_rx3;
    end

    initial
    begin
       i_clk = 0;
	   i_clk_rx0 =0;
	   i_clk_rx1 =0;
	   i_clk_rx2 =0;
	   i_clk_rx3 =0;
	   /*iRESET = 1;
	   #4
	   iRESET = 0;*/
    end
endmodule
