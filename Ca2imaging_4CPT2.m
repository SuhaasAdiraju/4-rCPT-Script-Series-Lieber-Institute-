%% Grab Calcium Transients surrounding event timestamps
% This script is written assuming the user has followed Ca2imaging 4 CPT 1, and
% has the mouse structure with event timestamps saved as a distinct
% variable, along with the calcium imaging,
% transients saved in a structure

% - Written by Suhaas S Adiraju

%%
% cd to location of of the structure
cd('Z:\Circuits projects (CPT)\CPT Recording Data\GCaMP6f'); %('yourpath')

% load file of choice
load ("S3Good_1855_Ca2.mat")
% Transients = Transients';

%% Trimming our signal (optional)


% What's your sampling rate
srate = 30.0136; % in the future this should always be 30 

% Set transients on the proper timescale, ("give me a vector of 0-total
% seconds in value, but with a length of the total # of samples in the original matrix")
Transients_TimeVec = linspace(0, ((length(Transients{1}))/srate), (length(Transients{1})));

% you can see right away that the transients length is too long, and we
% know the cpt schedule is only 1800s (30min), and we know that our
% 0seconds in the signal is true zero of the cpt task cause we use a TTL
% so we can trim the transients signal to the length of the cpt
cpt_length = Transients_TimeVec(Transients_TimeVec <= 1800);
for z = 1:length(Transients)
    cpt_transients{z} = Transients{z}(:,[1:(length(cpt_length))]);
end


%% Identify saving variables 

mousename = 'S3Good_1855_Ca2' %name of mouse/what you want to save the struc. as, must start w a letter;
saveplace = 'Z:\Circuits projects (CPT)\CPT Recording Data\GCaMP6f'; %where are you saving your data

%% Equalizing Resolutions


% First, we must up-sample, to match the scale(resolution) at which we have Transients
% i.e. event timestamps 
FIRBeam_Onidx = FIRBeam_On * srate; 
FIRBeam_Onidx =int64(FIRBeam_Onidx); % here im converting the class of the IDX values because as a double certain vals were not integers (ie 10385.00000 became 1.0385x10e6)
% Test: Transients(FIRBeam_Onidx);


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

%% Now we can grab the Transients of each timestamp

% EXPLAIN // SANITY CHECKS // CHANGE THE REST
% Okay so we know wanna grab our transients based on the timestamp,
% assessing our variables to do so, we have 
% 
% 'Event Name'idx: the correct resolution vector of timestamps for the given event

%  cpt_transients: taken from our original transients cell array,
%                  cpt_transients is a cell array, with each cell
%                  corresponding to each neuron (in example 68 accepted
%                  neurons), and now adjusted/trimmed to the length of the
%                  CPT schedule (1800seconds). 

% What we will do is loop through each event name timestamp, and each
% neuron cell array, and pull x seconds of transient before the event
% timestamp, and x seconds of transient after the event timestamp
    % I added some additional things to avoid errors, i.e. "only if the size of
    % the vector of timestamps is empty execute" and "only if you can
    % logically subtract X seconds from the first timestamp or logically
    % add X seconds to the last timestamp" 
timewin = cpt_transients{1,1}(:,:)
if sum(size(FIRBeam_On)) >= 2 
    for i = 1:length(FIRBeam_Onidx)
        for numcell = 1:length(cpt_transients)
            if (FIRBeam_Onidx(i)+(srate*4))<(length(cpt_transients{numcell})) && (FIRBeam_Onidx(i)-(srate*4))>(0)  
                CutTransients.FIRBeam_On_Transients{numcell,i} = cpt_transients{numcell}(:,[FIRBeam_Onidx(1,i)-(srate*4):FIRBeam_Onidx(1,i)+(srate*4)]);
            end
        end
    end
end

if sum(size(FIRBeam_Off)) >= 2 
    for i = 1:(length(FIRBeam_Offidx))
       for numcell = 1:length(cpt_transients) 
            if (FIRBeam_Offidx(i)+(srate*4))<(length(cpt_transients{numcell})) && (FIRBeam_Offidx(i)-(srate*4))>(0)        
                CutTransients.FIRBeam_Off_Transients{numcell,i} = cpt_transients{numcell}(:,[FIRBeam_Offidx(1,i)-(srate*4):FIRBeam_Offidx(1,i)+(srate*4)]);
            end
       end
    end
end

if sum(size(Center_ScTouch)) >= 2 
    for i = 1:length(Center_ScTouchidx)
        for numcell = 1:length(cpt_transients)
            if (Center_ScTouchidx(i)+(srate*4))<(length(cpt_transients{numcell})) && (Center_ScTouchidx(i)-(srate*4))>(0)              
                CutTransients.Center_ScTouch_Transients{numcell,i} = cpt_transients{numcell}(:,[Center_ScTouchidx(1,i)-(srate*4):Center_ScTouchidx(1,i)+(srate*4)]);
            end
        end
    end
end

if sum(size(Start_ITI)) >= 2 
    for i = 1:length(Start_ITIidx)
        for numcell = 1:length(cpt_transients)
            if (Start_ITIidx(i)+(srate*4))<(length(cpt_transients{numcell})) && (Start_ITIidx(i)-(srate*4))>(0)                        
                CutTransients.Start_ITI_Transients{numcell,i} = cpt_transients{numcell}(:,[Start_ITIidx(1,i)-(srate*4):Start_ITIidx(1,i)+(srate*4)]);
            end
        end
    end
end
if sum(size(Stimulus)) >= 2 
    for i = 1:length(Stimulusidx)
        for numcell = 1:length(cpt_transients)
            if (Stimulusidx(i)+(srate*4))<(length(cpt_transients{numcell})) && (Stimulusidx(i)-(srate*4))>(0)                      
                CutTransients.Stimulus_Transients{numcell,i} = cpt_transients{numcell}(:,[Stimulusidx(1,i)-(srate*4):Stimulusidx(1,i)+(srate*4)]);
            end
        end
    end
end
if sum(size(Hit)) >= 2
    for i = 1:length(Hitidx)
        for numcell = 1:length(cpt_transients)
            if (Hitidx(i)+(srate*4))<(length(cpt_transients{numcell})) && (Hitidx(i)-(srate*4))>(0)                        
                CutTransients.Hit_Transients{numcell,i} = cpt_transients{numcell}(:,[Hitidx(1,i)-(srate*4):Hitidx(1,i)+(srate*4)]);
            end
        end
    end
end    
if sum(size(Miss)) >= 2
    for i = 1:length(Missidx)
        for numcell = 1:length(cpt_transients)
            if (Missidx(i)+(srate*4))<(length(cpt_transients{numcell})) && (Missidx(i)-(srate*4))>(0)               
                CutTransients.Miss_Transients{numcell,i} = cpt_transients{numcell}(:,[Missidx(1,i)-(srate*4):Missidx(1,i)+(srate*4)]);
            end
        end
    end
end
if sum(size(Correct_Rej)) >= 2
    for i = 1:length(Correct_Rejidx)
        for numcell = 1:length(cpt_transients)
            if (Correct_Rejidx(i)+(srate*4))<(length(cpt_transients{numcell})) && (Correct_Rejidx(i)-(srate*4))>(0)                      
                CutTransients.Correct_Rej_Transients{numcell,i} = cpt_transients{numcell}(:,[Correct_Rejidx(1,i)-(srate*4):Correct_Rejidx(1,i)+(srate*4)]);
            end
        end
    end
end
if sum(size(False_Alarm)) >= 2
    for i = 1:length(False_Alarmidx)
        for numcell = 1:length(cpt_transients)
            if (False_Alarmidx(i)+(srate*4))<(length(cpt_transients{numcell})) && (False_Alarmidx(i)-(srate*4))>(0)                     
                CutTransients.False_Alarm_Transients{numcell,i} = cpt_transients{numcell}(:,[False_Alarmidx(1,i)-(srate*4):False_Alarmidx(1,i)+(srate*4)]);
            end
        end
    end
end

%% Save work
% you can resave the enitre 'CutTransients' structure, or individual
% variables of desire or whatever...

% The whole structure
cd(saveplace);
save(mousename,'-struct', 'CutTransients');

%% Some old plotting;
%{
len = size (Transients);
for z = 1:(len(1,1))
    figure; box off
    plot(cpt_length, cpt_transients(z, :), 'Color',[0.75, 0, 0.75])
    set(gca,'visible','off')
    set(gca,'xtick',[])
    title (sprintf('Cell %d ''s Trace during rCPT', z));
    xlabel('Time (s)')
end

% plot transients surrounding first hit 
hitlength = linspace(-((length(CutTransients.Hit_Transients{1})/srate)),(length(CutTransients.Hit_Transients{1})/srate),length(CutTransients.Hit_Transients{1}));

for z = 1:length(CutTransients.Hit_Transients)
    figure;
    plot(hitlength, CutTransients.Hit_Transients{z},'Color',[0.75, 0, 0.75], 'LineWidth',1.5)
    xlabel('Time(s)')
    ylabel('dF/F')
    xlim ([-4 4])
    ylim([-10 50])
end
%}
