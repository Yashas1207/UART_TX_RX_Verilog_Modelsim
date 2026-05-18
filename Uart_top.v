module uart_top(
    input clk,
    input reset,
    input tx_start,
    input [7:0] tx_data,
    output [7:0] rx_data,
    output rx_done
);

wire tx_wire;

uart_tx TX (
    .clk(clk),
    .reset(reset),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .tx(tx_wire),
    .tx_busy()
);

uart_rx RX (
    .clk(clk),
    .reset(reset),
    .rx(tx_wire),
    .rx_data(rx_data),
    .rx_done(rx_done)
);

endmodule