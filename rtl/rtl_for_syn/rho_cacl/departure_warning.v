module departure_warning
(
    input   wire         rst_n       ,
    input   wire         clk         ,
    input   wire         in_left_vld      ,
    input   wire         in_right_vld      ,
    input   wire  [7:0]  phase_left  ,  // rho max 
    input   wire  [7:0]  phase_right ,  // rho max 

    output reg           warning        
);

reg  [7:0]  phase_left_d ;
reg  [7:0]  phase_right_d;

reg phase_vld_d1,phase_vld_d2;

// 车道偏移率
// rate = | (phase_right - 90°) / (90° - phase_left) |
// 理想情况下 rate = 1，即两侧车道线夹角互补，视觉上对称
// rate > 1时左偏，rate < 1时右偏
reg  [15:0]  departure_rate;
//reg  [5:0]  warning_time_cnt;// warning持续50个clk后清零

// clk1
// 车道夹角寄存
// 左边
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        phase_left_d  <= 8'd0;
    else if(in_left_vld)
        phase_left_d <= phase_left;
end
// 右边
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        phase_right_d <= 8'd0;
    else if(in_right_vld)
        phase_right_d <= phase_right;
end
// clk2 计算偏移率
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        departure_rate <= 15'd0;
    else if(phase_vld_d1)
        departure_rate <= ((phase_right_d - 8'd90) << 8)/(8'd90 - phase_left_d);
end
// clk3 偏移报警
// (0.75~1.25) × 256 = 192~320
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        warning <= 1'd0;
    else if((phase_vld_d2 == 1'b1) && ((departure_rate < 16'd192) || (departure_rate > 16'd320)))
        warning <= 1'b1;            
end

//always @(posedge clk or negedge rst_n) begin
//    if(!rst_n) 
//        warning_time_cnt <= 6'd0;
//    else if(warning_time_cnt == 6'd50)
//        warning_time_cnt <= 6'd0;
//    else
//        warning_time_cnt <= warning_time_cnt + 1'd1;
//end
// 信号同步
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        phase_vld_d1 <= 1'd0;
        phase_vld_d2 <= 1'd0;        
    end
    else begin
        phase_vld_d1 <= in_right_vld;
        phase_vld_d2 <= phase_vld_d1;        
    end
end

endmodule