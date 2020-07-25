//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/25 17:02:32
// Design Name: 
// Module Name: if_id
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



module if_id(

    input clk,
    input rst,
    input flush,
    input flush_cause,
    input[5:0] stall,
    
    input[`InstAddrBus] pc_i,
    input[`InstAddrBus] npc_i,
    input               branch_flag_i,
    input[`InstBus] inst1_i,
    input[`InstBus] inst2_i,
    input issue_i,
    input is_in_delayslot1_i,
    input is_in_delayslot2_i,
    input next_first_inst_in_delayslot_i,
    input[`InstAddrBus] ex_pc_i,
    
    
    output reg[`InstAddrBus] pc_o,
    output reg[`InstAddrBus] npc_o,
    output reg               branch_flag_o,
    output reg[`InstBus] inst1_o,
    output reg[`InstBus] inst2_o,
    output reg issue_o,
    output reg is_in_delayslot1_o,
    output reg is_in_delayslot2_o,
    output reg next_first_inst_in_delayslot_o
    
    );
    
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            pc_o <= `ZeroWord;
            npc_o <= `ZeroWord;
            branch_flag_o <= `NotBranch;
            inst1_o <= `ZeroWord;
            inst2_o <= `ZeroWord;
            issue_o <= `DualIssue;
            is_in_delayslot1_o <= `NotInDelaySlot;
            is_in_delayslot2_o <= `NotInDelaySlot;
            next_first_inst_in_delayslot_o <= `NotInDelaySlot;
        end else if (flush == `Flush && flush_cause == `Exception) begin
            pc_o <= `ZeroWord;
            npc_o <= `ZeroWord;
            branch_flag_o <= `NotBranch;
            inst1_o <= `ZeroWord;
            inst2_o <= `ZeroWord;
            issue_o <= `DualIssue;
            is_in_delayslot1_o <= `NotInDelaySlot;
            is_in_delayslot2_o <= `NotInDelaySlot;
            next_first_inst_in_delayslot_o <= `NotInDelaySlot;
        end else if (flush == `Flush && flush_cause == `FailedBranchPrediction && pc_i == ex_pc_i + 4'h4) begin
            pc_o <= pc_i;
            npc_o <= npc_i;
            branch_flag_o <= branch_flag_i;
            inst1_o <= inst1_i;
            inst2_o <= `ZeroWord;
            issue_o <= issue_i;
            is_in_delayslot1_o <= `InDelaySlot;
            is_in_delayslot2_o <= `NotInDelaySlot;
            next_first_inst_in_delayslot_o <= next_first_inst_in_delayslot_i;
        end else if (flush == `Flush && flush_cause == `FailedBranchPrediction) begin
            pc_o <= `ZeroWord;
            npc_o <= `ZeroWord;
            branch_flag_o <= `NotBranch;
            inst1_o <= `ZeroWord;
            inst2_o <= `ZeroWord;
            issue_o <= `DualIssue;
            is_in_delayslot1_o <= `NotInDelaySlot;
            is_in_delayslot2_o <= `NotInDelaySlot;
            next_first_inst_in_delayslot_o <= `NotInDelaySlot;
        end else if (stall[1] == `Stop && stall[2] == `NoStop) begin
            pc_o <= `ZeroWord;
            npc_o <= `ZeroWord;
            branch_flag_o <= `NotBranch;
            inst1_o <= `ZeroWord;
            inst2_o <= `ZeroWord;
            issue_o <= `DualIssue;
            is_in_delayslot1_o <= `NotInDelaySlot;
            is_in_delayslot2_o <= `NotInDelaySlot;
            next_first_inst_in_delayslot_o <= next_first_inst_in_delayslot_i;
        end else if (stall[1] == `NoStop) begin
            pc_o <= pc_i;
            npc_o <= npc_i;
            branch_flag_o <= branch_flag_i;
            inst1_o <= inst1_i;
            inst2_o <= inst2_i;
            issue_o <= issue_i;
            is_in_delayslot1_o <= is_in_delayslot1_i;
            is_in_delayslot2_o <= is_in_delayslot2_i;
            next_first_inst_in_delayslot_o <= next_first_inst_in_delayslot_i;
        end
    end
    
endmodule
