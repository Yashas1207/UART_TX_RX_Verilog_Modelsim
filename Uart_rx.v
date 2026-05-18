module uart_rx(
    input clk,
    input reset,
    input rx,
    output reg [7:0] rx_data,
    output reg rx_done
);

parameter CLKS_PER_BIT = 87;

reg [15:0] clk_count;
reg [3:0] bit_index;
reg [7:0] data_reg;
reg [2:0] state;

localparam IDLE      = 3'b000,
           START_BIT = 3'b001,
           DATA_BITS = 3'b010,
           STOP_BIT  = 3'b011;

always @(posedge clk or posedge reset)
begin
    if(reset)
    begin
        state <= IDLE;
        clk_count <= 0;
        bit_index <= 0;
        rx_done <= 0;
    end
    else
    begin
        case(state)

        IDLE:
        begin
            rx_done <= 0;

            if(rx == 0)
            begin
                clk_count <= 0;
                state <= START_BIT;
            end
        end

        START_BIT:
        begin
            if(clk_count < (CLKS_PER_BIT-1)/2)
                clk_count <= clk_count + 1;
            else
            begin
                clk_count <= 0;
                state <= DATA_BITS;
            end
        end

        DATA_BITS:
        begin
            if(clk_count < CLKS_PER_BIT-1)
                clk_count <= clk_count + 1;
            else
            begin
                clk_count <= 0;
                data_reg[bit_index] <= rx;

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
            if(clk_count < CLKS_PER_BIT-1)
                clk_count <= clk_count + 1;
            else
            begin
                rx_done <= 1;
                rx_data <= data_reg;
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