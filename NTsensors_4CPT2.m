%% Grab NTransmitter Transients surrounding event timestamps
% This script is written assuming the user has followed EFT 4 CPT 1, and
% has the mouse structure with event timestamps saved as a distinct
% variable, along with bio-sensor imaging,
% transients saved in a structure

% - Written by Suhaas S Adiraju

%%
% cd to location of of the structure
cd('Z:\Circuits projects (CPT)\CPT Recording Data\GRAB_NE'); % ('yourpath')

% load file of choice
load ("GRAB_NE_1640.mat")

%% Trimming our signal (optional)
%{
% What's your sampling rate
srate = srate;

% Set transients on the proper timescale, ("give me a vector of 0-total
% seconds in value, but with a length of the total # of samples in the original matrix")
Transients_TimeVec = linspace(0, ((length(Transients))/srate), (length(Transients)));

 

% you can see right away that the transients length is too long, and we
% know the cpt schedule is only 1800s (30min), and we know that our
% 0seconds in the signal is true zero of the cpt task cause we use a TTL
% so we can trim the transients signal to the length of the cpt
cpt_length = Transients_TimeVec(Transients_TimeVec <= 1800);
int64(cpt_length)= cpt_length .*1000
(FIRBeam_On)
%}
%% Equalizing Resolutions

% Now we can grab transients = the length of the cpt schedule
% Transients = Transients(\);


% First, we must up-sample, to match the scale(resolution) at which we have Ne_transients
% i.e. event timestamps 
FIRBeam_Onidx = FIRBeam_On * srate; 
FIRBeam_Onidx =int64(FIRBeam_Onidx); % here im converting the class of the IDX values because as a double certain vals were not integers (ie 10385.00000 became 1.0385x10e6)
Transients(FIRBeam_Onidx);


FIRBeam_Offidx = FIRBeam_Off * srate; 
FIRBeam_Offidx = int64(FIRBeam_Offidx);

Center_ScTouchidx = Center_ScTouch * srate; 
Center_ScTouchidx = int64(Center_ScTouchidx);

Start_ITIidx =Start_ITI * srate; 
Start_ITIidx = int64(Start_ITIidx);

Stimulusidx = Stimulus * srate; 
Stimulusidx = int64(Stimulusidx);

Hitidx = Hit * srate; 
Hitidx = int64(Hitidx);

Missidx = Miss * srate; 
Missidx = int64(Missidx);

Correct_Rejidx =Correct_Rej * srate; 
Correct_Rejidx = int64(Correct_Rejidx);

False_Alarmidx = False_Alarm * srate; 
False_Alarmidx = int64(False_Alarmidx);

%% Now we can grab the Ne_transients of each timestamp

% Make it an if... statement, so that when we have empty variables (S2 as
%one case) then we can still run the full script and wont be stopped by
%errors
if sum(size(FIRBeam_On)) >= 2 
    for i = 1:length(FIRBeam_Onidx)
        if (FIRBeam_Onidx(i)+(srate*2))<(length(Ne_transients)) && (FIRBeam_Onidx(i)-(srate*2))>(0)  
            NeTransients.FIRBeam_On{i} = Ne_transients(1,[FIRBeam_Onidx(1,i)-(srate*2):FIRBeam_Onidx(1,i)+(srate*2)]);
        end
    end
end

if sum(size(FIRBeam_Off)) >= 2 
    for i = 1:(length(FIRBeam_Offidx))
        if (FIRBeam_Offidx(i)+(srate*2))<(length(Ne_transients)) && (FIRBeam_Offidx(i)-(srate*2))>(0)        
            NeTransients.FIRBeam_Off_Ne_transients{i} = Ne_transients(1,[FIRBeam_Offidx(1,i)-(srate*2):FIRBeam_Offidx(1,i)+(srate*2)]);
        end
    end
end

if sum(size(Center_ScTouch)) >= 2 
    for i = 1:length(Center_ScTouchidx)
        if (Center_ScTouchidx(i)+(srate*2))<(length(Ne_transients)) && (Center_ScTouchidx(i)-(srate*2))>(0)              
            NeTransients.Center_ScTouch_Ne_transients{i} = Ne_transients(1,[Center_ScTouchidx(1,i)-(srate*2):Center_ScTouchidx(1,i)+(srate*2)]);
        end
    end
end

if sum(size(Start_ITI)) >= 2 
    for i = 1:length(Start_ITIidx)
        if (Start_ITIidx(i)+(srate*2))<(length(Ne_transients)) && (Start_ITIidx(i)-(srate*2))>(0)                        
            NeTransients.Start_ITI_Ne_transients{i} = Ne_transients(1,[Start_ITIidx(1,i)-(srate*2):Start_ITIidx(1,i)+(srate*2)]);
        end
    end
end
if sum(size(Stimulus)) >= 2 
    for i = 1:length(Stimulusidx)
        if (Stimulusidx(i)+(srate*2))<(length(Ne_transients)) && (Stimulusidx(i)-(srate*2))>(0)                      
            NeTransients.Stimulus_Ne_transients{i} = Ne_transients(1,[Stimulusidx(1,i)-(srate*2):Stimulusidx(1,i)+(srate*2)]);
        end
    end
end
if sum(size(Hit)) >= 2
    for i = 1:length(Hitidx)
        if (Hitidx(i)+(srate*2))<(length(Ne_transients)) && (Hitidx(i)-(srate*2))>(0)                        
            NeTransients.Hit_Ne_transients{i} = Ne_transients(1,[Hitidx(1,i)-(srate*2):Hitidx(1,i)+(srate*2)]);
        end
    end
end    
if sum(size(Miss)) >= 2
    for i = 1:length(Missidx)
        if (Missidx(i)+(srate*2))<(length(Ne_transients)) && (Missidx(i)-(srate*2))>(0)               
            NeTransients.Miss_Ne_transients{i} = Ne_transients(1,[Missidx(1,i)-(srate*2):Missidx(1,i)+(srate*2)]);
        end
    end
end
if sum(size(Correct_Rej)) >= 2
    for i = 1:length(Correct_Rejidx)
        if (Correct_Rejidx(i)+(srate*2))<(length(Ne_transients)) && (Correct_Rejidx(i)-(srate*2))>(0)                      
            NeTransients.Correct_Rej_Ne_transients{i} = Ne_transients(1,[Correct_Rejidx(1,i)-(srate*2):Correct_Rejidx(1,i)+(srate*2)]);
        end
    end
end
if sum(size(False_Alarm)) >= 2
    for i = 1:length(False_Alarmidx)
        if (False_Alarmidx(i)+(srate*2))<(length(Ne_transients)) && (False_Alarmidx(i)-(srate*2))>(0)                     
            NeTransients.False_Alarm_Ne_transients{i} = Ne_transients(1,[False_Alarmidx(1,i)-(srate*2):False_Alarmidx(1,i)+(srate*2)]);
        end
    end
end
