function [Ground, Reference, LC, ACC, cpt_schLength] = sliceLFP(path2struc, struc_name, srate, TimeWin, saveplace, mousename)
%% Description
    % this function assumes you have completed processes from LFP4CPT script 1, and thus have
    % structures containing lfp combined with event TStamps for the subject

    % this function is meant to 1)trim the lfp to match the CPT schedule
    % length; 2)organize a structure containing the lfp based on channel
    % 3)slice the lfp into windows based on event-timestamps 

%--Written by Suhaas S. Adiraju 10/05/2021

%% INPUTS

% path2struc - 
    % user-defined path to your pre-made structure with lfp
    % data, this was made with the sirenia2mat function or
    % LFP4CPT_0sirenia2mat script, 

% struc_name - 
    % user-defined structure name within the defined path, so MATLAB can
    % load the file

% srate{1} - 
    % the sampling rate of the LFP recording (typically 2000Hz or
    % samples/second), but good practice to continuously define

% TimeWin{1} - 
    % the window around each event desired, i.e. 4 seconds of lfp around
    % every hit...

%% OUTPUTS

% structure containing user defined time-window of sliced LFP signal based
% on event-type behavioral timestamps, for each channel of the Ephys
% headstage (ground, reference, brain region 1, brain region 2)

%% Load-in

%pathway to your folder with full structures, ('yourpath')
    %path2struc = 'Z:\Circuits projects (CPT)\CPT Recording Data\LC-mPFC LFP';

%'change directory' to this path
cd(path2struc{1}); 

% define then load desired data structure 
    %filename = 'S3GOOD_1328_S';
load(struc_name{1});

% create a list of the variables were working with for speed 
%{
% first subtract lfp from the list...
vars= who; pat = 'lfp';
vars_idx = startsWith(vars,pat) == 1
for i = 1:length(vars_idx)
    if (vars_idx(i)) == 1
        vars(vars_idx) = [];
    end  
end
%}

% now for anything cycling through the event timestamps we can use vars 
%% Setting Time
% if the following steps *conceptually* confuse you, refer to 
% (Z:\Circuits projects (CPT)\Working With LFP\Signal-processing basics with sample data)
% then the script 'LFPPracticeScript_SignalProcessing1_FirstStepsAndSettingTime'

% define sampling rate (200samples/second (Hz))
    %srate{1} = 2000;

% get total time, by dividing length of lfp file (which is in samples) by sampling rate... 
timeEeg = (length(lfp))/srate{1}; % total time in seconds 

% give me a vector containing 0-->total time, scaled to the size
% of the original LFP file; and this will be your time axis that you plot on 
% run 'open linspace' if still confused 
EEGtimevec = linspace(0, timeEeg, (length(lfp))); 


%% Initial Trim of Signal
% upon quick glance is quite evident that this LFP recording was left on
% well after the ABET schedule had finished, and that this signal is too
% long; Even in cases where it is not left on intentionally the signal will
% tend to be longer than needed 


% Thus, of the timescaled vector, give me 1800s in this case (30 min schedule)
% think about it as EEGtimevec containing time in seconds within it, as
% values, so we want 1800s or values up to and equal to 1800
cpt_schLength = EEGtimevec(EEGtimevec <= 1800) ; 
assignin("base","cpt_schLength", cpt_schLength);

% because the vector of cpt_schLength was sourced from the time-vector scaled 
% to the # of data points from the EEG recording, we want EEG data points = to the length of our 1800s vector
lfp = lfp(:,[1:(length(cpt_schLength))]);

%% Split LFP channels for clarity 
% currently, our lfp variable contains all channels together, rows: 1-gint64, 2-reference-pin, 3-Brain reg.1, 4-Brain reg.2

% For clarity, and to avoid mistakes, lets split them up and save them with
% aptly named variables 


% can set prompts here...


%1- Ground 
savename.Ground.lfp = lfp(1,:); 
%2- straight pin, (ref. i think) 
savename.Reference.lfp = lfp(2,:);
%3- locus coeruleus electrode
savename.LC.lfp = lfp(3,:);
%4- anterior cingulate cortex electrode
savename.ACC.lfp = lfp (4,:);

%% Grabbing timestamps based LFP 
% For each electrode, and for each type of event, we need to grab the
% lfp, half a second before and after the timestamp... and save this
% as a structure(for ease)


% First, we must up-sample, to match the scale(resolution) we have lfp at
FIRBeam_Onidx = FIRBeam_On * srate{1}; 
FIRBeam_Onidx =int64(FIRBeam_Onidx); 

