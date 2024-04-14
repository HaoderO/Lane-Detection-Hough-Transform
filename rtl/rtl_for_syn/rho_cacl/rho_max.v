// 取出某个phase的ρ最大值 耗费256clk
module rho_max
(
    input  wire         rst_n       ,
    input  wire         clk         ,
    input  wire         in_vld      ,
    input  wire [27:0]  rho         ,// 高12bit：x坐标，低12bit：y坐标


    output reg          out_vld     ,    
    output reg  [27:0]  rho_max     // rho max 
);

reg  in_vld_d;
//wire in_vld_neg;
reg  [27:0] rho_d;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        in_vld_d <= 1'b0;
    else
        in_vld_d <= in_vld;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        out_vld <= 1'b0;
    else
        out_vld <= ~in_vld & in_vld_d;//遍历完所有的（256个）ρ后输出有效
    
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rho_d   <= 28'd0;
        rho_max <= 28'd0;
    end
    else if(in_vld == 1'b1) begin
        rho_d <= rho;
        if(rho_d > rho_max)  
            rho_max <= rho_d;
        else 
            rho_max <= rho_max;
    end
end
/*******************************************************/

endmodule