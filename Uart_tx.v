module uart_tx(
    input clk,
    input reset,
    input tx_start,
    input [7:0] tx_data,
    output reg tx,
    output reg tx_busy
);

parameter CLKS_PER_BIT = 87; // for 115200 baud @ 10MHz clock

reg [3:0] bit_index;
reg [7:0] data_reg;
reg [15:0] clk_count;
reg [2:0] state;

localparam IDLE      = 3'b000,
           START_BIT = 3'b001,
           DATA_BITS = 3'b010,
           STOP_BIT  = 3'b011;

always @(posedge clk or posedge reset)
begin
    if(reset)
    begin
        tx <= 1'b1;
        tx_busy <= 0;
        state <= IDLE;
        clk_count <= 0;
        bit_index <= 0;
    end
    else
    begin
        case(state)

        IDLE:
        begin
            tx <= 1'b1;
            tx_busy <= 0;
            clk_count <= 0;
            bit_index <= 0;

            if(tx_start)
            begin
                tx_busy <= 1;
                data_reg <= tx_data;
                state <= START_BIT;
            end
        end

        START_BIT:
        begin
            tx <= 1'b0;

            if(clk_count < CLKS_PER_BIT-1)
                clk_count <= clk_count + 1;
            else
            begin
                clk_count <= 0;
                state <= DATA_BITS;
            end
        end

        DATA_BITS:
        begin
            tx <= data_reg[bit_index];

            if(clk_count < CLKS_PER_BIT-1)
                clk_count <= clk_count + 1;
            else
            begin
                clk_count <= 0;

                if(bit_index < 7)
                    bit_index <= bit_index + 1;
                else
                begin
                    bit_index <= 0;
                    state <= STOP_BIT;
                end
            end
        end

        STOP_BIT:
        begin
            tx <= 1'b1;

            if(clk_count < CLKS_PER_BIT-1)
                clk_count <= clk_count + 1;
            else
            begin
                clk_count <= 0;
                state <= IDLE;
            end
        end

        default:
            state <= IDLE;

        endcase
    end
end

endmodule