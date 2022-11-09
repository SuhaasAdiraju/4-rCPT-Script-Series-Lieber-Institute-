%% PAC Demo

%Load LFP data

load('plot_lfp.mat');

%Create struct array with inputs
signal_data.timestamps = linspace(0,length(lfp_data),length(lfp_data)); %Just an array of linearly spaced, monotonically increasing variables
    % wouldnt this ^^ need to incorporate sampling rate? if you are saying timestamps?
    
signal_data.phase_EEG = lfp_data;                                       %LFP for phase extraction
signal_data.amplitude_EEG = lfp_data;                                   %LFP for envelope extraction
signal_data.phase_bandpass = [1 30];                                    %Phase frequency range
signal_data.amplitude_bandpass = [20 150];                              %Envelope frequency range
    % how do you identify amplitude range??

signal_data.srate = 2000;                                               %Sampling rate
signal_data.phase_extraction = 2;                                       %Extract phases with Morlet wavelets
    % unsure of the specific indication here, 2 phases? Oh no i get it, its
    % option '2' for phase extraction w/ morelet lol

phase_bins = 18;                                                        %Number of phase bins for amplitude distributions
    % thought process behind this #? Would how much time you're doing not
    % impact in any way 

amplitude_freq_bins = 1;                                                %Calculate coupling at every phase frequency
    % 1 bin for every freq.?

phase_freq_bins = 1;                                                    %Calculate coupling at every envelope frequency    
    % 1 bin for every freq.?

%Co-modulogram of phase-amplitude coupling values
cfc_heatmap(signal_data, phase_bins, amplitude_freq_bins, phase_freq_bins, 1);


%LFP-triggered average for theta-gamma coupling
LFP_triggered_avg(lfp_data, lfp_data, 5, 11, 2000, [-0.5 0.5], 0, 1);

%Modulation index value for theta-gamma coupling
signal_data.phase_bandpass = [5 11];
signal_data.amplitude_bandpass = [80 120];

[data] = makedatafile_morlet(signal_data);
[M] = modindex(data, 'y', 18);

%Phase map for gamma amplitude distribution
phase_map(signal_data, phase_bins, amplitude_freq_bins, phase_freq_bins, 1);

%Shuffled distribution of MI values
signal_data.phase_extraction = 1;

[mu, sigma, MI, z, p] = shuffle_MI(signal_data, phase_bins, 1);













