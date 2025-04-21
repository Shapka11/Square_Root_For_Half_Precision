`include "sqrt2.sv"

module sqrt2_tb;
    reg [15:0] data_bus = 16'hzzzz;
    reg [3:0] counter = 0;
    reg clk = 0;
    reg enable = 0;
    wire is_nan, is_pinf, is_ninf, result;
    integer testfile, logfile;
    integer test_num = 0;
    integer passed = 0;
    integer failed = 0;

    wire [15:0] io_data;
    assign io_data = (counter > 1) ? 16'hzzzz : data_bus;

    sqrt2 obj (
        .IO_DATA(io_data),
        .IS_NAN(is_nan),
        .IS_PINF(is_pinf),
        .IS_NINF(is_ninf),
        .RESULT(result),
        .CLK(clk),
        .ENABLE(enable)
    );

    always #1 clk = ~clk;

    always @(posedge clk) begin
        $fstrobe(logfile, "%0d\t\t%h\t%h\t\t%h\t\t%h\t\t%h", $time, io_data, is_nan, is_pinf, is_ninf, result);
    end

    initial begin
        testfile = $fopen("test_cases.txt", "r");
        logfile = $fopen("sqrt2_log.csv", "w");

        if (testfile == 0) begin
            $display("Error: Could not open test_cases.txt");
            $finish;
        end
        
        $display("=== Starting Test ===");
        $fdisplay(logfile, "Time\tIO_Data\tIs_NaN\tIs_PInf\tIs_NInf\tResult");
        
        // added all positive normal and denormal number + some special cases(nan, +-inf, +-zero, neg_num)
        while (!$feof(testfile)) begin
            reg [15:0] test_value;
            reg [15:0] test_ans;
            reg [15:0] my_ans;
            integer scan_res;

            scan_res = $fscanf(testfile, "%h %h", test_value, test_ans);

            test_num = test_num + 1;

            data_bus = test_value;
            enable = 1;
            #2;
            data_bus = 16'hzzzz;
            #22;
            my_ans = io_data;
            enable = 0;
            #2
                    
            if (my_ans === test_ans) begin
                passed = passed + 1;
            end else begin
                failed = failed + 1;
            end

        end
        
        $display("\n=== Test Summary ===");
        $display("Total tests: %0d", test_num);
        $display("Passed: %0d", passed);
        $display("Failed: %0d", failed);

        $fclose(testfile);
        $fclose(logfile);
        $finish;
    end

endmodule
