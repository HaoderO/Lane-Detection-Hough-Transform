`timescale 1ns/1ns          //时间精度
`define    clock_period 20  //时钟周期
//`define    MATLAB  //导出数据

module top_tb;
parameter           H_DISP = 640     ;   //图像宽度
parameter           V_DISP = 480     ;   //图像高度
parameter           DATA_WIDTH_12 = 12  ;
parameter           DATA_WIDTH_3 = 3    ;
parameter           DLY_CYCLE  = 8      ;
parameter           DLY_CYCLE1  = 10    ;

reg                 clk             ;
reg                 rst_n           ;

wire                VGA_hsync       ;   //VGA行同步
wire                VGA_vsync       ;   //VGA场同步
wire    [ 7:0]      VGA_data        ;   //VGA数据
wire                VGA_de          ;   //VGA数据使能

    wire    [11:0]      x_axis     ;
    wire    [11:0]      y_axis     ;
    wire                img_hsync           ;   //灰度数据行同步
    wire                img_vsync           ;   //灰度数据场同步
    wire    [23:0]      img_data            ;   //灰度数据
    wire                img_de              ;   //灰度数据使能
    
//top #
//(
//    .H_DISP         (H_DISP         ),  //图像宽度
//    .V_DISP         (V_DISP         )   //图像高度
//)
//u_top
//(                                     
//    .clk            (clk            ), 
//    .rst_n          (rst_n          ), 
//    
//    .VGA_hsync      (VGA_hsync      ),  //VGA行同步
//    .VGA_vsync      (VGA_vsync      ),  //VGA场同步
//    .VGA_data       (VGA_data       ),  //VGA数据
//    .VGA_de         (VGA_de         )   //VGA数据使能
//);

top # 
(
    .H_DISP(H_DISP),
    .V_DISP(V_DISP),
    .DATA_WIDTH_12(DATA_WIDTH_12),
    .DATA_WIDTH_3(DATA_WIDTH_3),
    .DLY_CYCLE(DLY_CYCLE),
    .DLY_CYCLE1(DLY_CYCLE1)
)
u_top 
(
    .clk(clk),
    .rst_n(rst_n),
    .img_hsync(img_hsync),
    .img_vsync(img_vsync),
    .img_data(img_data),
    .x_axis(x_axis),
    .y_axis(y_axis),
    .img_de(img_de),

    .VGA_hsync(VGA_hsync),
    .VGA_vsync(VGA_vsync),
    .VGA_data(VGA_data),
    .VGA_de(VGA_de)
);

img_gen # 
(
    .H_DISP             (H_DISP             ),
    .V_DISP             (V_DISP             )
)       
u_img_gen       
(       
    .clk                (clk                ),
    .rst_n              (rst_n              ),

    .img_hsync          (img_hsync          ),
    .img_vsync          (img_vsync          ),
    .x_axis             (x_axis             ),
    .y_axis             (y_axis             ),
    .img_data           (img_data           ),
    .img_de             (img_de             )
);      

initial begin
    clk = 1;
    forever
        #(`clock_period/2) clk = ~clk;
end

initial begin
    rst_n = 0; #(`clock_period*20+1);
    rst_n = 1;
end

//  新建txt文件用以存储modelsim仿真数据
integer processed_img_txt;

initial begin
    processed_img_txt = $fopen("./../../matlab/processed_img.txt");
end

//  将仿真数据写入txt
reg [20:0] pixel_cnt;

`ifdef MATLAB
always @(posedge clk) begin
    if(!rst_n) begin
        pixel_cnt <= 0;
    end
    else if(VGA_de) begin
        pixel_cnt = pixel_cnt + 1;
        $fdisplay(processed_img_txt,"%d",VGA_data);
        
        if(pixel_cnt == H_DISP*V_DISP) begin
            $fclose(processed_img_txt);
            $stop;
        end
    end
end
`else
initial begin
    #17000000 $stop;
end
`endif

endmodule