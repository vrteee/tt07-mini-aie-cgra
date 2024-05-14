

module compute_tile
(
    input wire clk, 
    input wire rst_n,
    input [7:0] switch_data_in,
    output reg [7:0] switch_data_out
);

    reg op_type;
    reg [3:0] weight;

    reg has_next_core;
    reg [1:0] next_core_index;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            op_type <= 1'b0;
            weight <= 4'b0000;
            has_next_core <= 1'b0;
            next_core_index <= 2'b00;
            switch_data_out <= 8'b00000000;
        
        end else if (switch_data_in[7:6] == 2'b00) begin
            weight <= switch_data_in[3:0];
        
        end else if (switch_data_in[7:6] == 2'b01) begin
            has_next_core <= 1'b1;
            next_core_index <= switch_data_in[5:4];
            op_type <= switch_data_in[0];
        
        end else begin
            if (op_type == 1'b0) begin
                switch_data_out <= switch_data_in[3:0] + weight;
            end else begin
                switch_data_out <= switch_data_in - weight;
            end
        end
    end
endmodule
