%% LFP 4 CPT script #2
% this script assumes you have completed LFP4CPT script 1, and thus have
% structures for each mouse for each recorded session, structures
% containing lfp combined with event TStamps

%--Written by Suhaas S. Adiraju 10/05/2021 (updated 11.19.21)

%% Load-in
clear; clc;

%pathway to your folder with full structures, ('yourpath')
path2struc = 'Z:\Circuits projects (CPT)\CPT Recording Data\LC-mPFC LFP';

%'change directory' to this path
cd(path2struc); 

% define then load desired data structure 
filename = 'S3GOOD_1328_S';
load(filename);

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
srate = 2000;

% get total time, by dividing length of lfp file (which is in samples) by sampling rate... 
timeEeg = (length(lfp))/srate; % total time in seconds 

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
cpt_schLength = EEGtimevec(EEGtimevec <= 1800); 


% because the vector of cpt_schLength was sourced from the time-vector scaled 
% to the # of data points from the EEG recording, we want EEG data points = to the length of our 1800s vector
lfp = lfp(:,[1:(length(cpt_schLength))]);

%% Split LFP channels for clarity 
% currently, our lfp variable contains all channels together, rows: 1-gint64, 2-reference-pin, 3-Brain reg.1, 4-Brain reg.2

% For clarity, and to avoid mistakes, lets split them up and save them with
% aptly named variables 

%1- gint64 
Ground.lfp = lfp(1,:); 
%2- straigh pin, (ref. i think) 
Reference.lfp = lfp(2,:);
%3- locus coeruleus electrode
LC.lfp = lfp(3,:);
%4- anterior cingulate cortex electrode
ACC.lfp = lfp (4,:);

%% Grabbing timestamps based LFP 
% For each electrode, and for each type of event, we need to grab the
% lfp, half a second before and after the timestamp... and save this
% as a structure(for ease)


% First, we must up-sample, to match the scale(resolution) we have lfp at
FIRBeam_Onidx = FIRBeam_On * 2000; 
FIRBeam_Onidx =int64(FIRBeam_Onidx); 

FIRBeam_Offidx = FIRBeam_Off * 2000; 
FIRBeam_Offidx = int64(FIRBeam_Offidx);

Center_ScTouchidx = Center_ScTouch * 2000; 
Center_ScTouchidx = int64(Center_ScTouchidx);

Start_ITIidx =Start_ITI * 2000; 
Start_ITIidx = int64(Start_ITIidx);

Stimulusidx = Stimulus * 2000; 
Stimulusidx = int64(Stimulusidx);

Hitidx = Hit * 2000; 
Hitidx = int64(Hitidx);

Missidx = Miss * 2000; 
Missidx = int64(Missidx);

Correct_Rejidx =Correct_Rej * 2000; 
Correct_Rejidx = int64(Correct_Rejidx);

False_Alarmidx = False_Alarm * 2000; 
False_Alarmidx = int64(False_Alarmidx);
 

% now we can grab the lfp of each timestamp

% Make it an if... statement, so that when we have empty variables (S2 as
%one case) then we can still run the full script and wont be stopped by
%errors
if sum(size(FIRBeam_On)) >= 2 
    for i = 1:length(FIRBeam_Onidx)
        if (FIRBeam_Onidx(i)+(srate*2))<(length(lfp)) && (FIRBeam_Onidx(i)-(srate*2))>(0)  
            Ground.FIRBeam_On_lfp{i} = Ground.lfp(1,[FIRBeam_Onidx(1,i)-(srate*2):FIRBeam_Onidx(1,i)+(srate*2)]);
            Reference.FIRBeam_On_lfp{i} = Reference.lfp(1,[FIRBeam_Onidx(1,i)-(srate*2):FIRBeam_Onidx(1,i)+(srate*2)]);
            LC.FIRBeam_On_lfp{i} = LC.lfp(1,[FIRBeam_Onidx(1,i)-(srate*2):FIRBeam_Onidx(1,i)+(srate*2)]);
            ACC.FIRBeam_On_lfp{i} = ACC.lfp(1,[FIRBeam_Onidx(1,i)-(srate*2):FIRBeam_Onidx(1,i)+(srate*2)]);
        end
    end
end

if sum(size(FIRBeam_Off)) >= 2 
    for i = 1:(length(FIRBeam_Offidx))
        if (FIRBeam_Offidx(i)+(srate*2))<(length(lfp)) && (FIRBeam_Offidx(i)-(srate*2))>(0)        
            Ground.FIRBeam_Off_lfp{i} = Ground.lfp(1,[FIRBeam_Offidx(1,i)-(srate*2):FIRBeam_Offidx(1,i)+(srate*2)]);
            Reference.FIRBeam_Off_lfp{i} = Reference.lfp(1,[FIRBeam_Offidx(1,i)-(srate*2):FIRBeam_Offidx(1,i)+(srate*2)]);
            LC.FIRBeam_Off_lfp{i} = LC.lfp(1,[FIRBeam_Offidx(1,i)-(srate*2):FIRBeam_Offidx(1,i)+(srate*2)]);
            ACC.FIRBeam_Off_lfp{i} = ACC.lfp(1,[FIRBeam_Offidx(1,i)-(srate*2):FIRBeam_Offidx(1,i)+(srate*2)]);
        end
    end
