quit -sim

.main clear

vlib work

vmap work work

vlog ./../../rtl/*.v
vlog ./../../rtl/sobel/*.v
vlog ./../../rtl/rho_cacl/*.v
vlog ./../../rtl/feature_point/*.v
vlog ./../*.v

vsim -voptargs=+acc work.top_tb

add wave -divider {top}
#add wave /top_tb/u_top/*
#add wave -divider {feature_point}
#add wave /top_tb/u_top/u_feature_point/*

add wave /top_tb/u_top/clk         
add wave /top_tb/u_top/rst_n         
add wave /top_tb/u_top/left_vld         
add wave /top_tb/u_top/phase_left_data  
add wave /top_tb/u_top/rho_left_data    
add wave /top_tb/u_top/right_vld        
add wave /top_tb/u_top/phase_right_data 
add wave /top_tb/u_top/rho_right_data   

run -all