FIRBeam_Offidx = FIRBeam_Off * srate{1}; 
FIRBeam_Offidx = int64(FIRBeam_Offidx);

Center_ScTouchidx = Center_ScTouch * srate{1}; 
Center_ScTouchidx = int64(Center_ScTouchidx);

Start_ITIidx =Start_ITI * srate{1}; 
Start_ITIidx = int64(Start_ITIidx);

Stimulusidx = Stimulus * srate{1}; 
Stimulusidx = int64(Stimulusidx);

Hitidx = Hit * srate{1}; 
Hitidx = int64(Hitidx);

Missidx = Miss * srate{1}; 
Missidx = int64(Missidx);

Correct_Rejidx =Correct_Rej * srate{1}; 
Correct_Rejidx = int64(Correct_Rejidx);

False_Alarmidx = False_Alarm * srate{1}; 
False_Alarmidx = int64(False_Alarmidx);
 

%% now we can grab the lfp of each timestamp

% Make it an if... statement, so that when we have empty variables (S2 as
%one case) then we can still run the full script and wont be stopped by
%errors
if sum(size(FIRBeam_On)) >= 2 
    for i = 1:length(FIRBeam_Onidx)
        if (FIRBeam_Onidx(i)+(srate{1}*TimeWin{1}))<(length(lfp)) && (FIRBeam_Onidx(i)-(srate{1}*TimeWin{1}))>(0)  
            savename.Ground.FIRBeam_On_lfp{i} = savename.Ground.lfp(1,[FIRBeam_Onidx(1,i)-(srate{1}*TimeWin{1}):FIRBeam_Onidx(1,i)+(srate{1}*TimeWin{1})]);
            savename.Reference.FIRBeam_On_lfp{i} = savename.Reference.lfp(1,[FIRBeam_Onidx(1,i)-(srate{1}*TimeWin{1}):FIRBeam_Onidx(1,i)+(srate{1}*TimeWin{1})]);
            savename.LC.FIRBeam_On_lfp{i} = savename.LC.lfp(1,[FIRBeam_Onidx(1,i)-(srate{1}*TimeWin{1}):FIRBeam_Onidx(1,i)+(srate{1}*TimeWin{1})]);
            savename.ACC.FIRBeam_On_lfp{i} = savename.ACC.lfp(1,[FIRBeam_Onidx(1,i)-(srate{1}*TimeWin{1}):FIRBeam_Onidx(1,i)+(srate{1}*TimeWin{1})]);
        end
    end
end

if sum(size(FIRBeam_Off)) >= 2 
    for i = 1:(length(FIRBeam_Offidx))
        if (FIRBeam_Offidx(i)+(srate{1}*TimeWin{1}))<(length(lfp)) && (FIRBeam_Offidx(i)-(srate{1}*TimeWin{1}))>(0)        
            savename.Ground.FIRBeam_Off_lfp{i} = savename.Ground.lfp(1,[FIRBeam_Offidx(1,i)-(srate{1}*TimeWin{1}):FIRBeam_Offidx(1,i)+(srate{1}*TimeWin{1})]);
            savename.Reference.FIRBeam_Off_lfp{i} = savename.Reference.lfp(1,[FIRBeam_Offidx(1,i)-(srate{1}*TimeWin{1}):FIRBeam_Offidx(1,i)+(srate{1}*TimeWin{1})]);
            savename.LC.FIRBeam_Off_lfp{i} = savename.LC.lfp(1,[FIRBeam_Offidx(1,i)-(srate{1}*TimeWin{1}):FIRBeam_Offidx(1,i)+(srate{1}*TimeWin{1})]);
            savename.ACC.FIRBeam_Off_lfp{i} = savename.ACC.lfp(1,[FIRBeam_Offidx(1,i)-(srate{1}*TimeWin{1}):FIRBeam_Offidx(1,i)+(srate{1}*TimeWin{1})]);
        end
    end
end

if sum(size(Center_ScTouch)) >= 2 
    for i = 1:length(Center_ScTouchidx)
        if (Center_ScTouchidx(i)+(srate{1}*TimeWin{1}))<(length(lfp)) && (Center_ScTouchidx(i)-(srate{1}*TimeWin{1}))>(0)              
            savename.Ground.Center_ScTouch_lfp{i} = savename.Ground.lfp(1,[Center_ScTouchidx(1,i)-(srate{1}*TimeWin{1}):Center_ScTouchidx(1,i)+(srate{1}*TimeWin{1})]);
            savename.Reference.Center_ScTouch_lfp{i} = savename.Reference.lfp(1,[Center_ScTouchidx(1,i)-(srate{1}*TimeWin{1}):Center_ScTouchidx(1,i)+(srate{1}*TimeWin{1})]);
            savename.LC.Center_ScTouch_lfp{i} = savename.LC.lfp(1,[Center_ScTouchidx(1,i)-(srate{1}*TimeWin{1}):Center_ScTouchidx(1,i)+(srate{1}*TimeWin{1})]);
            savename.ACC.Center_ScTouch_lfp{i} = savename.ACC.lfp(1,[Center_ScTouchidx(1,i)-(srate{1}*TimeWin{1}):Center_ScTouchidx(1,i)+(srate{1}*TimeWin{1})]);
        end
    end
