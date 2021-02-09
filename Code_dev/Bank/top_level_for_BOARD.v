// Это модуль верхнего уровня в проекте
// Он разработан для платы модуля доступа МД1-1РУ
// Так как тестирование и отладка коммутатора проводилась на данной плате


`timescale 1ns/1ns

`include "header.v"

// Это назначение пинам ПЛИС нужный функций
module top_level_for_BOARD
       (
	(* chip_pin = "g4", altera_attribute = "-name io_standard LVDS" *)   input wire          				i_clk,   
	
	//(* chip_pin = "v4", altera_attribute = "-name io_standard LVDS" *)   input wire          				iclk_125,
	
	(* chip_pin = "n2", altera_attribute = "-name io_standard \"1.5-V PCML\"" *)	output		SFP_TX_port2,	
	(* chip_pin = "r2", altera_attribute = "-name io_standard \"1.5-V PCML\"" *)	input		SFP_RX_port2,
	//(* chip_pin = "j2", altera_attribute = "-name io_standard \"1.5-V PCML\"" *)	output		SFP_TX_port3,
	//(* chip_pin = "l2", altera_attribute = "-name io_standard \"1.5-V PCML\"" *)	input		SFP_RX_port3,
	(* chip_pin = "u2", altera_attribute = "-name io_standard \"1.5-V PCML\"" *)	output		SFP_TX_port3,
	(* chip_pin = "w2", altera_attribute = "-name io_standard \"1.5-V PCML\"" *)	input		SFP_RX_port3,
	
	
	(* chip_pin = "h13"*)			input	iRX_CLK_0,						// GMII0
	(* chip_pin = "f12"*)			input       i_rx_dv_0,     
	(* chip_pin = "b12"*) 		input 	i_rx_d_0_0,
         (* chip_pin = "d12"*)			input 	i_rx_d_0_1,
         (* chip_pin = "e12"*)			input 	i_rx_d_0_2,
         (* chip_pin = "h11"*)			input 	i_rx_d_0_3,
	(* chip_pin = "j11"*) 		input 	i_rx_d_0_4,
	(* chip_pin = "h10"*) 		input 	i_rx_d_0_5,
	(* chip_pin = "g11"*)			input	i_rx_d_0_6,
	(* chip_pin = "g12"*) 		input	i_rx_d_0_7,
	
	
	(* chip_pin = "g13"*)			input		iRX_CLK_1,					// GMII1
	(* chip_pin = "a19"*)			input		i_rx_dv_1,     	
	(* chip_pin = "c19"*)			input		i_rx_d_1_0,
	(* chip_pin = "c16"*)			input		i_rx_d_1_1,
	(* chip_pin = "c18"*)			input		i_rx_d_1_2,
	(* chip_pin = "d17"*)			input		i_rx_d_1_3,
	(* chip_pin = "f18"*)			input		i_rx_d_1_4,
	(* chip_pin = "a18"*)			input		i_rx_d_1_5,
	(* chip_pin = "a17"*)			input		i_rx_d_1_6,
	(* chip_pin = "b16"*)			input		i_rx_d_1_7,
	
		
	(* chip_pin = "b13"*)	output         	o_rx_dv_0,    			 // GMII0
	(* chip_pin = "a13"*)	output		o_rx_d_0_0,				// GMII0
	(* chip_pin = "d13"*)	output		o_rx_d_0_1,
	(* chip_pin = "e14"*)	output		o_rx_d_0_2,
	(* chip_pin = "a14"*)	output		o_rx_d_0_3,
	(* chip_pin = "a15"*)	output		o_rx_d_0_4,
	(* chip_pin = "g17"*)	output		o_rx_d_0_5,
	(* chip_pin = "e15"*)	output		o_rx_d_0_6,
	(* chip_pin = "f15"*)	output		o_rx_d_0_7,
	(* chip_pin = "a12"*)	output 		o_clk_0,

	(* chip_pin = "a20"*)	output 		o_rx_dv_1,     	// GMII1
	(* chip_pin = "b20"*)	output		o_rx_d_1_0,		
	(* chip_pin = "c20"*)	output		o_rx_d_1_1,
	(* chip_pin = "b21"*)	output		o_rx_d_1_2,	//
	(* chip_pin = "d19"*)	output		o_rx_d_1_3,	//
	(* chip_pin = "a22"*)	output		o_rx_d_1_4,	//
	(* chip_pin = "b22"*)	output		o_rx_d_1_5,	//
	(* chip_pin = "c21"*)	output		o_rx_d_1_6,	//
	(* chip_pin = "e19"*)	output		o_rx_d_1_7,	//
	(* chip_pin = "f19"*)	output		o_clk_1
	
	
	/*output wire         				o_rx_dv_2,     // GMII2
	output wire          				o_rx_er_2,     // GMII2 
	output wire [7:0]   			o_rx_d_2,      // GMII2

	output wire         				o_rx_dv_3,     // GMII3
	output wire          				o_rx_er_3,     // GMII3 
	output wire [7:0]   			o_rx_d_3      // GMII3*/
 );	
 
 reg								i_RESET;

 wire 							w_clk_out_2;
 wire [7:0]						w_out_data_2;
 wire							w_out_DV_2;
 
 wire 							w_clk_out_3;
 wire [7:0]						w_out_data_3;
 wire							w_out_DV_3;
 
 reg reset;
