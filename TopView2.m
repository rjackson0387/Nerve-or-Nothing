% note: code assumes measurements in cm, can adjust if necessary
% script calculates average theta along length of nerve wrap for flexural
% rigidity calculation
clc; clear; 

% import top view image according to user input
prompt = 'What is the filename of the top view image with the nerve wrap?  ';
filename = input(prompt,"s");
img = imread(filename);

% determine parameters of text to be displayed on image
textPosX = size(img, 2)/2; % X position at the center
textPosY = 100; % Y position at the top
text = 'Adjust line to capture length of nerve wrap. Double click on line once complete.'; % instructions for user

% add user instructions to image using parameters defined above 
imgText = insertText(img, [textPosX textPosY], text, AnchorPoint = "Center", FontSize = 50, TextBoxColor = "k", BoxOpacity = 0.4, TextColor ="w"); 

% display image with interactive line ROI
figure(1)
imshow(imgText);
h = imdistline; % creates a draggable distance tool 
wait(h); % waits for user to double-click on line 

% calculate scale of pixels to real length
lengthPx = getDistance(h); %length of line in pixels
scale = 8/lengthPx; % change 8 to constant length of PN in cm (or in if preferred, just keep consistent

% add new user instructions to  image
text = cell(4,1);
text{1} = 'CAREFULLY FOLLOW THE INSTRUCTIONS BELOW:';
text{2} = 'Left click mouse to select intersections of lines and the edges of the nerve wrap.'; % instructions for user
text{3} = 'FOLLOW THIS ORDER: 1) top edge of the nerve wrap from left to right, 2) bottom edge of the nerve wrap from left to right';
text{4} = 'Double-click once complete.';
imgText = insertText(img, [textPosX textPosY; textPosX textPosY+95; textPosX textPosY+190; textPosX textPosY+285], text, AnchorPoint = "Center", FontSize = 50, TextBoxColor = "k", BoxOpacity = 0.4, TextColor ="w");

% determine parameters of perpendicular lines to be displayed along length
endpoints = getPosition(h); % matrix containing two endpoints [x1 y1; x2 y2]
increment = lengthPx/11; % increment along line length, adjust according to testing
direction = (endpoints(2, :) - endpoints(1, :)) / lengthPx; % direction vector along line

% plot perpendicular lines on new image
figure(1)
imshow(imgText)
hold on
for i = 1:10
    linePos = endpoints(1,:) + (i - 0.25)*increment*direction ; % adjust according to testing
    lineDirection = [direction(2), -direction(1)]; 
    lineLength = size(img, 1)/2; % adjust according to testing
    lineStart = linePos - lineLength/2*lineDirection;
    lineEnd = linePos + lineLength/2*lineDirection;
    line([lineStart(1) lineEnd(1)], [lineStart(2) lineEnd(2)], "Color", "w", "LineWidth", 1);
end
hold off

% will need to adjust positioning of lines depending on angle of img capture

[x,y] = getpts; % acquires points selected by user

% assuming user followed directions...
% remove excess points from END of array due to double-clicking/other errors
if length(x) > 20 || length(y) > 20
    for i = length(x):-1:21
        x(i) = [];
    end
    for i = length(y):-1:21
        y(i) = [];
    end
end

%calculate distance from PN to top edge
distanceCm = zeros(20,1);
for i = 1:10
    topEnd = [x(i) y(i)];
    linePos = endpoints(1,:) + (i - 0.25)*increment*direction ; % adjust according to testing
    distanceCm(i) = sqrt(sum((topEnd - linePos).^2))*scale; 
end

%calculate distance from PN to bottom edge
for i = 11:20
    bottomEnd = [x(i) y(i)];
    linePos = endpoints(1,:) + ((i-10) - 0.25)*increment*direction ; % adjust according to testing
    distanceCm(i) = sqrt(sum((bottomEnd - linePos).^2))*scale; 
end

% ask user for known width of nerve wrap
prompt = 'What is the width of the nerve wrap before draped?  ';
wrapWidthCm = input(prompt);
o = wrapWidthCm/2; % calculate overhang length in cm

% calculate average theta along length of PN
theta = zeros(20,1);
for i = 1:20
    theta(i) = asind(distanceCm(i)/o);
end
thetaAvg = mean(theta);


