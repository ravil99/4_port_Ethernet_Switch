`timescale 1ns/1ps

module speed_test;
reg         r_clk;

wire        w_clk_0;
wire        w_error_0;
wire        w_valid_0;
wire [7:0]       w_data_0;

wire        w_clk_1;
wire        w_error_1;
wire        w_valid_1;
wire [7:0]       w_data_1;

wire        w_clk_2;
wire        w_error_2;
wire        w_valid_2;
wire [7:0]       w_data_2;

wire        w_clk_3;
wire        w_error_3;
wire        w_valid_3;
wire [7:0]       w_data_3;

wire         					o_rx_dv_0;     // GMII0
	wire          				o_rx_er_0;     // GMII0 
	wire [7:0]   				o_rx_d_0;      // GMII0
    wire                           o_clk_0;


	wire         					o_rx_dv_1;     // GMII1
	wire          				o_rx_er_1;     // GMII1 
	wire [7:0]   				o_rx_d_1;      // GMII1
    wire                           o_clk_1;


	wire         					o_rx_dv_2;     // GMII2
	wire          				o_rx_er_2;     // GMII2 
	wire [7:0]   				o_rx_d_2;     // GMII2
    wire                           o_clk_2;


	wire         					o_rx_dv_3;     // GMII3
	wire          				o_rx_er_3;     // GMII3 
	wire [7:0]   				o_rx_d_3;      // GMII3
    wire                           o_clk_3;

initial
begin
 #0   r_clk=1'b0;
 end


pause_cost_TB_0 
# ( .long           (64)
)
block_0
(
    .clk   (w_clk_0),
    .er    (w_error_0),
    .dv    (w_valid_0),
    .data  (w_data_0)
);

pause_cost_TB_1
# ( .long           (64)
)
block_1
(
    .clk   (w_clk_1),
    .er   (w_error_1),
    .dv   (w_valid_1),
    .data  (w_data_1)
);

pause_cost_TB_2
# ( .long           (64)
)
block_2
(
    .clk   (w_clk_2),
    .er    (w_error_2),
    .dv    (w_valid_2),
    .data  (w_data_2)
);

pause_cost_TB_3
# ( .long           (64)
)
block_3
(
    .clk   (w_clk_3),
    .er    (w_error_3),
    .dv    (w_valid_3),
    .data  (w_data_3)
);

top_level top_level
(
        .i_clk              (r_clk),
        .i_clk_rx0          (w_clk_0),
        .i_clk_rx1          (w_clk_1),
        .i_clk_rx2          (w_clk_2),
        .i_clk_rx3          (w_clk_3),
//        .i_RESET            (),

        .i_rx_dv_0          (w_valid_0),
        .i_rx_er_0          (w_error_0),
        .i_rx_d_0           (w_data_0), 
               
        .i_rx_dv_1          (w_valid_1),
        .i_rx_er_1          (w_error_1),
        .i_rx_d_1           (w_data_1), 
                
        .i_rx_dv_2          (w_valid_2),
        .i_rx_er_2          (w_error_2),
        .i_rx_d_2           (w_data_2), 
                
        .i_rx_dv_3          (w_valid_3),
        .i_rx_er_3          (w_error_3),
        .i_rx_d_3           (w_data_3), 
               
        .o_rx_dv_0          (o_rx_dv_0),
        .o_rx_er_0          (o_rx_er_0),
        .o_rx_d_0           (o_rx_d_0),
        .o_clk_0            (o_clk_0),
                
        .o_rx_dv_1          (o_rx_dv_1),
        .o_rx_er_1          (o_rx_er_1),
        .o_rx_d_1           (o_rx_d_1),
        .o_clk_1            (o_clk_1),
                
        .o_rx_dv_2          (o_rx_dv_2),
        .o_rx_er_2          (o_rx_er_2),
        .o_rx_d_2           (o_rx_d_2),
        .o_clk_2            (o_clk_2),
               
        .o_rx_dv_3          (o_rx_dv_3),
        .o_rx_er_3          (o_rx_er_3),
        .o_rx_d_3           (o_rx_d_3),
        .o_clk_3            (o_clk_3)
);


always 
    begin
#4 r_clk=~r_clk;
    end

endmodule


