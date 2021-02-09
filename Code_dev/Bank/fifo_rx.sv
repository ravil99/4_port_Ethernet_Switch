`include "header.v"


module fifo_rx

#( parameter         pBITS  = 9,               // parameter declaration 
                    pWIDHT = 32,

                    wow=1'b0,
                    run= 1'b1)
    
    (
        input wire              i_clk_rx,       // Signal declaration 
        input wire              i_clk_tx,       // Signal declaration 
        input wire              ireset,

        input wire              ien,
//        input wire              ierror, 
        input wire  [pBITS-2:0] iw_data,
        
 //       output wire             oempty,
//        output wire             ofull,

        output reg              o_en,
        output reg              o_error,
        output reg [pBITS-2:0]  or_data
    ); 
//                    ending =2'b10;

    // Inner signal declaration
    reg [pBITS-1:0]          rArray [pWIDHT-1:0];

    reg [$clog2(pWIDHT)-1:0]                     rR_ptr='0;
    reg [$clog2(pWIDHT)-1:0]                     rW_ptr='0;

    reg [$clog2(pWIDHT)-1:0]                     rW_ptr_end='0;           

//    reg                         rFull='0;
    reg [1:0]                         stayts='0;
    reg [1:0]                         next_stayts='0;
    reg                               ierror=1'b0;
    reg [3:0]                         en;


    always @(posedge i_clk_rx)      // write
        begin
			if (ireset) begin
            rW_ptr <= '0;
            end
				
            if (~ireset && ien) begin
            rArray[rW_ptr] <= {ierror,iw_data};
            
//            rFull <= 1'b1;
//            rEmpty <= 1'b0;
            rW_ptr <= rW_ptr+1'b1;
            end

            en<={en[2:0],ien};

        if (en[3:1]==3'b111) begin
            rW_ptr_end<=rW_ptr;
            end

        end

    always @(posedge i_clk_tx)      // read
        begin
        if (ireset) begin
//            rW_ptr <= '0;
            rR_ptr <= '0;
        end

        else begin
            case (stayts)

            wow:        begin
                        rR_ptr<=rR_ptr;
                        o_en<=1'b0;
                        if (en==4'b1111)
                            begin
                            stayts<=next_stayts;
                            next_stayts<=run;
                            end
                        end

            run:        begin
                        if(rW_ptr_end==rR_ptr) begin
                            stayts<=next_stayts;
                            next_stayts<=wow;
                            o_en<=1'b0;
                            end
                        else begin
                            rR_ptr<=rR_ptr+1'b1;
                            o_en<=1'b1;
                            {o_error,or_data} <= rArray[rR_ptr];
                            end
                        end

 //           rFull <= 1'b0;
 //           rEmpty <= 1'b1;
			
            endcase

            end
        end

    // output
//    assign ofull = (rR_ptr == rW_ptr);
//    assign oempty = (rR_ptr == rW_ptr) ;

endmodule 