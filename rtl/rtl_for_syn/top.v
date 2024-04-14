`timescale 1 ns/1 ns

module top
#(
    parameter           H_DISP        = 640 ,   //图像宽度
    parameter           V_DISP        = 480 ,   //图像高度
    parameter           DATA_WIDTH_12 = 12  ,
    parameter           DATA_WIDTH_3  = 3   ,
    parameter           DLY_CYCLE     = 8   ,
    parameter           DLY_CYCLE1    = 10    
)
(
    input   wire        clk                 ,
    input   wire        rst_n               ,
    input   wire        img_hsync           ,   //img行同步
    input   wire        img_vsync           ,   //img场同步
    input   wire [23:0] img_data            ,   //img数据
    input   wire [11:0] x_axis              ,   //x坐标
    input   wire [11:0] y_axis              ,   //y坐标
    input   wire        img_de              ,     //img数据使能

    output  wire        VGA_hsync           ,   //VGA行同步
    output  wire        VGA_vsync           ,   //VGA场同步
    output  wire [ 7:0] VGA_data            ,   //VGA数据
    output  wire        VGA_de                  //VGA数据使能
);

//    wire                img_hsync           ;   //灰度数据行同步
//    wire                img_vsync           ;   //灰度数据场同步
//    wire    [23:0]      img_data            ;   //灰度数据
//    wire                img_de              ;   //灰度数据使能

    wire                gray_hsync          ;   //灰度数据行同步
    wire                gray_vsync          ;   //灰度数据场同步
    wire    [ 7:0]      gray_data           ;   //灰度数据
    wire                gray_de             ;   //灰度数据使能

    wire                sobel_hsync         ;
    wire                sobel_vsync         ;
    wire    [ 7:0]      sobel_data          ;
    wire                sobel_de            ;

    wire    [15:0]      rho_data            ;
    wire                rho_vld             ;



//    wire    [11:0]      x_axis,x_axis_d     ;
//    wire    [11:0]      y_axis,y_axis_d     ;
    wire    [11:0]      x_axis_d            ;
    wire    [11:0]      y_axis_d            ;
    wire    [ 2:0]      vga_sig,vga_sig_d   ;

    wire                feature_hsync       ; 
    wire                feature_vsync       ; 
    wire    [11:0]      x_left              ; 
    wire    [11:0]      y_left              ; 
    wire    [11:0]      x_right             ; 
    wire    [11:0]      y_right             ; 
    wire                feature_de          ; 

    wire                dilate_de           ;
    wire                dilate_hsync        ;
    wire                dilate_vsync        ;
    wire    [7:0]       dilate_data         ;

    wire                erode_de            ;
    wire                erode_hsync         ;
    wire                erode_vsync         ;
    wire    [7:0]       erode_data          ;

    wire    [7:0]       left_rdaddr         ;
    wire    [7:0]       right_rdaddr        ;
    wire    [23:0]      left_axis           ;
    wire    [23:0]      right_axis          ;
    wire                left_rden           ;
    wire                right_rden          ;
    wire                axis_vld            ;

    wire                left_vld            ;
    wire    [7:0]       phase_left_data     ;
    wire    [27:0]      rho_left_data       ;

    wire                right_vld           ;
    wire    [7:0]       phase_right_data    ;
    wire    [27:0]      rho_right_data      ;

    wire                warning             ;

assign vga_sig = {img_hsync,img_vsync,img_de};

//img_gen # 
//(
//    .H_DISP             (H_DISP             ),
//    .V_DISP             (V_DISP             )
//)       
//u_img_gen       
//(       
//    .clk                (clk                ),
//    .rst_n              (rst_n              ),
//
//    .img_hsync          (img_hsync          ),
//    .img_vsync          (img_vsync          ),
//    .x_axis             (x_axis             ),
//    .y_axis             (y_axis             ),
//    .img_data           (img_data           ),
//    .img_de             (img_de             )
//);      

// RGB转灰度图 耗费1clk
RGB_Gray #
(
    .H_DISP             (H_DISP             ),  //图像宽度
    .V_DISP             (V_DISP             )   //图像高度
)
u_RGB_Gray         
(       
    .clk                (clk                ),
    .rst_n              (rst_n              ),
    .RGB_hsync          (img_hsync          ),
    .RGB_vsync          (img_vsync          ),
    .RGB_data           (img_data           ),
    .RGB_de             (img_de             ),
//    .x_axis             (x_axis             ),
//    .y_axis             (y_axis             ),
    .gray_hsync         (gray_hsync         ),
    .gray_vsync         (gray_vsync         ),
    .gray_data          (gray_data          ),
    .gray_de            (gray_de            )

//    .gray_hsync         (VGA_hsync         ),
//    .gray_vsync         (VGA_vsync         ),
//    .gray_data          (VGA_data          ),
//    .gray_de            (VGA_de            )
);

// 耗费4clk
sobel #
(
    .H_DISP             (H_DISP             ),  //图像宽度
    .V_DISP             (V_DISP             )   //图像高度
)
u_sobel
(
    .clk                (clk                ),  //时钟
    .rst_n              (rst_n              ),  //复位

    .Y_hsync            (gray_hsync         ),  //Y分量行同步
    .Y_vsync            (gray_vsync         ),  //Y分量场同步
    .Y_data             (gray_data          ),  //Y分量数据
    .Y_de               (gray_de            ),  //Y分量数据使能

    .value              (8'd255             ),  //阈值

    .sobel_hsync        (sobel_hsync        ),  //sobel行同步
    .sobel_vsync        (sobel_vsync        ),  //sobel场同步
    .sobel_data         (sobel_data         ),  //sobel数据
    .sobel_de           (sobel_de           )   //sobel数据使能

//    .sobel_hsync            (VGA_hsync          ),  //sobel行同步
//    .sobel_vsync            (VGA_vsync          ),  //sobel场同步
//    .sobel_data             (VGA_data           ),  //sobel数据
//    .sobel_de               (VGA_de             )   //sobel数据使能
);
// 腐蚀 3clk 保证特征点质量的情况下缩小样本量
erode #
(
    .H_DISP         (H_DISP         ),   //图像宽度
    .V_DISP         (V_DISP         )    //图像高度
)
u_erode
(
    .clk            (clk            ),
    .rst_n          (rst_n          ),
    .bina_de        (sobel_de       ),   //bina分量数据使能
    .bina_hsync     (sobel_hsync    ),   //bina分量行同步
    .bina_vsync     (sobel_vsync    ),   //bina分量场同步
    .bina_data      (sobel_data     ),   //bina分量数据

    .erode_de       (erode_de       ),   //erode数据使能
    .erode_hsync    (erode_hsync    ),   //erode行同步
    .erode_vsync    (erode_vsync    ),   //erode场同步
    .erode_data     (erode_data     )    //erode数据

//    .erode_de       (VGA_de       ),   //erode数据使能
//    .erode_hsync    (VGA_hsync    ),   //erode行同步
//    .erode_vsync    (VGA_vsync    ),   //erode场同步
//    .erode_data     (VGA_data     )    //erode数据
);

// 特征点提取，耗费2clk
feature_point # 
(
    .H_DISP             (H_DISP             ),
    .V_DISP             (V_DISP             )
)
u_feature_point 
(
    .clk                (clk                ),
    .rst_n              (rst_n              ),
//    .pre_hsync          (sobel_hsync        ),
//    .pre_vsync          (sobel_vsync        ),
    .pre_data           (erode_data         ),
    .pre_de             (erode_de           ),
    .x_axis             (x_axis_d           ),
    .y_axis             (y_axis_d           ),

//    .feature_hsync      (feature_hsync      ),
//    .feature_vsync      (feature_vsync      ),
    .x_left             (x_left             ),
    .y_left             (y_left             ),
    .x_right            (x_right            ),
    .y_right            (y_right            ),
    .feature_de         (feature_de         )
);

// 多bit数据同步，将x_data、y_data延时5clk，与sobel_data同步
delay_xbit # 
(
    .DATA_WIDTH     (DATA_WIDTH_12      ),
    .DLY_CYCLE      (DLY_CYCLE          )
)           
delay_x             
(           
    .rst_n          (rst_n              ),
    .clk            (clk                ),
    .i_data         (x_axis             ),
    .o_data         (x_axis_d           )
);          

delay_xbit #        
(           
    .DATA_WIDTH     (DATA_WIDTH_12      ),
    .DLY_CYCLE      (DLY_CYCLE          )
)           
delay_y             
(           
    .rst_n          (rst_n              ),
    .clk            (clk                ),
    .i_data         (y_axis             ),
    .o_data         (y_axis_d           )
);
// vsync、hsync、de信号同步
delay_xbit #            
(           
    .DATA_WIDTH     (DATA_WIDTH_3       ),
    .DLY_CYCLE      (DLY_CYCLE          )
)           
delay_vga_sig         
(           
    .rst_n          (rst_n              ),
    .clk            (clk                ),
    .i_data         (vga_sig            ),
    .o_data         (vga_sig_d          )
);
// 特征点存储 耗费2clk
feature_stor # 
(
    .H_DISP         (H_DISP             ),
    .V_DISP         (V_DISP             )
)   
u_feature_stor  
(   
    .clk            (clk                ),
    .rst_n          (rst_n              ),
    .x_left         (x_left             ),
    .y_left         (y_left             ),
    .x_right        (x_right            ),
    .y_right        (y_right            ),
    .feature_de     (feature_de         ),
    .left_rdaddr    (left_rdaddr        ),// 考虑好什么时候开始才能读到坐标，当y坐标达到3/4V_DISP
    .right_rdaddr   (right_rdaddr       ),
    .left_rden      (left_rden          ),   
    .right_rden     (right_rden         ),  

    .axis_vld       (axis_vld           ),
    .left_axis      (left_axis          ),
    .right_axis     (right_axis         )
);

read_ram #
(
    .H_DISP         (H_DISP             ),
    .V_DISP         (V_DISP             )
)
u_read_ram 
(
    .clk            (clk                ),
    .rst_n          (rst_n              ),
    .axis_vsync     (vga_sig_d[1]       ),
    .axis_de        (vga_sig_d[0]       ),
//   .left_axis      (left_axis          ),
//   .right_axis     (right_axis         ),
//   .axis_vld       (axis_vld           ),

    .left_rdaddr    (left_rdaddr        ),
    .right_rdaddr   (right_rdaddr       ),
    .left_rden      (left_rden          ),   
    .right_rden     (right_rden         )
);

// ρ参数计算 ρ=xcos + ysin 耗费18clk
// rho_para_l，rho_para_r里面的角度参数不同，信号名完全相同
rho_para_l  u_rho_para_left 
(
    .rst_n          (rst_n              ),
    .clk            (clk                ),
    .interest_part  (1'b0               ),
    .in_vld         (axis_vld           ),
    .x_y_axis       (left_axis          ),

    .out_vld        (left_vld           ),
    .phase_data     (phase_left_data    ),
    .rho_data       (rho_left_data      )
);

rho_para_r  u_rho_para_right 
(
    .rst_n          (rst_n              ),
    .clk            (clk                ),
    .interest_part  (1'b1               ),
    .in_vld         (axis_vld           ),
    .x_y_axis       (right_axis         ),

    .out_vld        (right_vld          ),
    .phase_data     (phase_right_data   ),
    .rho_data       (rho_right_data     )
);
// 偏移报警
departure_warning  departure_warning_inst 
(
    .rst_n          (rst_n              ),
    .clk            (clk                ),
    .in_left_vld    (left_vld           ),
    .in_right_vld   (right_vld          ),
    .phase_left     (phase_left_data    ),
    .phase_right    (phase_right_data   ),
    .warning        (warning            )
);

endmodule