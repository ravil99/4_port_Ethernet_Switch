`include "header.v"

module fifo
    #(
        parameter pBITS  = 8,               // parameter declaration 
                  pWIDTH = 4
    )
    (
        input wire              iclk,       // Signal declaration 
        input wire              ireset,     // = aclr
        input wire              ird,        // = rdreq
        input wire              iwr,        // = wrreq
        input wire  [pBITS-1:0] iw_data,    // = data
        output wire             o_used_words,   
        output wire             o_almost_full,
        output wire             oempty,
        output wire             ofull,
        output reg [pBITS-1:0] or_data      // = q
    );       

    // Inner signal declaration
    reg [pBITS-1:0]          rArray [pWIDTH-1:0];

    reg [$clog2(pWIDTH)-1:0]                     rR_ptr='1;
    reg [$clog2(pWIDTH)-1:0]                     rW_ptr='0;           

    reg                         rFull;
    reg                         rEmpty='1;


//    wire wWr_en;

    // register file write operation
    always @(posedge iclk)
        begin
        if (ireset) begin
            rW_ptr <= 0;
            rR_ptr <= '1;
            rFull  <= 1'b0;
            rEmpty <= 1'b1;
        end 

        else begin
            case ({iwr, ird})
            //2'b00:
            2'b01: begin  // read
  //              if(~rEmpty) begin // not EMPTY
                    rR_ptr<=rR_ptr+1'b1;
                    rFull <= 1'b0;
                    rEmpty <= 1'b1;
  /*                  if ((rR_ptr) == rW_ptr+2'b10) begin
                        rEmpty <= 1'b1;
                        end
                    else rEmpty <= 1'b0;*/
                    
   //             end
            end

            2'b10: begin  // write
 //               if (~rFull) begin // not FULL
                    rArray[rW_ptr] <= iw_data;
                    rFull <= 1'b1;
                    rEmpty <= 1'b0;
                    rW_ptr <= rW_ptr+1'b1;

 /*                   if ((rW_ptr+1'b1) == rR_ptr) begin
                       rFull <= 1'b1;
                    end   
                    else rFull <= 1'b0;     */               
   //             end
            end

            2'b11: begin  // write and read
                rW_ptr <= rW_ptr+1'b1;
                rArray[rW_ptr] <= iw_data;
                
                rR_ptr <= rR_ptr+1'b1;
            end 
            endcase
            end
	or_data <= rArray[rR_ptr];		
        end
    // register file read operation
    
    // write enable if FIFO is not ful
//    assign wWr_en = iwr & ~rFull;

    // output
    assign ofull = (rR_ptr+1'b1 == rW_ptr)&& rFull;
    assign oempty = (rR_ptr+1'b1 == rW_ptr)&& rEmpty ;

endmodule 
