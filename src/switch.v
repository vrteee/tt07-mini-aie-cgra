


module switch 
#(parameter rank = 0)
(
    input wire clk, rst_n,
    input [7:0] switch_fifo_in, 
    output reg [7:0] switch_fifo_out,
    input [7:0] pe_fifo_in,
    output reg [7:0] pe_fifo_out
);

reg [7:0] prev_switch_fifo_in;
reg [7:0] prev_pe_fifo_in;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        switch_fifo_out <= 8'b00000000;
        pe_fifo_out <= 8'b00000000;
        prev_pe_fifo_in <= 8'b00000000;
        prev_switch_fifo_in <= 8'b00000000;

    end else begin
        if (pe_fifo_in != prev_pe_fifo_in) begin
            prev_pe_fifo_in <= pe_fifo_in;
            switch_fifo_out <= {4'b1111, pe_fifo_in[3:0]};
            
        end else if (switch_fifo_in != prev_switch_fifo_in) begin
            prev_switch_fifo_in <= switch_fifo_in;
            if (switch_fifo_in[5:4] == rank) begin
                pe_fifo_out <= switch_fifo_in;
            end else begin
                switch_fifo_out <= switch_fifo_in;
            end
        end 
    end
end

endmodule
