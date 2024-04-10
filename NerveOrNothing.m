% ensure current folder contains both top and x-sectional view images and script 
% highly recommend cropping images to reduce noise
close all 
clc; clear;
% x-section ---------------------------------------------------------------------------------------------------

% Import the cross-sectional image to be anayzed 
prompt = "What is the filename of the cross-sectional view image with the nerve wrap?  ";
filename = input(prompt,"s");
img = imread(filename);
sizeImg = size(img);

prompt = 'What is the diameter of the pseudonerve (in mm)? Please enter a numerical value.  ';
diameter = input(prompt)/1000 ; % convert to m

% determine parameters of text to be displayed on image
textPosX = sizeImg(2)/2; % X position at the center
textPosY = 100; % Y position at the top
text = 'Adjust line to capture diameter of pseudonerve. Double click on line once complete.'; % instructions for user
fontSize = round(sizeImg(2)*35/2000); 
% add user instructions to image using parameters defined above 
imgText = insertText(img, [textPosX textPosY], text, AnchorPoint = "Center", FontSize = fontSize, TextBoxColor = "k", BoxOpacity = 0.4, TextColor ="w"); 

% display image with interactive line ROI
figure(1)
imshow(imgText);
h = imdistline; % creates a draggable distance tool 
wait(h); % waits for user to double-click on line 

% calculate scale of pixels to real length
diameterPx = getDistance(h); %length of line = diameter in pixels
radiusPx = diameterPx/2; % radius in pixels
scale = diameter/diameterPx; % scale in units of m/pixels

% find center of circle
endpoints = getPosition(h);
center = (endpoints(2, :) + endpoints(1, :)) / 2;
% x_center = center(1); y_center = center(2);

% add user instructions to image using parameters defined above
text = 'Find the two points from which the nerve wrap leaves the pseudo nerve. For each point, click it and press Enter.'; 
imgText = insertText(img, [textPosX textPosY], text, AnchorPoint = "Center", FontSize = fontSize, TextBoxColor = "k", BoxOpacity = 0.4, TextColor ="w"); 

% Code to measure the angles for a perfect circular cross-section for
figure(1)
imshow(imgText);
hold on
viscircles(center, radiusPx,'EdgeColor','b');
axis on
plot(center(1),center(2),'ro','LineWidth',2);
% Find top and bottom points where this vertical line intersects with
% circular cross-section
x_top = center(1);
y_top = center(2) - radiusPx;
plot(x_top,y_top,'ro','LineWidth',2);

% Find points from which wrap leaves nerve
[x_left, y_left] = getpts();
[x_right, y_right] = getpts();

% accounts for selection of points right to left -> left to right
if x_left > x_right
    temp = [x_left, y_left];
    x_left = x_right;
    y_left = y_right;
    x_right = temp(1);
    y_right = temp(2);
end

% Calculate distance and plot lines between selected points and center
dist_left_center = sqrt((center(1) - x_left)^2 + (center(2) - y_left)^2);
dist_right_center = sqrt((x_right - center(1))^2 + (center(2) - y_right)^2);

plot([x_left center(1)], [y_left center(2)], "LineWidth",2);
plot([x_right center(1)], [y_right center(2)], "LineWidth",2);
plot([x_top center(1)], [y_top center(2)], "LineWidth",2);

% Calculate the remaining lengths 
dist_left_top = sqrt((x_top-x_left)^2+(y_left-y_top)^2);
dist_right_top = sqrt((x_right-x_top)^2+(y_right-y_top)^2);

% Fing angle for each triangle in degrees
angle_left = acosd(-(dist_left_top^2 - dist_left_center^2 - radiusPx^2)/(2*dist_left_center*radiusPx));
angle_right = acosd(-(dist_right_top^2 - dist_right_center^2 - radiusPx^2)/(2*dist_right_center*radiusPx));

% Find the arc length of each side in m
arclength_left = (angle_left/360)*(2*pi*radiusPx)*scale;
arclength_right = (angle_right/360)*(2*pi*radiusPx)*scale;
total_arclength = (arclength_left+arclength_right); 

% x_distance between the two points in m
x_dist_left_center = (center(1) - x_left)*scale;
x_dist_right_center = (x_right - center(1))*scale;
x_total_arclength = x_dist_left_center + x_dist_right_center;  

%%
% top view --------------------------------------------------------------------------------------------------- 

% import top view image according to user input
prompt = 'What is the filename of the top view image with the nerve wrap?  ';
filename = input(prompt,"s");
img = imread(filename);
sizeImg = size(img);

% establish parameters of nerve wrap
prompt = 'What is the width of the nerve wrap before draped (in cm)? Please enter a numerical value.  ';
w = input(prompt)/100; % convert to m
O = (w-total_arclength)/2; % in m
prompt = 'What is the length of the nerve wrap before draped (in cm)? Please enter a numerical value.  ';
l = input(prompt)/100; % in m
prompt = 'What is the mass of the nerve wrap (in g)? Please enter a numerical value.  ';
mass = input(prompt); % in g

area = (w*l); % in m^2 