initial begin
 reset = 1'b1;
 i_RESET = 1'b0;
 #100000 reset = 1'b0;
 end

 
 wire pll_625;
wire pll_12m5;
wire pll_312m5;
wire pll_locked;

// Настройка pll умножителя частот
pll625 pll625_
(
    .refclk   (i_clk ),//  refclk.clk
    .rst      (reset   ),//   reset.reset
    .outclk_0 (pll_625 ),// outclk0.clk
	 //.outclk_1 (pll_312m5),//pll_12m5 ),// outclk0.clk
	 //.outclk_2 (pll_12m5 ),// outclk0.clk
    .locked   (pll_locked) //  locked.export
);

// Порты 0 и 1 подключеются через PHY трансиверы
// Для этого использовалась IP-ядро от Altera

//------------------------------------------------------------------------------
// NATIVE PHY TRANCEIVER
//------------------------------------------------------------------------------
wire[7:0] tbi_rx_data [1:0];
wire      tbi_rx_ctrl [1:0];
wire      tbi_rx_clk  [1:0];
reg [7:0] tbi_tx_data [1:0];
reg       tbi_tx_ctrl [1:0];
wire      tbi_tx_clk  [1:0];
//
wire [1:0] pll_powerdown     ;//      pll_powerdown.pll_powerdown//!!!!		[0:0] pll_powerdown
wire [1:0] tx_analogreset    ;//     tx_analogreset.tx_analogreset
wire [1:0] tx_digitalreset   ;//    tx_digitalreset.tx_digitalreset
//wire [0:0] pll_locked        ;//         pll_locked.pll_locked
wire [1:0] tx_cal_busy       ;//        tx_cal_busy.tx_cal_busy
wire [1:0] rx_analogreset    ;//     rx_analogreset.rx_analogreset
wire [1:0] rx_digitalreset   ;//    rx_digitalreset.rx_digitalreset
wire [1:0] rx_cal_busy       ;//        rx_cal_busy.rx_cal_busy
//

