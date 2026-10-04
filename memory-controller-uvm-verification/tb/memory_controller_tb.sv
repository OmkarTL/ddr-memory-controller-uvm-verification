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

        // -----------------------------------------------------
        // Reset
        // -----------------------------------------------------
        $display("========================================");
        $display("   TEST 2: MULTIPLE MEMORY LOCATIONS");
        $display("========================================");

        $display("Applying reset...");

        #20;

        rst_n = 1'b1;

        $display("Reset released.");
        $display("----------------------------------------");


        // =====================================================
        // WRITE OPERATION 1
        // Address 0 -> 12345678
        // =====================================================

        $display("WRITE 1: Address = 0, Data = 12345678");

        @(negedge clk);

        valid    = 1'b1;
        write_en = 1'b1;
        addr     = 8'd0;
        wdata    = 32'h12345678;

        @(negedge clk);

        valid = 1'b0;

        wait(done == 1'b1);


        // =====================================================
        // WRITE OPERATION 2
        // Address 10 -> AAAAAAAA
        // =====================================================

        $display("WRITE 2: Address = 10, Data = AAAAAAAA");

        @(negedge clk);

        valid    = 1'b1;
        write_en = 1'b1;
        addr     = 8'd10;
        wdata    = 32'hAAAAAAAA;

        @(negedge clk);

        valid = 1'b0;

        wait(done == 1'b1);


        // =====================================================
        // WRITE OPERATION 3
        // Address 25 -> 55555555
        // =====================================================

        $display("WRITE 3: Address = 25, Data = 55555555");

        @(negedge clk);

        valid    = 1'b1;
        write_en = 1'b1;
        addr     = 8'd25;
        wdata    = 32'h55555555;

        @(negedge clk);

        valid = 1'b0;

        wait(done == 1'b1);


        // =====================================================
        // WRITE OPERATION 4
        // Address 100 -> DEADBEEF
        // =====================================================

        $display("WRITE 4: Address = 100, Data = DEADBEEF");

        @(negedge clk);

        valid    = 1'b1;
        write_en = 1'b1;
        addr     = 8'd100;
        wdata    = 32'hDEADBEEF;

        @(negedge clk);

        valid = 1'b0;

        wait(done == 1'b1);


        // =====================================================
        // WRITE OPERATION 5
        // Address 255 -> FFFFFFFF
        // =====================================================

        $display("WRITE 5: Address = 255, Data = FFFFFFFF");

        @(negedge clk);

        valid    = 1'b1;
        write_en = 1'b1;
        addr     = 8'd255;
        wdata    = 32'hFFFFFFFF;

        @(negedge clk);

        valid = 1'b0;

        wait(done == 1'b1);


        $display("----------------------------------------");
        $display("All WRITE operations completed.");
        $display("----------------------------------------");


        // =====================================================
        // READ OPERATION 1
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

        if (rdata === 32'h12345678)
            $display("PASS: Address 0 -> %h", rdata);
        else
            $display("FAIL: Address 0 -> Expected 12345678, Got %h", rdata);


        // =====================================================
        // READ OPERATION 2
        // =====================================================

        $display("READ 2: Address = 10");

        @(negedge clk);

        valid    = 1'b1;
        write_en = 1'b0;
        addr     = 8'd10;

        @(negedge clk);

        valid = 1'b0;

        wait(done == 1'b1);

        #1;

        if (rdata === 32'hAAAAAAAA)
            $display("PASS: Address 10 -> %h", rdata);
        else
            $display("FAIL: Address 10 -> Expected AAAAAAAA, Got %h", rdata);


        // =====================================================
        // READ OPERATION 3
        // =====================================================

        $display("READ 3: Address = 25");

        @(negedge clk);

        valid    = 1'b1;
        write_en = 1'b0;
        addr     = 8'd25;

        @(negedge clk);

        valid = 1'b0;

        wait(done == 1'b1);

        #1;

        if (rdata === 32'h55555555)
            $display("PASS: Address 25 -> %h", rdata);
        else
            $display("FAIL: Address 25 -> Expected 55555555, Got %h", rdata);


        // =====================================================
        // READ OPERATION 4
        // =====================================================

        $display("READ 4: Address = 100");

        @(negedge clk);

        valid    = 1'b1;
        write_en = 1'b0;
        addr     = 8'd100;

        @(negedge clk);

        valid = 1'b0;

        wait(done == 1'b1);

        #1;

        if (rdata === 32'hDEADBEEF)
            $display("PASS: Address 100 -> %h", rdata);
        else
            $display("FAIL: Address 100 -> Expected DEADBEEF, Got %h", rdata);


        // =====================================================
        // READ OPERATION 5
        // =====================================================

        $display("READ 5: Address = 255");

        @(negedge clk);

        valid    = 1'b1;
        write_en = 1'b0;
        addr     = 8'd255;

        @(negedge clk);

        valid = 1'b0;

        wait(done == 1'b1);

        #1;

        if (rdata === 32'hFFFFFFFF)
            $display("PASS: Address 255 -> %h", rdata);
        else
            $display("FAIL: Address 255 -> Expected FFFFFFFF, Got %h", rdata);


        // -----------------------------------------------------
        // Final result
        // -----------------------------------------------------

        $display("----------------------------------------");
        $display("TEST 2 COMPLETED");
        $display("----------------------------------------");
        #20;
        $finish;
    end
endmodule