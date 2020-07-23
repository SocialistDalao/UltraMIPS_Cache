@echo off
REM ****************************************************************************
REM Vivado (TM) v2019.2 (64-bit)
REM
REM Filename    : simulate.bat
REM Simulator   : Xilinx Vivado Simulator
REM Description : Script for simulating the design by launching the simulator
REM
REM Generated by Vivado on Thu Jul 23 15:16:42 +0800 2020
REM SW Build 2708876 on Wed Nov  6 21:40:23 MST 2019
REM
REM Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
REM
REM usage: simulate.bat
REM
REM ****************************************************************************
echo "xsim DCache_sim_dirty_behav -key {Behavioral:sim_1:Functional:DCache_sim_dirty} -tclbatch DCache_sim_dirty.tcl -view F:/Cache/ICache_sim_behav.wcfg -view F:/Cache/CacheAXI_Interface_sim_behav.wcfg -view F:/Cache/DCache_sim_dirty_behav.wcfg -log simulate.log"
call xsim  DCache_sim_dirty_behav -key {Behavioral:sim_1:Functional:DCache_sim_dirty} -tclbatch DCache_sim_dirty.tcl -view F:/Cache/ICache_sim_behav.wcfg -view F:/Cache/CacheAXI_Interface_sim_behav.wcfg -view F:/Cache/DCache_sim_dirty_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
