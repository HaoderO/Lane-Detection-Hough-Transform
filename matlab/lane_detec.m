close all; clear all; clc; 
 
% Read image into workspace
I = imread('lane.jpg'); 
figure; 
subplot(131), imshow(I); 
 
% Rotate the image
rotI = imrotate(I, 33, 'crop'); 
subplot(132), imshow(rotI); 
 
% Create a binary image
BW = edge(rotI, 'canny'); 
subplot(133), imshow(BW); 
 
% Create the hough transform using the binary image 
[H, T, R] = hough(BW); 
figure, imshow(H, [], 'XData', T, 'YData', R, 'InitialMagnification', 'fit'); 
xlabel('\theta'), ylabel('\rho'); 
axis on, axis normal, hold on;
colormap(gca, hot);
 
% Find peaks in the hough transform of the image
P = houghpeaks(H, 5); 
x = T(P(:,2));
y = R(P(:,1)); 
plot(x, y, 's', 'color', 'blue'); 
 
% Find lines and plot them
lines = houghlines(BW, T, R, P, 'FillGap', 5, 'MinLength', 7); 
figure, imshow(rotI), hold on; 
max_len = 0; 
for k = 1 : length(lines)  % here length(lines)=12
   xy = [lines(k).point1; lines(k).point2]; 
   plot(xy(:, 1), xy(:, 2), 'LineWidth', 2, 'Color', 'green');
   
   % Plot beginnings and ends of lines
   plot(xy(1,1), xy(1,2), 'x', 'LineWidth', 2, 'Color', 'yellow');
   plot(xy(2,1), xy(2,2), 'x', 'LineWidth', 2, 'Color', 'red'); 
   
   % Determine the endpoints of the longest line segment
   len = norm(lines(k).point1 - lines(k).point2); % distance between point1 and point2
   if ( len > max_len )
      max_len = len; 
      xy_long = xy; 
   end
end
 
% Highlinght the longest line segment by coloring it cyan
plot(xy_long(:, 1), xy_long(:, 2), 'LineWidth', 2, 'Color', 'cyan'); 