native_phy native_phy_(
		//input  wire [3:0]   pll_powerdown,           //           pll_powerdown.pll_powerdown
		//input  wire [3:0]   tx_analogreset,          //          tx_analogreset.tx_analogreset
		//input  wire [3:0]   tx_digitalreset,         //         tx_digitalreset.tx_digitalreset
		//input  wire [3:0]   ext_pll_clk,             //             ext_pll_clk.ext_pll_clk
		//input  wire [0:0]   tx_pll_refclk,           //           tx_pll_refclk.tx_pll_refclk
		//output wire [3:0]   tx_serial_data,          //          tx_serial_data.tx_serial_data
		//output wire [3:0]   pll_locked,              //              pll_locked.pll_locked
		//input  wire [3:0]   rx_analogreset,          //          rx_analogreset.rx_analogreset
		//input  wire [3:0]   rx_digitalreset,         //         rx_digitalreset.rx_digitalreset
		//input  wire [0:0]   rx_cdr_refclk,           //           rx_cdr_refclk.rx_cdr_refclk
		//input  wire [3:0]   rx_serial_data,          //          rx_serial_data.rx_serial_data
		//input  wire [3:0]   tx_std_coreclkin,        //        tx_std_coreclkin.tx_std_coreclkin
		//input  wire [3:0]   rx_std_coreclkin,        //        rx_std_coreclkin.rx_std_coreclkin
		//output wire [3:0]   tx_std_clkout,           //           tx_std_clkout.tx_std_clkout
		//output wire [3:0]   rx_std_clkout,           //           rx_std_clkout.rx_std_clkout
		//output wire [3:0]   tx_cal_busy,             //             tx_cal_busy.tx_cal_busy
		//output wire [3:0]   rx_cal_busy,             //             rx_cal_busy.rx_cal_busy
		//input  wire [559:0] reconfig_to_xcvr,        //        reconfig_to_xcvr.reconfig_to_xcvr
		//output wire [367:0] reconfig_from_xcvr,      //      reconfig_from_xcvr.reconfig_from_xcvr
		//input  wire [31:0]  tx_parallel_data,        //        tx_parallel_data.tx_parallel_data
		//input  wire [3:0]   tx_datak,                //                tx_datak.tx_datak
		//input  wire [139:0] unused_tx_parallel_data, // unused_tx_parallel_data.unused_tx_parallel_data
		//output wire [31:0]  rx_parallel_data,        //        rx_parallel_data.rx_parallel_data
		//output wire [3:0]   rx_datak,                //                rx_datak.rx_datak
		//output wire [3:0]   rx_errdetect,            //            rx_errdetect.rx_errdetect
		//output wire [3:0]   rx_disperr,              //              rx_disperr.rx_disperr
		//output wire [3:0]   rx_runningdisp,          //          rx_runningdisp.rx_runningdisp
		//output wire [3:0]   rx_patterndetect,        //        rx_patterndetect.rx_patterndetect
		//output wire [3:0]   rx_syncstatus,           //           rx_syncstatus.rx_syncstatus
		//output wire [199:0] unused_rx_parallel_data  // unused_rx_parallel_data.unused_rx_parallel_data
		//
		.pll_powerdown           (pll_powerdown),//           pll_powerdown.pll_powerdown
		.tx_analogreset          (tx_analogreset),//          tx_analogreset.tx_analogreset
		.tx_digitalreset         (tx_digitalreset),//         tx_digitalreset.tx_digitalreset
		//.tx_pll_refclk           (pll_125),//           tx_pll_refclk.tx_pll_refclk
		.ext_pll_clk             ({pll_625,pll_625}),             //             ext_pll_clk.ext_pll_clk
		.tx_serial_data          ({SFP_TX_port2,SFP_TX_port3}),//          tx_serial_data.tx_serial_data					SGMII - tranceivers
		//.pll_locked              (pll_locked),//              pll_locked.pll_locked
		.rx_analogreset          (rx_analogreset),//          rx_analogreset.rx_analogreset				
		.rx_digitalreset         (rx_digitalreset),//         rx_digitalreset.rx_digitalreset
		.rx_cdr_refclk           (i_clk),//           rx_cdr_refclk.rx_cdr_refclk
		.rx_serial_data          ({SFP_RX_port2, SFP_RX_port3}),//          rx_serial_data.rx_serial_data					SGMII - receivers		
		.tx_std_coreclkin        ({tbi_tx_clk[0],tbi_tx_clk[1]}),//        tx_std_coreclkin.tx_std_coreclkin
		.tx_std_clkout           ({tbi_tx_clk[0],tbi_tx_clk[1]}),//           tx_std_clkout.tx_std_clkout
		.rx_std_coreclkin        ({tbi_rx_clk[0],tbi_rx_clk[1]}),//        rx_std_coreclkin.rx_std_coreclkin
		.rx_std_clkout           ({tbi_rx_clk[0],tbi_rx_clk[1]}),//           rx_std_clkout.rx_std_clkout
		.tx_cal_busy             (tx_cal_busy),//             tx_cal_busy.tx_cal_busy
		.rx_cal_busy             (rx_cal_busy),//             rx_cal_busy.rx_cal_busy
		.reconfig_to_xcvr        (),//        reconfig_to_xcvr.reconfig_to_xcvr
		.reconfig_from_xcvr      (),//      reconfig_from_xcvr.reconfig_from_xcvr
		.tx_parallel_data        ({tbi_tx_data[0],tbi_tx_data[1]}),//        tx_parallel_data.tx_parallel_data
		.tx_datak                ({tbi_tx_ctrl[0],tbi_tx_ctrl[1]}),//                tx_datak.tx_datak
		.rx_parallel_data        ({tbi_rx_data[0],tbi_rx_data[1]}),//        rx_parallel_data.rx_parallel_data
		.rx_datak                ({tbi_rx_ctrl[0],tbi_rx_ctrl[1]}),//                rx_datak.rx_datak
		.unused_tx_parallel_data (),// unused_tx_parallel_data.unused_tx_parallel_data
		.rx_errdetect            (),//            rx_errdetect.rx_errdetect
		.rx_disperr              (),//              rx_disperr.rx_disperr
		.rx_runningdisp          (),//          rx_runningdisp.rx_runningdisp
		.rx_patterndetect        (),//        rx_patterndetect.rx_patterndetect
		.rx_syncstatus           (),//           rx_syncstatus.rx_syncstatus
		.unused_rx_parallel_data ()// unused_rx_parallel_data.unused_rx_parallel_data
	);
