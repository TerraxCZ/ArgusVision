clearvars ; close all ; clc;

dataDir = "SmileyTESTimg";

first = HyperCube(dataDir);

%first.spectrum(2,2)
first.slice(400)
