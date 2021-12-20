function [slicedSensorStruc] = sliceNTsensors(struc_path, struc_name, srate{1}, TimeWin, saveplace, mousename)
%% DESCRIPTION
% This function is to grab neuro-transmitter sensor transients surrounding event timestamps
% This function is written assuming the user has followed NTsensors4CPT 1, and
% has the mouse structure with event timestamps saved as a distinct
% variable, along with the bio-sensor imaging, transients saved in a structure

% - Written by Suhaas S Adiraju

%% INPUTS 

% struc_path = path to folder of saved structure

% struc_name = name of saved structure

% srate{1} = sampling rate of recording 

% TimeWin = user defined time window size of analysis (ie 4s around each
% hit event)

% saveplace = place you'd like to store your new structure

% mousename = name you would like to save it as

%% OUTPUTS 

% structure of transients sliced based on event-type timestamps


%%

% cd to location of of the structure
cd(struc_path{1});

% load file of choice
load (struc_name{1})

Transients = Ne_transients;

%% Trimming our signal (optional)

% Set transients on the proper timescale, ("give me a vector of 0-total
% seconds in value, but with a length of the total # of samples in the original matrix")
Transients_TimeVec = linspace(0, ((length(Transients))/srate{1}{1}), (length(Transients)));

% you can see right away that the transients length is too long, and we
% know the cpt schedule is only 1800s (30min), and we know that our
% 0seconds in the signal is true zero of the cpt task cause we use a TTL
% so we can trim the transients signal to the length of the cpt
cpt_length = Transients_TimeVec(Transients_TimeVec <= 1800);
cpt_transients = Transients(:,[1:(length(cpt_length))]);

%ylabel('dF/F (change in fluorescent expression)')
%}
%% Equalizing Resolutions

% Now we can grab transients = the length of the cpt schedule
% Transients = Transients(\);


% First, we must up-sample, to match the scale(resolution) at which we have Transients
% i.e. event timestamps 
FIRBeam_Onidx = FIRBeam_On * srate{1}; 
FIRBeam_Onidx =int64(FIRBeam_Onidx); % here im converting the class of the IDX values because as a double certain vals were not integers (ie 10385.00000 became 1.0385x10e6)


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

%% Now we can grab the Transients of each timestamp

% Make it an if... statement, so that when we have empty variables (S2 as
%one case) then we can still run the full script and wont be stopped by
%errors

if sum(size(FIRBeam_On)) >= 2 
    for i = 1:length(FIRBeam_Onidx)
        if (FIRBeam_Onidx(i)+(srate{1}*TimeWin{1}))<(length(Transients)) && (FIRBeam_Onidx(i)-(srate{1}*TimeWin{1}))>(0)  
            CutTransients.FIRBeam_On_transients{i} = Transients(1,[FIRBeam_Onidx(1,i)-(srate{1}*TimeWin{1}):FIRBeam_Onidx(1,i)+(srate{1}*TimeWin{1})]);
        end
    end
end

if sum(size(FIRBeam_Off)) >= 2 
    for i = 1:(length(FIRBeam_Offidx))
        if (FIRBeam_Offidx(i)+(srate{1}*TimeWin{1}))<(length(Transients)) && (FIRBeam_Offidx(i)-(srate{1}*TimeWin{1}))>(0)        
            CutTransients.FIRBeam_Off_Transients{i} = Transients(1,[FIRBeam_Offidx(1,i)-(srate{1}*TimeWin{1}):FIRBeam_Offidx(1,i)+(srate{1}*TimeWin{1})]);
        end
    end
end

if sum(size(Center_ScTouch)) >= 2 
    for i = 1:length(Center_ScTouchidx)
        if (Center_ScTouchidx(i)+(srate{1}*TimeWin{1}))<(length(Transients)) && (Center_ScTouchidx(i)-(srate{1}*TimeWin{1}))>(0)              
            CutTransients.Center_ScTouch_Transients{i} = Transients(1,[Center_ScTouchidx(1,i)-(srate{1}*TimeWin{1}):Center_ScTouchidx(1,i)+(srate{1}*TimeWin{1})]);
        end
    end
end

if sum(size(Start_ITI)) >= 2 
    for i = 1:length(Start_ITIidx)
        if (Start_ITIidx(i)+(srate{1}*TimeWin{1}))<(length(Transients)) && (Start_ITIidx(i)-(srate{1}*TimeWin{1}))>(0)                        
            CutTransients.Start_ITI_Transients{i} = Transients(1,[Start_ITIidx(1,i)-(srate{1}*TimeWin{1}):Start_ITIidx(1,i)+(srate{1}*TimeWin{1})]);
        end
    end
end
if sum(size(Stimulus)) >= 2 
    for i = 1:length(Stimulusidx)
        if (Stimulusidx(i)+(srate{1}*TimeWin{1}))<(length(Transients)) && (Stimulusidx(i)-(srate{1}*TimeWin{1}))>(0)                      
            CutTransients.Stimulus_Transients{i} = Transients(1,[Stimulusidx(1,i)-(srate{1}*TimeWin{1}):Stimulusidx(1,i)+(srate{1}*TimeWin{1})]);
        end
    end
end
if sum(size(Hit)) >= 2
    for i = 1:length(Hitidx)
        if (Hitidx(i)+(srate{1}*TimeWin{1}))<(length(Transients)) && (Hitidx(i)-(srate{1}*TimeWin{1}))>(0)                        
            CutTransients.Hit_Transients{i} = Transients(1,[Hitidx(1,i)-(srate{1}*TimeWin{1}):Hitidx(1,i)+(srate{1}*TimeWin{1})]);
        end
    end
end    
if sum(size(Miss)) >= 2
    for i = 1:length(Missidx)
        if (Missidx(i)+(srate{1}*TimeWin{1}))<(length(Transients)) && (Missidx(i)-(srate{1}*TimeWin{1}))>(0)               
            CutTransients.Miss_Transients{i} = Transients(1,[Missidx(1,i)-(srate{1}*TimeWin{1}):Missidx(1,i)+(srate{1}*TimeWin{1})]);
        end
    end
end
if sum(size(Correct_Rej)) >= 2
    for i = 1:length(Correct_Rejidx)
        if (Correct_Rejidx(i)+(srate{1}*TimeWin{1}))<(length(Transients)) && (Correct_Rejidx(i)-(srate{1}*TimeWin{1}))>(0)                      
            CutTransients.Correct_Rej_Transients{i} = Transients(1,[Correct_Rejidx(1,i)-(srate{1}*TimeWin{1}):Correct_Rejidx(1,i)+(srate{1}*TimeWin{1})]);
        end
    end
end
if sum(size(False_Alarm)) >= 2
    for i = 1:length(False_Alarmidx)
        if (False_Alarmidx(i)+(srate{1}*TimeWin{1}))<(length(Transients)) && (False_Alarmidx(i)-(srate{1}*TimeWin{1}))>(0)                     
            CutTransients.False_Alarm_Transients{i} = Transients(1,[False_Alarmidx(1,i)-(srate{1}*TimeWin{1}):False_Alarmidx(1,i)+(srate{1}*TimeWin{1})]);
        end
    end
end

%% Can save this structure of sliced transients as well or continue straight into script #3
cd(saveplace{1});
save(mousename{1}, '-struct', 'savename')

sprintf('Your new structure has been saved with in path ''%d'', with name ''%d''',saveplace{1},mousename{1})
end

