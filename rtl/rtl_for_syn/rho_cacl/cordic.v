// https://blog.csdn.net/u010712012/article/details/77755567

// ??????18?clk
module cordic
(
    // input
    clk     ,
    rst_n   ,
    phase   ,
    in_vld  ,
    // output
    sin     ,    
    cos     ,
    out_vld ,
    error
);

    input           clk        ;
    input           rst_n      ;
    input           in_vld     ;
    input   [31:0]  phase      ;

    output  reg     out_vld    ;
    output  [31:0]  sin        ;
    output  [31:0]  cos        ;
    output  [31:0]  error      ;

//???????x0?y0?????16??????????xn?yn?
//?????cos?i???i????????????????????
`define rot0  32'd2949120       //45у*2^16
`define rot1  32'd1740992       //26.5651бу*2^16
`define rot2  32'd919872        //14.0362бу*2^16
`define rot3  32'd466944        //7.1250бу*2^16
`define rot4  32'd234368        //3.5763бу*2^16
`define rot5  32'd117312        //1.7899бу*2^16
`define rot6  32'd58688         //0.8952бу*2^16
`define rot7  32'd29312         //0.4476бу*2^16
`define rot8  32'd14656         //0.2238бу*2^16
`define rot9  32'd7360          //0.1119бу*2^16
`define rot10 32'd3648          //0.0560бу*2^16
`define rot11 32'd1856          //0.0280бу*2^16
`define rot12 32'd896           //0.0140бу*2^16
`define rot13 32'd448           //0.0070бу*2^16
`define rot14 32'd256           //0.0035бу*2^16
`define rot15 32'd128           //0.0018бу*2^16

parameter Pipeline = 16;
parameter K = 32'h09b74;    //K=0.607253*2^16,32'h09b74,

reg signed     [31:0]         sin;
reg signed     [31:0]         cos;
reg signed     [31:0]         error;
reg signed     [31:0]         x0 =0,y0 =0,z0 =0;
reg signed     [31:0]         x1 =0,y1 =0,z1 =0;
reg signed     [31:0]         x2 =0,y2 =0,z2 =0;
reg signed     [31:0]         x3 =0,y3 =0,z3 =0;
reg signed     [31:0]         x4 =0,y4 =0,z4 =0;
reg signed     [31:0]         x5 =0,y5 =0,z5 =0;
reg signed     [31:0]         x6 =0,y6 =0,z6 =0;
reg signed     [31:0]         x7 =0,y7 =0,z7 =0;
reg signed     [31:0]         x8 =0,y8 =0,z8 =0;
reg signed     [31:0]         x9 =0,y9 =0,z9 =0;
reg signed     [31:0]         x10=0,y10=0,z10=0;
reg signed     [31:0]         x11=0,y11=0,z11=0;
reg signed     [31:0]         x12=0,y12=0,z12=0;
reg signed     [31:0]         x13=0,y13=0,z13=0;
reg signed     [31:0]         x14=0,y14=0,z14=0;
reg signed     [31:0]         x15=0,y15=0,z15=0;
reg signed     [31:0]         x16=0,y16=0,z16=0;
reg            [ 1:0]         Quadrant [Pipeline:0];

