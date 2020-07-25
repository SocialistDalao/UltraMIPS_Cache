//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/18 16:52:57
// Design Name: 
// Module Name: booth2
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


module booth2(
    input[32:0] x, // 被乘数
    input[2:0] y, // 乘数的三位
    input is_msub, // 是否是乘减指令
    output reg[63:0] z // 部分积
    );
    wire[32:0] x_neg;
    assign x_neg = -x;
    always @ * begin
        case({is_msub, y})
            4'b0011, 4'b1100:
                z = {{30{x[32]}}, x, 1'b0};
            4'b0100, 4'b1011:
                z = {{30{x_neg[32]}}, x_neg, 1'b0};
            4'b0001, 4'b0010, 4'b1101, 4'b1110:
                z = {{31{x[32]}}, x};
            4'b0101, 4'b0110, 4'b1001, 4'b1010:
                z = {{31{x_neg[32]}}, x_neg};
            default:
                z = 64'b0;
        endcase
    end
endmodule
