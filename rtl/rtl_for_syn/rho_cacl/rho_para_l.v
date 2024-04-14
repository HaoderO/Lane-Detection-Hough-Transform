module rho_para_l
(
    input  wire         rst_n       ,
    input  wire         clk         ,
    input  wire         interest_part,// 0：left，1：right
    input  wire         in_vld      ,
//    input   wire [23:0]  left_axis       ,// 高12bit：x坐标，低12bit：y坐标
//    input   wire [23:0]  right_axis      ,// 高12bit：x坐标，低12bit：y坐标
    input  wire [23:0]  x_y_axis      ,// 高12bit：x坐标，低12bit：y坐标

 
    output reg          out_vld     ,    
    output reg  [7:0]   phase_data   ,  // rho max 
    output reg  [27:0]  rho_data     // rho max 
);

wire       [23:0]  x           ;
wire       [23:0]  y           ;

wire [27:0] rho_10,rho_15,rho_20,rho_25,rho_30,rho_35,rho_40,rho_45,
            rho_50,rho_55,rho_60,rho_65,rho_70,rho_75,rho_80,rho_85;
wire        vld_10,vld_15,vld_20,vld_25,vld_30,vld_35,vld_40,vld_45,
            vld_50,vld_55,vld_60,vld_65,vld_70,vld_75,vld_80,vld_85;
wire [27:0] rho_10_max,rho_15_max,rho_20_max,rho_25_max,rho_30_max,rho_35_max,rho_40_max,rho_45_max,
            rho_50_max,rho_55_max,rho_60_max,rho_65_max,rho_70_max,rho_75_max,rho_80_max,rho_85_max;
wire        vld_10_max,vld_15_max,vld_20_max,vld_25_max,vld_30_max,vld_35_max,vld_40_max,vld_45_max,
            vld_50_max,vld_55_max,vld_60_max,vld_65_max,vld_70_max,vld_75_max,vld_80_max,vld_85_max;
// 高4bit表示对应的phase编码
// 0000：phase=100°,0001：phase=105°,0010：phase=110°,0011：phase=115°
// 0100：phase=120°,0101：phase=125°,0110：phase=130°,0111：phase=135°
// 1000：phase=140°,1001：phase=145°,1010：phase=150°,1011：phase=155°
// 1100：phase=160°,1101：phase=165°,1110：phase=170°,1111：phase=175°
wire [31:0] code_rho_10_max,code_rho_15_max,code_rho_20_max,code_rho_25_max,code_rho_30_max,code_rho_35_max,code_rho_40_max,code_rho_45_max,
            code_rho_50_max,code_rho_55_max,code_rho_60_max,code_rho_65_max,code_rho_70_max,code_rho_75_max,code_rho_80_max,code_rho_85_max;
reg  [31:0] rho_10_15_max,rho_20_25_max,rho_30_35_max,rho_40_45_max,
            rho_50_55_max,rho_60_65_max,rho_70_75_max,rho_80_85_max;
reg  [31:0] rho_10_15_20_25_max,rho_30_35_40_45_max,
            rho_50_55_60_65_max,rho_70_75_80_85_max;
reg  [31:0] rho_10_15_20_25_30_35_40_45_max,
            rho_50_55_60_65_70_75_80_85_max;
reg  [31:0] rho_max;
reg         rho_vld_d1,rho_vld_d2,rho_vld_d3,rho_vld_d4;

assign x  = x_y_axis[23:12];
assign y  = x_y_axis[11:0];

