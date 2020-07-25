onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib simple_dual_ram_opt

do {wave.do}

view wave
view structure
view signals

do {simple_dual_ram.udo}

run -all

quit -force
