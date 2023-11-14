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
size = size(nerve_grayscale);
[center, radius] = imfindcircles(nerve_grayscale,[240,270],"ObjectPolarity","bright","Sensitivity",0.99); % Diamter range may have to be changed
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

% Plot a vertical line through circle's center
%plot([x_center x_center], [0 size(1)],'LineWidth',2);
%plot([0 size(2)], [y_center y_center],'LineWidth',2);

% Find top and bottom points where this vertical line intersects with
% circular cross-section
top_x = x_center;
top_y = y_center - radius;
plot(top_x,top_y,'ro','LineWidth',2);
bottom_x = x_center;
bottom_y = y_center + radius;
%plot(bottom_x,bottom_y,'go','LineWidth',2);

% Plot horizontal lines that pass through these points
%plot([0 size(2)], [top_y top_y],'b','LineWidth',2);
%plot([0 size(2)], [bottom_y bottom_y],'b','LineWidth',2);


for i = 1:numel(angle)
  e = x_center + radius*cosd(angle(i));
  h = y_center + radius*sind(angle(i));
  x(i)= e;
  y(i) = h;
  %plot([x_center e], [y_center h]);
end

x_dist = x - x_center;
y_dist = (y_center+radius)- y; 

% Find inner angle using tangent of these two distances^ and subtract that from 90
for j = 1:i
tangent(j) = x_dist(j)/y_dist(j);
angle_from_horiz(j) = 90 - atand(tangent(j));
end

hold on
for k = 1:j
    plot([x_center x(k)], [y_center-radius y(k)],"Color",[0 1 1]);
  
    %angle_line_m(k) = (y(k)-(y_center-radius))/(x(k)-x_center);
    %angle_line_int(k) = top_y - angle_line_m(k)*top_x;
    %angle_line_y = (angle_line_m(k)*im_width + angle_line_int(k));
    %angle_line_y(angle_line_y<(y_center-radius)) = 0;
    %plot(im_width,angle_line_y,'c','LineWidth',1);
    
    if x(k) < x_center
        plot([0 x(k)], [y(k) y(k)],"Color",[0 1 1]);
    elseif x(k) == x_center
        continue
    else
        plot([x(k) size(2)], [y(k) y(k)],"Color",[0 1 1]); 
    end

    hold on
    if angle_from_horiz(k) > 90
       angle_from_horiz(k) = 180 - angle_from_horiz(k);
    end
    %angle_string(k) = string(angle_from_horiz(k));
end
%angle_string = flip(string(angle_from_horiz));
%angle_string = [angle_string(end),angle_string(1:end-1)];

%for m = 1:k
     %text(x(m),y(m),angle_string(m),"Color",[1 1 1]);
%end

sorted_ref_angles = sort(angle_from_horiz);
sorted_ref_angles = [sorted_ref_angles(end),sorted_ref_angles(1:end-1)];

[wrap_x, wrap_y] = getpts;
wrap_x = rot90(wrap_x);
wrap_y = rot90(wrap_y);
if length(wrap_x) < length(x) || length(wrap_y) < length(y)
    missingpts = length(x) - length(wrap_x);
    wrap_x = [wrap_x, zeros(1, length(x)-length(wrap_x))];
    wrap_y = [wrap_y, zeros(1, length(y)-length(wrap_y))];
    active = 1;
end

for t = 1:k  
    wrap_x_dist(t) = wrap_x(t) - x_center;
    wrap_y_dist(t) = wrap_y(t) - (y_center-radius);
    tangent_wrap(t) = wrap_x_dist(t)/wrap_y_dist(t);
    wrap_angle_from_horiz(t) = 90 - atand(tangent_wrap(t));
    if wrap_angle_from_horiz(t) > 90
       wrap_angle_from_horiz(t) = 180 - wrap_angle_from_horiz(t);
    end
end

if active == 1
    wrap_x_dist(1,length(wrap_x_dist)-missingpts+1:end)= 0;
    wrap_y_dist(1,length(wrap_y_dist)-missingpts+1:end)= 0;
    wrap_angle_from_horiz(1,length(wrap_angle_from_horiz)-missingpts+1:end)= 0;
end