/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                         */
/*  \   \        Copyright (c) 2003-2013 Xilinx, Inc.                 */
/*  /   /        All Right Reserved.                                  */
/* /---/   /\                                                         */
/* \   \  /  \                                                        */
/*  \___\/\___\                                                       */
/**********************************************************************/

#if defined(_WIN32)
 #include "stdio.h"
#endif
#include "iki.h"
#include <string.h>
#include <math.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                         */
/*  \   \        Copyright (c) 2003-2013 Xilinx, Inc.                 */
/*  /   /        All Right Reserved.                                  */
/* /---/   /\                                                         */
/* \   \  /  \                                                        */
/*  \___\/\___\                                                       */
/**********************************************************************/

#if defined(_WIN32)
 #include "stdio.h"
#endif
#include "iki.h"
#include <string.h>
#include <math.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
typedef void (*funcp)(char *, char *);
extern int main(int, char**);
extern void execute_2(char*, char *);
extern void execute_581(char*, char *);
extern void execute_582(char*, char *);
extern void execute_3550(char*, char *);
extern void execute_3551(char*, char *);
extern void execute_3552(char*, char *);
extern void execute_3553(char*, char *);
extern void execute_3554(char*, char *);
extern void execute_3555(char*, char *);
extern void execute_3556(char*, char *);
extern void execute_3557(char*, char *);
extern void execute_3558(char*, char *);
extern void execute_3559(char*, char *);
extern void execute_4(char*, char *);
extern void execute_571(char*, char *);
extern void execute_572(char*, char *);
extern void execute_573(char*, char *);
extern void execute_574(char*, char *);
extern void execute_575(char*, char *);
extern void execute_576(char*, char *);
extern void execute_577(char*, char *);
extern void execute_578(char*, char *);
extern void execute_579(char*, char *);
extern void execute_580(char*, char *);
extern void execute_3493(char*, char *);
extern void execute_3494(char*, char *);
extern void execute_3495(char*, char *);
extern void execute_3496(char*, char *);
extern void execute_3497(char*, char *);
extern void vlog_simple_process_execute_0_fast_no_reg_no_agg(char*, char*, char*);
extern void execute_3499(char*, char *);
extern void execute_3500(char*, char *);
extern void execute_3501(char*, char *);
extern void execute_3502(char*, char *);
extern void execute_3503(char*, char *);
extern void execute_3504(char*, char *);
extern void execute_3505(char*, char *);
extern void execute_3507(char*, char *);
extern void execute_3508(char*, char *);
extern void vlog_const_rhs_process_execute_0_fast_no_reg_no_agg(char*, char*, char*);
extern void execute_3526(char*, char *);
extern void execute_3528(char*, char *);
extern void execute_3529(char*, char *);
extern void execute_3530(char*, char *);
extern void execute_3531(char*, char *);
extern void execute_3532(char*, char *);
extern void execute_3533(char*, char *);
extern void execute_3534(char*, char *);
extern void execute_3535(char*, char *);
extern void execute_3536(char*, char *);
extern void execute_3537(char*, char *);
extern void execute_3538(char*, char *);
extern void execute_3539(char*, char *);
extern void execute_3540(char*, char *);
extern void execute_3541(char*, char *);
extern void execute_3542(char*, char *);
extern void execute_3543(char*, char *);
extern void execute_3544(char*, char *);
extern void execute_3545(char*, char *);
extern void execute_3546(char*, char *);
extern void execute_3547(char*, char *);
extern void execute_3548(char*, char *);
extern void execute_3549(char*, char *);
extern void execute_6(char*, char *);
extern void execute_8(char*, char *);
extern void execute_9(char*, char *);
extern void execute_10(char*, char *);
extern void execute_11(char*, char *);
extern void execute_12(char*, char *);
extern void execute_587(char*, char *);
extern void execute_588(char*, char *);
extern void execute_589(char*, char *);
extern void execute_590(char*, char *);
extern void execute_591(char*, char *);
extern void execute_592(char*, char *);
extern void execute_593(char*, char *);
extern void execute_594(char*, char *);
extern void execute_595(char*, char *);
extern void execute_596(char*, char *);
extern void execute_597(char*, char *);
extern void execute_598(char*, char *);
extern void execute_599(char*, char *);
extern void execute_600(char*, char *);
extern void execute_601(char*, char *);
extern void execute_602(char*, char *);
extern void execute_603(char*, char *);
extern void execute_604(char*, char *);
extern void execute_605(char*, char *);
extern void execute_606(char*, char *);
extern void execute_607(char*, char *);
extern void execute_608(char*, char *);
extern void execute_609(char*, char *);
extern void execute_610(char*, char *);
extern void execute_611(char*, char *);
extern void execute_612(char*, char *);
extern void execute_742(char*, char *);
extern void execute_743(char*, char *);
extern void execute_744(char*, char *);
extern void execute_753(char*, char *);
extern void execute_754(char*, char *);
extern void execute_755(char*, char *);
extern void execute_756(char*, char *);
extern void execute_757(char*, char *);
extern void execute_759(char*, char *);
extern void execute_760(char*, char *);
extern void execute_764(char*, char *);
extern void execute_765(char*, char *);
extern void execute_766(char*, char *);
extern void execute_767(char*, char *);
extern void execute_768(char*, char *);
extern void execute_15(char*, char *);
extern void execute_43(char*, char *);
extern void execute_729(char*, char *);
extern void execute_730(char*, char *);
extern void execute_731(char*, char *);
extern void execute_732(char*, char *);
extern void execute_733(char*, char *);
extern void execute_734(char*, char *);
extern void execute_735(char*, char *);
extern void execute_24(char*, char *);
extern void execute_25(char*, char *);
extern void execute_26(char*, char *);
extern void execute_40(char*, char *);
extern void execute_41(char*, char *);
extern void execute_42(char*, char *);
extern void execute_661(char*, char *);
extern void execute_662(char*, char *);
extern void execute_663(char*, char *);
extern void execute_664(char*, char *);
extern void execute_665(char*, char *);
extern void execute_666(char*, char *);
extern void execute_667(char*, char *);
extern void execute_669(char*, char *);
extern void execute_670(char*, char *);
extern void execute_671(char*, char *);
extern void execute_672(char*, char *);
extern void execute_676(char*, char *);
extern void execute_680(char*, char *);
extern void execute_681(char*, char *);
extern void execute_682(char*, char *);
extern void execute_683(char*, char *);
extern void execute_684(char*, char *);
extern void execute_685(char*, char *);
extern void execute_688(char*, char *);
extern void execute_690(char*, char *);
extern void execute_691(char*, char *);
extern void execute_692(char*, char *);
extern void execute_693(char*, char *);
extern void execute_694(char*, char *);
extern void execute_695(char*, char *);
extern void execute_696(char*, char *);
extern void execute_697(char*, char *);
extern void execute_698(char*, char *);
extern void execute_699(char*, char *);
extern void execute_700(char*, char *);
extern void execute_701(char*, char *);
extern void execute_702(char*, char *);
extern void execute_703(char*, char *);
extern void execute_28(char*, char *);
extern void execute_29(char*, char *);
extern void execute_30(char*, char *);
extern void execute_31(char*, char *);
extern void execute_673(char*, char *);
extern void execute_674(char*, char *);
extern void execute_675(char*, char *);
extern void execute_38(char*, char *);
extern void execute_39(char*, char *);
extern void execute_3302(char*, char *);
extern void execute_3303(char*, char *);
extern void execute_3304(char*, char *);
extern void execute_3313(char*, char *);
extern void execute_3314(char*, char *);
extern void execute_3315(char*, char *);
extern void execute_3316(char*, char *);
extern void execute_3317(char*, char *);
extern void execute_3319(char*, char *);
extern void execute_3320(char*, char *);
extern void execute_3324(char*, char *);
extern void execute_3325(char*, char *);
extern void execute_3326(char*, char *);
extern void execute_3327(char*, char *);
extern void execute_3328(char*, char *);
extern void execute_511(char*, char *);
extern void execute_539(char*, char *);
extern void vlog_simple_process_execute_0_fast_no_reg(char*, char*, char*);
extern void execute_3289(char*, char *);
extern void execute_3290(char*, char *);
extern void execute_3291(char*, char *);
extern void execute_3292(char*, char *);
extern void execute_3293(char*, char *);
extern void execute_3294(char*, char *);
extern void execute_3295(char*, char *);
extern void execute_520(char*, char *);
extern void execute_521(char*, char *);
extern void execute_522(char*, char *);
extern void execute_536(char*, char *);
extern void execute_537(char*, char *);
extern void execute_538(char*, char *);
extern void execute_3221(char*, char *);
extern void execute_3222(char*, char *);
extern void execute_3223(char*, char *);
extern void execute_3224(char*, char *);
extern void execute_3225(char*, char *);
extern void execute_3226(char*, char *);
extern void execute_3227(char*, char *);
extern void execute_3229(char*, char *);
extern void execute_3230(char*, char *);
extern void execute_3231(char*, char *);
extern void execute_3232(char*, char *);
extern void execute_3236(char*, char *);
extern void execute_3240(char*, char *);
extern void execute_3241(char*, char *);
extern void execute_3242(char*, char *);
extern void execute_3243(char*, char *);
extern void execute_3244(char*, char *);
extern void execute_3245(char*, char *);
extern void execute_3248(char*, char *);
extern void execute_3250(char*, char *);
extern void execute_3251(char*, char *);
extern void execute_3252(char*, char *);
extern void execute_3253(char*, char *);
extern void execute_3254(char*, char *);
extern void execute_3255(char*, char *);
extern void execute_3256(char*, char *);
extern void execute_3257(char*, char *);
extern void execute_3258(char*, char *);
extern void execute_3259(char*, char *);
extern void execute_3260(char*, char *);
extern void execute_3261(char*, char *);
extern void execute_3262(char*, char *);
extern void execute_3263(char*, char *);
extern void execute_584(char*, char *);
extern void execute_585(char*, char *);
extern void execute_586(char*, char *);
extern void execute_3560(char*, char *);
extern void execute_3561(char*, char *);
extern void execute_3562(char*, char *);
extern void execute_3563(char*, char *);
extern void execute_3564(char*, char *);
extern void vlog_transfunc_eventcallback(char*, char*, unsigned, unsigned, unsigned, char *);
extern void transaction_60(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_61(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_73(char*, char*, unsigned, unsigned, unsigned);
extern void transaction_76(char*, char*, unsigned, unsigned, unsigned);
funcp funcTab[244] = {(funcp)execute_2, (funcp)execute_581, (funcp)execute_582, (funcp)execute_3550, (funcp)execute_3551, (funcp)execute_3552, (funcp)execute_3553, (funcp)execute_3554, (funcp)execute_3555, (funcp)execute_3556, (funcp)execute_3557, (funcp)execute_3558, (funcp)execute_3559, (funcp)execute_4, (funcp)execute_571, (funcp)execute_572, (funcp)execute_573, (funcp)execute_574, (funcp)execute_575, (funcp)execute_576, (funcp)execute_577, (funcp)execute_578, (funcp)execute_579, (funcp)execute_580, (funcp)execute_3493, (funcp)execute_3494, (funcp)execute_3495, (funcp)execute_3496, (funcp)execute_3497, (funcp)vlog_simple_process_execute_0_fast_no_reg_no_agg, (funcp)execute_3499, (funcp)execute_3500, (funcp)execute_3501, (funcp)execute_3502, (funcp)execute_3503, (funcp)execute_3504, (funcp)execute_3505, (funcp)execute_3507, (funcp)execute_3508, (funcp)vlog_const_rhs_process_execute_0_fast_no_reg_no_agg, (funcp)execute_3526, (funcp)execute_3528, (funcp)execute_3529, (funcp)execute_3530, (funcp)execute_3531, (funcp)execute_3532, (funcp)execute_3533, (funcp)execute_3534, (funcp)execute_3535, (funcp)execute_3536, (funcp)execute_3537, (funcp)execute_3538, (funcp)execute_3539, (funcp)execute_3540, (funcp)execute_3541, (funcp)execute_3542, (funcp)execute_3543, (funcp)execute_3544, (funcp)execute_3545, (funcp)execute_3546, (funcp)execute_3547, (funcp)execute_3548, (funcp)execute_3549, (funcp)execute_6, (funcp)execute_8, (funcp)execute_9, (funcp)execute_10, (funcp)execute_11, (funcp)execute_12, (funcp)execute_587, (funcp)execute_588, (funcp)execute_589, (funcp)execute_590, (funcp)execute_591, (funcp)execute_592, (funcp)execute_593, (funcp)execute_594, (funcp)execute_595, (funcp)execute_596, (funcp)execute_597, (funcp)execute_598, (funcp)execute_599, (funcp)execute_600, (funcp)execute_601, (funcp)execute_602, (funcp)execute_603, (funcp)execute_604, (funcp)execute_605, (funcp)execute_606, (funcp)execute_607, (funcp)execute_608, (funcp)execute_609, (funcp)execute_610, (funcp)execute_611, (funcp)execute_612, (funcp)execute_742, (funcp)execute_743, (funcp)execute_744, (funcp)execute_753, (funcp)execute_754, (funcp)execute_755, (funcp)execute_756, (funcp)execute_757, (funcp)execute_759, (funcp)execute_760, (funcp)execute_764, (funcp)execute_765, (funcp)execute_766, (funcp)execute_767, (funcp)execute_768, (funcp)execute_15, (funcp)execute_43, (funcp)execute_729, (funcp)execute_730, (funcp)execute_731, (funcp)execute_732, (funcp)execute_733, (funcp)execute_734, (funcp)execute_735, (funcp)execute_24, (funcp)execute_25, (funcp)execute_26, (funcp)execute_40, (funcp)execute_41, (funcp)execute_42, (funcp)execute_661, (funcp)execute_662, (funcp)execute_663, (funcp)execute_664, (funcp)execute_665, (funcp)execute_666, (funcp)execute_667, (funcp)execute_669, (funcp)execute_670, (funcp)execute_671, (funcp)execute_672, (funcp)execute_676, (funcp)execute_680, (funcp)execute_681, (funcp)execute_682, (funcp)execute_683, (funcp)execute_684, (funcp)execute_685, (funcp)execute_688, (funcp)execute_690, (funcp)execute_691, (funcp)execute_692, (funcp)execute_693, (funcp)execute_694, (funcp)execute_695, (funcp)execute_696, (funcp)execute_697, (funcp)execute_698, (funcp)execute_699, (funcp)execute_700, (funcp)execute_701, (funcp)execute_702, (funcp)execute_703, (funcp)execute_28, (funcp)execute_29, (funcp)execute_30, (funcp)execute_31, (funcp)execute_673, (funcp)execute_674, (funcp)execute_675, (funcp)execute_38, (funcp)execute_39, (funcp)execute_3302, (funcp)execute_3303, (funcp)execute_3304, (funcp)execute_3313, (funcp)execute_3314, (funcp)execute_3315, (funcp)execute_3316, (funcp)execute_3317, (funcp)execute_3319, (funcp)execute_3320, (funcp)execute_3324, (funcp)execute_3325, (funcp)execute_3326, (funcp)execute_3327, (funcp)execute_3328, (funcp)execute_511, (funcp)execute_539, (funcp)vlog_simple_process_execute_0_fast_no_reg, (funcp)execute_3289, (funcp)execute_3290, (funcp)execute_3291, (funcp)execute_3292, (funcp)execute_3293, (funcp)execute_3294, (funcp)execute_3295, (funcp)execute_520, (funcp)execute_521, (funcp)execute_522, (funcp)execute_536, (funcp)execute_537, (funcp)execute_538, (funcp)execute_3221, (funcp)execute_3222, (funcp)execute_3223, (funcp)execute_3224, (funcp)execute_3225, (funcp)execute_3226, (funcp)execute_3227, (funcp)execute_3229, (funcp)execute_3230, (funcp)execute_3231, (funcp)execute_3232, (funcp)execute_3236, (funcp)execute_3240, (funcp)execute_3241, (funcp)execute_3242, (funcp)execute_3243, (funcp)execute_3244, (funcp)execute_3245, (funcp)execute_3248, (funcp)execute_3250, (funcp)execute_3251, (funcp)execute_3252, (funcp)execute_3253, (funcp)execute_3254, (funcp)execute_3255, (funcp)execute_3256, (funcp)execute_3257, (funcp)execute_3258, (funcp)execute_3259, (funcp)execute_3260, (funcp)execute_3261, (funcp)execute_3262, (funcp)execute_3263, (funcp)execute_584, (funcp)execute_585, (funcp)execute_586, (funcp)execute_3560, (funcp)execute_3561, (funcp)execute_3562, (funcp)execute_3563, (funcp)execute_3564, (funcp)vlog_transfunc_eventcallback, (funcp)transaction_60, (funcp)transaction_61, (funcp)transaction_73, (funcp)transaction_76};
const int NumRelocateId= 244;

void relocate(char *dp)
{
	iki_relocate(dp, "xsim.dir/DCache_sim_dirty_behav/xsim.reloc",  (void **)funcTab, 244);

	/*Populate the transaction function pointer field in the whole net structure */
}

void sensitize(char *dp)
{
	iki_sensitize(dp, "xsim.dir/DCache_sim_dirty_behav/xsim.reloc");
}

	// Initialize Verilog nets in mixed simulation, for the cases when the value at time 0 should be propagated from the mixed language Vhdl net

void wrapper_func_0(char *dp)

{

}

void simulate(char *dp)
{
		iki_schedule_processes_at_time_zero(dp, "xsim.dir/DCache_sim_dirty_behav/xsim.reloc");
	wrapper_func_0(dp);

	iki_execute_processes();

	// Schedule resolution functions for the multiply driven Verilog nets that have strength
	// Schedule transaction functions for the singly driven Verilog nets that have strength

}
#include "iki_bridge.h"
void relocate(char *);

void sensitize(char *);

void simulate(char *);

extern SYSTEMCLIB_IMP_DLLSPEC void local_register_implicit_channel(int, char*);
extern void implicit_HDL_SCinstantiate();

extern void implicit_HDL_SCcleanup();

extern SYSTEMCLIB_IMP_DLLSPEC int xsim_argc_copy ;
extern SYSTEMCLIB_IMP_DLLSPEC char** xsim_argv_copy ;

int main(int argc, char **argv)
{
    iki_heap_initialize("ms", "isimmm", 0, 2147483648) ;
    iki_set_sv_type_file_path_name("xsim.dir/DCache_sim_dirty_behav/xsim.svtype");
    iki_set_crvs_dump_file_path_name("xsim.dir/DCache_sim_dirty_behav/xsim.crvsdump");
    void* design_handle = iki_create_design("xsim.dir/DCache_sim_dirty_behav/xsim.mem", (void *)relocate, (void *)sensitize, (void *)simulate, 0, isimBridge_getWdbWriter(), 0, argc, argv);
     iki_set_rc_trial_count(100);
    (void) design_handle;
    return iki_simulate_design();
}