% determine parameters of text to be displayed on image
textPosX = sizeImg(2)/2; % X position at the center
textPosY = 100; % Y position at the top
text = 'Adjust line to capture length of nerve wrap along the pseudonerve. Double click on line once complete.'; % instructions for user

% add user instructions to image using parameters defined above 
fontSize = round(sizeImg(2)*35/2000); 
imgText = insertText(img, [textPosX textPosY], text, AnchorPoint = "Center", FontSize = fontSize, TextBoxColor = "k", BoxOpacity = 0.4, TextColor ="w"); 

% display image with interactive line ROI
figure(2)
imshow(imgText);

h = imdistline; % creates a draggable distance tool 
wait(h); % waits for user to double-click on line 

% calculate scale of pixels to real length
lengthPx = getDistance(h); %length of line in pixels
scale = l/lengthPx; % scale in units of m/pixels

% create interactive line for user to ID axis of PN
endpoints = getPosition(h); % matrix containing two endpoints [x1 y1; x2 y2]
direction = (endpoints(2, :) - endpoints(1, :)); % direction vector along line

%straighten image by rotating according to axis of PN
theta = atand(direction(2)/direction(1)); %in degrees
img_rot = imrotate(img,theta); %requires angle in degrees
sizeImg_rot = size(img_rot);

%finding new coordinates of endpoints
P1 = [endpoints(1,1); endpoints(1,2)];
P2 = [endpoints(2,1); endpoints(2,2)];
RotMatrix = [cosd(-theta) -sind(-theta); sind(-theta) cosd(-theta)]; 
% centerImg = sizeImg([1 2])/2;
% centerImg_rot = sizeImg_rot([1 2])/2;

P1_rot = round(RotMatrix* (P1 - (sizeImg([1 2])/2).') + ((sizeImg_rot([1 2])/2).'));
P2_rot = round(RotMatrix* (P2 - (sizeImg([1 2])/2).') + ((sizeImg_rot([1 2])/2).'));

figure(2)
imshow(img_rot);

% convert to binary img
img_gs = im2gray(img_rot);
thresh = graythresh(img_gs); % default, faulty when there is too much background noise
%thresh = 0.6                                                                                                                                                                                                                                                                                                                                                                                                                                                                ;
img_bw = imbinarize(img_gs, thresh); 

figure(2)
imshow(img_bw);

axis on
hold on

% initialize arrays for distance calculation
x_top = zeros(round(P2_rot(1)-P1_rot(1))+1, 1);
x_bottom = zeros(round(P2_rot(1)-P1_rot(1))+1, 1);
y_top = zeros(round(P2_rot(1)-P1_rot(1))+1, 1);
y_bottom = zeros(round(P2_rot(1)-P1_rot(1))+1, 1);

% define bounds for binary analysis -> mitigate detection of noise 
y_PN = (P1_rot(2) + P2_rot(2))/2;
y_top_bound = round(y_PN - (w/scale)/2); % min conformability -> max width of nerve wrap
y_bottom_bound = round(y_PN + (w/scale)/2);

% if bounds exceed image size, redefine as img_rot limits
if y_top_bound < 1
    y_top_bound = 1;
end
if y_bottom_bound > sizeImg_rot(1)
    y_bottom_bound = sizeImg_rot(1);
end

% binary analysis
stop = 0;
i = 1;
for cc = round(P1_rot(1)):1:round(P2_rot(1))
    for rr = y_top_bound:1:y_bottom_bound
        if img_bw(rr,cc) ==1 && stop ==0
            x_top(i) = cc;
            y_top(i) = rr;
            plot(cc,rr,'ro');
            stop = stop+1;
        end
    end
    stop = 0;
    i = i +1;
end

stop=0;
i = 1;
for cc = round(P1_rot(1)):1:round(P2_rot(1))
    for rr = y_bottom_bound:-1:y_top_bound
        if img_bw(rr,cc) ==1 && stop ==0
            x_bottom(i) = cc;
            y_bottom(i) = rr;
            plot(cc,rr,'ro');
            stop = stop+1;
        end
    end
    stop = 0;
    i = i +1;
end
hold off

distance = (y_bottom-y_top)*scale; % full x distance between two ends in m
distance_correct = distance - x_total_arclength; % remove section of nerve wrap that is flush with pseudo nerve

% calculate theta
theta = zeros(1, length(distance_correct));
for i = 1:length(distance_correct)
    theta(i) = acosd((distance_correct(i)/2)/O);
end

thetaAvg = mean(theta);

%flexural rigidity calculation
vals.theta = thetaAvg; % in degrees
vals.O = O; % in m
vals.M = mass/area; % in g/m^2
vals.G = 9.81 * vals.M * ((cosd(vals.theta/2))/(8*tand(vals.theta))) * (vals.O)^3 * 1000; % in µN-m
vals.C = -log10(vals.G);

% display values as a table
clc; 
values = [vals.theta, vals.M, vals.O, vals.G, vals.C];
column_label = {'Theta (degrees)', 'Mass per Unit Area(g/m^2)', 'Overhang Length (m)', 'Flexural Rigidity (µN-m)', 'Conformability'};
T = array2table(values, 'VariableNames', column_label);
disp(T);
