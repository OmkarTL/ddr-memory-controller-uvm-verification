`timescale 1ns/1ps

module memory_controller #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32
)(
    input  logic                  clk,
    input  logic                  rst_n,

    // Request interface
    input  logic                  valid,
    input  logic                  write_en,
    input  logic [ADDR_WIDTH-1:0] addr,
    input  logic [DATA_WIDTH-1:0] wdata,

    // Response interface
    output logic [DATA_WIDTH-1:0] rdata,
    output logic                  busy,
    output logic                  done
);

    // 256 x 32-bit memory
    logic [DATA_WIDTH-1:0] mem [0:(1 << ADDR_WIDTH)-1];

    typedef enum logic [1:0] {
        IDLE  = 2'b00,
        WRITE = 2'b01,
        READ  = 2'b10
    } state_t;

    state_t state;

    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            state <= IDLE;
            rdata <= '0;
            done  <= 1'b0;
        end
        else begin

            // done is a one-cycle pulse
            done <= 1'b0;
            case (state)
                IDLE: begin
                    if (valid) begin
                        if (write_en)
                            state <= WRITE;
                        else
                            state <= READ;
                    end
                end
                WRITE: begin
                    mem[addr] <= wdata;
                    done  <= 1'b1;
                    state <= IDLE;
                end
                READ: begin
                    rdata <= mem[addr];
                    done  <= 1'b1;
                    state <= IDLE;
                end
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end
    assign busy = (state != IDLE);
endmodule