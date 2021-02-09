module sram 
    #(
        parameter DATA_WIDTH = 32, 
                  DEPTH = 4608
    )(
        input wire                      i_clk,
        input wire [$clog2(DEPTH)-1:0]  i_addr_wr,
        input wire [$clog2(DEPTH)-1:0]  i_addr_r, 
        input wire                      i_write,
        input wire                      i_read,
        input wire [DATA_WIDTH-1:0]     i_data,
        output reg [DATA_WIDTH-1:0]     o_data 
    );

    reg [DATA_WIDTH-1:0] memory_array [0:DEPTH-1]; 

    always @ (posedge i_clk)
    begin
        if (i_write) begin
            memory_array[i_addr_wr] <= i_data;
        end
        if (i_read) begin
            o_data <= memory_array[i_addr_r]; 
        end   
    end

endmodule
