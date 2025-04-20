module sqrt2(
    inout wire [15:0] IO_DATA,
    output wire IS_NAN,
    output wire IS_PINF,
    output wire IS_NINF,
    output wire RESULT,
    input wire CLK,
    input wire ENABLE
    );

    reg [4:0] exp = 0;
    reg [11:0] mant = 0;
    reg sign = 0;
    reg [15:0] data_out = 0;
    reg [15:0] data_spec_case_num = 0;
    reg [4:0] shift_mant = 0;

    reg is_spec_case = 0;
    reg is_pos_inf = 0;
    reg is_neg_zero = 0;
    reg is_pos_zero = 0;
    reg is_nan = 0;
    reg is_neg_num = 0;
    reg is_denorm_num = 0;
    reg is_result = 0;

    reg [3:0] counter = 0;
    reg [11:0] res_mant = 0;
    reg [23:0] remainder = 0;

    assign IS_NAN = (is_nan == 1 || is_neg_num == 1) ? 1 : 0;
    assign IS_PINF = is_pos_inf;
    assign IS_NINF = 0;
    assign RESULT = is_result;
    assign IO_DATA = (counter < 2) ? 16'bzzzz : data_out;

    always @(negedge ENABLE) begin
        exp = 0;
        mant = 0;
        sign = 0;
        data_out = 0;
        shift_mant = 0;
        data_spec_case_num = 0;
        is_result = 0;
        is_nan = 0;
        is_pos_inf = 0;
        is_neg_zero = 0;
        is_pos_zero = 0;
        is_neg_num = 0;
        is_denorm_num = 0;
        is_spec_case = 0;
        counter = 0;
        res_mant = 0;
        remainder = 0;
    end

    always @(posedge CLK) begin
        if (ENABLE) begin

            if (counter != 4'd15) begin // при counter == 15 он перестанет считать
                counter = counter + 1;
            end
            
            if (counter == 4'd1) begin // на 1 такте - парсинг
                sign = IO_DATA[15];
                exp = IO_DATA[14:10];
                mant = IO_DATA[9:0];
                is_nan = (exp == 5'b11111 && mant != 0);
                is_pos_inf = (exp == 5'b11111 && mant == 0 && sign == 0);
                is_pos_zero = (sign == 0 && mant == 0 && exp == 0);
                is_neg_zero = (sign == 1 && mant == 0 && exp == 0);
                is_neg_num = (sign == 1 && is_neg_zero == 0 && is_nan == 0);
                is_spec_case = (is_nan || is_pos_inf || is_neg_zero);
                is_denorm_num = (sign == 0 && exp == 0 && mant != 0);
                data_spec_case_num = IO_DATA;
                
                //install data
                if (is_denorm_num) begin
                    
                    if (mant[9] == 1) begin // exp = -15
                        shift_mant = 1;
                    end else if (mant[8] == 1) begin // exp = -16
                        shift_mant = 2;
                    end else if (mant[7] == 1) begin // exp = -17
                        shift_mant = 3;
                    end else if (mant[6] == 1) begin // exp = -18
                        shift_mant = 4;
                    end else if (mant[5] == 1) begin // exp = -19
                        shift_mant = 5;
                    end else if (mant[4] == 1) begin // exp = -20
                        shift_mant = 6;
                    end else if (mant[3] == 1) begin // exp = -21
                        shift_mant = 7;
                    end else if (mant[2] == 1) begin // exp = -22
                        shift_mant = 8;
                    end else if (mant[1] == 1) begin // exp = -23
                        shift_mant = 9;
                    end else if (mant[0] == 1) begin // exp = -24
                        shift_mant = 10;
                    end

                    mant = mant << shift_mant;
                    exp = 5'd15 - ((5'd14 + shift_mant) >> 1);

                    if (shift_mant[0] == 1) begin
                        exp = exp - 1;
                        mant = mant << 1;
                    end

                end else begin
                    mant[10] = 1;
                    if (exp[0] == 0) begin
                        mant = mant << 1;
                    end
                    
                    if (exp >= 5'd15) begin
                        exp = 5'd15 + ((exp - 5'd15) >> 1);
                    end else begin
                        exp = 5'd15 - ((5'd15 - exp) >> 1);
                    end
                    
                    if (mant[11] == 1 && exp < 4'd15) begin
                        exp = exp - 1;
                    end
                end
            end

            if (counter != 4'd1 && is_result == 0 && is_spec_case == 0) begin // вычисление корня
                remainder = (remainder << 2) + mant[11:10];
                res_mant = res_mant << 1;

                if (remainder >= (res_mant << 1) + 1) begin
                    remainder = remainder - ((res_mant << 1) + 1);
                    res_mant = res_mant + 1;
                end

                mant = mant << 2;
            end

            if (counter == 4'd12 || (is_spec_case && counter > 1)) begin
                is_result = 1;
            end

            if (counter > 4'd1) begin //вывод ответа со 2 такта

                if (is_pos_inf || is_neg_zero || is_pos_zero) begin
                    data_out = data_spec_case_num;
                end else if (is_neg_num) begin
                    data_out = 16'hfe00;
                end else if (is_nan) begin
                    data_out = data_spec_case_num;
                    data_out[9] = 1;
                end else begin
                    data_out[14:10] = exp;
                    data_out[9:0] = res_mant;
                end

            end

        end

    end

endmodule
