// 特征点读取，耗费3clk
module read_ram #
(
    parameter H_DISP            = 12'd640       ,   //图像宽度
    parameter V_DISP            = 12'd480           //图像高度
)
(
    input   wire         clk             , 
    input   wire         rst_n           , 

    input   wire         axis_vsync      , 
    input   wire         axis_de         , 

    output  reg  [7:0]   left_rdaddr     ,   //读地址
    output  reg  [7:0]   right_rdaddr    ,   //读地址
    output  reg          left_rden       ,   //读使能
    output  reg          right_rden          //读使能
);

wire [11:0]  x_left          ;   //左下部分感兴趣区域特征点的x坐标
wire [11:0]  y_left          ;   //左下部分感兴趣区域特征点的y坐标
wire [11:0]  x_right         ;   //右下部分感兴趣区域特征点的x坐标
wire [11:0]  y_right         ;   //右下部分感兴趣区域特征点的y坐标
//reg  [7:0]   l_rdaddr        ;
//reg  [7:0]   r_rdaddr        ;
 
reg         axis_vsync_d     ;
reg         axis_scd_frame   ;   //第二帧
wire        axis_vsync_neg   ;   //

// 等第2帧再读取存储的特征点坐标，避免读到空数据
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        axis_vsync_d <= 1'b0;
    else
        axis_vsync_d <= axis_vsync;
end

always @(posedge clk) begin
    if(!rst_n)
        axis_scd_frame <= 1'b0;
    else if(~axis_vsync && axis_vsync_d)
        axis_scd_frame <= 1'b1;
end

assign axis_vsync_neg = ~axis_vsync & axis_vsync_d;

//生成读地址
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        left_rdaddr  <= 8'd0;
    else if(axis_vsync_neg)
        left_rdaddr  <= 8'd0;
    else if(left_rdaddr == 8'd255)
        left_rdaddr  <= left_rdaddr;
    else if(axis_scd_frame && axis_de)
        left_rdaddr  <= left_rdaddr  + 1'd1;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        right_rdaddr <= 8'd0;
    else if(axis_vsync_neg)
        right_rdaddr <= 8'd0;
    else if(right_rdaddr == 8'd255)
        right_rdaddr  <= right_rdaddr;
    else if(axis_scd_frame && axis_de)
        right_rdaddr <= right_rdaddr + 1'd1;
end
//生成读使能
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        left_rden  <= 1'd0;
    else if(left_rdaddr == 8'd255)
        left_rden  <= 1'd0;
    else if(axis_scd_frame && axis_de)
        left_rden  <= 1'd1;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        right_rden <= 1'd0;
    else if(right_rdaddr == 8'd255)
        right_rden <= 1'd0;
    else if(axis_scd_frame && axis_de)
        right_rden <= 1'd1;
end
// 将读地址与读使能对齐
//always @(posedge clk or negedge rst_n) begin
//    if(!rst_n) 
//    begin
//        left_rdaddr  <= 8'd0;
//        right_rdaddr <= 8'd0;
//    end
//    else if(axis_scd_frame && axis_de)
//    begin
//        left_rdaddr  <= l_rdaddr;
//        right_rdaddr <= r_rdaddr;        
//    end
//end

endmodule