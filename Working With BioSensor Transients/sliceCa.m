function [varargout] = sliceCa;

%% Description
% Grab Calcium Transients surrounding event timestamps
% This function is written assuming the user has followed Ca2imaging 4 CPT 1, and
% has the mouse structure with event timestamps saved as a distinct
% variable, along with the calcium imaging,
% transients saved in a structure

% - Written by Suhaas S Adiraju

%% OUTPUTS 

% Single structure containing all neurons sliced transients based on event
% type

% OR (if 'dont save' option is selected)

% Each event-type sliced transients (same thing just not in single
% structure format)


prepans2 = questdlg('Have you already run CaImaging4CPT1, or have a matlab data structure containing both the behavioral timestamps and calcium transients?')
if strcmp(prepans2,'Yes') == 1
    % Purpose statement 
    waitfor(msgbox(sprintf('Welcome to CaImaging4CPT script 2: slice Ca!\n\nPurpose: Walk the user through defining the inputs necessary to run the functino slice Ca, made to slice calcium imaging transients from all cells, based on behavioral event timestamps, for user-defined windows of time-length\n\nINPUTS:-structure: the previously saved MATLAB data-structure generated from CaImaging4CPT 1.\n\n-srate: the sampling rate that the data was collected at so that we can match the resolutions of the behavioral-timestamps and the transients\n\n-(TimeWin / 2): user-defined window of time surrounding each event that you would like to slice transients of (i.e. 4 seconds time window =''s 2s befor a hit and 2s after\n\nOUTPUT:\n-CaImaging Mouse Structure: a user-named structure containing the sliced transients')))
    
    %% Define Required Variables 
    % Previously saved structure 
    waitfor(msgbox(sprintf('A file selector will pop up,\nThen select your previously saved structure from Ca2imaging_4CPT1')))
    [struc_name, struc_path] = uigetfile('','Select the path to your existing structure created from Ca2imaging_4CPT1')
    while (struc_name) == 0
        waitfor(warndlg('You did not properly select an lfp file. Please try again. Or if you would like to quit execution, hit stop button, found under editor tab'))
        [struc_name, struc_path] = uigetfile('','Please select the LFP + timestamps containing structure you already made')
    end
    
    %Sampling rate
            % waitfor(msgbox(sprintf('A window will pop up,\n Then enter WHAT IS THE SAMPLING RATE OF THE RECORDING (in Hz)')
            % pause
    sratePrompt = {'What is the sampling rate of the data? (Automatically in Hz)'}
    srate = inputdlg(sratePrompt)
        % srate = str2num(srateCell{1});
    while isempty(srate) == 1 
          waitfor(warndlg('Please enter the sampling rate, you left this empty. If you would like to quit this script, press stop button, found under the editor tab'))
          srate = inputdlg(prompt1) 
    end
    
    
    %Time Window
            %waitfor(msgbox(sprintf('A window will pop up,\n Then enter WHAT SIZE TIME WINDOWS WOULD YOU LIKE TO ASSESS (s)')))
    TimeWinPrompt = {'How many SECONDS BEFORE AND AFTER each event would you like to take? (ie ans of 10 will take 10s before and after each event =''ing 20s'}
    TimeWin = inputdlg(TimeWinPrompt)
    while isempty(TimeWin{1})== 1 
          waitfor(warndlg('Please enter the time-window, you left this empty. If you would like to quit this script, press stop button, at the top of MATLAB, found under the editor tab'))
          TimeWin = inputdlg(prompt1) 
    end
    
    
    %mousename or name to save resulting structure
    mousename = append(struc_name, '_sliced');

    
    % saveplace; where you want to save resulting structure 
    waitfor(msgbox(sprintf('A file selector will pop up,\nThen select\nWHERE YOU WOULD LIKE TO SAVE YOUR RESULTING STRUCTURE (what folder would you like to save it in)?')))
    [saveplace] = uigetdir('','What folder would you like to save your output structure in?')
    while (saveplace) == 0 
          waitfor(warndlg('Please choose a folder, you left this empty. If you would like to quit this script, press stop button, at the top of MATLAB, found under the editor tab'))
          [saveplace] = uigetdir('','What folder would you like to save your output structure in?')
    end
    
    
    elseif strcmp(prepans2,'Yes') == 0
        waitfor(warndlg('You must have a previously saved MATLAB data structure containing timestamps and transients to successfully run this script'))
    end
 

%% Load
% cd to location of of the structure
cd(struc_path); 

% load file of choice
load (struc_name);

srate = str2num(srate{1});
TimeWin = str2num(TimeWin{1});

%% Trimming our signal (optional)

% Set transients on the proper timescale, ("give me a vector of 0-total
% seconds in value, but with a length of the total # of samples in the original matrix")
Transients_TimeVec = linspace(0, (length(Transients{1})/(srate)), (length(Transients{1})));

% you can see right away that the transients length is too long, and we
% know the cpt schedule is only 1800s (30min), and we know that our
% 0seconds in the signal is true zero of the cpt task cause we use a TTL
% so we can trim the transients signal to the length of the cpt

cpt_length = Transients_TimeVec(Transients_TimeVec <= 2700);
for z = 1:length(Transients)
    cpt_transients{z} = Transients{z}(:,1:(length(cpt_length)));
end

%% Equalizing Resolutions


% First, we must up-sample, to match the scale(resolution) at which we have Transients
% i.e. event timestamps 

FIRBeam_Onidx = FIRBeam_On * srate; 
% FIRBeam_Onidx =int64(FIRBeam_Onidx);


FIRBeam_Offidx = FIRBeam_Off * srate; 
% FIRBeam_Offidx = int64(FIRBeam_Offidx);

Center_ScTouchidx = Center_ScTouch * srate; 
% Center_ScTouchidx = int64(Center_ScTouchidx);

Start_ITIidx =Start_ITI * srate; 
% Start_ITIidx = int64(Start_ITIidx);

Stimulusidx = Stimulus * srate; 
% Stimulusidx = int64(Stimulusidx);

Hitidx = Hit * srate; 
% Hitidx = int64(Hitidx);

Missidx = Miss * srate; 
% Missidx = int64(Missidx);

Correct_Rejidx =Correct_Rej * srate; 
% Correct_Rejidx = int64(Correct_Rejidx);

False_Alarmidx = False_Alarm * srate; 
% False_Alarmidx = int64(False_Alarmidx);

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
if sum(size(FIRBeam_On)) >= 2 
    for i = 1:length(FIRBeam_Onidx)
        for numcell = 1:length(cpt_transients)
            if (FIRBeam_Onidx(i)+(srate*TimeWin))<(length(cpt_transients{numcell})) && (FIRBeam_Onidx(i)-(srate*TimeWin))>(0)  
                CutTransients.FIRBeam_On_Transients{numcell,i} = cpt_transients{numcell}(:,FIRBeam_Onidx(1,i)-(srate*TimeWin):FIRBeam_Onidx(1,i)+(srate*TimeWin));
            end
        end
    end
end

if sum(size(FIRBeam_Off)) >= 2 
    for i = 1:(length(FIRBeam_Offidx))
       for numcell = 1:length(cpt_transients) 
            if (FIRBeam_Offidx(i)+(srate*TimeWin))<(length(cpt_transients{numcell})) && (FIRBeam_Offidx(i)-(srate*TimeWin))>(0)        
                CutTransients.FIRBeam_Off_Transients{numcell,i} = cpt_transients{numcell}(:,FIRBeam_Offidx(1,i)-(srate*TimeWin):FIRBeam_Offidx(1,i)+(srate*TimeWin));
            end
       end
    end
end

if sum(size(Center_ScTouch)) >= 2 
    for i = 1:length(Center_ScTouchidx)
        for numcell = 1:length(cpt_transients)
            if (Center_ScTouchidx(i)+(srate*TimeWin))<(length(cpt_transients{numcell})) && (Center_ScTouchidx(i)-(srate*TimeWin))>(0)              
                CutTransients.Center_ScTouch_Transients{numcell,i} = cpt_transients{numcell}(:,Center_ScTouchidx(1,i)-(srate*TimeWin):Center_ScTouchidx(1,i)+(srate*TimeWin));
            end
        end
    end
end

if sum(size(Start_ITI)) >= 2 
    for i = 1:length(Start_ITIidx)
        for numcell = 1:length(cpt_transients)
            if (Start_ITIidx(i)+(srate*TimeWin))<(length(cpt_transients{numcell})) && (Start_ITIidx(i)-(srate*TimeWin))>(0)                        
                CutTransients.Start_ITI_Transients{numcell,i} = cpt_transients{numcell}(:,Start_ITIidx(1,i)-(srate*TimeWin):Start_ITIidx(1,i)+(srate*TimeWin));
            end
        end
    end
end

if sum(size(Stimulus)) >= 2 
    for i = 1:length(Stimulusidx)
        for numcell = 1:length(cpt_transients)
            if (Stimulusidx(i)+(srate*TimeWin))<(length(cpt_transients{numcell})) && (Stimulusidx(i)-(srate*TimeWin))>(0)                      
                CutTransients.Stimulus_Transients{numcell,i} = cpt_transients{numcell}(:,Stimulusidx(1,i)-(srate*TimeWin):Stimulusidx(1,i)+(srate*TimeWin));
            end
        end
    end
end

if sum(size(Hit)) >= 2
    for i = 1:length(Hitidx)
        for numcell = 1:length(cpt_transients)
            if (Hitidx(i)+(srate*TimeWin))<(length(cpt_transients{numcell})) && (Hitidx(i)-(srate*TimeWin))>(0)                        
                CutTransients.Hit_Transients{numcell,i} = cpt_transients{numcell}(:,Hitidx(1,i)-(srate*TimeWin):Hitidx(1,i)+(srate*TimeWin));
            end
        end
    end
end   

if sum(size(Miss)) >= 2
    for i = 1:length(Missidx)
        for numcell = 1:length(cpt_transients)
            if (Missidx(i)+(srate*TimeWin))<(length(cpt_transients{numcell})) && (Missidx(i)-(srate*TimeWin))>(0)               
                CutTransients.Miss_Transients{numcell,i} = cpt_transients{numcell}(:,Missidx(1,i)-(srate*TimeWin):Missidx(1,i)+(srate*TimeWin));
            end
        end
    end
end

if sum(size(Correct_Rej)) >= 2
    for i = 1:length(Correct_Rejidx)
        for numcell = 1:length(cpt_transients)
            if (Correct_Rejidx(i)+(srate*TimeWin))<(length(cpt_transients{numcell})) && (Correct_Rejidx(i)-(srate*TimeWin))>(0)                      
                CutTransients.Correct_Rej_Transients{numcell,i} = cpt_transients{numcell}(:,Correct_Rejidx(1,i)-(srate*TimeWin):Correct_Rejidx(1,i)+(srate*TimeWin));
            end
        end
    end
end

if sum(size(False_Alarm)) >= 2
    for i = 1:length(False_Alarmidx)
        for numcell = 1:length(cpt_transients)
            if (False_Alarmidx(i)+(srate*TimeWin))<(length(cpt_transients{numcell})) && (False_Alarmidx(i)-(srate*TimeWin))>(0)                     
                CutTransients.False_Alarm_Transients{numcell,i} = cpt_transients{numcell}(:,False_Alarmidx(1,i)-(srate*TimeWin):False_Alarmidx(1,i)+(srate*TimeWin));
            end
        end
    end
end

%% check if the structures are empty
if isempty(FIRBeam_On) == 1
    FIRBeam_On_emptycheck = cellfun(@isempty,CutTransients.FIRBeam_On_Transients);
    CutTransients.FIRBeam_On_Transients    = CutTransients.FIRBeam_On_Transients(:,FIRBeam_On_emptycheck(1,:)==0);
end

if isempty('CutTransients.FIRBeam_Off_Transients') == 1
    FIRBeam_Off_emptycheck = cellfun('isempty',CutTransients.FIRBeam_Off_Transients);
    CutTransients.FIRBeam_Off_Transients   = CutTransients.FIRBeam_Off_Transients(:,FIRBeam_Off_emptycheck(1,:)==0);
end

if isempty('CutTransients.Center_ScTouch_Transients') == 1
    Center_ScTouch_emptycheck = cellfun('isempty',CutTransients.Center_ScTouch_Transients);
    CutTransients.Center_ScTouch_Transients     = CutTransients.Center_ScTouch_Transients(:,Center_ScTouch_emptycheck(1,:)==0);

end

if isempty('CutTransients.Start_ITI_Transients') == 1
    Start_ITI_emptycheck = cellfun('isempty',CutTransients.Start_ITI_Transients);
    CutTransients.Start_ITI_Transients     = CutTransients.Start_ITI_Transients(:,Start_ITI_emptycheck(1,:)==0);
end

if isempty('CutTransients.Stimulus_Transients') == 1
    Stimulus_emptycheck = cellfun('isempty',CutTransients.Stimulus_Transients);
    CutTransients.Stimulus_Transients      = CutTransients.Stimulus_Transients(:,Stimulus_emptycheck(1,:)==0);

end

if isempty('CutTransients.Hit_Transients') == 1
    Hit_emptycheck = cellfun('isempty',CutTransients.Hit_Transients);
    CutTransients.Hit_Transients           = CutTransients.Hit_Transients(:,Hit_emptycheck(1,:)==0);
end


if isempty('CutTransients.Miss_Transients') == 1
    Miss_emptycheck = cellfun('isempty',CutTransients.Miss_Transients);
    CutTransients.Miss_Transients          = CutTransients.Miss_Transients(:,Miss_emptycheck(1,:)==0);

end

if isempty('CutTransients.Correct_Rej_Transients') == 1
    Correct_Rej_emptycheck = cellfun('isempty',CutTransients.Correct_Rej_Transients);
    CutTransients.Correct_Rej_Transients   = CutTransients.Correct_Rej_Transients(:,Correct_Rej_emptycheck(1,:)==0);

end

if isempty('CutTransients.False_Alarm_Transients') == 1
    False_Alarm_emptycheck = cellfun('isempty',CutTransients.False_Alarm_Transients);
    CutTransients.False_Alarm_Transients   = CutTransients.False_Alarm_Transients(:,False_Alarm_emptycheck(1,:)==0);

end



CutTransients.srate = srate;
CutTransients.TimeWin = TimeWin;
CutTransients.Transients = Transients;

waitfor(msgbox(sprintf('Transients have been sliced according to event-timestamps!')))
%% Sanity Checks 
    sanitychecks = questdlg(sprintf('We can perform some sanity checks now to verify that our extractions were successful\n\nBasically we''ll test random extracted values to see if they correctly match-up to the ground-truth data set (where they are coming from)\n\nWould you like to do a sanity check?'))
        % lets do it with the variable 'Hits', so we have Hit timestamps,
        % then an index of timestamps 'Hitidx' which is scaled in
        % resolution to our recording. To avoid any possible bias, we can
        % say
    while strcmp(sanitychecks,'Yes') == 1
%         while strcmp(sanitychecks,"Yes") == 1
            HitTest = (randi(length(Hit),[1 1]))
            HitCheck = Hit(1,HitTest)
            HitidxOg = Hitidx(1,HitTest)
            HitidxCheck = Hitidx(1,HitTest)/srate
           waitfor(msgbox(sprintf('Sanity Check 1:\nTaking a random number timestamp from our original Hits timestamps log;\n\nTimestamp #: %d\nTimestamp-value: %d .\n\nAnd comparing this by grabbing the same timestamp # in our created Hits index (scaled to match the resolution of our sampling rate of %d, or *30):\nHitidx(%d) = %d / srate(%d) = %d.\n\nThis was a randomized test, so we can have considereable confidence in the entire index\n',HitTest,HitCheck,srate,HitTest,HitidxOg,srate,HitidxCheck)))
           sanitychecks = questdlg(sprintf('Would you like to perform another round of this sanity check test?'))
    end
    
%% Save work
% you can resave the enitre 'CutTransients' structure, or individual
% variables of desire or whatever...


 cd(saveplace);
 mousename = erase(mousename,'.mat');
 %assignin('base',mousename,CutTransients);
 save(mousename,'-struct', 'CutTransients');
 waitfor(msgbox(sprintf('Your new structure has been saved in \nPath: ''%s'',\nName ''%s''\nIt is also stored in the Workspace to your right for assessment/use',saveplace,mousename)))
 


%% Vars display?
vardisplay = questdlg('Would you like to evaluate the variable created?')
    if strcmp(vardisplay,'Yes') == 1 
        waitfor(msgbox(sprintf('When you are finished evaluating the variable\nCLICK INTO THE COMMAND WINDOW (bottom of MATLAB)\n then type in ''dbcont''')))
        openvar('CutTransients')
        sprintf('\n\nTYPE ''dbcont'' BELOW HERE')
        keyboard;
    elseif strcmp(vardisplay,'Yes') == 0
    end

%% Preliminary Plotting 
    plotprompt = (sprintf('Would you like to do some preliminary plotting of what you just made?\n\nWARNING: THIS WILL BE A PLOT OF EACH NEURONS'' ACTIVITY, SO USE WISELY\n\nAlso, if you would like to refer back to any of these figures, save them while they are on the screen so you dont have to rerun this script'))
    plotans = questdlg(plotprompt);
      % This plot is pointless  
     
if strcmp(plotans,'Yes') == 1
        %{
        len = size (Transients);
        % FULL-TIME ACTIVITY PROFILE FOR EVERY CELL 
        for z = 1:(len(1,2))
            figure; box off
            plot(cpt_length, (cell2mat(cpt_transients{z}(:,:))), 'Color',[0.75, 0, 0.75])
            set(gca,'visible','off')
            set(gca,'xtick',[])
            title (sprintf('Cell %d ''s Trace during rCPT', z));
            xlabel('Time (s)')
        end
        %}
        

    Timevector = linspace(0,length(Transients{z})/srate,(length(Transients{z})));
    % Plot Full trace 
    for z = 1:length(Transients)
        F = figure;
        plot(Timevector,(cell2mat(Transients{z})),"Color",[0.75, 0, 0.75],'LineWidth',1)
        title(sprintf('Cell: %d Full Session Trace',z))
        xlabel('Time (s)')
        ylabel('dF/F')
        uiwait(Figure)
    end
end





