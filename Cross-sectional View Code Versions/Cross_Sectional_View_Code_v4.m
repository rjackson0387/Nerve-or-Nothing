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
prompt2 = "What is the size of the nerve in the apparatus (in mm)?";
%prompt2 = input(prompt2);

size = size(nerve_grayscale);
% if prompt2 == 1
[center, radius] = imfindcircles(nerve_grayscale,[240,270],"ObjectPolarity","bright","Sensitivity",0.99);
% elseif prompt2 == 2
    % [center, radius] = imfindcircles(nerve_grayscale,[#,#],"ObjectPolarity","bright","Sensitivity",0.99);
% elseif prompt2 == 3
    % [center, radius] = imfindcircles(nerve_grayscale,[#,#],"ObjectPolarity","bright","Sensitivity",0.99);
% elseif prompt2 == 4
    % [center, radius] = imfindcircles(nerve_grayscale,[#,#],"ObjectPolarity","bright","Sensitivity",0.99);
% elseif prompt2 == 5
    % [center, radius] = imfindcircles(nerve_grayscale,[#,#],"ObjectPolarity","bright","Sensitivity",0.99);
% end

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


% Automatically detect all points of the nerve wrap 
wrap_y_position = [];
wrap_x_position = [];
first = 0;
for cc = 1:1:size(2)
    for rr = 1:1:size(1)
        if BW(rr,cc) == 1
            if first == 0
                wrap_y_position(cc) = rr;
                wrap_x_position(cc) = cc;
                first = first + 1;
            end
            break
        end
    end
    first = 0;
end

plot(wrap_x_position,wrap_y_position,'ro');



% Extract values from all wrap points that correspond with angle
% increments only
rounded_y = round(y); % Start by rounding the y values that correspond with angle masurements to whole numbers

% This block of text removes the y values that corresponds with 0 and 90
% degrees (we don't need them)
[minA, maxA] = bounds(rounded_y);
rounded_y = changem(rounded_y,0,minA);
rounded_y = changem(rounded_y,0,maxA);
rounded_y(rounded_y == 0) = [];

% This for loop pulls out any xy pairs that match the ones that correspond
% with the angles for the left half of the image
for p = 1:1:size(2)/2
    for q = 1:1:length(rounded_y)/2
        if wrap_y_position(p) == rounded_y(q)
            extract_wrap_y_pos_half1(p) = wrap_y_position(p);
            extract_wrap_x_pos_half1(p) = wrap_x_position(p);
        end
    end
end

% Remove any values that do not correspond
extract_wrap_y_pos_half1(extract_wrap_y_pos_half1 == 0) = [];
extract_wrap_x_pos_half1(extract_wrap_x_pos_half1 == 0) = [];

% This for loop pulls out any xy pairs that match the ones that correspond
% with the angles for the right half of the image
for a = size(2)/2+1:1:size(2)
    for b = length(rounded_y)/2+1:1:length(rounded_y)
        if wrap_y_position(a) == rounded_y(b)
            extract_wrap_y_pos_half2(a) = wrap_y_position(a);
            extract_wrap_x_pos_half2(a) = wrap_x_position(a);
        end
    end
end

% Remove any values that do not correspond
extract_wrap_y_pos_half2(extract_wrap_y_pos_half2 == 0) = [];
extract_wrap_x_pos_half2(extract_wrap_x_pos_half2 == 0) = [];


% This for loop removes any duplicate values for the xy pairs, only keeping
% the first pair of the xy duplicate for the left half of the image
for tt = length(extract_wrap_y_pos_half1):-1:2
    if extract_wrap_y_pos_half1(tt) == extract_wrap_y_pos_half1(tt-1)
        final_wrap_y_pos_half1(tt) = 0;
        final_wrap_x_pos_half1(tt) = 0;
    else
        final_wrap_y_pos_half1(tt) = extract_wrap_y_pos_half1(tt);
        final_wrap_x_pos_half1(tt) = extract_wrap_x_pos_half1(tt);
    end
end
final_wrap_y_pos_half1(1) = extract_wrap_y_pos_half1(1);
final_wrap_x_pos_half1(1) = extract_wrap_x_pos_half1(1);

% This for loop removes any duplicate values for the xy pairs, only keeping
% the first pair of the xy duplicate for the right half of the image
for vv = length(extract_wrap_y_pos_half2):-1:2
    if extract_wrap_y_pos_half2(vv) == extract_wrap_y_pos_half2(vv-1)
        final_wrap_y_pos_half2(vv) = 0;
        final_wrap_x_pos_half2(vv) = 0;
    else
        final_wrap_y_pos_half2(vv) = extract_wrap_y_pos_half2(vv);
        final_wrap_x_pos_half2(vv) = extract_wrap_x_pos_half2(vv);
    end
end
final_wrap_y_pos_half2(1) = extract_wrap_y_pos_half2(1);
final_wrap_x_pos_half2(1) = extract_wrap_x_pos_half2(1);


% Join the two halves together
selected_wrap_y_points = [final_wrap_y_pos_half1, final_wrap_y_pos_half2];
selected_wrap_x_points = [final_wrap_x_pos_half1, final_wrap_x_pos_half2];
selected_wrap_y_points(selected_wrap_y_points == 0) = [];
selected_wrap_x_points(selected_wrap_x_points == 0) = [];

% Plot these xy pairs, they should match up almost exactly with the
% horizontal lines that correspond to each angle
plot(selected_wrap_x_points, selected_wrap_y_points,'yo');


len = length(selected_wrap_y_points);
selected_wrap_x_points = rot90(selected_wrap_x_points,3);
selected_wrap_y_points = rot90(selected_wrap_y_points,3);

%%% Calculate the angle from horizontal top line using automatically selected points
for t = 1:len  
    wrap_x_dist(t) = selected_wrap_x_points(t) - x_center;
    wrap_y_dist(t) = selected_wrap_y_points(t) - (y_center-radius);
    tangent_wrap(t) = wrap_x_dist(t)/wrap_y_dist(t);
    wrap_angle_from_horiz(t) = 90 - atand(tangent_wrap(t));
    if wrap_angle_from_horiz(t) > 90
       wrap_angle_from_horiz(t) = 180 - wrap_angle_from_horiz(t);
    end
end

% Fix ref angle vector to macth automatically detected ones
% Maybe compare y-dist and wrap-y-dist values (threshold diff of 0.5 pixels)
