`timescale 1 ns/1 ns

module img_gen
#(
    parameter H_SYNC        = 96                    ,   //行同步信号
    parameter H_BACK        = 48                    ,   //行显示后沿
    parameter H_DISP        = 640                   ,   //行有效数据
    parameter H_FRONT       = 16                    ,   //行显示前沿
    parameter H_TOTAL       = 800                   ,   //行扫描周期

    parameter V_SYNC        = 2                     ,   //场同步信号
    parameter V_BACK        = 33                    ,   //场显示后沿
    parameter V_DISP        = 480                   ,   //场有效数据   
    parameter V_FRONT       = 10                    ,   //场显示前沿
    parameter V_TOTAL       = 525                       //场扫描周期
)
(
    //system --------------------------------------------
    input   wire                clk                     ,   //时钟
    input   wire                rst_n                   ,   //复位，低电平有效
    //img output ----------------------------------------
//    output  reg     [15:0]      cnt_v                   ,   //行计数器

    output  wire                img_hsync               ,   //img行同步
    output  wire                img_vsync               ,   //img场同步
    output  reg     [23:0]      img_data                ,   //img数据
    output  reg     [11:0]      x_axis                ,   //x坐标
    output  reg     [11:0]      y_axis                ,   //y坐标
    output  reg                 img_de                      //img数据使能
);

reg     [15:0]              cnt_h                   ;
wire                        add_cnt_h               ;
wire                        end_cnt_h               ;
reg     [15:0]              cnt_v                   ;
wire                        add_cnt_v               ;
wire                        end_cnt_v               ;
wire                        img_req                 ;

wire   [11:0]      x                ;   //x坐标
wire   [11:0]      y                ;   //y坐标
//---------------------------------------------------
reg     [23:0]              ram [H_DISP*V_DISP-1:0] ;
reg     [31:0]              i                       ;
//==========================================================================
//==    行、场计数
//==========================================================================
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt_h <= 16'd0;
    else if(add_cnt_h) begin
        if(end_cnt_h)
            cnt_h <= 16'd0;
        else
            cnt_h <= cnt_h + 1'd1;
    end
end

assign add_cnt_h = 1;
assign end_cnt_h = add_cnt_h && cnt_h==H_TOTAL-1;
//---------------------------------------------------
always @(posedge clk or negedge rst_n) begin 
    if(!rst_n)
        cnt_v <= 16'd0;
    else if(add_cnt_v) begin
        if(end_cnt_v)
            cnt_v <= 16'd0;
        else
            cnt_v <= cnt_v + 1'd1;
    end
end

assign add_cnt_v = end_cnt_h;
assign end_cnt_v = add_cnt_v && cnt_v==V_TOTAL-1;
//==========================================================================
//==    输出
//==========================================================================
//行场同步
//---------------------------------------------------
assign img_hsync = (cnt_h < H_SYNC) ? 1'b0 : 1'b1;
assign img_vsync = (cnt_v < V_SYNC) ? 1'b0 : 1'b1;

//数据请求
assign img_req = (cnt_h >= H_SYNC + H_BACK - 1) && (cnt_h < H_SYNC + H_BACK + H_DISP - 1) &&
                 (cnt_v >= V_SYNC + V_BACK    ) && (cnt_v < V_SYNC + V_BACK + V_DISP    );

//读取txt文件到raw数组中,格式为16进制
//---------------------------------------------------
initial begin
    $readmemh("./../../matlab/pre_img.txt", ram);
end

//数据输出
//---------------------------------------------------
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        img_data <= 24'd0;
        i <= 0;
    end
    else if(img_req) begin
        img_data <= ram[i];
        i <= i + 1;
    end
    else if(i==H_DISP*V_DISP) begin
        img_data <= 24'd0;
        i <= 0;
    end
end

//assign x = img_req ? (cnt_h - (H_SYNC + H_BACK - 1'b1)) : 11'd0;
assign x = img_req ? (cnt_h - (H_SYNC + H_BACK + 1'b1)) : 12'd0;
assign y = img_req ? (cnt_v - (V_SYNC + V_BACK - 1'b1)) : 12'd0;

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        x_axis <= 12'd0;
        y_axis <= 12'd0;
    end
    else if(img_req) begin
        x_axis <= x;
        y_axis <= y;
    end
end

//数据使能
always @(posedge clk) begin 
    img_de <= img_req;
end

endmodule

