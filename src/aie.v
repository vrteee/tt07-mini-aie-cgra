`default_nettype none

module tt_um_mini_aie_2x2 (
    input  wire [7:0] ui_in,    // Dedicated inputs - connected to the input switches
    output wire [7:0] uo_out,   // Dedicated outputs - connected to the 7 segment display
    /* verilator lint_off UNUSEDSIGNAL */
    input  wire [7:0] uio_in,   // IOs: Bidirectional Input path
    /* verilator lint_on UNUSEDSIGNAL */
    output wire [7:0] uio_out,  // IOs: Bidirectional Output path
    output wire [7:0] uio_oe,   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  wire reset = !rst_n & ena;
  assign uio_oe = 8'b11111111;

  // intermediate regs between FIFOs
  reg [7:0] switch_in_reg[4];
  reg [7:0] switch_out_reg[4];

  reg [7:0] pe_out_reg[4];
  reg [7:0] pe_in_reg[4];

  // control signals
  logic switch_fifo_rd_en[4];
  logic switch_fifo_wr_en[4];
  
  // generate noc and pe array
  generate
    genvar i;
    for (i = 0; i < 4; i = i + 1) begin : gen
      if (i == 0) begin
        synchronous_fifo #(
            .DEPTH(4),
            .DATA_WIDTH(8)
        ) fifo (
            .clk(clk),
            .rst_n(rst_n),
            .w_en(ena),
            .r_en(switch_fifo_rd_en[i]),
            .data_in(ui_in + uio_in),
            .data_out(switch_in_reg[i]),
            .full(),
            .empty()
        );
      end else begin
        synchronous_fifo #(
            .DEPTH(4),
            .DATA_WIDTH(8)
        ) fifo (
            .clk(clk),
            .rst_n(rst_n),
            .w_en(switch_fifo_wr_en[i-1]),
            .r_en(switch_fifo_rd_en[i]),
            .data_in(switch_out_reg[i-1]),
            .data_out(switch_in_reg[i]),
            .full(),
            .empty()
        );
      end

      switch #(
          .rank(i)
      ) switch (
          .clk(clk),
          .rst_n(rst_n),
          .switch_fifo_in(switch_in_reg[i]),
          .switch_fifo_out(switch_out_reg[i]),
          .pe_fifo_in(pe_out_reg[i]),
          .pe_fifo_out(pe_in_reg[i]),
          .rd_en(switch_fifo_rd_en[i]),
          .wr_en(switch_fifo_wr_en[i])
      );

      compute_tile pe (
          .clk(clk),
          .rst_n(rst_n),
          .switch_data_in(pe_in_reg[i]),
          .switch_data_out(pe_out_reg[i])
      );
    end

  endgenerate
  assign uo_out = switch_out_reg[2];
  assign uio_out = ui_in + uio_in;

endmodule
