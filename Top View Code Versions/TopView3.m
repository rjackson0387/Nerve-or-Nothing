% note: code assumes measurements in cm, can adjust if necessary
% script calculates average theta along length of nerve wrap for flexural
% rigidity calculation
clc; clear; 

% import top view image according to user input
prompt = 'What is the filename of the top view image with the nerve wrap?  ';
filename = input(prompt,"s");
img = imread(filename);
size = size(img);

% establish parameters of nerve wrap
prompt = 'What is the width of the nerve wrap before draped (in cm)? Please enter a numerical value.  ';
width = input(prompt);
O = width/2;
prompt = 'What is the length of the nerve wrap before draped (in cm)? Please enter a numerical value.  ';
l = input(prompt);
prompt = 'What is the mass of the nerve wrap (in g)? Please enter a numerical value.  ';
mass = input(prompt);

area = (width*l)/10000; % in m^2 

% determinze parameters of text to be displayed on image
textPosX = size(2)/2; % X position at the center
textPosY = 100; % Y position at the top
text = 'Adjust line to capture length of pseudo-nerve. Double click on line once complete.'; % instructions for user

% add user instructions to image using parameters defined above 
imgText = insertText(img, [textPosX textPosY], text, AnchorPoint = "Center", FontSize = 50, TextBoxColor = "k", BoxOpacity = 0.4, TextColor ="w"); 

% display image with interactive line ROI
figure(1)
imshow(imgText);

% use line below to verify angle of image 
%hold on
%line([0 size(2)],[round(size(1)/2) round(size(1)/2)], "Color", "w", "LineWidth", 1); % creates a draggable distance tool 
%hold off

h = imdistline; % creates a draggable distance tool 
wait(h); % waits for user to double-click on line 

% calculate scale of pixels to real length
lengthPx = getDistance(h); %length of line in pixels
scale = 0.08/lengthPx; % change # to constant length of PN in m 

% create interactive line for user to ID axis of PN
endpoints = getPosition(h); % matrix containing two endpoints [x1 y1; x2 y2]
direction = (endpoints(2, :) - endpoints(1, :)); % direction vector along line

%straighten image by rotating according to axis of PN
thetaImg = atan(direction(2)/direction(1)); %in radians
thetaImg = thetaImg*180/pi; %in degrees
img_rot = imrotate(img,thetaImg); %requires angle in degrees
figure(1)
imshow(img_rot);

% use line below to verify angle of image 
%hold on
%line([0 size(2)],[round(size(1)/2) round(size(1)/2)], "Color", "w", "LineWidth", 1); % creates a draggable distance tool 
%hold off

img_gs = im2gray(img);
img_bw = im2bw(img_gs, 0.7); %adjust threshold according to testing on apparatus
figure(1)
imshow(img_bw);
hold on

x_top = zeros(1,size(2));
x_bottom = zeros(1,size(2));
y_top = zeros(1,size(2));
y_bottom = zeros(1,size(2));

stop = 0;
for cc = 1:1:size(2)
    for rr = 1:1:size(1)
        if img_bw(rr,cc) ==1
            if stop == 0
                x_top(cc) = cc;
                y_top(cc) = rr;
                plot(cc,rr,'ro');
                stop = stop+1;
            end
        end
    end
    stop = 0;
end

for cc = size(2):-1:1
    for rr = size(1):-1:1
        if img_bw(rr,cc) ==1
            if stop == 0
                x_bottom(cc) = cc;
                y_bottom(cc) = rr;
                plot(cc,rr,'ro');
                stop = stop+1;
            end
        end
    end
    stop = 0;
end
hold off

distance = rmoutliers((y_bottom-y_top)*scale); %in m without outliers (like vals along PN)

% calculate theta
theta = zeros(1, length(distance));
for i = 1:length(distance)
    theta(i) = asind((distance(i)/2)/O);
end
thetaAvg = mean(theta);

%flexural rigidity calculation
vals.theta = thetaAvg;
vals.O = O;
vals.M = mass/area; % in g/m^2
vals.G = 9.81 * (10^(-6)) * vals.M * (cos(vals.theta/2)/(8*tan(vals.theta))) * (vals.O)^3;