end

if sum(size(Center_ScTouch)) >= 2 
    for i = 1:length(Center_ScTouchidx)
        if (Center_ScTouchidx(i)+(srate*2))<(length(lfp)) && (Center_ScTouchidx(i)-(srate*2))>(0)              
            Ground.Center_ScTouch_lfp{i} = Ground.lfp(1,[Center_ScTouchidx(1,i)-(srate*2):Center_ScTouchidx(1,i)+(srate*2)]);
            Reference.Center_ScTouch_lfp{i} = Reference.lfp(1,[Center_ScTouchidx(1,i)-(srate*2):Center_ScTouchidx(1,i)+(srate*2)]);
            LC.Center_ScTouch_lfp{i} = LC.lfp(1,[Center_ScTouchidx(1,i)-(srate*2):Center_ScTouchidx(1,i)+(srate*2)]);
            ACC.Center_ScTouch_lfp{i} = ACC.lfp(1,[Center_ScTouchidx(1,i)-(srate*2):Center_ScTouchidx(1,i)+(srate*2)]);
        end
    end
end

if sum(size(Start_ITI)) >= 2 
    for i = 1:length(Start_ITIidx)
        if (Start_ITIidx(i)+(srate*2))<(length(lfp)) && (Start_ITIidx(i)-(srate*2))>(0)                        
            Ground.Start_ITI_lfp{i} = Ground.lfp(1,[Start_ITIidx(1,i)-(srate*2):Start_ITIidx(1,i)+(srate*2)]);
            Reference.Start_ITI_lfp{i} = Reference.lfp(1,[Start_ITIidx(1,i)-(srate*2):Start_ITIidx(1,i)+(srate*2)]);
            LC.Start_ITI_lfp{i} = LC.lfp(1,[Start_ITIidx(1,i)-(srate*2):Start_ITIidx(1,i)+(srate*2)]);
            ACC.Start_ITI_lfp{i} = ACC.lfp(1,[Start_ITIidx(1,i)-(srate*2):Start_ITIidx(1,i)+(srate*2)]);
        end
    end
end
if sum(size(Stimulus)) >= 2 
    for i = 1:length(Stimulusidx)
        if (Stimulusidx(i)+(srate*2))<(length(lfp)) && (Stimulusidx(i)-(srate*2))>(0)                      
            Ground.Stimulus_lfp{i} = Ground.lfp(1,[Stimulusidx(1,i)-(srate*2):Stimulusidx(1,i)+(srate*2)]);
            Reference.Stimulus_lfp{i} = Reference.lfp(1,[Stimulusidx(1,i)-(srate*2):Stimulusidx(1,i)+(srate*2)]);
            LC.Stimulus_lfp{i} = LC.lfp(1,[Stimulusidx(1,i)-(srate*2):Stimulusidx(1,i)+(srate*2)]);
            ACC.Stimulus_lfp{i} = ACC.lfp(1,[Stimulusidx(1,i)-(srate*2):Stimulusidx(1,i)+(srate*2)]);
        end
    end
end
if sum(size(Hit)) >= 2
    for i = 1:length(Hitidx)
        if (Hitidx(i)+(srate*2))<(length(lfp)) && (Hitidx(i)-(srate*2))>(0)                        
            Ground.Hit_lfp{i} = Ground.lfp(1,[Hitidx(1,i)-(srate*2):Hitidx(1,i)+(srate*2)]);
            Reference.Hit_lfp{i} = Reference.lfp(1,[Hitidx(1,i)-(srate*2):Hitidx(1,i)+(srate*2)]);
            LC.Hit_lfp{i} = LC.lfp(1,[Hitidx(1,i)-(srate*2):Hitidx(1,i)+(srate*2)]);
            ACC.Hit_lfp{i} = ACC.lfp(1,[Hitidx(1,i)-(srate*2):Hitidx(1,i)+(srate*2)]);
        end
    end
