clearvars ; close all ; clc;

dataDir = "SmileyTESTimg";

[hypCub, spect] = load_hypercube_bmp(dataDir);

spectrum_at(hypCub, spect, 2, 2)

mono_slice(hypCub,spect,400)