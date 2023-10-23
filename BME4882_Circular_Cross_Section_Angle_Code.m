% Code to measure conformability angle from a circular cross section
clc; clear;

% Import image and convert to grayscale
import =imread('SideViewPseudoNerveTube.jpg');
nerve_grayscale = im2gray(import);

% Find image size and detect circular cross-section of the nerve, including radius and center data 
size = size(nerve_grayscale);
[center, radius] = imfindcircles(nerve_grayscale,[350,400],"ObjectPolarity","bright","Sensitivity",0.99);
x1 = center(1);
y1 = center(2);

% Show image with detected circle to validate
figure
imshow(nerve_grayscale); 
viscircles(center, radius,'EdgeColor','b');
hold on
axis on
plot(x1,y1,'ro','LineWidth',2);

% Plot a vertical line through circle's center
plot([x1 x1], [0 size(1)],'LineWidth',3);
plot([0 size(2)], [y1 y1],'LineWidth',3);

% Find top and bottom points where this vertical line intersects with
% circular cross-section
top_x = x1;
top_y = y1 - radius(1);
plot(top_x,top_y,'go','LineWidth',2);
bottom_x = x1;
bottom_y = y1 + radius(1);
plot(bottom_x,bottom_y,'go','LineWidth',2);

% Plot horizontal lines that pass through these points
plot([0 size(2)], [top_y top_y],'b','LineWidth',3);
plot([0 size(2)], [bottom_y bottom_y],'b','LineWidth',3);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Show a binarized image for easier visibility
BW = imbinarize(nerve_grayscale,0.5);
figure
imshow(BW);
hold on
axis on

% Plot same points and lines as those in the grayscale image
plot(x1,y1,'ro','LineWidth',2);
plot([x1 x1], [0 size(1)],'LineWidth',3);
plot([0 size(2)], [y1 y1],'LineWidth',3);
plot(top_x,top_y,'go','LineWidth',2);
plot(bottom_x,bottom_y,'go','LineWidth',2);
plot([0 size(2)], [top_y top_y],'b','LineWidth',3);
plot([0 size(2)], [bottom_y bottom_y],'b','LineWidth',3);

% User selects two points on each side of nerve wrap where wrap meets the
% horizontal lines. First two should be on the left side and second two
% should be on thr right. User needs to click enter after each pair of
% points
[a,b] = getpts;
[c,d] = getpts;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plot the same lines and points from grayscale image once more
figure
imshow(BW);
hold on
axis on

plot(x1,y1,'ro','LineWidth',2);
plot([x1 x1], [0 size(1)],'LineWidth',3);
plot([0 size(2)], [y1 y1],'LineWidth',3);
plot(top_x,top_y,'go','LineWidth',2);
plot(bottom_x,bottom_y,'go','LineWidth',2);
plot([0 size(2)], [top_y top_y],'b','LineWidth',3);
plot([0 size(2)], [bottom_y bottom_y],'b','LineWidth',3);


% Plot points that the user selected as well as lines that connect these
% points with the top point where the wrap makes contact with the nerve
plot(a(1),b(1),'ro',a(2),b(2),'ro','LineWidth',3);
plot([top_x a(1)], [top_y b(1)],'m','LineWidth',3);
plot([top_x a(2)], [top_y b(2)],'m','LineWidth',3);
plot(c(1),d(1),'ro',c(2),d(2),'ro','LineWidth',3);
plot([top_x c(1)], [top_y d(1)],'y','LineWidth',3);
plot([top_x c(2)], [top_y d(2)],'y','LineWidth',3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Calculate the angle between the the top horizontal and each line created
% by the user's points
opposite1 = norm([a(1);b(1)]-[x1;y1]);
adjacent1 = norm([top_x;top_y]-[x1;y1]);
tangent1 = opposite1/adjacent1;
ang_ls = 90 - atand(tangent1);

opposite2 = norm([a(2);b(2)]-[bottom_x;bottom_y]);
adjacent2 = norm([top_x;top_y]-[bottom_x;bottom_x]);
tangent2 = opposite2/adjacent2;
ang_lb = 90 - atand(tangent2);

opposite3 = norm([c(1);d(1)]-[x1;y1]);
adjacent3 = norm([top_x;top_y]-[x1;y1]);
tangent3 = opposite3/adjacent3;
ang_rs = 90 - atand(tangent3);

opposite4 = norm([c(2);d(2)]-[bottom_x;bottom_y]);
adjacent4 = norm([top_x;top_y]-[bottom_x;bottom_x]);
tangent4 = opposite4/adjacent4;
ang_rb = 90 - atand(tangent4);