assign code_rho_10_max = {4'b0000,rho_10_max};
assign code_rho_15_max = {4'b0001,rho_15_max};
assign code_rho_20_max = {4'b0010,rho_20_max};
assign code_rho_25_max = {4'b0011,rho_25_max};
assign code_rho_30_max = {4'b0100,rho_30_max};
assign code_rho_35_max = {4'b0101,rho_35_max};
assign code_rho_40_max = {4'b0110,rho_40_max};
assign code_rho_45_max = {4'b0111,rho_45_max};
assign code_rho_50_max = {4'b1000,rho_50_max};
assign code_rho_55_max = {4'b1001,rho_55_max};
assign code_rho_60_max = {4'b1010,rho_60_max};
assign code_rho_65_max = {4'b1011,rho_65_max};
assign code_rho_70_max = {4'b1100,rho_70_max};
assign code_rho_75_max = {4'b1101,rho_75_max};
assign code_rho_80_max = {4'b1110,rho_80_max};
assign code_rho_85_max = {4'b1111,rho_85_max};


// ρ参数计算 耗费18clk
// phase = 100°
rho_cacl  phase_10 
(
    .rst_n(rst_n),.clk(clk),.interest_part(1'b0),.in_vld(in_vld),.x(x),.y(y),.phase({16'd1,16'd100 - 16'd90}),

    .out_vld(vld_10),.rho_data(rho_10)
);
// phase = 105°
rho_cacl  phase_15 
(
    .rst_n(rst_n),.clk(clk),.interest_part(1'b0),.in_vld(in_vld),.x(x),.y(y),.phase({16'd1,16'd105 - 16'd90}),

    .out_vld(vld_15),.rho_data(rho_15)
);
// phase = 110°
rho_cacl  phase_20 
(
    .rst_n(rst_n),.clk(clk),.interest_part(1'b0),.in_vld(in_vld),.x(x),.y(y),.phase({16'd1,16'd110 - 16'd90}),

    .out_vld(vld_20),.rho_data(rho_20)
);
// phase = 115°
rho_cacl  phase_25 
(
    .rst_n(rst_n),.clk(clk),.interest_part(1'b0),.in_vld(in_vld),.x(x),.y(y),.phase({16'd1,16'd115 - 16'd90}),

    .out_vld(vld_25),.rho_data(rho_25)
);
// phase = 120°
rho_cacl  phase_30 
(
    .rst_n(rst_n),.clk(clk),.interest_part(1'b0),.in_vld(in_vld),.x(x),.y(y),.phase({16'd1,16'd120 - 16'd90}),

    .out_vld(vld_30),.rho_data(rho_30)
);
// phase = 125°
rho_cacl  phase_35 
(
    .rst_n(rst_n),.clk(clk),.interest_part(1'b0),.in_vld(in_vld),.x(x),.y(y),.phase({16'd1,16'd125 - 16'd90}),

    .out_vld(vld_35),.rho_data(rho_35)
);
// phase = 130°
rho_cacl  phase_40 
(
    .rst_n(rst_n),.clk(clk),.interest_part(1'b0),.in_vld(in_vld),.x(x),.y(y),.phase({16'd1,16'd130 - 16'd90}),

    .out_vld(vld_40),.rho_data(rho_40)
);
// phase = 135°
rho_cacl  phase_45 
(
    .rst_n(rst_n),.clk(clk),.interest_part(1'b0),.in_vld(in_vld),.x(x),.y(y),.phase({16'd1,16'd135 - 16'd90}),

    .out_vld(vld_45),.rho_data(rho_45)
);
// phase = 140°
rho_cacl  phase_50 
(
    .rst_n(rst_n),.clk(clk),.interest_part(1'b0),.in_vld(in_vld),.x(x),.y(y),.phase({16'd1,16'd140 - 16'd90}),

    .out_vld(vld_50),.rho_data(rho_50)
);
// phase = 145°
rho_cacl  phase_55 
(
    .rst_n(rst_n),.clk(clk),.interest_part(1'b0),.in_vld(in_vld),.x(x),.y(y),.phase({16'd1,16'd145 - 16'd90}),

    .out_vld(vld_55),.rho_data(rho_55)
);
// phase = 150°
rho_cacl  phase_60 
(
    .rst_n(rst_n),.clk(clk),.interest_part(1'b0),.in_vld(in_vld),.x(x),.y(y),.phase({16'd1,16'd150 - 16'd90}),

    .out_vld(vld_60),.rho_data(rho_60)
);
// phase = 155°
rho_cacl  phase_65 
(
    .rst_n(rst_n),.clk(clk),.interest_part(1'b0),.in_vld(in_vld),.x(x),.y(y),.phase({16'd1,16'd155 - 16'd90}),

    .out_vld(vld_65),.rho_data(rho_65)
);
// phase = 160°
rho_cacl  phase_70 
(
    .rst_n(rst_n),.clk(clk),.interest_part(1'b0),.in_vld(in_vld),.x(x),.y(y),.phase({16'd1,16'd160 - 16'd90}),

    .out_vld(vld_70),.rho_data(rho_70)
);
// phase = 165°
rho_cacl  phase_75 
(
    .rst_n(rst_n),.clk(clk),.interest_part(1'b0),.in_vld(in_vld),.x(x),.y(y),.phase({16'd1,16'd165 - 16'd90}),

    .out_vld(vld_75),.rho_data(rho_75)
);
// phase = 170°
rho_cacl  phase_80 
(
    .rst_n(rst_n),.clk(clk),.interest_part(1'b0),.in_vld(in_vld),.x(x),.y(y),.phase({16'd1,16'd170 - 16'd90}),

    .out_vld(vld_80),.rho_data(rho_80)
);
// phase = 175°
rho_cacl  phase_85 
(
    .rst_n(rst_n),.clk(clk),.interest_part(1'b0),.in_vld(in_vld),.x(x),.y(y),.phase({16'd1,16'd175 - 16'd90}),

    .out_vld(vld_85),.rho_data(rho_85)
);

