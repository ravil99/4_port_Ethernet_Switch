`include "clog2.sv"

module ram_dual
#(
    parameter int WIDTH         = 8                 ,
    parameter int WORDS         = 1024              ,
    parameter int ADDR_WIDTH    = clog2(WORDS)      ,
    parameter int USE_EAB       = 1                 ,
    parameter int USE_RD_ENA    = 1                 ,
    parameter int USE_ALTSYNC   = 0
    
)
(
    output wire [WIDTH-1:0]         odata       ,
    output logic                    oval        ,
    input  logic  [WIDTH-1:0]       idata       ,
    input  logic  [ADDR_WIDTH-1:0]  iaddr_in    ,
    input  logic  [ADDR_WIDTH-1:0]  iaddr_out   ,
    input  logic                    iwr_ena     ,
    input  logic                    ird_ena     ,
    input  logic                    iclk
); 
    
    localparam int lpMEM_WORDS = 2**clog2(WORDS);
    
generate if (USE_ALTSYNC)
begin : alt_sync_ram_on
    
    alt_sync_dpram
    #(
        .pDATA_W        (WIDTH      ),
        .pWORDS         (WORDS      ),
        .pUSE_EAB       (USE_EAB    ),
        .pUSE_RD_ENA    (USE_RD_ENA )
        
    )
        alt_sync_dpram_
    (
        .idata          (idata      ),
        .iaddr_in       (iaddr_in   ),
        .iwr_ena        (iwr_ena    ),
        
        .iaddr_out      (iaddr_out  ),
        .ird_ena        (ird_ena    ),
        .odata          (odata      ),
        .oval           (oval       ),
        
        .iclk           (iclk       )
    ); 
end
else
begin : alt_sync_ram_off

    // WRITE PART
        
    logic [ADDR_WIDTH-1:0] raddr_in = 'b0;
    logic [WIDTH-1:0]      rdata_in = 'b0;
    logic                  rwr_ena  = 'b0;
        
    always_ff @(posedge iclk)
    begin
        
        rwr_ena  <= iwr_ena;
        rdata_in <= idata;
        raddr_in <= iaddr_in;
    
    end
    
    // READ PART
    logic [ADDR_WIDTH-1:0]    raddr_out = 'b0;
    logic [WIDTH-1:0]         rdata_out = 'b0;
    logic                     rrd_ena   = 'b0;
    
    assign odata = rdata_out;
    
    always_ff @(posedge iclk)
    begin
        if ((USE_RD_ENA) ? ird_ena : 1'b1)	
            raddr_out <= iaddr_out;
        else
            raddr_out <= raddr_out;
        
        rrd_ena <= ird_ena;
        oval    <= rrd_ena;
    end
    
    if (USE_EAB > 0)
    begin : eab_on
    
        logic [WIDTH-1:0] mem [0:lpMEM_WORDS-1] = '{default: '0}   /* synthesis ramstyle = "auto, no_rw_check" */;
        
        always_ff @(posedge iclk)
        begin
            if (rwr_ena)
                mem[raddr_in] <= rdata_in;
            
            rdata_out <= mem[raddr_out];
        end
    end
    else
    begin : eab_off
    
        logic [WIDTH-1:0] mem [0:lpMEM_WORDS-1] /* synthesis ramstyle = "logic, no_rw_check" */;
        
        always_ff @(posedge iclk)
        begin
            if (rwr_ena)
                mem[raddr_in] <= rdata_in;
                
            rdata_out <= mem[raddr_out];
        end
    
    end
end
endgenerate
    
endmodule
