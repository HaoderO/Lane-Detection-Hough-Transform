// 特征点提取，耗费2clk
module feature_point #
(
    parameter H_DISP            = 12'd640       ,   //图像宽度
    parameter V_DISP            = 12'd480           //图像高度
)
(
    input   wire                clk             , 
    input   wire                rst_n           , 

//    input   wire                pre_hsync       ,   //RGB行同步
//    input   wire                pre_vsync       ,   //RGB场同步
    input   wire    [7:0]       pre_data        ,   //RGB数据
    input   wire                pre_de          ,   //RGB数据使能
    input   wire    [11:0]      x_axis          ,   //x坐标
    input   wire    [11:0]      y_axis          ,   //y坐标

//    output  reg                 feature_hsync   ,   //感兴趣区域行同步
//    output  reg                 feature_vsync   ,   //感兴趣区域场同步
    output  reg     [11:0]      x_left          ,   //左下部分感兴趣区域特征点的x坐标
    output  reg     [11:0]      y_left          ,   //左下部分感兴趣区域特征点的y坐标
    output  reg     [11:0]      x_right         ,   //右下部分感兴趣区域特征点的x坐标
    output  reg     [11:0]      y_right         ,   //右下部分感兴趣区域特征点的y坐标
    output  reg                 feature_de          //感兴趣区域数据使能
);

    wire            interest_region ;
//    wire  [23:0]    position        ;
    reg             feature_flag   ;

    reg    [11:0]      x_axis_d          ;
    reg    [11:0]      y_axis_d          ;
// 感兴趣区域为图像左下角和右下角
/*
    ********************************************
    *                                          *
    *                                          *
    *        maybe sky or …… sth else          *
    *                                          *
    *                                          *
    *  ***************        ***************  *
    *  ***************        ***************  *
    *  **interest*****        ******region***  *
    *  ***************        ***************  *
    *                                          *
    ********************************************
*/
assign interest_region = (pre_de && 
                          (
                           (
                            (y_axis > (V_DISP >> 1)) && (y_axis < (V_DISP - 40))
                           ) 
                           && 
                           (
                            ((x_axis > 60) && (x_axis < ((H_DISP >> 1) - 60))) 
                            || 
                            ((x_axis > ((H_DISP >> 1) + 60)) && (x_axis < H_DISP - 60))
                           )
                          )
                         ) ? 1'b1 : 1'b0;

//*************************************************//
// 特征点选取
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        feature_flag <= 1'b0;
//    else if(interest_region && (RGB_de == 1'b1))
    else if(interest_region && (pre_data == 8'hff))
        feature_flag <= 1'b1;
    else
        feature_flag <= 1'b0;
end
// 信号同步
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
    begin
        x_axis_d <= 12'd0;
        y_axis_d <= 12'd0;
    end
    else if(interest_region)
    begin
        x_axis_d <= x_axis;
        y_axis_d <= y_axis;
    end
end
//*************************************************//

//*************************************************//
// 输出特征点坐标
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
    begin
        x_left  <= 12'd0;
        y_left  <= 12'd0;
        x_right <= 12'd0;
        y_right <= 12'd0;
    end
    else if(feature_flag && (x_axis_d < (H_DISP >> 1)))
    begin
        x_left  <= x_axis_d;
        y_left  <= y_axis_d;
    end
    else if(feature_flag && (x_axis_d > (H_DISP >> 1)))
    begin
        x_right <= x_axis_d;
        y_right <= y_axis_d;        
    end
    else 
    begin
        x_left  <= 12'd0;
        y_left  <= 12'd0;
        x_right <= 12'd0;
        y_right <= 12'd0;
    end
end
// 输出特征点坐标有效标志
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        feature_de <= 1'b0;
    else
        feature_de <= feature_flag;
end
//*************************************************//

endmodule