// 获取局部phase的ρ参数最大值 耗费256clk
rho_max  u_rho_max_10 
(
    .rst_n(rst_n),.clk(clk),.in_vld(vld_10),.rho(rho_10),
    
    .out_vld(vld_10_max),.rho_max(rho_10_max)
);
rho_max  u_rho_max_15 
(
    .rst_n(rst_n),.clk(clk),.in_vld(vld_15),.rho(rho_15),
    
    .out_vld(vld_15_max),.rho_max(rho_15_max)
);
rho_max  u_rho_max_20 
(
    .rst_n(rst_n),.clk(clk),.in_vld(vld_20),.rho(rho_20),
    
    .out_vld(vld_20_max),.rho_max(rho_20_max)
);
rho_max  u_rho_max_25 
(
    .rst_n(rst_n),.clk(clk),.in_vld(vld_25),.rho(rho_25),
    
    .out_vld(vld_25_max),.rho_max(rho_25_max)
);
rho_max  u_rho_max_30 
(
    .rst_n(rst_n),.clk(clk),.in_vld(vld_30),.rho(rho_30),
    
    .out_vld(vld_30_max),.rho_max(rho_30_max)
);
rho_max  u_rho_max_35 
(
    .rst_n(rst_n),.clk(clk),.in_vld(vld_35),.rho(rho_35),
    
    .out_vld(vld_35_max),.rho_max(rho_35_max)
);
rho_max  u_rho_max_40 
(
    .rst_n(rst_n),.clk(clk),.in_vld(vld_40),.rho(rho_40),
    
    .out_vld(vld_40_max),.rho_max(rho_40_max)
);
rho_max  u_rho_max_45 
(
    .rst_n(rst_n),.clk(clk),.in_vld(vld_45),.rho(rho_45),
    
    .out_vld(vld_45_max),.rho_max(rho_45_max)
);
rho_max  u_rho_max_50 
(
    .rst_n(rst_n),.clk(clk),.in_vld(vld_50),.rho(rho_50),
    
    .out_vld(vld_50_max),.rho_max(rho_50_max)
);
rho_max  u_rho_max_55 
(
    .rst_n(rst_n),.clk(clk),.in_vld(vld_55),.rho(rho_55),
    
    .out_vld(vld_55_max),.rho_max(rho_55_max)
);
rho_max  u_rho_max_60 
(
    .rst_n(rst_n),.clk(clk),.in_vld(vld_60),.rho(rho_60),
    
    .out_vld(vld_60_max),.rho_max(rho_60_max)
);
rho_max  u_rho_max_65 
(
    .rst_n(rst_n),.clk(clk),.in_vld(vld_65),.rho(rho_65),
    
    .out_vld(vld_65_max),.rho_max(rho_65_max)
);
rho_max  u_rho_max_70 
(
    .rst_n(rst_n),.clk(clk),.in_vld(vld_70),.rho(rho_70),
    
    .out_vld(vld_70_max),.rho_max(rho_70_max)
);
rho_max  u_rho_max_75 
(
    .rst_n(rst_n),.clk(clk),.in_vld(vld_75),.rho(rho_75),
    
    .out_vld(vld_75_max),.rho_max(rho_75_max)
);
rho_max  u_rho_max_80 
(
    .rst_n(rst_n),.clk(clk),.in_vld(vld_80),.rho(rho_80),
    
    .out_vld(vld_80_max),.rho_max(rho_80_max)
);
rho_max  u_rho_max_85 
(
    .rst_n(rst_n),.clk(clk),.in_vld(vld_85),.rho(rho_85),
    
    .out_vld(vld_85_max),.rho_max(rho_85_max)
);

