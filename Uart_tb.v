`timescale 1ns/1ps

module uart_tb;

reg clk;
reg reset;
reg tx_start;
reg [7:0] tx_data;

wire [7:0] rx_data;
wire rx_done;

uart_top DUT (
    .clk(clk),
    .reset(reset),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .rx_data(rx_data),
    .rx_done(rx_done)
);

always #5 clk = ~clk; // 10ns clock period

initial
begin
    clk = 0;
    reset = 1;
    tx_start = 0;
    tx_data = 8'h00;

    #20;
    reset = 0;

    #20;
    tx_data = 8'hA5;
    tx_start = 1;

    #10;
    tx_start = 0;

    #100000;

    $stop;
end

endmodule