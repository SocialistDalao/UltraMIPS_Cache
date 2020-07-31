//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/18 16:51:29
// Design Name: 
// Module Name: mul
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module mul(
    input clk,
    input resetn,
    input flush,
    input flush_cause,
    input[31:0] x, // 被乘数
    input[31:0] y, // 乘数
    input s, // 1为有符号乘法，0为无符号乘法
    output[63:0] z // 积
    );
    
    wire[32:0] x_ext; // 根据乘法属性对x进行符号扩展或零扩展
    wire[33:0] y_ext; // 根据乘法属性对y进行符号扩展或零扩展
    wire[63:0] pp0, pp1, pp2, pp3, pp4, pp5, pp6, pp7, pp8, pp9, pp10, pp11, pp12, pp13, pp14, pp15, pp16; // 改进的Booth算法生成的部分积
    wire[63:0] pp17;
    wire[33:0] c;
    // 寄存器输入和输出
    wire[63:0] pp0_in, pp1_in, pp2_in, pp3_in, pp4_in, pp5_in, pp6_in, pp7_in, pp8_in, pp9_in, pp10_in, pp11_in, pp12_in, pp13_in, pp14_in, pp15_in, pp16_in, pp17_in;
    reg[63:0] pp0_out, pp1_out, pp2_out, pp3_out, pp4_out, pp5_out, pp6_out, pp7_out, pp8_out, pp9_out, pp10_out, pp11_out, pp12_out, pp13_out, pp14_out, pp15_out, pp16_out, pp17_out;
    // 第一级压缩结果
    wire[63:0] s_l1_1, s_l1_2, s_l1_3, s_l1_4, s_l1_5, s_l1_6;
    wire[63:0] c_l1_1, c_l1_2, c_l1_3, c_l1_4, c_l1_5, c_l1_6;
    // 第二级压缩结果
    wire[63:0] s_l2_1, s_l2_2, s_l2_3, s_l2_4;
    wire[63:0] c_l2_1, c_l2_2, c_l2_3, c_l2_4;
    // 第三级压缩结果
    wire[63:0] s_l3_1, s_l3_2;
    wire[63:0] c_l3_1, c_l3_2;
    // 第四级压缩结果
    wire[63:0] s_l4_1, s_l4_2;
    wire[63:0] c_l4_1, c_l4_2;
    // 第五级压缩结果
    wire[63:0] s_l5_1;
    wire[63:0] c_l5_1;
    // 第六级压缩结果
    wire[63:0] s_l6_1;
    wire[63:0] c_l6_1;
    
    wire clear;
    
    // 根据有符号还是无符号乘法对x进行扩展
    assign x_ext = s ? {x[31], x} : {1'b0, x};
    assign y_ext = s ? {{2{y[31]}}, y} : {2'b00, y};
    
    assign clear = resetn == `RstEnable || flush == `Flush && flush_cause == `Exception;
    
    // 生成部分积
    booth2 u_b0(.x(x_ext), .y({y_ext[1:0], 1'b0}), .z(pp0), .c(c[1:0]));
    booth2 u_b1(.x(x_ext), .y(y_ext[3:1]), .z(pp1), .c(c[3:2]));
    booth2 u_b2(.x(x_ext), .y(y_ext[5:3]), .z(pp2), .c(c[5:4]));
    booth2 u_b3(.x(x_ext), .y(y_ext[7:5]), .z(pp3), .c(c[7:6]));
    booth2 u_b4(.x(x_ext), .y(y_ext[9:7]), .z(pp4), .c(c[9:8]));
    booth2 u_b5(.x(x_ext), .y(y_ext[11:9]), .z(pp5), .c(c[11:10]));
    booth2 u_b6(.x(x_ext), .y(y_ext[13:11]), .z(pp6), .c(c[13:12]));
    booth2 u_b7(.x(x_ext), .y(y_ext[15:13]), .z(pp7), .c(c[15:14]));
    booth2 u_b8(.x(x_ext), .y(y_ext[17:15]), .z(pp8), .c(c[17:16]));
    booth2 u_b9(.x(x_ext), .y(y_ext[19:17]), .z(pp9), .c(c[19:18]));
    booth2 u_b10(.x(x_ext), .y(y_ext[21:19]), .z(pp10), .c(c[21:20]));
    booth2 u_b11(.x(x_ext), .y(y_ext[23:21]), .z(pp11), .c(c[23:22]));
    booth2 u_b12(.x(x_ext), .y(y_ext[25:23]), .z(pp12), .c(c[25:24]));
    booth2 u_b13(.x(x_ext), .y(y_ext[27:25]), .z(pp13), .c(c[27:26]));
    booth2 u_b14(.x(x_ext), .y(y_ext[29:27]), .z(pp14), .c(c[29:28]));
    booth2 u_b15(.x(x_ext), .y(y_ext[31:29]), .z(pp15), .c(c[31:30]));
    booth2 u_b16(.x(x_ext), .y(y_ext[33:31]), .z(pp16), .c(c[33:32]));
    assign pp17 = {30'b0, c};
    
    assign pp0_in = pp0;
    assign pp1_in = {pp1[61:0], 2'b0};
    assign pp2_in = {pp2[59:0], 4'b0};
    assign pp3_in = {pp3[57:0], 6'b0};
    assign pp4_in = {pp4[55:0], 8'b0};
    assign pp5_in = {pp5[53:0], 10'b0};
    assign pp6_in = {pp6[51:0], 12'b0};
    assign pp7_in = {pp7[49:0], 14'b0};
    assign pp8_in = {pp8[47:0], 16'b0};
    assign pp9_in = {pp9[45:0], 18'b0};
    assign pp10_in = {pp10[43:0], 20'b0};
    assign pp11_in = {pp11[41:0], 22'b0};
    assign pp12_in = {pp12[39:0], 24'b0};
    assign pp13_in = {pp13[37:0], 26'b0};
    assign pp14_in = {pp14[35:0], 28'b0};
    assign pp15_in = {pp15[33:0], 30'b0};
    assign pp16_in = {pp16[31:0], 32'b0};
    assign pp17_in = pp17;
    
    // 寄存器
    always @ (posedge clk) begin
        if (clear) begin
            pp0_out <= {`ZeroWord, `ZeroWord};
            pp1_out <= {`ZeroWord, `ZeroWord};
            pp2_out <= {`ZeroWord, `ZeroWord};
            pp3_out <= {`ZeroWord, `ZeroWord};
            pp4_out <= {`ZeroWord, `ZeroWord};
            pp5_out <= {`ZeroWord, `ZeroWord};
            pp6_out <= {`ZeroWord, `ZeroWord};
            pp7_out <= {`ZeroWord, `ZeroWord};
            pp8_out <= {`ZeroWord, `ZeroWord};
            pp9_out <= {`ZeroWord, `ZeroWord};
            pp10_out <= {`ZeroWord, `ZeroWord};
            pp11_out <= {`ZeroWord, `ZeroWord};
            pp12_out <= {`ZeroWord, `ZeroWord};
            pp13_out <= {`ZeroWord, `ZeroWord};
            pp14_out <= {`ZeroWord, `ZeroWord};
            pp15_out <= {`ZeroWord, `ZeroWord};
            pp16_out <= {`ZeroWord, `ZeroWord};
            pp17_out <= {`ZeroWord, `ZeroWord};
        end else begin
            pp0_out <= pp0_in;
            pp1_out <= pp1_in;
            pp2_out <= pp2_in;
            pp3_out <= pp3_in;
            pp4_out <= pp4_in;
            pp5_out <= pp5_in;
            pp6_out <= pp6_in;
            pp7_out <= pp7_in;
            pp8_out <= pp8_in;
            pp9_out <= pp9_in;
            pp10_out <= pp10_in;
            pp11_out <= pp11_in;
            pp12_out <= pp12_in;
            pp13_out <= pp13_in;
            pp14_out <= pp14_in;
            pp15_out <= pp15_in;
            pp16_out <= pp16_in;
            pp17_out <= pp17_in;
        end
    end
    
    // 压缩部分积
    csa u_csa_l1_1(
        .x(pp0_out),
        .y(pp1_out),
        .z(pp2_out),
        .s(s_l1_1),
        .c(c_l1_1)
        );
    csa u_csa_l1_2(
        .x(pp3_out),
        .y(pp4_out),
        .z(pp5_out),
        .s(s_l1_2),
        .c(c_l1_2)
        );
    csa u_csa_l1_3(
        .x(pp6_out),
        .y(pp7_out),
        .z(pp8_out),
        .s(s_l1_3),
        .c(c_l1_3)
        );
    csa u_csa_l1_4(
        .x(pp9_out),
        .y(pp10_out),
        .z(pp11_out),
        .s(s_l1_4),
        .c(c_l1_4)
        );
    csa u_csa_l1_5(
        .x(pp12_out),
        .y(pp13_out),
        .z(pp14_out),
        .s(s_l1_5),
        .c(c_l1_5)
        );
    csa u_csa_l1_6(
        .x(pp15_out),
        .y(pp16_out),
        .z(pp17_out),
        .s(s_l1_6),
        .c(c_l1_6)
        );
    csa u_csa_l2_1(
        .x(s_l1_1),
        .y(s_l1_2),
        .z(s_l1_3),
        .s(s_l2_1),
        .c(c_l2_1)
        );
    csa u_csa_l2_2(
        .x(s_l1_4),
        .y(s_l1_5),
        .z(s_l1_6),
        .s(s_l2_2),
        .c(c_l2_2)
        );
    csa u_csa_l2_3(
        .x({c_l1_1[62:0], 1'b0}),
        .y({c_l1_2[62:0], 1'b0}),
        .z({c_l1_3[62:0], 1'b0}),
        .s(s_l2_3),
        .c(c_l2_3)
        );
    csa u_csa_l2_4(
        .x({c_l1_4[62:0], 1'b0}),
        .y({c_l1_5[62:0], 1'b0}),
        .z({c_l1_6[62:0], 1'b0}),
        .s(s_l2_4),
        .c(c_l2_4)
        );
    csa u_csa_l3_1(
        .x(s_l2_1),
        .y(s_l2_2),
        .z(s_l2_3),
        .s(s_l3_1),
        .c(c_l3_1)
        );
    csa u_csa_l3_2(
        .x(s_l2_4),
        .y({c_l2_1[62:0], 1'b0}),
        .z({c_l2_2[62:0], 1'b0}),
        .s(s_l3_2),
        .c(c_l3_2)
        );
    csa u_csa_l4_1(
        .x(s_l3_1),
        .y(s_l3_2),
        .z({c_l3_1[62:0], 1'b0}),
        .s(s_l4_1),
        .c(c_l4_1)
        );
    csa u_csa_l4_2(
        .x({c_l3_2[62:0], 1'b0}),
        .y({c_l2_3[62:0], 1'b0}),
        .z({c_l2_4[62:0], 1'b0}),
        .s(s_l4_2),
        .c(c_l4_2)
        );
    csa u_csa_l5_1(
        .x(s_l4_1),
        .y(s_l4_2),
        .z({c_l4_1[62:0], 1'b0}),
        .s(s_l5_1),
        .c(c_l5_1)
        );
    csa u_csa_l6_1(
        .x(s_l5_1),
        .y({c_l5_1[62:0], 1'b0}),
        .z({c_l4_2[62:0], 1'b0}),
        .s(s_l6_1),
        .c(c_l6_1)
        );
    
    // 加法
    fa64 u_fa64(.a(s_l6_1), .b({c_l6_1[62:0], 1'b0}), .cin(1'b0), .sub(1'b0), .s(z), .cout());
    
endmodule
