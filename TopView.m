clc; clear;

%% Calibration

% import calibration image
prompt = "What is the filename of the top view calibration image?  ";
filename = input(prompt,"s");
import = imread(filename);

BW = im2bw(import,.4); %chose an arbitrary value for level for now, will need to test

%% Top View Measurement

% import nerve wrap image
prompt = "What is the filename of the top view image with the nerve wrap?  ";
filename = input(prompt,"s");
import = imread(filename);