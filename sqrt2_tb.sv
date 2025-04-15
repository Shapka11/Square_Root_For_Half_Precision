`include "sqrt2.sv"

module sqrt2_tb; 
	reg [15:0] data_bus = 16'hzzzz;
	reg [3:0] counter = 0;
    reg clk = 0;
    reg enable = 0;
    wire is_nan, is_pinf, is_ninf, result;
    integer filename;

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
        $fstrobe(filename, "%0d\t%h", $time, io_data);

		if (counter < 4'd15 && clk == 1) begin
			counter = counter + 1;
		end

    end

	always @(negedge enable) begin
		counter = 0;
	end
 

    initial begin
        filename = $fopen("sqrt2_log.csv", "w");
        $display("=== Starting Test ===");

        data_bus = 16'h1234; // ans = 270b
        enable = 1;
        #2;
        data_bus = 16'hzzzz;
        #22;
        enable = 0;
        #2

        data_bus = 16'h6066; // ans = 4dee
        enable = 1;
        #2;
        data_bus = 16'hzzzz;
        #22;
        enable = 0;
        #2

        data_bus = 16'h10c7; // ans = 262e
		enable = 1;
        #2;
        data_bus = 16'hzzzz;
        #22;
        enable = 0;
        #2

        data_bus = 16'h0016; // ans = 14b0
		enable = 1;
        #2;
        data_bus = 16'hzzzz;
        #22;
        enable = 0;
        #2

        data_bus = 16'h002c; // ans = 16a2
		enable = 1;
        #2;
        data_bus = 16'hzzzz;
        #22;
        enable = 0;
        #2

        data_bus = 16'hffff; // ans = ffff
		enable = 1;
        #2;
        data_bus = 16'hzzzz;
        #22;
        enable = 0;
        #2

        data_bus = 16'h0000; // ans = 0000
		enable = 1;
        #2;
        data_bus = 16'hzzzz;
        #22;
        enable = 0;
        #2

        data_bus = 16'h8000; // ans = 8000
		enable = 1;
        #2;
        data_bus = 16'hzzzz;
        #22;
        enable = 0;
        #2

        data_bus = 16'h7c00; // ans = 7c00
		enable = 1;
        #2;
        data_bus = 16'hzzzz;
        #22;
        enable = 0;
        #2

        data_bus = 16'hfc00; // ans = fe00
		enable = 1;
        #2;
        data_bus = 16'hzzzz;
        #22;
        enable = 0;
        #2

        data_bus = 16'h7d00; // ans = 7f00
		enable = 1;
        #2;
        data_bus = 16'hzzzz;
        #22;
        enable = 0;
        #2

        $display("=== Test Complete ===");
        $fclose(filename);
        $finish;
    end

endmodule
