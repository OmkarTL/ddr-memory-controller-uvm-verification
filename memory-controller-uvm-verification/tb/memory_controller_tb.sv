`timescale 1ns/1ps

module memory_controller_tb;

    parameter ADDR_WIDTH = 8;
    parameter DATA_WIDTH = 32;

    logic                  clk;
    logic                  rst_n;
    logic                  valid;
    logic                  write_en;
    logic [ADDR_WIDTH-1:0] addr;
    logic [DATA_WIDTH-1:0] wdata;

    logic [DATA_WIDTH-1:0] rdata;
    logic                  busy;
    logic                  done;

    integer pass_count;
    integer fail_count;

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
    // Clock
    // ---------------------------------------------------------
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // ---------------------------------------------------------
    // Main Test
    // ---------------------------------------------------------
    initial begin

        rst_n     = 1'b0;
        valid     = 1'b0;
        write_en  = 1'b0;
        addr      = '0;
        wdata     = '0;

        pass_count = 0;
        fail_count = 0;

        $display("========================================");
        $display(" TEST 5: READ-AFTER-WRITE VERIFICATION");
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
        // TEST PAIR 1
        // Address 50
        // =====================================================

        $display("WRITE 1: Address = 50, Data = CAFEBABE");

        @(negedge clk);

        valid    = 1'b1;
        write_en = 1'b1;
        addr     = 8'd50;
        wdata    = 32'hCAFEBABE;

        @(negedge clk);

        valid = 1'b0;

        wait(done == 1'b1);

        $display("READ 1: Address = 50");

        @(negedge clk);

        valid    = 1'b1;
        write_en = 1'b0;
        addr     = 8'd50;

        @(negedge clk);

        valid = 1'b0;

        wait(done == 1'b1);

        #1;

        if (rdata === 32'hCAFEBABE) begin
            $display("PASS: Address 50 -> %h", rdata);
            pass_count = pass_count + 1;
        end
        else begin
            $display("FAIL: Address 50 -> Expected CAFEBABE, Got %h", rdata);
            fail_count = fail_count + 1;
        end


        // =====================================================
        // TEST PAIR 2
        // Address 75
        // =====================================================

        $display("----------------------------------------");

        $display("WRITE 2: Address = 75, Data = 12345678");

        @(negedge clk);

        valid    = 1'b1;
        write_en = 1'b1;
        addr     = 8'd75;
        wdata    = 32'h12345678;

        @(negedge clk);

        valid = 1'b0;

        wait(done == 1'b1);

        $display("READ 2: Address = 75");

        @(negedge clk);

        valid    = 1'b1;
        write_en = 1'b0;
        addr     = 8'd75;

        @(negedge clk);

        valid = 1'b0;

        wait(done == 1'b1);

        #1;

        if (rdata === 32'h12345678) begin
            $display("PASS: Address 75 -> %h", rdata);
            pass_count = pass_count + 1;
        end
        else begin
            $display("FAIL: Address 75 -> Expected 12345678, Got %h", rdata);
            fail_count = fail_count + 1;
        end


        // =====================================================
        // TEST PAIR 3
        // Address 100
        // =====================================================

        $display("----------------------------------------");

        $display("WRITE 3: Address = 100, Data = DEADBEEF");

        @(negedge clk);

        valid    = 1'b1;
        write_en = 1'b1;
        addr     = 8'd100;
        wdata    = 32'hDEADBEEF;

        @(negedge clk);

        valid = 1'b0;

        wait(done == 1'b1);

        $display("READ 3: Address = 100");

        @(negedge clk);

        valid    = 1'b1;
        write_en = 1'b0;
        addr     = 8'd100;

        @(negedge clk);

        valid = 1'b0;

        wait(done == 1'b1);

        #1;

        if (rdata === 32'hDEADBEEF) begin
            $display("PASS: Address 100 -> %h", rdata);
            pass_count = pass_count + 1;
        end
        else begin
            $display("FAIL: Address 100 -> Expected DEADBEEF, Got %h", rdata);
            fail_count = fail_count + 1;
        end


        // =====================================================
        // TEST PAIR 4
        // Address 150
        // =====================================================

        $display("----------------------------------------");

        $display("WRITE 4: Address = 150, Data = AAAAAAAA");

        @(negedge clk);

        valid    = 1'b1;
        write_en = 1'b1;
        addr     = 8'd150;
        wdata    = 32'hAAAAAAAA;

        @(negedge clk);

        valid = 1'b0;

        wait(done == 1'b1);

        $display("READ 4: Address = 150");

        @(negedge clk);

        valid    = 1'b1;
        write_en = 1'b0;
        addr     = 8'd150;

        @(negedge clk);

        valid = 1'b0;

        wait(done == 1'b1);

        #1;

        if (rdata === 32'hAAAAAAAA) begin
            $display("PASS: Address 150 -> %h", rdata);
            pass_count = pass_count + 1;
        end
        else begin
            $display("FAIL: Address 150 -> Expected AAAAAAAA, Got %h", rdata);
            fail_count = fail_count + 1;
        end


        // -----------------------------------------------------
        // Final Result
        // -----------------------------------------------------

        $display("----------------------------------------");
        $display("TEST 5 RESULTS");
        $display("----------------------------------------");

        $display("PASS COUNT : %0d", pass_count);
        $display("FAIL COUNT : %0d", fail_count);

        if (fail_count == 0) begin
            $display("========================================");
            $display("          TEST 5 PASSED");
            $display("========================================");
        end
        else begin
            $display("========================================");
            $display("          TEST 5 FAILED");
            $display("========================================");
        end

        #20;

        $finish;

    end

endmodule