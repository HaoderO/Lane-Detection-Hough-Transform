// 特征点存储，耗费2clk
module feature_stor #
(
    parameter H_DISP            = 12'd640       ,   //图像宽度
    parameter V_DISP            = 12'd480           //图像高度
)
(
    input   wire         clk             , 
    input   wire         rst_n           , 
    input   wire [11:0]  x_left          ,   //左下部分感兴趣区域特征点的x坐标
    input   wire [11:0]  y_left          ,   //左下部分感兴趣区域特征点的y坐标
    input   wire [11:0]  x_right         ,   //右下部分感兴趣区域特征点的x坐标
    input   wire [11:0]  y_right         ,   //右下部分感兴趣区域特征点的y坐标
    input   wire         feature_de      ,   //感兴趣区域数据使能

    input   wire [7:0]   left_rdaddr     ,   //读地址
    input   wire [7:0]   right_rdaddr    ,   //读地址
    input   wire         left_rden       ,   //读地址
    input   wire         right_rden      ,   //读地址

    output  reg          axis_vld        ,// 
    output  wire [23:0]  left_axis       ,// 高12bit：x坐标，低12bit：y坐标
    output  wire [23:0]  right_axis       // 高12bit：x坐标，低12bit：y坐标

);

wire left_part ;// 左下感兴趣区域有效
wire right_part;// 右下感兴趣区域有效

reg  left_wren ;// 写使能
reg  right_wren;// 写使能

//reg   left_rden_d;// 
//reg  right_rden_d;// 

reg [7:0] left_wraddr ;// 写地址
reg [7:0] right_wraddr;// 写地址

reg [23:0] left_position ;
reg [23:0] right_position;

// 感兴趣区域坐标不会出现0，所以下面对额逻辑导致left_part始终为1，进而写入无效坐标
//assign left_part  = (x_left < (H_DISP >> 1)) ? 1'b1 : 1'b0;

assign left_part  = ((x_left < (H_DISP >> 1)) && (x_left > 12'd0)) ? 1'b1 : 1'b0;
assign right_part = (x_right > (H_DISP >> 1)) ? 1'b1 : 1'b0;

// 生成写地址
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        left_wraddr <= 8'd0;
    else if(left_wraddr == 8'd255)
        left_wraddr <= 8'd0;
    else if((feature_de == 1'b1) && (left_part == 1'b1))
        left_wraddr <= left_wraddr + 1'b1;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        right_wraddr <= 8'd0;
    else if(right_wraddr == 8'd255)
        right_wraddr <= 8'd0;
    else if((feature_de == 1'b1) && (right_part == 1'b1))
        right_wraddr <= right_wraddr + 1'b1;
end

// 生成写使能
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        left_wren <= 1'b0;
    else if(left_wraddr == 8'd255)
        left_wren <= 1'b0;
    else if(left_part == 1'b1)
        left_wren <= feature_de;
    else 
        left_wren <= 1'b0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        right_wren <= 1'b0;
    else if(right_wraddr == 8'd255)
        right_wren <= 1'b0;
    else if(right_part == 1'b1)
        right_wren <= feature_de;
    else 
        right_wren <= 1'b0;
end
// 生成写数据
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        left_position <= 24'd0;
    else if((feature_de == 1'b1) && (left_part == 1'b1))
        left_position <= {x_left,y_left};
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        right_position <= 24'd0;
    else if((feature_de == 1'b1) && (right_part == 1'b1))
        right_position <= {x_right,y_right};
end

feature_ram left
(
	.clock      (clk            ),
	.data       (left_position  ),
	.rdaddress  (left_rdaddr    ),
    .rden       (left_rden      ),
	.wraddress  (left_wraddr    ),
	.wren       (left_wren      ),
    
	.q          (left_axis      )
);

feature_ram right
(
	.clock      (clk),
	.data       (right_position ),
	.rdaddress  (right_rdaddr   ),
    .rden       (right_rden     ),
	.wraddress  (right_wraddr   ),
	.wren       (right_wren     ),

	.q          (right_axis     )
);

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
    begin
//        left_rden_d  <= 1'd0;        
//        right_rden_d <= 1'd0;        
        axis_vld      <= 1'd0;
    end
    else
    begin
//        left_rden_d  <= left_rden;        
//        right_rden_d <= right_rden;                
        axis_vld      <= left_rden | right_rden;
    end
end

endmodule