end

if sum(size(Start_ITI)) >= 2 
    for i = 1:length(Start_ITIidx)
        if (Start_ITIidx(i)+(srate{1}*TimeWin{1}))<(length(lfp)) && (Start_ITIidx(i)-(srate{1}*TimeWin{1}))>(0)                        
            savename.Ground.Start_ITI_lfp{i} = savename.Ground.lfp(1,[Start_ITIidx(1,i)-(srate{1}*TimeWin{1}):Start_ITIidx(1,i)+(srate{1}*TimeWin{1})]);
            savename.Reference.Start_ITI_lfp{i} = savename.Reference.lfp(1,[Start_ITIidx(1,i)-(srate{1}*TimeWin{1}):Start_ITIidx(1,i)+(srate{1}*TimeWin{1})]);
            savename.LC.Start_ITI_lfp{i} = savename.LC.lfp(1,[Start_ITIidx(1,i)-(srate{1}*TimeWin{1}):Start_ITIidx(1,i)+(srate{1}*TimeWin{1})]);
            savename.ACC.Start_ITI_lfp{i} = savename.ACC.lfp(1,[Start_ITIidx(1,i)-(srate{1}*TimeWin{1}):Start_ITIidx(1,i)+(srate{1}*TimeWin{1})]);
        end
    end
end
if sum(size(Stimulus)) >= 2 
    for i = 1:length(Stimulusidx)
        if (Stimulusidx(i)+(srate{1}*TimeWin{1}))<(length(lfp)) && (Stimulusidx(i)-(srate{1}*TimeWin{1}))>(0)                      
            savename.Ground.Stimulus_lfp{i} = savename.Ground.lfp(1,[Stimulusidx(1,i)-(srate{1}*TimeWin{1}):Stimulusidx(1,i)+(srate{1}*TimeWin{1})]);
            savename.Reference.Stimulus_lfp{i} = savename.Reference.lfp(1,[Stimulusidx(1,i)-(srate{1}*TimeWin{1}):Stimulusidx(1,i)+(srate{1}*TimeWin{1})]);
            savename.LC.Stimulus_lfp{i} = savename.LC.lfp(1,[Stimulusidx(1,i)-(srate{1}*TimeWin{1}):Stimulusidx(1,i)+(srate{1}*TimeWin{1})]);
            savename.ACC.Stimulus_lfp{i} = savename.ACC.lfp(1,[Stimulusidx(1,i)-(srate{1}*TimeWin{1}):Stimulusidx(1,i)+(srate{1}*TimeWin{1})]);
        end
    end
end
if sum(size(Hit)) >= 2
    for i = 1:length(Hitidx)
        if (Hitidx(i)+(srate{1}*TimeWin{1}))<(length(lfp)) && (Hitidx(i)-(srate{1}*TimeWin{1}))>(0)                        
            savename.Ground.Hit_lfp{i} = savename.Ground.lfp(1,[Hitidx(1,i)-(srate{1}*TimeWin{1}):Hitidx(1,i)+(srate{1}*TimeWin{1})]);
            savename.Reference.Hit_lfp{i} = savename.Reference.lfp(1,[Hitidx(1,i)-(srate{1}*TimeWin{1}):Hitidx(1,i)+(srate{1}*TimeWin{1})]);
            savename.LC.Hit_lfp{i} = savename.LC.lfp(1,[Hitidx(1,i)-(srate{1}*TimeWin{1}):Hitidx(1,i)+(srate{1}*TimeWin{1})]);
            savename.ACC.Hit_lfp{i} = savename.ACC.lfp(1,[Hitidx(1,i)-(srate{1}*TimeWin{1}):Hitidx(1,i)+(srate{1}*TimeWin{1})]);
        end
    end
