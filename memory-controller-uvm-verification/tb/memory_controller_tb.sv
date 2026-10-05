`timescale 1ns/1ps

module memory_controller_tb;

    // ---------------------------------------------------------
    // Parameters
    // ---------------------------------------------------------
    parameter ADDR_WIDTH = 8;
    parameter DATA_WIDTH = 32;

    // ---------------------------------------------------------
    // Testbench signals
    // ---------------------------------------------------------
    logic                  clk;
    logic                  rst_n;

    logic                  valid;
    logic                  write_en;
    logic [ADDR_WIDTH-1:0] addr;
    logic [DATA_WIDTH-1:0] wdata;

    logic [DATA_WIDTH-1:0] rdata;
    logic                  busy;
    logic                  done;

    // ---------------------------------------------------------
    // DUT
    // ---------------------------------------------------------
    memory_controller #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk      (clk),
        .rst_n    (rst_n),

        .valid    (valid),
        .write_en (write_en),
        .addr     (addr),
        .wdata    (wdata),

        .rdata    (rdata),
        .busy     (busy),
        .done     (done)
    );

    // ---------------------------------------------------------
    // Clock generation
    // ---------------------------------------------------------
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // ---------------------------------------------------------
    // Test
    // ---------------------------------------------------------
    initial begin

        // -----------------------------------------------------
        // Initialize
        // -----------------------------------------------------
        rst_n    = 1'b0;
        valid    = 1'b0;
        write_en = 1'b0;
        addr     = '0;
        wdata    = '0;

        $display("========================================");
        $display(" TEST 3: BOUNDARY ADDRESS & DATA PATTERN");
        $display("========================================");

        // -----------------------------------------------------
        // Reset
        // -----------------------------------------------------
        $display("Applying reset...");

        #20;

        rst_n = 1'b1;

        $display("Reset released.");
        $display("----------------------------------------");


        // =====================================================
        // WRITE 1
        // Address 0
        // Data 00000000
        // =====================================================

        $display("WRITE 1: Address = 0, Data = 00000000");

        @(negedge clk);

        valid    = 1'b1;
        write_en = 1'b1;
        addr     = 8'd0;
        wdata    = 32'h00000000;

        @(negedge clk);

        valid = 1'b0;

        wait(done == 1'b1);


        // =====================================================
        // WRITE 2
        // Address 1
        // Data FFFFFFFF
        // =====================================================

        $display("WRITE 2: Address = 1, Data = FFFFFFFF");

        @(negedge clk);

        valid    = 1'b1;
        write_en = 1'b1;
        addr     = 8'd1;
        wdata    = 32'hFFFFFFFF;

        @(negedge clk);

        valid = 1'b0;

        wait(done == 1'b1);


        // =====================================================
        // WRITE 3
        // Address 254
        // Data AAAAAAAA
        // =====================================================

        $display("WRITE 3: Address = 254, Data = AAAAAAAA");

        @(negedge clk);

        valid    = 1'b1;
        write_en = 1'b1;
        addr     = 8'd254;
        wdata    = 32'hAAAAAAAA;

        @(negedge clk);

        valid = 1'b0;

        wait(done == 1'b1);


        // =====================================================
        // WRITE 4
        // Address 255
        // Data 55555555
        // =====================================================

        $display("WRITE 4: Address = 255, Data = 55555555");

        @(negedge clk);

        valid    = 1'b1;
        write_en = 1'b1;
        addr     = 8'd255;
        wdata    = 32'h55555555;

        @(negedge clk);

        valid = 1'b0;

        wait(done == 1'b1);


        $display("----------------------------------------");
        $display("All boundary WRITE operations completed.");
        $display("----------------------------------------");


        // =====================================================
        // READ 1
        // Address 0
        // =====================================================

        $display("READ 1: Address = 0");

        @(negedge clk);

        valid    = 1'b1;
        write_en = 1'b0;
        addr     = 8'd0;

        @(negedge clk);

        valid = 1'b0;

        wait(done == 1'b1);

        #1;

        if (rdata === 32'h00000000)
            $display("PASS: Address 0 -> %h", rdata);
        else
            $display("FAIL: Address 0 -> Expected 00000000, Got %h", rdata);


        // =====================================================
        // READ 2
        // Address 1
        // =====================================================

        $display("READ 2: Address = 1");

        @(negedge clk);

        valid    = 1'b1;
        write_en = 1'b0;
        addr     = 8'd1;

        @(negedge clk);

        valid = 1'b0;

        wait(done == 1'b1);

        #1;

        if (rdata === 32'hFFFFFFFF)
            $display("PASS: Address 1 -> %h", rdata);
        else
            $display("FAIL: Address 1 -> Expected FFFFFFFF, Got %h", rdata);


        // =====================================================
        // READ 3
        // Address 254
        // =====================================================

        $display("READ 3: Address = 254");

        @(negedge clk);

        valid    = 1'b1;
        write_en = 1'b0;
        addr     = 8'd254;

        @(negedge clk);

        valid = 1'b0;

        wait(done == 1'b1);

        #1;

        if (rdata === 32'hAAAAAAAA)
            $display("PASS: Address 254 -> %h", rdata);
        else
            $display("FAIL: Address 254 -> Expected AAAAAAAA, Got %h", rdata);


        // =====================================================
        // READ 4
        // Address 255
        // =====================================================

        $display("READ 4: Address = 255");

        @(negedge clk);

        valid    = 1'b1;
        write_en = 1'b0;
        addr     = 8'd255;

        @(negedge clk);

        valid = 1'b0;

        wait(done == 1'b1);

        #1;

        if (rdata === 32'h55555555)
            $display("PASS: Address 255 -> %h", rdata);
        else
            $display("FAIL: Address 255 -> Expected 55555555, Got %h", rdata);


        // -----------------------------------------------------
        // Final result
        // -----------------------------------------------------

        $display("----------------------------------------");
        $display("TEST 3 COMPLETED");
        $display("----------------------------------------");

        #20;

        $finish;

    end

endmodule