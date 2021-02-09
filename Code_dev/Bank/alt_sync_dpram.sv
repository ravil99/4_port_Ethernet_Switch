//`include "sv_clog2.v"

module alt_sync_dpram
#(
    parameter int pDATA_W        = 8,
    parameter int pWORDS         = 1024,
    parameter int cADDR_W        = $clog2(pWORDS),
    parameter int pUSE_EAB       = 1,
    parameter int pUSE_RD_ENA    = 1,
    parameter int pUSE_OUT_REG   = 1
    
)
(
    input  bit  [pDATA_W -1:0]  idata       ,
    input  bit  [cADDR_W-1:0]   iaddr_in    ,
    input  bit                  iwr_ena     ,
    
    input  bit  [cADDR_W-1:0]   iaddr_out   ,
    input  bit                  ird_ena     ,
    output wire [pDATA_W -1:0]  odata       ,
    output bit                  oval        ,
    
    input  logic                iclk
); 
    
    localparam  lpIMPLEMENT_IN_LES  = (pUSE_EAB     ) ? "OFF"    : "ON"          ;
    localparam  lpOUTDATA_REG       = (pUSE_OUT_REG ) ? "CLOCK1" : "UNREGISTERED";
    wire        wrd_ena;
    assign      wrd_ena = (pUSE_RD_ENA) ? ird_ena : 1'b1;

    altsyncram
   #(
        .address_aclr_b         ( "NONE"            ) ,
        .address_reg_b          ( "CLOCK1"          ) ,
        .clock_enable_input_a   ( "NORMAL"          ) ,
        .clock_enable_input_b   ( "NORMAL"          ) ,
        .lpm_type               ( "altsyncram"      ) ,
        .numwords_a             ( 2**cADDR_W        ) ,
        .numwords_b             ( 2**cADDR_W        ) ,
        .operation_mode         ( "DUAL_PORT"       ) ,
        .outdata_aclr_b         ( "NONE"            ) ,
        .outdata_reg_b          ( lpOUTDATA_REG     ) ,
        .widthad_a              ( cADDR_W           ) ,
        .widthad_b              ( cADDR_W           ) ,
        .width_a                ( pDATA_W           ) ,
        .width_b                ( pDATA_W           ) ,
        .implement_in_les       ( lpIMPLEMENT_IN_LES)
    )
        ram_
    (
        .clock0                 ( iclk              ) ,
        .clocken0               ( 1'b1              ) ,
        .wren_a                 ( iwr_ena           ) ,
        .address_a              ( iaddr_in          ) ,
        .data_a                 ( idata             ) ,
        //
        .clock1                 ( iclk              ) ,
        .rden_b                 ( wrd_ena           ) ,
        .address_b              ( iaddr_out         ) ,
        .q_b                    ( odata             ) ,
        //
        .aclr0                  ( 1'b0              ) ,
        .aclr1                  ( 1'b0              ) ,
        .addressstall_a         ( 1'b0              ) ,
        .addressstall_b         ( 1'b0              ) ,
        .byteena_a              ( 1'b1              ) ,
        .byteena_b              ( 1'b1              ) ,
        .clocken1               ( 1'b1              ) ,
        .clocken2               ( 1'b1              ) ,
        .clocken3               ( 1'b1              ) ,
        .data_b                 ( {pDATA_W{1'b1}}   ) ,
        .eccstatus              (                   ) ,
        .q_a                    (                   ) ,
        .rden_a                 ( 1'b1              ) ,
        .wren_b                 ( 1'b0              ) 
    );
    
    
    generate if (pUSE_RD_ENA)
    begin : rd_ena_on
        
        bit rrd_ena = 'b0;
        
        always_ff @(posedge iclk)
        begin
            rrd_ena <= ird_ena;
            oval    <= (pUSE_OUT_REG > 0) ? rrd_ena : ird_ena;
        end
    end
    else
    begin
        always_comb
        begin
            oval = 1'b0;
        end
    end
    endgenerate

endmodule
