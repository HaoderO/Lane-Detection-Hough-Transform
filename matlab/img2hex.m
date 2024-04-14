clc;
close all;
clear all;

pre_img = imread('lane1.jpg');    

[v,h,N] = size(pre_img); 
RGB_ij = uint64(zeros(v,h));

fid = fopen('pre_img1.txt','w');
for i = 1:v
    for j = 1:h
        R = double(pre_img(i,j,1));
        G = double(pre_img(i,j,2));
        B = double(pre_img(i,j,3));
        
        RGB          = R*(2^16) + G*(2^8) + B;
        RGB_ij(i,j)  = RGB;
        RGB_hex      = dec2hex(RGB);
        
        fprintf(fid,'%s\n',RGB_hex);
    end
end
fclose(fid); 

%imshow(pre_img),title('origin'); 