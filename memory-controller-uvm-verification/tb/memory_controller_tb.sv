`timescale 1ns/1ps

module memory_controller_tb;

    // ---------------------------------------------------------
    // Parameters and testbench signals
    // ---------------------------------------------------------
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

    integer total_pass_count;
    integer total_fail_count;
    integer test_pass_count;
    integer test_fail_count;

    // ---------------------------------------------------------
    // Device Under Test (DUT)
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
    // Clock generation: 10 ns period
    // ---------------------------------------------------------
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // ---------------------------------------------------------
    // Common write transaction
    // ---------------------------------------------------------
    task automatic write_memory(
        input logic [ADDR_WIDTH-1:0] wr_addr,
        input logic [DATA_WIDTH-1:0] wr_data
    );
    begin
        @(negedge clk);
        valid    = 1'b1;
        write_en = 1'b1;
        addr     = wr_addr;
        wdata    = wr_data;

        @(negedge clk);
        valid = 1'b0;

        wait (done == 1'b1);
        @(negedge clk);
    end
    endtask

    // ---------------------------------------------------------
    // Common read transaction
    // ---------------------------------------------------------
    task automatic read_memory(
        input logic [ADDR_WIDTH-1:0] rd_addr
    );
    begin
        @(negedge clk);
        valid    = 1'b1;
        write_en = 1'b0;
        addr     = rd_addr;

        @(negedge clk);
        valid = 1'b0;

        wait (done == 1'b1);
        #1;
    end
    endtask

    // ---------------------------------------------------------
    // Compare read data and update test/global counters
    // ---------------------------------------------------------
    task automatic check_data(
        input string check_name,
        input logic [DATA_WIDTH-1:0] expected_data
    );
    begin
        if (rdata === expected_data) begin
            $display("PASS: %s | Expected = %h | Received = %h",
                     check_name, expected_data, rdata);
            test_pass_count  = test_pass_count + 1;
            total_pass_count = total_pass_count + 1;
        end
        else begin
            $display("FAIL: %s | Expected = %h | Received = %h",
                     check_name, expected_data, rdata);
            test_fail_count  = test_fail_count + 1;
            total_fail_count = total_fail_count + 1;
        end
    end
    endtask

    // ---------------------------------------------------------
    // Check controller outputs during reset
    // ---------------------------------------------------------
    task automatic check_reset_outputs(input string check_name);
    begin
        #1;
        if ((busy === 1'b0) &&
            (done === 1'b0) &&
            (rdata === {DATA_WIDTH{1'b0}})) begin
            $display("PASS: %s", check_name);
            test_pass_count  = test_pass_count + 1;
            total_pass_count = total_pass_count + 1;
        end
        else begin
            $display("FAIL: %s | busy=%b done=%b rdata=%h",
                     check_name, busy, done, rdata);
            test_fail_count  = test_fail_count + 1;
            total_fail_count = total_fail_count + 1;
        end
    end
    endtask

    // ---------------------------------------------------------
    // Apply a fresh controller reset between independent tests.
    // This resets the controller; memory retention is checked in
    // Test 7 and is not assumed to be cleared by this reset.
    // ---------------------------------------------------------
    task automatic reset_controller;
    begin
        @(negedge clk);
        valid    = 1'b0;
        write_en = 1'b0;
        addr     = '0;
        wdata    = '0;
        rst_n    = 1'b0;
        #20;
        rst_n = 1'b1;
        @(negedge clk);
    end
    endtask

    // ---------------------------------------------------------
    // Start and finish each test's individual result accounting
    // ---------------------------------------------------------
    task automatic start_test(input string test_name);
    begin
        test_pass_count = 0;
        test_fail_count = 0;
        $display("\n==================================================");
        $display(" %s", test_name);
        $display("==================================================");
    end
    endtask

    task automatic finish_test(input string test_name);
    begin
        $display("----------------------------------------");
        $display("%s: PASS=%0d | FAIL=%0d",
                 test_name, test_pass_count, test_fail_count);
        if (test_fail_count == 0)
            $display("RESULT: %s PASSED", test_name);
        else
            $display("RESULT: %s FAILED", test_name);
        $display("==================================================");
    end
    endtask

    // =========================================================
    // TEST 1: BASIC WRITE AND READ
    // =========================================================
    task automatic test_1_basic_write_read;
    begin
        start_test("TEST 1: BASIC WRITE AND READ");

        $display("WRITE: Address = 10, Data = AAAAAAAA");
        write_memory(8'd10, 32'hAAAAAAAA);

        $display("READ: Address = 10");
        read_memory(8'd10);
        check_data("Test 1 basic readback", 32'hAAAAAAAA);

        finish_test("TEST 1");
    end
    endtask

    // =========================================================
    // TEST 2: MULTIPLE MEMORY LOCATIONS
    // =========================================================
    task automatic test_2_multiple_locations;
    begin
        start_test("TEST 2: MULTIPLE MEMORY LOCATIONS");

        $display("Writing five different memory locations...");
        write_memory(8'd0,   32'h12345678);
        write_memory(8'd10,  32'hAAAAAAAA);
        write_memory(8'd25,  32'h55555555);
        write_memory(8'd100, 32'hDEADBEEF);
        write_memory(8'd255, 32'hFFFFFFFF);

        read_memory(8'd0);
        check_data("Address 0", 32'h12345678);

        read_memory(8'd10);
        check_data("Address 10", 32'hAAAAAAAA);

        read_memory(8'd25);
        check_data("Address 25", 32'h55555555);

        read_memory(8'd100);
        check_data("Address 100", 32'hDEADBEEF);

        read_memory(8'd255);
        check_data("Address 255", 32'hFFFFFFFF);

        finish_test("TEST 2");
    end
    endtask

    // =========================================================
    // TEST 3: BOUNDARY ADDRESS AND DATA PATTERN
    // =========================================================
    task automatic test_3_boundary_addresses;
    begin
        start_test("TEST 3: BOUNDARY ADDRESS AND DATA PATTERN");

        write_memory(8'd0,   32'h00000000);
        write_memory(8'd1,   32'hFFFFFFFF);
        write_memory(8'd254, 32'hAAAAAAAA);
        write_memory(8'd255, 32'h55555555);

        read_memory(8'd0);
        check_data("Lowest address 0 / zero data", 32'h00000000);

        read_memory(8'd1);
        check_data("Address 1 / all-ones data", 32'hFFFFFFFF);

        read_memory(8'd254);
        check_data("Address 254 / alternating data A", 32'hAAAAAAAA);

        read_memory(8'd255);
        check_data("Highest address 255 / alternating data 5", 32'h55555555);

        finish_test("TEST 3");
    end
    endtask

    // =========================================================
    // TEST 4: BACK-TO-BACK READ/WRITE
    // =========================================================
    task automatic test_4_back_to_back;
    begin
        start_test("TEST 4: BACK-TO-BACK READ/WRITE");

        $display("Performing three successive writes...");
        write_memory(8'd10, 32'h11111111);
        write_memory(8'd20, 32'h22222222);
        write_memory(8'd30, 32'h33333333);

        read_memory(8'd10);
        check_data("Back-to-back read address 10", 32'h11111111);

        read_memory(8'd20);
        check_data("Back-to-back read address 20", 32'h22222222);

        read_memory(8'd30);
        check_data("Back-to-back read address 30", 32'h33333333);

        finish_test("TEST 4");
    end
    endtask

    // =========================================================
    // TEST 5: READ-AFTER-WRITE VERIFICATION
    // =========================================================
    task automatic test_5_read_after_write;
    begin
        start_test("TEST 5: READ-AFTER-WRITE VERIFICATION");

        write_memory(8'd50,  32'hCAFEBABE);
        read_memory(8'd50);
        check_data("Read-after-write address 50", 32'hCAFEBABE);

        write_memory(8'd75,  32'h12345678);
        read_memory(8'd75);
        check_data("Read-after-write address 75", 32'h12345678);

        write_memory(8'd100, 32'hDEADBEEF);
        read_memory(8'd100);
        check_data("Read-after-write address 100", 32'hDEADBEEF);

        write_memory(8'd150, 32'hAAAAAAAA);
        read_memory(8'd150);
        check_data("Read-after-write address 150", 32'hAAAAAAAA);

        finish_test("TEST 5");
    end
    endtask

    // =========================================================
    // TEST 6: DATA INTEGRITY AND MEMORY ISOLATION
    // =========================================================
    task automatic test_6_data_integrity_isolation;
    begin
        start_test("TEST 6: DATA INTEGRITY AND MEMORY ISOLATION");

        // Initial writes
        write_memory(8'd40, 32'hAAAAAAAA);
        write_memory(8'd41, 32'h55555555);
        write_memory(8'd42, 32'h12345678);
        write_memory(8'd43, 32'hDEADBEEF);

        // First readback
        read_memory(8'd40);
        check_data("Initial read address 40", 32'hAAAAAAAA);

        read_memory(8'd41);
        check_data("Initial read address 41", 32'h55555555);

        read_memory(8'd42);
        check_data("Initial read address 42", 32'h12345678);

        read_memory(8'd43);
        check_data("Initial read address 43", 32'hDEADBEEF);

        // Overwrite only address 41
        $display("Overwriting address 41 with F0F0F0F0...");
        write_memory(8'd41, 32'hF0F0F0F0);

        // Other locations must remain unchanged
        read_memory(8'd40);
        check_data("Isolation: address 40 unchanged", 32'hAAAAAAAA);

        read_memory(8'd41);
        check_data("Isolation: address 41 updated", 32'hF0F0F0F0);

        read_memory(8'd42);
        check_data("Isolation: address 42 unchanged", 32'h12345678);

        read_memory(8'd43);
        check_data("Isolation: address 43 unchanged", 32'hDEADBEEF);

        finish_test("TEST 6");
    end
    endtask

    // =========================================================
    // TEST 7: RESET BEHAVIOR AND MEMORY RETENTION
    // =========================================================
    task automatic test_7_reset_behavior;
    begin
        start_test("TEST 7: RESET BEHAVIOR VERIFICATION");

        // Initial reset is asserted here and checked.
        @(negedge clk);
        rst_n = 1'b0;
        valid = 1'b0;
        write_en = 1'b0;
        #20;
        check_reset_outputs("Initial reset outputs");

        rst_n = 1'b1;
        @(negedge clk);

        // Write data and verify it before the second reset.
        $display("WRITE: Address = 60, Data = ABCD1234");
        write_memory(8'd60, 32'hABCD1234);

        read_memory(8'd60);
        check_data("Data before reset at address 60", 32'hABCD1234);

        // Apply reset while preserving the memory contents.
        @(negedge clk);
        $display("Applying reset again...");
        rst_n = 1'b0;
        #1;
        check_reset_outputs("Controller outputs cleared by reset");

        #19;
        rst_n = 1'b1;
        @(negedge clk);

        // Verify that reset did not erase the stored memory data.
        $display("Checking memory retention after reset...");
        read_memory(8'd60);
        check_data("Memory retention at address 60", 32'hABCD1234);

        finish_test("TEST 7");
    end
    endtask

    // =========================================================
    // MAIN TEST SEQUENCE
    // =========================================================
    initial begin
        // Initialize all testbench signals and counters.
        rst_n             = 1'b0;
        valid             = 1'b0;
        write_en          = 1'b0;
        addr              = '0;
        wdata             = '0;
        total_pass_count  = 0;
        total_fail_count  = 0;
        test_pass_count   = 0;
        test_fail_count   = 0;

        $display("\n***********************************************");
        $display(" MEMORY CONTROLLER - MASTER VERIFICATION TEST");
        $display("***********************************************");

        // Initial reset before starting the test suite.
        #20;
        rst_n = 1'b1;
        @(negedge clk);

        test_1_basic_write_read();

        reset_controller();
        test_2_multiple_locations();

        reset_controller();
        test_3_boundary_addresses();

        reset_controller();
        test_4_back_to_back();

        reset_controller();
        test_5_read_after_write();

        reset_controller();
        test_6_data_integrity_isolation();

        reset_controller();
        test_7_reset_behavior();

        // Overall verification summary.
        $display("\n***********************************************");
        $display("           FINAL VERIFICATION SUMMARY");
        $display("***********************************************");
        $display("TOTAL PASSED CHECKS : %0d", total_pass_count);
        $display("TOTAL FAILED CHECKS : %0d", total_fail_count);

        if (total_fail_count == 0)
            $display("OVERALL RESULT      : ALL CHECKS PASSED");
        else
            $display("OVERALL RESULT      : VERIFICATION FAILED");

        $display("***********************************************");

        #20;
        $finish;
    end

endmodule