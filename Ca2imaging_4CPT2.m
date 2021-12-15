
%% Description

% Grab Calcium Transients surrounding event timestamps
% This function is written assuming the user has followed Ca2imaging 4 CPT 1, and
% has the mouse structure with event timestamps saved as a distinct
% variable, along with the calcium imaging,
% transients saved in a structure

% - Written by Suhaas S Adiraju

%% INPUTS 

% Format for ALL INPUTS: {''};

% struc_path - 
    % path to your premade structure with event timestamps and cell
    % transients 


% struc_name - 
    % name of the structure

% srate - 
    % sampling rate of data collected 

% TimeWin - 
    % desired window of time for slices ie 2 seconds surrounding hit, or 4
    % seconds surrounding hit

%% OUTPUTS 
% Single structure containing all neurons sliced transients based on event
% type

% OR (if 'dont save' option is selected)

% Each event-type sliced transients (same thing just not in single
% structure format)
%%
% cd to location of of the structure
cd(struc_path{1}); 

% load file of choice
load (struc_name{1})


%% Trimming our signal (optional)

% Set transients on the proper timescale, ("give me a vector of 0-total
% seconds in value, but with a length of the total # of samples in the original matrix")
Transients_TimeVec = linspace(0, ((length(Transients{1}))/srate{1}), (length(Transients{1})));

% you can see right away that the transients length is too long, and we
% know the cpt schedule is only 1800s (30min), and we know that our
% 0seconds in the signal is true zero of the cpt task cause we use a TTL
% so we can trim the transients signal to the length of the cpt

cpt_length = Transients_TimeVec(Transients_TimeVec <= 1800);
for z = 1:length(Transients)
    cpt_transients{z} = Transients{z}(:,[1:(length(cpt_length))]);
end

%% Equalizing Resolutions


% First, we must up-sample, to match the scale(resolution) at which we have Transients
% i.e. event timestamps 
FIRBeam_Onidx = FIRBeam_On * srate{1}; 
FIRBeam_Onidx =int64(FIRBeam_Onidx); % here im converting the class of the IDX values because as a double certain vals were not integers (ie 10385.00000 became 1.0385x10e6)
% Test: Transients(FIRBeam_Onidx);


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
struc_name
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
if sum(size(FIRBeam_On)) >= 2 
    for i = 1:length(FIRBeam_Onidx)
        for numcell = 1:length(cpt_transients)
            if (FIRBeam_Onidx(i)+(srate{1}*TimeWin{1}))<(length(cpt_transients{numcell})) && (FIRBeam_Onidx(i)-(srate{1}*TimeWin{1}))>(0)  
                CutTransients.FIRBeam_On_Transients{numcell,i} = cpt_transients{numcell}(:,[FIRBeam_Onidx(1,i)-(srate{1}*TimeWin{1}):FIRBeam_Onidx(1,i)+(srate{1}*TimeWin{1})]);
            end
        end
    end
end

if sum(size(FIRBeam_Off)) >= 2 
    for i = 1:(length(FIRBeam_Offidx))
       for numcell = 1:length(cpt_transients) 
            if (FIRBeam_Offidx(i)+(srate{1}*TimeWin{1}))<(length(cpt_transients{numcell})) && (FIRBeam_Offidx(i)-(srate{1}*TimeWin{1}))>(0)        
                CutTransients.FIRBeam_Off_Transients{numcell,i} = cpt_transients{numcell}(:,[FIRBeam_Offidx(1,i)-(srate{1}*TimeWin{1}):FIRBeam_Offidx(1,i)+(srate{1}*TimeWin{1})]);
            end
       end
    end
end

if sum(size(Center_ScTouch)) >= 2 
    for i = 1:length(Center_ScTouchidx)
        for numcell = 1:length(cpt_transients)
            if (Center_ScTouchidx(i)+(srate{1}*TimeWin{1}))<(length(cpt_transients{numcell})) && (Center_ScTouchidx(i)-(srate{1}*TimeWin{1}))>(0)              
                CutTransients.Center_ScTouch_Transients{numcell,i} = cpt_transients{numcell}(:,[Center_ScTouchidx(1,i)-(srate{1}*TimeWin{1}):Center_ScTouchidx(1,i)+(srate{1}*TimeWin{1})]);
            end
        end
    end
end

if sum(size(Start_ITI)) >= 2 
    for i = 1:length(Start_ITIidx)
        for numcell = 1:length(cpt_transients)
            if (Start_ITIidx(i)+(srate{1}*TimeWin{1}))<(length(cpt_transients{numcell})) && (Start_ITIidx(i)-(srate{1}*TimeWin{1}))>(0)                        
                CutTransients.Start_ITI_Transients{numcell,i} = cpt_transients{numcell}(:,[Start_ITIidx(1,i)-(srate{1}*TimeWin{1}):Start_ITIidx(1,i)+(srate{1}*TimeWin{1})]);
            end
        end
    end
end
if sum(size(Stimulus)) >= 2 
    for i = 1:length(Stimulusidx)
        for numcell = 1:length(cpt_transients)
            if (Stimulusidx(i)+(srate{1}*TimeWin{1}))<(length(cpt_transients{numcell})) && (Stimulusidx(i)-(srate{1}*TimeWin{1}))>(0)                      
                CutTransients.Stimulus_Transients{numcell,i} = cpt_transients{numcell}(:,[Stimulusidx(1,i)-(srate{1}*TimeWin{1}):Stimulusidx(1,i)+(srate{1}*TimeWin{1})]);
            end
        end
    end
end
if sum(size(Hit)) >= 2
    for i = 1:length(Hitidx)
        for numcell = 1:length(cpt_transients)
            if (Hitidx(i)+(srate{1}*TimeWin{1}))<(length(cpt_transients{numcell})) && (Hitidx(i)-(srate{1}*TimeWin{1}))>(0)                        
                CutTransients.Hit_Transients{numcell,i} = cpt_transients{numcell}(:,[Hitidx(1,i)-(srate{1}*TimeWin{1}):Hitidx(1,i)+(srate{1}*TimeWin{1})]);
            end
        end
    end
end    
if sum(size(Miss)) >= 2
    for i = 1:length(Missidx)
        for numcell = 1:length(cpt_transients)
            if (Missidx(i)+(srate{1}*TimeWin{1}))<(length(cpt_transients{numcell})) && (Missidx(i)-(srate{1}*TimeWin{1}))>(0)               
                CutTransients.Miss_Transients{numcell,i} = cpt_transients{numcell}(:,[Missidx(1,i)-(srate{1}*TimeWin{1}):Missidx(1,i)+(srate{1}*TimeWin{1})]);
            end
        end
    end
end
if sum(size(Correct_Rej)) >= 2
    for i = 1:length(Correct_Rejidx)
        for numcell = 1:length(cpt_transients)
            if (Correct_Rejidx(i)+(srate{1}*TimeWin{1}))<(length(cpt_transients{numcell})) && (Correct_Rejidx(i)-(srate{1}*TimeWin{1}))>(0)                      
                CutTransients.Correct_Rej_Transients{numcell,i} = cpt_transients{numcell}(:,[Correct_Rejidx(1,i)-(srate{1}*TimeWin{1}):Correct_Rejidx(1,i)+(srate{1}*TimeWin{1})]);
            end
        end
    end
end
if sum(size(False_Alarm)) >= 2
    for i = 1:length(False_Alarmidx)
        for numcell = 1:length(cpt_transients)
            if (False_Alarmidx(i)+(srate{1}*TimeWin{1}))<(length(cpt_transients{numcell})) && (False_Alarmidx(i)-(srate{1}*TimeWin{1}))>(0)                     
                CutTransients.False_Alarm_Transients{numcell,i} = cpt_transients{numcell}(:,[False_Alarmidx(1,i)-(srate{1}*TimeWin{1}):False_Alarmidx(1,i)+(srate{1}*TimeWin{1})]);
            end
        end
    end
end


%% Save work
% you can resave the enitre 'CutTransients' structure, or individual
% variables of desire or whatever...

% The whole structure
x = input('If you would like to save the sliced transients structure, you may, but it will take a while most likely,\nand will be quite hefty to load in.\n\nYou can also take the outputs of the function, and move forward with your processing analysis, \nwithout saving this step \n\nIf you would like to save the whole thing indicate so using ''1''\nIf you would like to move forward with output data instead of saving right now indicate ''2''');

if x == 1
 cd(saveplace{1});
 save(mousename{1},'-struct', 'CutTransients');
elseif x == 2
end
end

%% Some plotting for fun;

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