end    
if sum(size(Miss)) >= 2
    for i = 1:length(Missidx)
        if (Missidx(i)+(srate{1}*TimeWin{1}))<(length(lfp)) && (Missidx(i)-(srate{1}*TimeWin{1}))>(0)               
            savename.Ground.Miss_lfp{i} = savename.Ground.lfp(1,[Missidx(1,i)-(srate{1}*TimeWin{1}):Missidx(1,i)+(srate{1}*TimeWin{1})]);
            savename.Reference.Miss_lfp{i} = savename.Reference.lfp(1,[Missidx(1,i)-(srate{1}*TimeWin{1}):Missidx(1,i)+(srate{1}*TimeWin{1})]);
            savename.LC.Miss_lfp{i} = savename.LC.lfp(1,[Missidx(1,i)-(srate{1}*TimeWin{1}):Missidx(1,i)+(srate{1}*TimeWin{1})]);
            savename.ACC.Miss_lfp{i} = savename.ACC.lfp(1,[Missidx(1,i)-(srate{1}*TimeWin{1}):Missidx(1,i)+(srate{1}*TimeWin{1})]);
        end
    end
end
if sum(size(Correct_Rej)) >= 2
    for i = 1:length(Correct_Rejidx)
        if (Correct_Rejidx(i)+(srate{1}*TimeWin{1}))<(length(lfp)) && (Correct_Rejidx(i)-(srate{1}*TimeWin{1}))>(0)                      
            savename.Ground.Correct_Rej_lfp{i} = savename.Ground.lfp(1,[Correct_Rejidx(1,i)-(srate{1}*TimeWin{1}):Correct_Rejidx(1,i)+(srate{1}*TimeWin{1})]);
            savename.Reference.Correct_Rej_lfp{i} = savename.Reference.lfp(1,[Correct_Rejidx(1,i)-(srate{1}*TimeWin{1}):Correct_Rejidx(1,i)+(srate{1}*TimeWin{1})]);
            savename.LC.Correct_Rej_lfp{i} = savename.LC.lfp(1,[Correct_Rejidx(1,i)-(srate{1}*TimeWin{1}):Correct_Rejidx(1,i)+(srate{1}*TimeWin{1})]);
            savename.ACC.Correct_Rej_lfp{i} = savename.ACC.lfp(1,[Correct_Rejidx(1,i)-(srate{1}*TimeWin{1}):Correct_Rejidx(1,i)+(srate{1}*TimeWin{1})]);
        end
    end
end
if sum(size(False_Alarm)) >= 2
    for i = 1:length(False_Alarmidx)
        if (False_Alarmidx(i)+(srate{1}*TimeWin{1}))<(length(lfp)) && (False_Alarmidx(i)-(srate{1}*TimeWin{1}))>(0)                     
            savename.Ground.False_Alarm_lfp{i} = savename.Ground.lfp(1,[False_Alarmidx(1,i)-(srate{1}*TimeWin{1}):False_Alarmidx(1,i)+(srate{1}*TimeWin{1})]);
            savename.Reference.False_Alarm_lfp{i} = savename.Reference.lfp(1,[False_Alarmidx(1,i)-(srate{1}*TimeWin{1}):False_Alarmidx(1,i)+(srate{1}*TimeWin{1})]);
            savename.LC.False_Alarm_lfp{i} = savename.LC.lfp(1,[False_Alarmidx(1,i)-(srate{1}*TimeWin{1}):False_Alarmidx(1,i)+(srate{1}*TimeWin{1})]);
            savename.ACC.False_Alarm_lfp{i} = savename.ACC.lfp(1,[False_Alarmidx(1,i)-(srate{1}*TimeWin{1}):False_Alarmidx(1,i)+(srate{1}*TimeWin{1})]);
        end
    end
end

%% Saving / Moving forward
sprintf('Everything has been extracted!\nNow you have 4 separate structures (within your main mouse structure)\nOne for each channel...\nAnd within them\nRaw LFP, and event based extracted LFP windows of data!')
x = input('Would you like to save all of these channels automatically? It could take a while...\n  -Or you can move forward with processing the variables you have(right side) and save later\n  -Or you can save individual things manually\n\nInput ''1'' to save all automatically\nInput ''2'' to handle it on your own...')
if x == 1
    %y = input('Where would you like to save these structures?\nINPUT STYLE {''path''}')
    cd(saveplace{1})
    save(mousename{1},'-struct','savename')
%     save('Ground', '-struct','Ground')
%     save('LC', '-struct','LC')
%     save('Reference', '-struct','Reference')
    sprintf('Your new structure has been saved with in path ''%s'',\nwith name ''%s''!',saveplace{1},mousename{1})
elseif x == 2 
    assignin('base',mousename{1},savename)
end

end
