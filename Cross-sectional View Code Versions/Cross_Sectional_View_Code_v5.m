clc; clear;

% Import the cross-sectional image to be anayzed 
prompt = "What is the filename of the top view image with the nerve wrap?  ";
filename = input(prompt,"s");
import = imread(filename);
figure
imshow(import);


% Convert images to grayscale and binary for future use
nerve_grayscale = im2gray(import);
BW = im2bw(nerve_grayscale);

% Find image size and detect circular cross-section of the nerve, including radius and center data 
prompt2 = "What is the size of the nerve in the apparatus (in mm)?  ";
prompt2 = input(prompt2);

size = size(nerve_grayscale);
if prompt2 == 1
    [center, radius] = imfindcircles(nerve_grayscale,[50,60],"ObjectPolarity","dark","Sensitivity",0.97);
elseif prompt2 == 2
    [center, radius] = imfindcircles(nerve_grayscale,[100,160],"ObjectPolarity","dark","Sensitivity",0.97);
elseif prompt2 == 3
    [center, radius] = imfindcircles(nerve_grayscale,[150,180],"ObjectPolarity","dark","Sensitivity",0.98);
elseif prompt2 == 4
    [center, radius] = imfindcircles(nerve_grayscale,[200,230],"ObjectPolarity","dark","Sensitivity",0.99);
elseif prompt2 == 5
    [center, radius] = imfindcircles(nerve_grayscale,[240,260],"ObjectPolarity","bright","Sensitivity",0.992);
end

x_center = center(1);
y_center = center(2);
im_width = 1:1:size(2);


% Code to measure the angles for a perfect circular cross-section for
% multiple points
lineLength2 = radius;
angle=[90:10:440]; 

figure
imshow(nerve_grayscale); 
viscircles(center, radius,'EdgeColor','b');
hold on
axis on
plot(x_center,y_center,'ro','LineWidth',2);


% Find top and bottom points where this vertical line intersects with
% circular cross-section
top_x = x_center;
top_y = y_center - radius;
plot(top_x,top_y,'ro','LineWidth',2);
bottom_x = x_center;
bottom_y = y_center + radius;
%plot(bottom_x,bottom_y,'go','LineWidth',2);


% Find points that wrap leaves nerve
[wrap_left_x, wrap_left_y] = getpts();
[wrap_right_x, wrap_right_y] = getpts;

wrap_left_x_dist = x_center - wrap_left_x;
wrap_left_y_dist = y_center - wrap_left_y;

wrap_right_x_dist = wrap_right_x - x_center;
wrap_right_y_dist = y_center - wrap_right_y;

% Calculate distance between these points and center
left_pt_dist = sqrt(wrap_left_x_dist^2 + wrap_left_y_dist^2);
right_pt_dist = sqrt(wrap_right_x_dist^2 + wrap_right_y_dist^2);
centerline_dist = sqrt((top_x-x_center)^2+(y_center-top_y)^2);

plot([wrap_left_x x_center], [wrap_left_y y_center], "LineWidth",2);
plot([wrap_right_x x_center], [wrap_right_y y_center], "LineWidth",2);
plot([top_x x_center], [top_y y_center], "LineWidth",2);

% Calculate the remaining lengths 
dist_bt_left_and_center = sqrt((top_x-wrap_left_x)^2+(wrap_left_y-top_y)^2);
dist_bt_right_and_center = sqrt((wrap_right_x-top_x)^2+(wrap_right_y-top_y)^2);


% Fing angle for each triangle
angle1 = acosd(-(dist_bt_left_and_center^2 - left_pt_dist^2 - centerline_dist^2)/(2*left_pt_dist*centerline_dist));
angle2 = acosd(-(dist_bt_right_and_center^2 - right_pt_dist^2 - centerline_dist^2)/(2*right_pt_dist*centerline_dist));

% Find the arc length of each side
arclength1 = (angle1/360)*(2*pi*radius);
arclength2 = (angle2/360)*(2*pi*radius);

% Convert this value to mm length
px_2_mm_ratio = prompt2/radius;
arclength1_mm = arclength1*px_2_mm_ratio;
arclenth2_mm = arclength2*px_2_mm_ratio;