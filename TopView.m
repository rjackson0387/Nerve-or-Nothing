clc; clear;

%% Calibration - might not need this section tbh

% import calibration image
prompt = "What is the filename of the top view calibration image?  ";
filename = input(prompt,"s");
img = imread(filename);

%% Top View Measurement

% import nerve wrap image
prompt = "What is the filename of the top view image with the nerve wrap?  ";
filename = input(prompt,"s");
img = imread(filename);
imshow(img);
% now ideally we have img of full pseudo nerve with wrap draped over
% wrap should not be longer than length of pseudonerve

h = imdistline; % creates a draggable distance tool 
% adjust line to capture full length of pseudo nerve (PN)

%% With this tool, we may have to run code section by section
prompt = "What is the length of the pseudo nerve in pixels?  ";
length_px = input(prompt,"s");
scale = 8/length_px; %replace 8 w/ length of PN, keep units consistant
imshow(img);
h = imdistline;

%% Now run imdistline to get max width of nerve wrap according to top view
prompt = "What is the maximum width of the nerve wrap?  ";
width_px = input(prompt,"s");
width_cm = width_px * scale; %I'm assuming cm, but we can adjust units accordingly

