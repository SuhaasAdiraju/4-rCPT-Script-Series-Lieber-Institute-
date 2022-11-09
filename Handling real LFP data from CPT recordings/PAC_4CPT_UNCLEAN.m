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


 

%Event_Type = cell2mat(lfp_cell);


%% 

SubsNum = inputdlg('How many subjects would you like to include in averaging across')
SubsNum = str2num(SubsNum{1})
waitfor(msgbox(sprintf('Okay, you have selected to average across %d subjects\nA window will pop up %d times after calculating PAC for each subject\n\nSELECT 1 SUBJECT''s cleaned LFP DATA STRUCTURE EACH TIME',SubsNum,SubsNum)))


for x = 1:(SubsNum)
    if x <= (SubsNum)
        waitfor(msgbox({'A file selector will pop up. Then select the path to your existing sliced data structure (that you made in LFP4CPT3)'}))
     
                [struc_name, struc_path] = uigetfile('','Please select the previously saved structure containing event-timestamp based transient slices')
                while struc_name == 0     
                    waitfor(warndlg('Sorry, you did not correctly select a saved data-structure. Press okay to try again. Or if you would like to stop execution of this script hit the ''stop'' button at the top of MATLAB'))
                    [struc_name, struc_path] = uigetfile('','Please select the previously saved structure containing event-timestamp based transient slices')
                end
                tic
                cd(struc_path);
                load (struc_name) %load your structure
                toc
            
        %% What event type would you like to look at? (MANUALLY DEFINE 'Event_Type IF STRUCTURE IN WORKSPACE ALREADY)
            vars = who;
            sprintf('Here''s a list of the channels for reminder')
            sprintf('%s\n',vars{:})
            waitfor(msgbox({'A window will pop up containing LFP recordings from regions, you may choose 1 by typing it into the response'}))
            
            regionprompt = (sprintf('%s\n',vars{:}))
            titleRegionprompt = ('What brain region / channel do you want to look at?') 
            region = inputdlg(regionprompt, titleRegionprompt, [1 100])
            while exist(region{1},"var") == 0
                waitfor(warndlg(sprintf('%s, doesn''t seem to exist. Please try again, or, if you are trying to quit the script, press the stop button under the editor tab at the top of MATLAB',region{1})))
                region = inputdlg(regionprompt, titleRegionprompt, [1 100])
            end
            if exist(region{1},"var") == 1
                eval(region{1})
            end
            waitfor(msgbox({'The Event types stored in the region you selected are printed below in the command window.';' ';'COPY THE TITLE TEXT TO THE ONE YOU DESIRE TO CHECK OUT!';' ';'Then, IN THE COMMAND WINDOW (BOTTOM OF THE PAGE), PRESS ANY KEY TO CONTINUE'}))
            who -regexp Transients$
            pause
            Eventprompt = {'What event type would you like to look at?'}
            Event_name = inputdlg(Eventprompt)
            while isempty(Event_name) == 1
                waitfor(warndlg('You didnt type in an event-type, please try again. Or if you are trying to quit the script, press the stop button under the editor tab at the top of MATLAB'))
                Event_name = inputdlg(Eventprompt)
            end
            Event_Type = (eval(region{1}).(Event_name{1})); 


        for eventi = 1:length(Event_Type)
            %waitfor(msgbox(sprintf('Hit okay to run PAC analysis on selected LFP signal data!')))
            %Create struct array with inputs
            signal_data.timestamps = linspace(0,length(Event_Type{1,eventi}),length(Event_Type{1,eventi})); %Just an array of linearly spaced, monotonically increasing variables
                % wouldnt this ^^ need to incorporate sampling rate? if you are saying timestamps?
                
            signal_data.phase_EEG = Event_Type{1,eventi};                                       %LFP for phase extraction
            signal_data.amplitude_EEG = Event_Type{1,eventi};                                   %LFP for envelope extraction
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
                %cfc_heatmap(signal_data, phase_bins, amplitude_freq_bins, phase_freq_bins, plotans);
            

            %Phase map for gamma amplitude distribution
                %phase_map(signal_data, phase_bins, amplitude_freq_bins, phase_freq_bins, plotans);
          

            %LFP-triggered average for theta-gamma coupling
                %LFP_triggered_avg(Event_Type{1,eventi}, Event_Type{1,eventi}, 5, 11, 2000, [-0.5 0.5], 0, plotans);
            
            %Modulation index value for theta-gamma coupling
            signal_data.phase_bandpass = [5 11];
            signal_data.amplitude_bandpass = [80 120];
            
            [data] = makedatafile_morlet(signal_data);
            [M] = modindex(data, plotans, 18);
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
   
%     if plotans == 1
%         waitfor(msgbox('Okay, some figures will pop up now, exit out of them to cycle through, save them as .png if you want to refer back'))
%     end
    mousename = append(erase(struc_name,'.mat'),'_',region{1},'_',Event_name{1})
    waitfor(msgbox(sprintf('A file-selector will pop-up, the choose Where would you like to save your PAC modulation index score (what folder)')))
    saveplace = uigetdir('Where would you like to save your PAC modulation index score (what folder)')
    cd(saveplace);
    %cell2mat(mousename)
    mousename = erase(mousename,'.mat');
    mousename = append(mousename,'_PACstats')
    save (mousename,'-struct','Sub');
    
    clearvars -except SubsNum plotans x

    end
end

waitfor(msgbox('Subjects have been analyzed for phase-amplitude coupling!'))
end

%%