// 获取ρ最大值 4clk
///////////////////////////////////////////////////
// 8/16
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        rho_10_15_max <= 32'd0;
    else if(code_rho_10_max[27:0] >= code_rho_15_max[27:0]) 
        rho_10_15_max <= code_rho_10_max;
    else 
        rho_10_15_max <= code_rho_15_max;
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        rho_20_25_max <= 32'd0;
    else if(code_rho_20_max[27:0] >= code_rho_25_max[27:0]) 
        rho_20_25_max <= code_rho_20_max;
    else 
        rho_20_25_max <= code_rho_25_max;
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        rho_30_35_max <= 32'd0;
    else if(code_rho_30_max[27:0] >= code_rho_35_max[27:0]) 
        rho_30_35_max <= code_rho_30_max;
    else 
        rho_30_35_max <= code_rho_35_max;
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        rho_40_45_max <= 32'd0;
    else if(code_rho_40_max[27:0] >= code_rho_45_max[27:0]) 
        rho_40_45_max <= code_rho_40_max;
    else 
        rho_40_45_max <= code_rho_45_max;
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        rho_50_55_max <= 32'd0;
    else if(code_rho_50_max[27:0] >= code_rho_55_max[27:0]) 
        rho_50_55_max <= code_rho_50_max;
    else 
        rho_50_55_max <= code_rho_55_max;
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        rho_60_65_max <= 32'd0;
    else if(code_rho_60_max[27:0] >= code_rho_65_max[27:0]) 
        rho_60_65_max <= code_rho_60_max;
    else 
        rho_60_65_max <= code_rho_65_max;
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        rho_70_75_max <= 32'd0;
    else if(code_rho_70_max[27:0] >= code_rho_75_max[27:0]) 
        rho_70_75_max <= code_rho_70_max;
    else 
        rho_70_75_max <= code_rho_75_max;
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        rho_80_85_max <= 32'd0;
    else if(code_rho_80_max[27:0] >= code_rho_85_max[27:0]) 
        rho_80_85_max <= code_rho_80_max;
    else 
        rho_80_85_max <= code_rho_85_max;
end
///////////////////////////////////////////////////
// 4/8
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        rho_10_15_20_25_max <= 32'd0;
    else if(rho_10_15_max[27:0] >= rho_20_25_max[27:0]) 
        rho_10_15_20_25_max <= rho_10_15_max;
    else 
        rho_10_15_20_25_max <= rho_20_25_max;
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        rho_30_35_40_45_max <= 32'd0;
    else if(rho_30_35_max[27:0] >= rho_40_45_max[27:0]) 
        rho_30_35_40_45_max <= rho_30_35_max;
    else 
        rho_30_35_40_45_max <= rho_40_45_max;
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        rho_50_55_60_65_max <= 32'd0;
    else if(rho_50_55_max[27:0] >= rho_60_65_max[27:0]) 
        rho_50_55_60_65_max <= rho_50_55_max;
    else 
        rho_50_55_60_65_max <= rho_60_65_max;
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        rho_70_75_80_85_max <= 32'd0;
    else if(rho_70_75_max[27:0] >= rho_80_85_max[27:0]) 
        rho_70_75_80_85_max <= rho_70_75_max;
    else 
        rho_70_75_80_85_max <= rho_80_85_max;
end
///////////////////////////////////////////////////
// 2/4
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        rho_10_15_20_25_30_35_40_45_max <= 32'd0;
    else if(rho_10_15_20_25_max[27:0] >= rho_30_35_40_45_max[27:0]) 
        rho_10_15_20_25_30_35_40_45_max <= rho_10_15_20_25_max;
    else 
        rho_10_15_20_25_30_35_40_45_max <= rho_30_35_40_45_max;
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        rho_50_55_60_65_70_75_80_85_max <= 32'd0;
    else if(rho_50_55_60_65_max[27:0] >= rho_70_75_80_85_max[27:0]) 
        rho_50_55_60_65_70_75_80_85_max <= rho_50_55_60_65_max;
    else 
        rho_50_55_60_65_70_75_80_85_max <= rho_70_75_80_85_max;
end
///////////////////////////////////////////////////
// ρ MAX
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        rho_max <= 32'd0;
    else if(rho_10_15_20_25_30_35_40_45_max[27:0] >= rho_50_55_60_65_70_75_80_85_max[27:0]) 
        rho_max <= rho_10_15_20_25_30_35_40_45_max;
    else 
        rho_max <= rho_50_55_60_65_70_75_80_85_max;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        rho_data <= 28'd0;
    else if(rho_vld_d4) 
        rho_data <= rho_max;
