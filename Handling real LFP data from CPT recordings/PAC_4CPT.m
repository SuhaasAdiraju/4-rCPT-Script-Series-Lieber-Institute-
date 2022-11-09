function [PAC_stats_struc] = PAC_4CPT


%% PAC4CPT
% this script is a walkthrough and nested functions incorporation of phase
% amplitude coupling.


% PAC method code - Henry Hallock

% Adaptation for current CPT data - Suhaas Adiraju



% hasnt been customized yet (like inputs for srate, and frequency upper
% lower limits)


%% Initial setup 
% clear; clc; 

plotans = questdlg('Would you like to plot all the phase-amplitude coupling associated plots? You can answer ''No'' to just get the statistics...')
if strcmp(plotans,'Yes') == 1
    plotans = 1
elseif strcmp(plotans,'No') == 0 
    plotans = 0
end
% I want to look at PAC during that ITI average response window I made
% waitfor(msgbox(sprintf('\n When you press ok, a file-selector will pop up. In there, select the lfp file or structure you would like to load to perform PAC analysis')));


 

%lfp_mat = cell2mat(lfp_cell);


%% 

SubsNum = inputdlg('How many subjects would you like to include in averaging across')
SubsNum = str2num(SubsNum{1})
waitfor(msgbox(sprintf('Okay, you have selected to average across %d subjects\nA window will pop up %d times after calculating PAC for each subject\n\nSELECT 1 SUBJECT''s cleaned LFP DATA STRUCTURE EACH TIME',SubsNum,SubsNum)))


rangeans = inputdlg({'Enter lower-bound of phase range', 'Enter upper-bound of phase range'})
    lowerbound = str2num(rangeans{1});
    upperbound = str2num(rangeans{2});


for x = 1:(SubsNum)
    if x <= (SubsNum)
        [lfp_dataName, lfp_path] = uigetfile('','Please select the data file you would like to perform PAC analysis on')
            while (lfp_dataName) == 0
                warndlg('You didn''t correctly select the lfp file to run PAC on. Please try again. Or if you are trying to quit the script, press the stop button under the editor tab at the top of MATLAB')
                [lfp_dataName, lfp_path] = uigetfile('','Please select the data file you would like to perform PAC analysis on')
            end
            mousename = lfp_dataName;
            cd(lfp_path);
            lfp_data = (load(mousename));
            lfp_mat = (lfp_data.Events_Accepted_lfp(:)'); 

        for eventi = 1:length(lfp_mat)
            %waitfor(msgbox(sprintf('Hit okay to run PAC analysis on selected LFP signal data!')))
            %Create struct array with inputs
            signal_data.timestamps = linspace(0,length(lfp_mat{1,eventi}),length(lfp_mat{1,eventi})); %Just an array of linearly spaced, monotonically increasing variables
                % wouldnt this ^^ need to incorporate sampling rate? if you are saying timestamps?
                
            signal_data.phase_EEG = lfp_mat{1,eventi};                                       %LFP for phase extraction
            signal_data.amplitude_EEG = lfp_mat{1,eventi};                                   %LFP for envelope extraction
            signal_data.phase_bandpass = [0 30];                                    %Phase frequency range
            signal_data.amplitude_bandpass = [20 150];                              %Envelope frequency range
            
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
            %cfc_heatmap(signal_data, phase_bins, amplitude_freq_bins, phase_freq_bins, plotans);
            

            %Phase map for gamma amplitude distribution
            %phase_map(signal_data, phase_bins, amplitude_freq_bins, phase_freq_bins, plotans);
          

            %LFP-triggered average for theta-gamma coupling
                %LFP_triggered_avg(lfp_mat{1,eventi}, lfp_mat{1,eventi}, 5, 11, 2000, [-0.5 0.5], 0, plotans);
            
            %Modulation index value for theta-gamma coupling
            signal_data.phase_bandpass = [lowerbound upperbound];
            signal_data.amplitude_bandpass = [80 120];
            
            [data] = makedatafile_morlet(signal_data);
            [M] = modindex(data, plotans, 18, eventi);
            TrialModVals(1,eventi) = M.MI;
            TrialAmpVals(eventi,:) = M.amp;
            TrialNormAmpVals(eventi,:) = M.NormAmp;
            TrialPhaseAxisVals(eventi,:) = M.PhaseAxis;
            
            %Shuffled distribution of MI values
            signal_data.phase_extraction = 1;
            
            [mu(1,eventi), sigma(1,eventi), MI(1,eventi), z(1,eventi), p(1,eventi)] = shuffle_MI(signal_data, phase_bins, 0);
             
        end
    Sub.ModVal = mean(TrialModVals,2);
    Sub.AmpVals = mean(TrialAmpVals,1);
    Sub.NormAmpVals = mean(TrialNormAmpVals,1);
    Sub.PhaseAxisVals = mean(TrialPhaseAxisVals,1);
    Sub.mu = mean(mu,2);
    Sub.sigma = mean(sigma,2);
    Sub.MI = mean(MI,2);
    Sub.z = mean(z,2);
    Sub.p = mean(p,2);
   
    if plotans == 1
    waitfor(msgbox('Okay, some figures will pop up now, exit out of them to cycle through, save them as .png if you want to refer back'))
    end

    waitfor(msgbox(sprintf('A file-selector will pop-up, the choose Where would you like to save your PAC modulation index score (what folder)')))
    saveplace = uigetdir('Where would you like to save your PAC modulation index score (what folder)')
    cd(saveplace);
    %cell2mat(mousename)
    mousename = erase(mousename,'.mat');
    mousename = append(mousename,'_PACstats')
    save (mousename,'-struct','Sub');
    
    clearvars -except SubsNum plotans x lowerbound upperbound

    end
end

waitfor(msgbox('Subjects have been analyzed for phase-amplitude coupling!'))
end

%%










