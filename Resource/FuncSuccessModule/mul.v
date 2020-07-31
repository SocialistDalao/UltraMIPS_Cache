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
    input rst,
    input flush,
    input flush_cause,
    input ex_issue_mode_i,
    input[5:0] stall, // 阻塞信号
    input[31:0] x, // 被乘数
    input[31:0] y, // 乘数
    input[63:0] hilo, // {HI, LO}寄存器的值
    input[1:0] op, // 指令类型
    input s, // 1为有符号乘法，0为无符号乘法
    output[63:0] z // 积
    );
    wire[32:0] x_ext; // 根据乘法属性对x进行符号扩展或零扩展
    wire[33:0] y_ext; // 根据乘法属性对y进行符号扩展或零扩展
    wire is_msub;
    wire[63:0] pp0, pp1, pp2, pp3, pp4, pp5, pp6, pp7, pp8, pp9, pp10, pp11, pp12, pp13, pp14, pp15, pp16; // 改进的Booth算法生成的部分积
    wire[63:0] pp17;
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
    
    // 根据有符号还是无符号乘法对x进行扩展
    assign x_ext = s ? {x[31], x} : {1'b0, x};
    assign y_ext = s ? {{2{y[31]}}, y} : {2'b00, y};
    assign is_msub = (op == `MSUB);
    
    // 生成部分积
    booth2 u_b0(.x(x_ext), .y({y_ext[1:0], 1'b0}), .is_msub(is_msub), .z(pp0));
    booth2 u_b1(.x(x_ext), .y(y_ext[3:1]), .is_msub(is_msub), .z(pp1));
    booth2 u_b2(.x(x_ext), .y(y_ext[5:3]), .is_msub(is_msub), .z(pp2));
    booth2 u_b3(.x(x_ext), .y(y_ext[7:5]), .is_msub(is_msub), .z(pp3));
    booth2 u_b4(.x(x_ext), .y(y_ext[9:7]), .is_msub(is_msub), .z(pp4));
    booth2 u_b5(.x(x_ext), .y(y_ext[11:9]), .is_msub(is_msub), .z(pp5));
    booth2 u_b6(.x(x_ext), .y(y_ext[13:11]), .is_msub(is_msub), .z(pp6));
    booth2 u_b7(.x(x_ext), .y(y_ext[15:13]), .is_msub(is_msub), .z(pp7));
    booth2 u_b8(.x(x_ext), .y(y_ext[17:15]), .is_msub(is_msub), .z(pp8));
    booth2 u_b9(.x(x_ext), .y(y_ext[19:17]), .is_msub(is_msub), .z(pp9));
    booth2 u_b10(.x(x_ext), .y(y_ext[21:19]), .is_msub(is_msub), .z(pp10));
    booth2 u_b11(.x(x_ext), .y(y_ext[23:21]), .is_msub(is_msub), .z(pp11));
    booth2 u_b12(.x(x_ext), .y(y_ext[25:23]), .is_msub(is_msub), .z(pp12));
    booth2 u_b13(.x(x_ext), .y(y_ext[27:25]), .is_msub(is_msub), .z(pp13));
    booth2 u_b14(.x(x_ext), .y(y_ext[29:27]), .is_msub(is_msub), .z(pp14));
    booth2 u_b15(.x(x_ext), .y(y_ext[31:29]), .is_msub(is_msub), .z(pp15));
    booth2 u_b16(.x(x_ext), .y(y_ext[33:31]), .is_msub(is_msub), .z(pp16));
    assign pp17 = (op == `MULT) ? 0 : hilo;
    
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
        if (rst == `RstEnable) begin
            pp0_out <= 64'h0000000000000000;
            pp1_out <= 64'h0000000000000000;
            pp2_out <= 64'h0000000000000000;
            pp3_out <= 64'h0000000000000000;
            pp4_out <= 64'h0000000000000000;
            pp5_out <= 64'h0000000000000000;
            pp6_out <= 64'h0000000000000000;
            pp7_out <= 64'h0000000000000000;
            pp8_out <= 64'h0000000000000000;
            pp9_out <= 64'h0000000000000000;
            pp10_out <= 64'h0000000000000000;
            pp11_out <= 64'h0000000000000000;
            pp12_out <= 64'h0000000000000000;
            pp13_out <= 64'h0000000000000000;
            pp14_out <= 64'h0000000000000000;
            pp15_out <= 64'h0000000000000000;
            pp16_out <= 64'h0000000000000000;
            pp17_out <= 64'h0000000000000000;
        end else if (flush == `Flush && flush_cause == `FailedBranchPrediction && ex_issue_mode_i == `DualIssue) begin
            pp0_out <= 64'h0000000000000000;
            pp1_out <= 64'h0000000000000000;
            pp2_out <= 64'h0000000000000000;
            pp3_out <= 64'h0000000000000000;
            pp4_out <= 64'h0000000000000000;
            pp5_out <= 64'h0000000000000000;
            pp6_out <= 64'h0000000000000000;
            pp7_out <= 64'h0000000000000000;
            pp8_out <= 64'h0000000000000000;
            pp9_out <= 64'h0000000000000000;
            pp10_out <= 64'h0000000000000000;
            pp11_out <= 64'h0000000000000000;
            pp12_out <= 64'h0000000000000000;
            pp13_out <= 64'h0000000000000000;
            pp14_out <= 64'h0000000000000000;
            pp15_out <= 64'h0000000000000000;
            pp16_out <= 64'h0000000000000000;
            pp17_out <= 64'h0000000000000000;
        end else if (flush == `Flush && flush_cause == `FailedBranchPrediction && ex_issue_mode_i == `SingleIssue) begin
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
        end else if (flush == `Flush && flush_cause == `Exception) begin
            pp0_out <= 64'h0000000000000000;
            pp1_out <= 64'h0000000000000000;
            pp2_out <= 64'h0000000000000000;
            pp3_out <= 64'h0000000000000000;
            pp4_out <= 64'h0000000000000000;
            pp5_out <= 64'h0000000000000000;
            pp6_out <= 64'h0000000000000000;
            pp7_out <= 64'h0000000000000000;
            pp8_out <= 64'h0000000000000000;
            pp9_out <= 64'h0000000000000000;
            pp10_out <= 64'h0000000000000000;
            pp11_out <= 64'h0000000000000000;
            pp12_out <= 64'h0000000000000000;
            pp13_out <= 64'h0000000000000000;
            pp14_out <= 64'h0000000000000000;
            pp15_out <= 64'h0000000000000000;
            pp16_out <= 64'h0000000000000000;
            pp17_out <= 64'h0000000000000000;
        end else if (stall[2] == `Stop && stall[3] == `NoStop) begin
            pp0_out <= 64'h0000000000000000;
            pp1_out <= 64'h0000000000000000;
            pp2_out <= 64'h0000000000000000;
            pp3_out <= 64'h0000000000000000;
            pp4_out <= 64'h0000000000000000;
            pp5_out <= 64'h0000000000000000;
            pp6_out <= 64'h0000000000000000;
            pp7_out <= 64'h0000000000000000;
            pp8_out <= 64'h0000000000000000;
            pp9_out <= 64'h0000000000000000;
            pp10_out <= 64'h0000000000000000;
            pp11_out <= 64'h0000000000000000;
            pp12_out <= 64'h0000000000000000;
            pp13_out <= 64'h0000000000000000;
            pp14_out <= 64'h0000000000000000;
            pp15_out <= 64'h0000000000000000;
            pp16_out <= 64'h0000000000000000;
            pp17_out <= 64'h0000000000000000;
        end else if (stall[2] == `NoStop) begin
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
    assign z = s_l6_1 + {c_l6_1[62:0], 1'b0};
endmodule