end
/*
模块看的坐标角度是这样，所以根据初中所学知识，需要对角度值做调整
    ——|————————→x
      |
      | 
      ↓
      y
*/ 
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        phase_data <= 8'd0;
    else if(rho_vld_d4 && interest_part)// right
        begin
        case(rho_max[31:28])
            4'b0000 : phase_data <= 8'd180 - 8'd10;
            4'b0001 : phase_data <= 8'd180 - 8'd15;
            4'b0010 : phase_data <= 8'd180 - 8'd20;
            4'b0011 : phase_data <= 8'd180 - 8'd25;
            4'b0100 : phase_data <= 8'd180 - 8'd30;
            4'b0101 : phase_data <= 8'd180 - 8'd35;
            4'b0110 : phase_data <= 8'd180 - 8'd40;
            4'b0111 : phase_data <= 8'd180 - 8'd45;
            4'b1000 : phase_data <= 8'd180 - 8'd50;
            4'b1001 : phase_data <= 8'd180 - 8'd55;
            4'b1010 : phase_data <= 8'd180 - 8'd60;
            4'b1011 : phase_data <= 8'd180 - 8'd65;
            4'b1100 : phase_data <= 8'd180 - 8'd70;
            4'b1101 : phase_data <= 8'd180 - 8'd75;
            4'b1110 : phase_data <= 8'd180 - 8'd80;
            4'b1111 : phase_data <= 8'd180 - 8'd85;
            default : phase_data <= 8'd180 - 8'd45;
        endcase
    end 
    else if(rho_vld_d4 && ~interest_part)// left
        begin
        case(rho_max[31:28])
            4'b0000 : phase_data <= 8'd10 /*8'd90 - 8'd10 8'd180 - 8'd100*/;
            4'b0001 : phase_data <= 8'd15 /*8'd90 - 8'd15 8'd180 - 8'd105*/;
            4'b0010 : phase_data <= 8'd20 /*8'd90 - 8'd20 8'd180 - 8'd110*/;
            4'b0011 : phase_data <= 8'd25 /*8'd90 - 8'd25 8'd180 - 8'd115*/;
            4'b0100 : phase_data <= 8'd30 /*8'd90 - 8'd30 8'd180 - 8'd120*/;
            4'b0101 : phase_data <= 8'd35 /*8'd90 - 8'd35 8'd180 - 8'd125*/;
            4'b0110 : phase_data <= 8'd40 /*8'd90 - 8'd40 8'd180 - 8'd130*/;
            4'b0111 : phase_data <= 8'd45 /*8'd90 - 8'd45 8'd180 - 8'd135*/;
            4'b1000 : phase_data <= 8'd50 /*8'd90 - 8'd50 8'd180 - 8'd140*/;
            4'b1001 : phase_data <= 8'd55 /*8'd90 - 8'd55 8'd180 - 8'd145*/;
            4'b1010 : phase_data <= 8'd60 /*8'd90 - 8'd60 8'd180 - 8'd150*/;
            4'b1011 : phase_data <= 8'd65 /*8'd90 - 8'd65 8'd180 - 8'd155*/;
            4'b1100 : phase_data <= 8'd70 /*8'd90 - 8'd70 8'd180 - 8'd160*/;
            4'b1101 : phase_data <= 8'd75 /*8'd90 - 8'd75 8'd180 - 8'd165*/;
            4'b1110 : phase_data <= 8'd80 /*8'd90 - 8'd80 8'd180 - 8'd170*/;
            4'b1111 : phase_data <= 8'd85 /*8'd90 - 8'd85 8'd180 - 8'd175*/;
            default : phase_data <= 8'd45 /*8'd90 - 8'd45 8'd180 - 8'd135*/;
        endcase
    end 
end
// 信号同步
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rho_vld_d1 <= 1'd0;
        rho_vld_d2 <= 1'd0;
        rho_vld_d3 <= 1'd0;
        rho_vld_d4 <= 1'd0;
        out_vld    <= 1'd0;
    end
    else begin
        rho_vld_d1 <= vld_10_max;
        rho_vld_d2 <= rho_vld_d1;
        rho_vld_d3 <= rho_vld_d2;
        rho_vld_d4 <= rho_vld_d3;
        out_vld    <= rho_vld_d4;
    end
end

endmodule