reg     in_vld_d1,in_vld_d2,in_vld_d3,in_vld_d4,in_vld_d5
       ,in_vld_d6,in_vld_d7,in_vld_d8,in_vld_d9,in_vld_d10
       ,in_vld_d11,in_vld_d12,in_vld_d13,in_vld_d14,in_vld_d15
       ,in_vld_d16,in_vld_d17;

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        in_vld_d1  <= 1'b0;in_vld_d2  <= 1'b0;in_vld_d3  <= 1'b0;
        in_vld_d4  <= 1'b0;in_vld_d5  <= 1'b0;in_vld_d6  <= 1'b0;
        in_vld_d7  <= 1'b0;in_vld_d8  <= 1'b0;in_vld_d9  <= 1'b0;
        in_vld_d10 <= 1'b0;in_vld_d11 <= 1'b0;in_vld_d12 <= 1'b0;
        in_vld_d13 <= 1'b0;in_vld_d14 <= 1'b0;in_vld_d15 <= 1'b0;
        in_vld_d16 <= 1'b0;in_vld_d17 <= 1'b0;out_vld    <= 1'b0;
    end
    else 
    begin
        in_vld_d1  <= in_vld    ;in_vld_d2  <= in_vld_d1 ;in_vld_d3  <= in_vld_d2 ;
        in_vld_d4  <= in_vld_d3 ;in_vld_d5  <= in_vld_d4 ;in_vld_d6  <= in_vld_d5 ;
        in_vld_d7  <= in_vld_d6 ;in_vld_d8  <= in_vld_d7 ;in_vld_d9  <= in_vld_d8 ;
        in_vld_d10 <= in_vld_d9 ;in_vld_d11 <= in_vld_d10;in_vld_d12 <= in_vld_d11;
        in_vld_d13 <= in_vld_d12;in_vld_d14 <= in_vld_d13;in_vld_d15 <= in_vld_d14;
        in_vld_d16 <= in_vld_d15;in_vld_d17 <= in_vld_d16;out_vld    <= in_vld_d17;
    end
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        x0 <= 1'b0;                         
        y0 <= 1'b0;
        z0 <= 1'b0;
    end
    else 
    begin
        x0 <= K;
        y0 <= 32'd0;
        z0 <= phase[15:0] << 16;
    end
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        x1 <= 1'b0;                         
        y1 <= 1'b0;
        z1 <= 1'b0;
    end
    else if(z0[31])
    begin
        x1 <= x0 + y0;
        y1 <= y0 - x0;
        z1 <= z0 + `rot0;
    end
    else
    begin
      x1 <= x0 - y0;
      y1 <= y0 + x0;
      z1 <= z0 - `rot0;
    end
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        x2 <= 1'b0;                         
        y2 <= 1'b0;
        z2 <= 1'b0;
    end
    else if(z1[31])
   begin
        x2 <= x1 + (y1 >>> 1);
        y2 <= y1 - (x1 >>> 1);
        z2 <= z1 + `rot1;
   end
   else
   begin
        x2 <= x1 - (y1 >>> 1);
        y2 <= y1 + (x1 >>> 1);
        z2 <= z1 - `rot1;
   end
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        x3 <= 1'b0;                         
        y3 <= 1'b0;
        z3 <= 1'b0;
    end
    else if(z2[31])
    begin
        x3 <= x2 + (y2 >>> 2);
        y3 <= y2 - (x2 >>> 2);
        z3 <= z2 + `rot2;
    end
    else
    begin
        x3 <= x2 - (y2 >>> 2);
        y3 <= y2 + (x2 >>> 2);
        z3 <= z2 - `rot2;
    end
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        x4 <= 1'b0;                         
        y4 <= 1'b0;
        z4 <= 1'b0;
    end
    else if(z3[31])
   begin
       x4 <= x3 + (y3 >>> 3);
       y4 <= y3 - (x3 >>> 3);
       z4 <= z3 + `rot3;
   end
   else
   begin
       x4 <= x3 - (y3 >>> 3);
       y4 <= y3 + (x3 >>> 3);
       z4 <= z3 - `rot3;
   end
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        x5 <= 1'b0;                         
        y5 <= 1'b0;
        z5 <= 1'b0;
    end
    else if(z4[31])
   begin
       x5 <= x4 + (y4 >>> 4);
       y5 <= y4 - (x4 >>> 4);
       z5 <= z4 + `rot4;
   end
   else
   begin
       x5 <= x4 - (y4 >>> 4);
       y5 <= y4 + (x4 >>> 4);
       z5 <= z4 - `rot4;
   end
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        x6 <= 1'b0;                         
        y6 <= 1'b0;
        z6 <= 1'b0;
    end
    else if(z5[31])
   begin
       x6 <= x5 + (y5 >>> 5);
       y6 <= y5 - (x5 >>> 5);
       z6 <= z5 + `rot5;
   end
   else
   begin
       x6 <= x5 - (y5 >>> 5);
       y6 <= y5 + (x5 >>> 5);
       z6 <= z5 - `rot5;
   end
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        x7 <= 1'b0;                         
        y7 <= 1'b0;
        z7 <= 1'b0;
    end
    else if(z6[31])
   begin
       x7 <= x6 + (y6 >>> 6);
       y7 <= y6 - (x6 >>> 6);
       z7 <= z6 + `rot6;
   end
   else
   begin
       x7 <= x6 - (y6 >>> 6);
       y7 <= y6 + (x6 >>> 6);
       z7 <= z6 - `rot6;
   end
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        x8 <= 1'b0;                         
        y8 <= 1'b0;
        z8 <= 1'b0;
    end
    else if(z7[31])
   begin
       x8 <= x7 + (y7 >>> 7);
       y8 <= y7 - (x7 >>> 7);
       z8 <= z7 + `rot7;
   end
   else
   begin
       x8 <= x7 - (y7 >>> 7);
       y8 <= y7 + (x7 >>> 7);
       z8 <= z7 - `rot7;
   end
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        x9 <= 1'b0;                         
        y9 <= 1'b0;
        z9 <= 1'b0;
    end
    else if(z8[31])
   begin
       x9 <= x8 + (y8 >>> 8);
       y9 <= y8 - (x8 >>> 8);
       z9 <= z8 + `rot8;
   end
   else
   begin
       x9 <= x8 - (y8 >>> 8);
       y9 <= y8 + (x8 >>> 8);
       z9 <= z8 - `rot8;
   end
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        x10 <= 1'b0;                         
        y10 <= 1'b0;
        z10 <= 1'b0;
    end
    else if(z9[31])
   begin
       x10 <= x9 + (y9 >>> 9);
       y10 <= y9 - (x9 >>> 9);
       z10 <= z9 + `rot9;
   end
   else
   begin
       x10 <= x9 - (y9 >>> 9);
       y10 <= y9 + (x9 >>> 9);
       z10 <= z9 - `rot9;
   end
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        x11 <= 1'b0;                         
        y11 <= 1'b0;
        z11 <= 1'b0;
    end
    else if(z10[31])
   begin
       x11 <= x10 + (y10 >>> 10);
       y11 <= y10 - (x10 >>> 10);
       z11 <= z10 + `rot10;
   end
   else
   begin
       x11 <= x10 - (y10 >>> 10);
       y11 <= y10 + (x10 >>> 10);
       z11 <= z10 - `rot10;
   end
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        x12 <= 1'b0;                         
        y12 <= 1'b0;
        z12 <= 1'b0;
    end
    else if(z11[31])
   begin
       x12 <= x11 + (y11 >>> 11);
       y12 <= y11 - (x11 >>> 11);
       z12 <= z11 + `rot11;
   end
   else
   begin
       x12 <= x11 - (y11 >>> 11);
       y12 <= y11 + (x11 >>> 11);
       z12 <= z11 - `rot11;
   end
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        x13 <= 1'b0;                         
        y13 <= 1'b0;
        z13 <= 1'b0;
    end
    else if(z12[31])
   begin
       x13 <= x12 + (y12 >>> 12);
       y13 <= y12 - (x12 >>> 12);
       z13 <= z12 + `rot12;
   end
   else
   begin
       x13 <= x12 - (y12 >>> 12);
       y13 <= y12 + (x12 >>> 12);
       z13 <= z12 - `rot12;
   end
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        x14 <= 1'b0;                         
        y14 <= 1'b0;
        z14 <= 1'b0;
    end
    else if(z13[31])
   begin
       x14 <= x13 + (y13 >>> 13);
       y14 <= y13 - (x13 >>> 13);
       z14 <= z13 + `rot13;
   end
   else
   begin
       x14 <= x13 - (y13 >>> 13);
       y14 <= y13 + (x13 >>> 13);
       z14 <= z13 - `rot13;
   end
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        x15 <= 1'b0;                         
        y15 <= 1'b0;
        z15 <= 1'b0;
    end
    else if(z14[31])
   begin
       x15 <= x14 + (y14 >>> 14);
       y15 <= y14 - (x14 >>> 14);
       z15 <= z14 + `rot14;
   end
   else
   begin
       x15 <= x14 - (y14 >>> 14);
       y15 <= y14 + (x14 >>> 14);
       z15 <= z14 - `rot14;
   end
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        x16 <= 1'b0;                         
        y16 <= 1'b0;
        z16 <= 1'b0;
    end
    else if(z15[31])
   begin
       x16 <= x15 + (y15 >>> 15);
       y16 <= y15 - (x15 >>> 15);
       z16 <= z15 + `rot15;
   end
   else
   begin
       x16 <= x15 - (y15 >>> 15);
       y16 <= y15 + (x15 >>> 15);
       z16 <= z15 - `rot15;
   end
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        Quadrant[0 ] <= 2'b00;
        Quadrant[1 ] <= 2'b00;
        Quadrant[2 ] <= 2'b00;
        Quadrant[3 ] <= 2'b00;
        Quadrant[4 ] <= 2'b00;
        Quadrant[5 ] <= 2'b00;
        Quadrant[6 ] <= 2'b00;
        Quadrant[7 ] <= 2'b00;
        Quadrant[8 ] <= 2'b00;
        Quadrant[9 ] <= 2'b00;
        Quadrant[10] <= 2'b00;
        Quadrant[11] <= 2'b00;
        Quadrant[12] <= 2'b00;
        Quadrant[13] <= 2'b00;
        Quadrant[14] <= 2'b00;
        Quadrant[15] <= 2'b00;
        Quadrant[16] <= 2'b00;
    end
    else
    begin
        Quadrant[0 ] <= phase[17:16];
        Quadrant[1 ] <= Quadrant[0 ];
        Quadrant[2 ] <= Quadrant[1 ];
        Quadrant[3 ] <= Quadrant[2 ];
        Quadrant[4 ] <= Quadrant[3 ];
        Quadrant[5 ] <= Quadrant[4 ];
        Quadrant[6 ] <= Quadrant[5 ];
        Quadrant[7 ] <= Quadrant[6 ];
        Quadrant[8 ] <= Quadrant[7 ];
        Quadrant[9 ] <= Quadrant[8 ];
        Quadrant[10] <= Quadrant[9 ];
        Quadrant[11] <= Quadrant[10];
        Quadrant[12] <= Quadrant[11];
        Quadrant[13] <= Quadrant[12];
        Quadrant[14] <= Quadrant[13];
        Quadrant[15] <= Quadrant[14];
        Quadrant[16] <= Quadrant[15];
    end
end

always @ (posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        cos <= 1'b0;
        sin <= 1'b0;
        error <= 1'b0;
    end
    else
    begin
        error <= z16;
        case(Quadrant[16])
            2'b00: //if the phase is in first Quadrant,the sin(X)=sin(A),cos(X)=cos(A)
                begin
                    cos <= x16;
                    sin <= y16;
                end
            2'b01: //if the phase is in second Quadrant,the sin(X)=sin(A+90)=cosA,cos(X)=cos(A+90)=-sinA
                begin
                    cos <= ~(y16) + 1'b1;//-sin
                    sin <= x16;//cos
                end
            2'b10: //if the phase is in third Quadrant,the sin(X)=sin(A+180)=-sinA,cos(X)=cos(A+180)=-cosA
                begin
                    cos <= ~(x16) + 1'b1;//-cos
                    sin <= ~(y16) + 1'b1;//-sin
                end
            2'b11: //if the phase is in forth Quadrant,the sin(X)=sin(A+270)=-cosA,cos(X)=cos(A+270)=sinA
                begin
                    cos <= y16;//sin
                    sin <= ~(x16) + 1'b1;//-cos
                end
        endcase
    end
end


endmodule