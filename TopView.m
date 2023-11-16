clc; clear;

%% Pseudo Nerve Length Measurement

% import nerve wrap image
prompt = "What is the filename of the top view image with the nerve wrap?  ";
filename = input(prompt,"s");
img = imread(filename);
imshow(img);
% now ideally we have img of full pseudo nerve with wrap draped over
% wrap should not be longer than length of pseudonerve

h = imdistline; % creates a draggable distance tool 
% adjust line to capture full length of pseudo nerve (PN), I'm not sure if
% it will store the value to variable h, will adjust code once tested with
% image

%% With this tool, we may have to run code section by section
length_px = getDistance(h);
scale = 8/length_px;

%% Draped Wrap Maximum Overhang Width Measurement
imshow(img);
h = imdistline;

%% Width of nerve wrap in image 
width_px = getDistance(h);
width_cm = width_px * scale; %I'm assuming cm, but we can adjust units accordingly
x = (width_cm - 4)/2; %replace 4 w known diameter of pseudonerve
% x in the img Alex drew out
theta = asin(x/4); % replace 4 with known overhand length (will this be constant?)
 
%% Notes

% I arbitrarily entered values for measurements which I think will be
% constant? So will have to go back and adjust
% ATM, this code will require user to manually drag line tool to width of
% nerve wrap draped over PN, might want to instead do what Jared did with autmatically
% generating the lines (except idrk how to... oops) 
