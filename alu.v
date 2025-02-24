`timescale 1ns/10ps

module ALU_and_or_not (
    input [31:0] A, B,
    input [3:0] operation,
    output reg [31:0] result,
    output reg zero,
    output reg carry
);
    always @(*) begin
    case (operation)
        4'b0000: {carry, result} = {1'b0, A & B}; // AND
        4'b0001: {carry, result} = {1'b0, A | B}; // OR
        4'b0010: {carry, result} = {1'b0, ~A};    // NOT
        default: {carry, result} = {1'b0, 32'b0};
    endcase
    zero = (result == 32'b0);
end

endmodule

module ALU_add_sub (
    input [31:0] A, B,
    input add_sub,
    output [31:0] result,
    output carry,
    output zero
);
    wire [31:0] sum, difference;
    wire carry_add, carry_sub;

    assign {carry_add, sum} = A + B;
    assign {carry_sub, difference} = A - B;

    assign result = (add_sub == 0) ? sum : difference;
    assign carry = (add_sub == 0) ? carry_add : carry_sub;
    assign zero = (result == 32'b0);
endmodule

module ALU_mul (
    input signed [31:0] A, B,
    output reg signed [63:0] product
);
    reg signed [63:0] product_reg;
    reg signed [33:0] multiplier_ext;
    reg signed [32:0] multiplicand_ext;
    integer i;

    always @(*) 
    begin
        product_reg = 64'b0;
        multiplier_ext = {B, 2'b00};
        multiplicand_ext = {A, 1'b0};

        for (i = 0; i < 32; i = i + 1) begin
            case (multiplier_ext[2:0])
                3'b001, 3'b010: product_reg = product_reg + (multiplicand_ext << i);
                3'b011: product_reg = product_reg + ((multiplicand_ext << i) << 1);
                3'b100: product_reg = product_reg - ((multiplicand_ext << i) << 1);
                3'b101, 3'b110: product_reg = product_reg - (multiplicand_ext << i);
            endcase
            multiplier_ext = multiplier_ext >>> 1;
        end
    end

    assign product = product_reg;
endmodule

module ALU_div (
    input [31:0] A, B,
    output reg [31:0] quotient,
    output reg [31:0] remainder
);
    integer i;
    reg [63:0] dividend;
    
    always @(*) 
    begin
        dividend = {32'b0, A}; 
        quotient = 32'b0;
        remainder = 32'b0;

        for (i = 31; i >= 0; i = i - 1) begin
            dividend = dividend << 1;
            dividend[0] = A[i];

            if (dividend[63:32] >= B) begin
                dividend[63:32] = dividend[63:32] - B;
                quotient[i] = 1;
            end
        end

        remainder = dividend[63:32];
    end
endmodule