end    
if sum(size(Miss)) >= 2
    for i = 1:length(Missidx)
        if (Missidx(i)+(srate*2))<(length(lfp)) && (Missidx(i)-(srate*2))>(0)               
            Ground.Miss_lfp{i} = Ground.lfp(1,[Missidx(1,i)-(srate*2):Missidx(1,i)+(srate*2)]);
            Reference.Miss_lfp{i} = Reference.lfp(1,[Missidx(1,i)-(srate*2):Missidx(1,i)+(srate*2)]);
            LC.Miss_lfp{i} = LC.lfp(1,[Missidx(1,i)-(srate*2):Missidx(1,i)+(srate*2)]);
            ACC.Miss_lfp{i} = ACC.lfp(1,[Missidx(1,i)-(srate*2):Missidx(1,i)+(srate*2)]);
        end
    end
end
if sum(size(Correct_Rej)) >= 2
    for i = 1:length(Correct_Rejidx)
        if (Correct_Rejidx(i)+(srate*2))<(length(lfp)) && (Correct_Rejidx(i)-(srate*2))>(0)                      
            Ground.Correct_Rej_lfp{i} = Ground.lfp(1,[Correct_Rejidx(1,i)-(srate*2):Correct_Rejidx(1,i)+(srate*2)]);
            Reference.Correct_Rej_lfp{i} = Reference.lfp(1,[Correct_Rejidx(1,i)-(srate*2):Correct_Rejidx(1,i)+(srate*2)]);
            LC.Correct_Rej_lfp{i} = LC.lfp(1,[Correct_Rejidx(1,i)-(srate*2):Correct_Rejidx(1,i)+(srate*2)]);
            ACC.Correct_Rej_lfp{i} = ACC.lfp(1,[Correct_Rejidx(1,i)-(srate*2):Correct_Rejidx(1,i)+(srate*2)]);
        end
    end
end
if sum(size(False_Alarm)) >= 2
    for i = 1:length(False_Alarmidx)
        if (False_Alarmidx(i)+(srate*2))<(length(lfp)) && (False_Alarmidx(i)-(srate*2))>(0)                     
            Ground.False_Alarm_lfp{i} = Ground.lfp(1,[False_Alarmidx(1,i)-(srate*2):False_Alarmidx(1,i)+(srate*2)]);
            Reference.False_Alarm_lfp{i} = Reference.lfp(1,[False_Alarmidx(1,i)-(srate*2):False_Alarmidx(1,i)+(srate*2)]);
            LC.False_Alarm_lfp{i} = LC.lfp(1,[False_Alarmidx(1,i)-(srate*2):False_Alarmidx(1,i)+(srate*2)]);
            ACC.False_Alarm_lfp{i} = ACC.lfp(1,[False_Alarmidx(1,i)-(srate*2):False_Alarmidx(1,i)+(srate*2)]);
        end
    end
end



%% Some plotting and playing with the data (unnecessary for analysis)
% total time on task
figure;
box off;
plot(cpt_schLength,ACC.lfp,'k');
xlabel('Time(s)')
ylabel('Voltage')
title('ACC LFP Full Session')

% surrounding hit example 
% x axis for plot
hitlength = linspace(-((length(ACC.Hit_lfp{1})/srate)),(length(ACC.Hit_lfp{1})/srate),length(ACC.Hit_lfp{1}));
figure;
box off;
plot(hitlength, ACC.Hit_lfp{1}, 'r')
xlim ([-4 4])
xlabel('Time(s)')
ylabel('Voltage')
title('ACC LFP surrounding Hit event')

% filter for theta 
thetasample = bandpass(ACC.Hit_lfp{1},[4 7], 2000);
gammasample = bandpass(ACC.Hit_lfp{1}, [30 50], 2000);                              
figure;
box off;
subplot 211
plot(hitlength, thetasample, 'r')
xlim ([-4 4])
xlabel('Time(s)')
ylabel('Voltage (mV)')
title('Theta Filtered (4-7Hz) Surrounding Hit Event')                                            
subplot 212
plot(hitlength, gammasample, 'g')
xlim ([-4 4])
xlabel('Time(s)')
ylabel('Voltage (mV)')
title('Slow-Gamma Filtered (30-50 Hz) Surrounding Hit Event')

% power spec 
params.tapers = [5 9];
params.pad = 0;
params.Fs = 2000; % Srate
params.fpass = [0 200];
params.err = [2 0.05];
params.trialave = 0;

[S,t,Serr] = mtspectrumc(ACC.lfp, params);
[S_hit,t_hit,Serr_hit] = mtspectrumc(ACC.Hit_lfp{1}, params);

figure;
box off;
p1 = plot (t,S);
p1.LineWidth = 2;
p1.Color = [0 .4 0]
xlim ([0 60]);
xlabel('Frequencies (Hz)');
title('Power Spectrum analysis of total task time LFP');

t_hit2 = t_hit.^2
figure;
p2 = plot(t_hit2, S_hit);
p2.LineWidth = 2;
p2.Color = [0 .4 0]
xlim ([0 60]);
xlabel('Frequencies (Hz)');
title('Power Spectrum analysis of Hit-Centered LFP');



                                     
                                            
