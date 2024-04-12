`timescale 1 ps/ 1 ps

module rho_cacl_tb;

// Inputs
reg             clk     ;
reg             in_vld  ;
reg             rst_n   ;
reg     [15:0]  cnt     ;
reg     [15:0]  cnt_n   ;
reg     [31:0]  phase   ;
reg     [31:0]  phase_n ;
//reg     [11:0]  x  = 100     ;
//reg     [11:0]  y  = 100     ;

wire            out_vld ;
wire    [31:0]  sin     ;
wire    [31:0]  cos     ;
wire    [31:0]  error   ;

// Instantiate the Unit Under Test (UUT)
rho_cacl  rho_cacl_inst 
(
    .rst_n      (rst_n      ),
    .clk        (clk        ),
    .in_vld     (in_vld     ),
    .x          (100         ),
    .y          (100          ),
    .phase      (phase      ),

    .out_vld    (out_vld    ),
    .rho_data   (rho_data   )
);

initial
begin
    #0 clk = 1'b0;
    #10000 rst_n = 1'b0;
    #10000 rst_n = 1'b1;
    #10000000 $stop;
end 

always #10000 
begin
    clk = ~clk;
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cnt <= 1'b0;
    else
        cnt <= cnt_n;
end

always @ (*)
begin
    if(cnt == 16'd359)
        cnt_n = 1'b0;
    else
        cnt_n = cnt + 1'b1;
end

//生成相位,phase[17:16]为相位的象限,phase[15:10]为相位的值
always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        phase <= 1'b0;
    else
        phase <= phase_n;
end

always @ (*)
begin
    if(cnt <= 16'd90)// 第一象限
        phase_n = cnt;
    else if(cnt > 16'd90 && cnt <= 16'd180)// 第二象限
        phase_n = {16'd01,cnt - 16'd90};
    else if(cnt > 16'd180 && cnt <= 16'd270)// 第三象限
        phase_n = {16'd10,cnt - 16'd180};
    else if(cnt > 16'd270)// 第四象限
        phase_n = {16'd11,cnt - 16'd270};
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
        in_vld <= 1'b0;
    else if((cnt == 16'd30) || (cnt == 16'd45) || (cnt == 16'd60) || (cnt == 16'd90)
        || (cnt == 16'd120) || (cnt == 16'd135) || (cnt == 16'd150) || (cnt == 16'd180)
        || (cnt == 16'd210) || (cnt == 16'd225) || (cnt == 16'd240) || (cnt == 16'd270)
        || (cnt == 16'd300) || (cnt == 16'd315) || (cnt == 16'd330) || (cnt == 16'd360))
        in_vld <= 1'b1;
    else
        in_vld <= 1'b0;
end

endmodule

