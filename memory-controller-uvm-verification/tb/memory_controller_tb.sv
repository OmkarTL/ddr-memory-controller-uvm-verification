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
    // Clock generation
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
        $display(" TEST 6: DATA INTEGRITY & MEMORY ISOLATION");
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
        // INITIAL WRITE OPERATIONS
        // =====================================================

        $display("WRITE 1: Address = 40, Data = AAAAAAAA");

        @(negedge clk);
        valid    = 1'b1;
        write_en = 1'b1;
        addr     = 8'd40;
        wdata    = 32'hAAAAAAAA;

        @(negedge clk);
        valid = 1'b0;

        wait(done == 1'b1);


        $display("WRITE 2: Address = 41, Data = 55555555");

        @(negedge clk);
        valid    = 1'b1;
        write_en = 1'b1;
        addr     = 8'd41;
        wdata    = 32'h55555555;

        @(negedge clk);
        valid = 1'b0;

        wait(done == 1'b1);


        $display("WRITE 3: Address = 42, Data = 12345678");

        @(negedge clk);
        valid    = 1'b1;
        write_en = 1'b1;
        addr     = 8'd42;
        wdata    = 32'h12345678;

        @(negedge clk);
        valid = 1'b0;

        wait(done == 1'b1);


        $display("WRITE 4: Address = 43, Data = DEADBEEF");

        @(negedge clk);
        valid    = 1'b1;
        write_en = 1'b1;
        addr     = 8'd43;
        wdata    = 32'hDEADBEEF;

        @(negedge clk);
        valid = 1'b0;

        wait(done == 1'b1);

        $display("----------------------------------------");
        $display("Initial memory contents written.");
        $display("----------------------------------------");


        // =====================================================
        // FIRST READBACK
        // =====================================================

        $display("READ 1: Address = 40");

        @(negedge clk);
        valid    = 1'b1;
        write_en = 1'b0;
        addr     = 8'd40;

        @(negedge clk);
        valid = 1'b0;

        wait(done == 1'b1);
        #1;

        if (rdata === 32'hAAAAAAAA) begin
            $display("PASS: Address 40 -> %h", rdata);
            pass_count = pass_count + 1;
        end
        else begin
            $display("FAIL: Address 40 -> Expected AAAAAAAA, Got %h", rdata);
            fail_count = fail_count + 1;
        end


        $display("READ 2: Address = 41");

        @(negedge clk);
        valid    = 1'b1;
        write_en = 1'b0;
        addr     = 8'd41;

        @(negedge clk);
        valid = 1'b0;

        wait(done == 1'b1);
        #1;

        if (rdata === 32'h55555555) begin
            $display("PASS: Address 41 -> %h", rdata);
            pass_count = pass_count + 1;
        end
        else begin
            $display("FAIL: Address 41 -> Expected 55555555, Got %h", rdata);
            fail_count = fail_count + 1;
        end


        $display("READ 3: Address = 42");

        @(negedge clk);
        valid    = 1'b1;
        write_en = 1'b0;
        addr     = 8'd42;

        @(negedge clk);
        valid = 1'b0;

        wait(done == 1'b1);
        #1;

        if (rdata === 32'h12345678) begin
            $display("PASS: Address 42 -> %h", rdata);
            pass_count = pass_count + 1;
        end
        else begin
            $display("FAIL: Address 42 -> Expected 12345678, Got %h", rdata);
            fail_count = fail_count + 1;
        end


        $display("READ 4: Address = 43");

        @(negedge clk);
        valid    = 1'b1;
        write_en = 1'b0;
        addr     = 8'd43;

        @(negedge clk);
        valid = 1'b0;

        wait(done == 1'b1);
        #1;

        if (rdata === 32'hDEADBEEF) begin
            $display("PASS: Address 43 -> %h", rdata);
            pass_count = pass_count + 1;
        end
        else begin
            $display("FAIL: Address 43 -> Expected DEADBEEF, Got %h", rdata);
            fail_count = fail_count + 1;
        end


        // =====================================================
        // OVERWRITE ONLY ADDRESS 41
        // =====================================================

        $display("----------------------------------------");
        $display("Overwriting Address 41...");
        $display("WRITE: Address = 41, Data = F0F0F0F0");

        @(negedge clk);
        valid    = 1'b1;
        write_en = 1'b1;
        addr     = 8'd41;
        wdata    = 32'hF0F0F0F0;

        @(negedge clk);
        valid = 1'b0;

        wait(done == 1'b1);

        $display("----------------------------------------");
        $display("Verifying memory isolation...");
        $display("----------------------------------------");


        // =====================================================
        // SECOND READBACK
        // =====================================================

        // Address 40 must remain unchanged
        $display("READ: Address = 40");

        @(negedge clk);
        valid    = 1'b1;
        write_en = 1'b0;
        addr     = 8'd40;

        @(negedge clk);
        valid = 1'b0;

        wait(done == 1'b1);
        #1;

        if (rdata === 32'hAAAAAAAA) begin
            $display("PASS: Address 40 unchanged -> %h", rdata);
            pass_count = pass_count + 1;
        end
        else begin
            $display("FAIL: Address 40 corrupted -> %h", rdata);
            fail_count = fail_count + 1;
        end


        // Address 41 must contain new data
        $display("READ: Address = 41");

        @(negedge clk);
        valid    = 1'b1;
        write_en = 1'b0;
        addr     = 8'd41;

        @(negedge clk);
        valid = 1'b0;

        wait(done == 1'b1);
        #1;

        if (rdata === 32'hF0F0F0F0) begin
            $display("PASS: Address 41 updated -> %h", rdata);
            pass_count = pass_count + 1;
        end
        else begin
            $display("FAIL: Address 41 update failed -> %h", rdata);
            fail_count = fail_count + 1;
        end


        // Address 42 must remain unchanged
        $display("READ: Address = 42");

        @(negedge clk);
        valid    = 1'b1;
        write_en = 1'b0;
        addr     = 8'd42;

        @(negedge clk);
        valid = 1'b0;

        wait(done == 1'b1);
        #1;

        if (rdata === 32'h12345678) begin
            $display("PASS: Address 42 unchanged -> %h", rdata);
            pass_count = pass_count + 1;
        end
        else begin
            $display("FAIL: Address 42 corrupted -> %h", rdata);
            fail_count = fail_count + 1;
        end


        // Address 43 must remain unchanged
        $display("READ: Address = 43");

        @(negedge clk);
        valid    = 1'b1;
        write_en = 1'b0;
        addr     = 8'd43;

        @(negedge clk);
        valid = 1'b0;

        wait(done == 1'b1);
        #1;

        if (rdata === 32'hDEADBEEF) begin
            $display("PASS: Address 43 unchanged -> %h", rdata);
            pass_count = pass_count + 1;
        end
        else begin
            $display("FAIL: Address 43 corrupted -> %h", rdata);
            fail_count = fail_count + 1;
        end


        // =====================================================
        // FINAL RESULT
        // =====================================================

        $display("----------------------------------------");
        $display("TEST 6 RESULTS");
        $display("----------------------------------------");

        $display("PASS COUNT : %0d", pass_count);
        $display("FAIL COUNT : %0d", fail_count);

        if (fail_count == 0) begin
            $display("========================================");
            $display("          TEST 6 PASSED");
            $display("========================================");
        end
        else begin
            $display("========================================");
            $display("          TEST 6 FAILED");
            $display("========================================");
        end

        #20;

        $finish;

    end

endmodule   