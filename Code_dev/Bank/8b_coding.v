module _8b_coder_decoder
(
	input  				i8b_tx_clk,
   input               igmii_rx_val,
	input       [7:0]   igmii_rx_data,
	output reg  [7:0]   o8b_tx_data,
   output reg          o8b_tx_service,
   //
	input  				i8b_rx_clk,
   input       [7:0]   i8b_rx_data,
   input               i8b_rx_service,
   output reg          ogmii_tx_val,
	output reg  [7:0]   ogmii_tx_data
);
//
//==============================
// GMII to 8B
//==============================
localparam [7:0] Dh_z  = 8'h41;
localparam [7:0] D5_6  = 8'h50;
localparam [7:0] D16_2 = 8'hC5;
localparam [7:0] K28_0 = 8'h1C;//8'b0001_1100;
localparam [7:0] K28_1 = 8'h3C;//8'b0011_1100;
localparam [7:0] K28_2 = 8'h5C;//8'b0101_1100;
localparam [7:0] K28_3 = 8'h7C;//8'b0111_1100;
localparam [7:0] K28_4 = 8'h9C;//8'b1001_1100;
localparam [7:0] K28_5 = 8'hBC;//8'b1011_1100;
localparam [7:0] K28_6 = 8'hDC;//8'b1101_1100;
localparam [7:0] K28_7 = 8'hFC;//8'b1111_1100;
localparam [7:0] K23_7 = 8'hF7;//8'b1111_0111;
localparam [7:0] K27_7 = 8'hFB;//8'b1111_1011;
localparam [7:0] K29_7 = 8'hFD;//8'b1111_1101;
localparam [7:0] K30_7 = 8'hFE;//8'b1111_1110;
//
reg [7:0]   gmii_rx_data [4:0];
reg [4:0]   gmii_rx_val;
reg			cnt_idle = 1'b0;
reg [1:0]   delay_cnt = 'b0;
//
localparam  WAIT_STATE = 2'b00;
localparam  SOP_STATE = 2'b01;
localparam  PAYLOAD_STATE = 2'b10;
localparam  EOP_STATE = 2'b11;
reg [1:0]   _8b_tx_st = WAIT_STATE;
//
always_ff@(posedge i8b_tx_clk)begin
    //
    gmii_rx_data[0]<= igmii_rx_data;
    gmii_rx_data[1]<= gmii_rx_data[0];
    gmii_rx_data[2]<= gmii_rx_data[1];
    gmii_rx_data[3]<= gmii_rx_data[2];
    gmii_rx_val[0] <= igmii_rx_val;
    gmii_rx_val[1] <= gmii_rx_val[0];
    gmii_rx_val[2] <= gmii_rx_val[1];
    gmii_rx_val[3] <= gmii_rx_val[2];
    //
    case (_8b_tx_st)
        WAIT_STATE:begin
				delay_cnt <= 'b0;
            if (!cnt_idle)begin//first idle 10bit {K28.5}
               o8b_tx_data    <= K28_5;
					cnt_idle	    	<= 1'b1;
					o8b_tx_service <= 1'b1;
               end
            else begin//second idle 10bit {D5.6}
					cnt_idle			<= 1'b0;
               o8b_tx_data		<= Dh_z;
					o8b_tx_service	<= 1'b0;
               end
            //
            if (gmii_rx_val[0])begin
               _8b_tx_st		<= SOP_STATE;
               delay_cnt		<= 2'd1;
               end
            end
        SOP_STATE:begin
            if (!cnt_idle)begin
               o8b_tx_data		<= K27_7;
					o8b_tx_service	<= 1'b1;
               cnt_idle			<= 1'b1;
               _8b_tx_st		<= PAYLOAD_STATE;
               delay_cnt		<= delay_cnt + 1'b1;
               end
            else begin
               o8b_tx_data		<= Dh_z;
					o8b_tx_service	<= 1'b0;
               cnt_idle			<= 1'b0;
               delay_cnt		<= delay_cnt + 1'b1;
                end
            end
        PAYLOAD_STATE:begin
            cnt_idle			<= cnt_idle + 1'b1;
            o8b_tx_service	<= 1'b0;
            o8b_tx_data		<= gmii_rx_data[delay_cnt];
            if (!gmii_rx_val[delay_cnt-1])begin
                _8b_tx_st <= EOP_STATE;
                delay_cnt <= 'b0;
                end
            end
        EOP_STATE:begin
            if (delay_cnt==2'd0)begin
                o8b_tx_data     <= K29_7;
                cnt_idle        <= cnt_idle + 1'b1;
                o8b_tx_service   <= 1'b1;
					 delay_cnt       <= delay_cnt + 1'b1;
					 //if (!cnt_idle)begin
                //    delay_cnt       <= 'b0;
                //    _8b_tx_st       <= WAIT_STATE;
                //    end
					 //else begin
					//	delay_cnt       <= delay_cnt + 1'b1;
					//	end
                end
            else if (delay_cnt > 2'd0)begin
                o8b_tx_data     <= K23_7;
                cnt_idle        <= cnt_idle + 1'b1;
                o8b_tx_service  <= 1'b1;
					 //_8b_tx_st       <= WAIT_STATE;
					 if (cnt_idle)begin
                    delay_cnt       <= 'b0;
                    _8b_tx_st       <= WAIT_STATE;
                    end
                end
            end
    endcase
    //
    end
//
//==============================
// 8B to GMII
//==============================
reg [7:0]   _8b_rx_data;
reg         _8b_rx_service;
//
reg         _8b_rx_eop = 1'b0;
reg         _8b_rx_sop = 'b0;
//
localparam WAIT_START = 2'b00;
localparam DATA_STATE = 2'b01;
localparam WAIT_STOP = 2'b10;
reg [1:0] _8b_rx_st = WAIT_START;
//
always_ff@(posedge i8b_rx_clk)begin
    //
    _8b_rx_service <= i8b_rx_service;
    _8b_rx_data    <= i8b_rx_data;
    //
	case (_8b_rx_st)
	    WAIT_START:begin
            ogmii_tx_data  <= 'b0;
            ogmii_tx_val   <= 1'b0;
            if ((_8b_rx_data == K27_7) && _8b_rx_service)
		        _8b_rx_st  <= DATA_STATE;
            end
	    DATA_STATE:begin
            if ((_8b_rx_service)&& (_8b_rx_data == K29_7))begin//eop
			    _8b_rx_st      <= WAIT_START;
                ogmii_tx_data  <= 'b0;
                ogmii_tx_val   <= 1'b0;
                end
            else if (_8b_rx_service) begin//wait service EOP data
                _8b_rx_st      <= WAIT_STOP;
                ogmii_tx_data  <= _8b_rx_data;
                ogmii_tx_val   <= 1'b1;
                end
            else begin//if (!_8b_rx_service) begin
                ogmii_tx_data  <= _8b_rx_data;
                ogmii_tx_val   <= 1'b1;
                end
            end
        WAIT_STOP:begin
            if (_8b_rx_data == K29_7)begin//eop
			    _8b_rx_st      <= WAIT_START;
                ogmii_tx_data  <= 'b0;
                ogmii_tx_val   <= 1'b0;
                end
            else begin//wait service EOP data
                ogmii_tx_data  <= _8b_rx_data;
                ogmii_tx_val   <= 1'b1;
                end
            end
        default:begin
            _8b_rx_st      <= WAIT_START;
            end
	endcase
    //
end
//
//
/*
//==============================
// Compare
//==============================
localparam DATA_DELAY =5;
reg [7:0] compare_data [DATA_DELAY-1:0] = '{DATA_DELAY{'b0}};
reg [DATA_DELAY-1:0] compare_val = 'b0;
reg compare_err;
always_ff@(posedge iclk)begin
    integer i;
    compare_data[0] <= igmii_rx_data;
    compare_val[0] <= igmii_rx_val;
    //
    for (i=1;i<DATA_DELAY;i++)begin
        compare_data[i] <= compare_data[i-1];
        compare_val[i] <= compare_val[i-1];
        end
    //
    compare_err = ((compare_data[DATA_DELAY-1] != ogmii_tx_data) || (compare_val[DATA_DELAY-1]!=ogmii_tx_val));
    end
//
*/
//
endmodule