//
//------------------------------------------------------------------------------
//wire [3:0] tx_ready          ;//           tx_ready.tx_ready
//wire [0:0] pll_select        ;//         pll_select.pll_select
//wire [3:0] rx_ready          ;//           rx_ready.rx_ready
//wire [3:0] rx_is_lockedtodata;// rx_is_lockedtodata.rx_is_lockedtodata

phy_reset  phy_reset_(
		//output wire [0:0] pll_powerdown,      //      pll_powerdown.pll_powerdown
		//output wire [3:0] tx_analogreset,     //     tx_analogreset.tx_analogreset
		//output wire [3:0] tx_digitalreset,    //    tx_digitalreset.tx_digitalreset
		//output wire [3:0] tx_ready,           //           tx_ready.tx_ready
		//input  wire [0:0] pll_locked,         //         pll_locked.pll_locked
		//input  wire [0:0] pll_select,         //         pll_select.pll_select
		//input  wire [3:0] tx_cal_busy,        //        tx_cal_busy.tx_cal_busy
		//output wire [3:0] rx_analogreset,     //     rx_analogreset.rx_analogreset
		//output wire [3:0] rx_digitalreset,    //    rx_digitalreset.rx_digitalreset
		//output wire [3:0] rx_ready,           //           rx_ready.rx_ready
		//input  wire [3:0] rx_is_lockedtodata, // rx_is_lockedtodata.rx_is_lockedtodata
		//input  wire [3:0] rx_cal_busy         //        rx_cal_busy.rx_cal_busy
		//
		.clock             (i_clk),//              clock.clk
		.reset             (reset),//              reset.reset
		.pll_powerdown     (pll_powerdown),//      pll_powerdown.pll_powerdown
		.tx_analogreset    (tx_analogreset),//     tx_analogreset.tx_analogreset
		.tx_digitalreset   (tx_digitalreset),//    tx_digitalreset.tx_digitalreset
		.tx_ready          (),//           tx_ready.tx_ready
		.pll_locked        (pll_locked),//         pll_locked.pll_locked
		.pll_select        (0),//         pll_select.pll_select
		.tx_cal_busy       (tx_cal_busy),//        tx_cal_busy.tx_cal_busy
		.rx_analogreset    (rx_analogreset),//     rx_analogreset.rx_analogreset
		.rx_digitalreset   (rx_digitalreset),//    rx_digitalreset.rx_digitalreset
		.rx_ready          (),//           rx_ready.rx_ready
		.rx_is_lockedtodata(2'b11),// rx_is_lockedtodata.rx_is_lockedtodata
		.rx_cal_busy       (rx_cal_busy)//        rx_cal_busy.rx_cal_busy
	);
	
wire[7:0] gmii_rx_data [1:0];
wire      gmii_rx_val  [1:0];
wire[7:0] gmii_tx_data [1:0];
wire      gmii_tx_val  [1:0];
//
generate 
genvar h;
for(h=0;h<2;h++)begin:convert_8b_to_gmii
    _8b_coder_decoder
    _8b_coder_decoder_
    (
        .i8b_tx_clk     (tbi_tx_clk  [h]),		//FIFO to NATIVE PHY
        .igmii_rx_val   (gmii_tx_val [h] ),
        .igmii_rx_data  (gmii_tx_data [h]),
        .o8b_tx_data    (tbi_tx_data [h]),			
        .o8b_tx_service (tbi_tx_ctrl [h]),
        //
        .i8b_rx_clk     (tbi_rx_clk  [h]),		//NATIVE PHY to FIFO 	
        .i8b_rx_data    (tbi_rx_data [h]),
        .i8b_rx_service (tbi_rx_ctrl [h]),
        .ogmii_tx_val   (gmii_rx_val [h]),			
        .ogmii_tx_data  (gmii_rx_data [h])
    );
end
endgenerate

reg 					r_fifo_out_RD_EN = '1;

top_level switch 
(
		.i_clk				(i_clk),
		
		.i_RESET			(i_RESET),
		
		.i_clk_rx0			(iRX_CLK_0),
		.i_rx_dv_0			(i_rx_dv_0),    
		.i_rx_er_0			(),    
		.i_rx_d_0			({i_rx_d_0_7,i_rx_d_0_6,i_rx_d_0_5,i_rx_d_0_4,i_rx_d_0_3,i_rx_d_0_2,i_rx_d_0_1,i_rx_d_0_0}),      
		                          
		.i_clk_rx1			(iRX_CLK_1),
		.i_rx_dv_1			(i_rx_dv_1),    
		.i_rx_er_1			(),    
		.i_rx_d_1			({i_rx_d_1_7,i_rx_d_1_6,i_rx_d_1_5,i_rx_d_1_4,i_rx_d_1_3,i_rx_d_1_2,i_rx_d_1_1,i_rx_d_1_0}),      
		
		.i_clk_rx2			(tbi_rx_clk[0]),		
		.i_rx_dv_2			(gmii_rx_val[0]),    
		.i_rx_er_2			(),    
		.i_rx_d_2			(gmii_rx_data[0]),      
	
		.i_clk_rx3			(tbi_rx_clk[1]), 
		.i_rx_dv_3			(gmii_rx_val[1]),    
		.i_rx_er_3			(),    
		.i_rx_d_3			(gmii_rx_data[1]),      
		                          
		.o_rx_dv_0			(o_rx_dv_0),    
		.o_rx_er_0			(),    
		.o_rx_d_0			({o_rx_d_0_7,o_rx_d_0_6,o_rx_d_0_5,o_rx_d_0_4,o_rx_d_0_3,o_rx_d_0_2,o_rx_d_0_1,o_rx_d_0_0}),
		.o_clk_0			(o_clk_0),
		                          
		.o_rx_dv_1			(o_rx_dv_1),     
		.o_rx_er_1			(),     
		.o_rx_d_1			({o_rx_d_1_7,o_rx_d_1_6,o_rx_d_1_5,o_rx_d_1_4,o_rx_d_1_3,o_rx_d_1_2,o_rx_d_1_1,o_rx_d_1_0}),
		.o_clk_1			(o_clk_1),
		                          
		.o_rx_dv_2			(w_out_DV_2),    
		.o_rx_er_2			(),    
		.o_rx_d_2			(w_out_data_2),      
		.o_clk_2			(w_clk_out_2),
		                          
		.o_rx_dv_3			(w_out_DV_3),    
		.o_rx_er_3			(),    
		.o_rx_d_3			(w_out_data_3),
		.o_clk_3			(w_clk_out_3)
);  

		//wire                        			fifo_rx_er_0;
		//wire					fifo_rx_er_1;
	
	
/*	 dc_fifo fifo_tx_2
	(
		.data			(w_out_data_2),
		.rdclk			(tbi_tx_clk[0]),
		.rdreq			(r_fifo_out_RD_EN),
		.wrclk			(w_clk_out_2),
		.wrreq			(w_out_DV_2),
		.q				(gmii_tx_data[0]),
		.rdempty		(),
		.wrfull			()			
	);

		
	 dc_fifo fifo_tx_3
	(
		.data			(w_out_data_3),
		.rdclk			(tbi_tx_clk[1]),
		.rdreq			(r_fifo_out_RD_EN),
		.wrclk			(w_clk_out_3),
		.wrreq			(w_out_DV_3),
		.q				(gmii_tx_data[1]),
		.rdempty		(),
		.wrfull			()			
	);*/

// Порты 2 и 3 подключались напрямую, без IP-ядра Native PHY
// Для "выравнивания" по частотам использовались FIFO c 2 тактовыми частотами
// i_clk_rx - для записи
// i_clk_tx - для чтения

fifo_rx FIFO_TX_2
	
	(.i_clk_rx					(w_clk_out_2),
	 .i_clk_tx					(tbi_tx_clk[0]),
	 .ireset						(i_RESET),
	 .ien						(w_out_DV_2),
	 .iw_data					(w_out_data_2),
	 .o_error					(),
	 .o_en						(gmii_tx_val[0]),
	 .or_data					(gmii_tx_data[0])
	 );
	 

fifo_rx FIFO_TX_3
	
	(.i_clk_rx					(w_clk_out_3),
	 .i_clk_tx					(tbi_tx_clk[1]),
	 .ireset						(i_RESET),
	 .ien						(w_out_DV_3),
	 .iw_data					(w_out_data_3),
	 .o_error					(),
	 .o_en						(gmii_tx_val[1]),
	 .or_data					(gmii_tx_data[1])
	 );

	endmodule