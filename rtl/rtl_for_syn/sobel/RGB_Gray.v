module RGB_Gray #
(
    parameter H_DISP            = 12'd640       ,   //图像宽度
    parameter V_DISP            = 12'd480           //图像高度
)
(
    input   wire                clk             , 
    input   wire                rst_n           , 

    input   wire                RGB_hsync       ,   //RGB行同步
    input   wire                RGB_vsync       ,   //RGB场同步
    input   wire    [23:0]      RGB_data        ,   //RGB数据
    input   wire                RGB_de          ,   //RGB数据使能

//    input   wire    [11:0]      x_axis          ,   //x坐标
//    input   wire    [11:0]      y_axis          ,   //y坐标

    output  reg                 gray_hsync      ,   //灰度图行同步
    output  reg                 gray_vsync      ,   //灰度图场同步
    output  reg     [7:0]       gray_data       ,   //灰度图数据
    output  reg                 gray_de             //灰度图数据使能
);

    wire    [7:0]       R   ;
    wire    [7:0]       G   ;
    wire    [7:0]       B   ;

//    wire    interest_region ;

assign R    =   RGB_data[23:16];
assign G    =   RGB_data[15:8 ];
assign B    =   RGB_data[ 7:0 ];

//assign interest_region = (y_axis > (V_DISP >> 1)) && 
//                                   ((x_axis < ((H_DISP >> 1) - 50)) || 
//                                    (x_axis > ((H_DISP >> 1) + 50)));

//*************************************************//
// 取单一通道做灰度

//assign gray_hsync   =   RGB_hsync;
//assign gray_vsync   =   RGB_vsync;
//assign gray_de      =   RGB_de;

//  R分量灰度图
//assign gray_data = {RGB_data[23:16],RGB_data[23:16],RGB_data[23:16]};

//  G分量灰度图
//assign gray_data = {RGB_data[15:8],RGB_data[15:8],RGB_data[15:8]};

//  B分量灰度图
//assign gray_data = {RGB_data[7:0],RGB_data[7:0],RGB_data[7:0]};
//*************************************************//

//*************************************************//
// 根据灰度转换公式Gray = 0.299*Red + 0.587*Green + 0.144*Blue取近似得 
// Gray = (0.25 + 0.03125)*Red + (0.5 + 0.0625)*Green + (0.0625 + 0.03125)*Blue
// Gray = 0.28125*Red + 0.5625*Green + 0.09375*Blue
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        gray_data <= 8'h00;
//    else if(interest_region && (RGB_de == 1'b1))
    else if(RGB_de == 1'b1)
                gray_data <= (R >> 2) + (R >> 5) + 
                     (G >> 1) + (G >> 4) + 
                     (B >> 4) + (B >> 5);
    else
        gray_data <= 8'h00;
end
// 信号同步
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        gray_hsync <= 1'b0;
        gray_vsync <= 1'b0;
        gray_de    <= 1'b0;
    end
    else begin
        gray_hsync <= RGB_hsync;
        gray_vsync <= RGB_vsync;
        gray_de    <= RGB_de   ;
    end
end
//*************************************************//

endmodule