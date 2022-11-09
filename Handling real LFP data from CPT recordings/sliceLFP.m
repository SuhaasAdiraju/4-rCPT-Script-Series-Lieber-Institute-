function sliceLFP
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

% srate - 
    % the sampling rate of the LFP recording (typically 2000Hz or
    % samples/second), but good practice to continuously define

% TimeWin - 
    % the window around each event desired, i.e. 4 seconds of lfp around
    % every hit...

%% OUTPUTS

% structure containing user defined time-window of sliced LFP signal based
% on event-type behavioral timestamps, for each channel of the Ephys
% headstage (ground, reference, brain region 1, brain region 2)



%% Define all necessary inputs
clearvars -except stage; clc;
ansmain = questdlg('Have you run LFP4CPT 2 and created/saved an LFP structure with associated timestamps?')
if strcmp(ansmain, 'No') == 1
    warndlg('You will not be able to run this script or the function without the structure resulting from the previous section! Sorry, go back and run ''LFP4CPT2_createStructLFP''')
    error('Issue encountered please rerun script')
elseif strcmp(ansmain, 'Yes') == 1

waitfor(msgbox(sprintf('Welcome to LFP 4 CPT data series script 3 (sliceLFP)!\n\n\nPURPOSE:\nSlice user-defined size windows (seconds surrounding) of the raw LFP data, at each behavioral event timestamp for all event-types.\n\nINPUTS:\n-struc_path & _name: User-selected file containing raw LFP and event timestamps.\n\n-srate: User-defined sampling rate of the data collected\n\n-TimeWin: User-defined time-window (how many seconds of LFP surrounding each event would you like to take?)\n\n-mousename: User-defined name for new structure\n\n-saveplace: User-selected folder to save the resulting structure\n\n\nOUTPUTS:\n-mouse_struc: User-named, new structure containing sliced windows of LFP for every event-type and timestamp')));
                                    
    % lfp_path
    waitfor(msgbox({'A file selector will pop up';' ';'Then select the the path to your existing LFP + timestamps structure'}))
    
    [struc_name, struc_path] = uigetfile
    while (struc_name) == 0
        waitfor(warndlg('You did not properly select an lfp file. Please try again. Or if you would like to quit execution, hit stop button, found under editor tab'))
        [struc_name, struc_path] = uigetfile('','Please select the LFP + timestamps containing structure you already made')
    end


    
    % srate{1} 
    prompt1 = {'What sampling rate was this data collected at (input in Hz automatically)'}
    srate = inputdlg(prompt1) 
    while isempty(srate) == 1 
          waitfor(warndlg('Please enter the sampling rate, you left this empty. If you would like to quit this script, press stop button, found under the editor tab'))
          srate = inputdlg(prompt1) 
    end

    % TimeWin 
    prompt2 = {'What size window would you like to slice of the LFP data (size in total seconds surrounding)';' ';'i.e. Input: 4, would be 2 seconds before and after each event'}
    TimeWin = inputdlg(sprintf('What size window would you like to slice of the LFP data\n(size in total seconds surrounding)\n\ni.e. Input: 4, would be 2 seconds before and after each event\n'))
    while isempty(TimeWin{1}) == 1
          waitfor(warndlg('Please enter the time window you would like to assess, you left this empty. If you would like to quit this script, press stop button, found under the editor tab'))
          TimeWin = inputdlg(sprintf('What size window would you like to slice of the LFP data\n(size in total seconds surrounding)\n\ni.e. Input: 4, would be 2 seconds before and after each event\n'))
    end
    
    % saveplace
    waitfor(msgbox(sprintf('A file selector will pop up,\nThen select the the path YOU WOULD LIKE TO SAVE YOUR OUTPUT STRUCTURE')))
    saveplace = uigetdir ('','Please select the folder in which you would like to save your resulting structure')
    while (saveplace) == 0 
            % error('You did not properly select an place to save. Please try again')
            waitfor(warndlg('You did not properly select an place to save. Please try again. Or if you are trying to quit the script, press Stop, in the editor tab of MATLAB'))
            saveplace = uigetdir('','Please select the folder in which you would like to save your resulting structure')
    end
    
    % mousename:
        %prompt3 = {'Enter the identifying number of this mouse *ONE-WORD*'}
    mousename = erase(struc_name,'.mat');
    mousename = append(mousename,'_',(num2str(TimeWin{1})),'s','_sliced')
        while isempty(mousename) == 1
            waitfor(warndlg('You did not enter a name for your output structure. Please try again. Or if you are trying to quit the script, press Stop, in the editor tab of MATLAB'))
            mousename = inputdlg(prompt3)
        end


   waitfor(msgbox(sprintf('All necessary inputs recieved! Hit OK to run sliceLFP function!')))
    

%% Load-in

%pathway to your folder with full structures, ('yourpath')
% path2struc = 'Z:\Circuits projects (CPT)\CPT Recording Data\LC-mPFC LFP';

%'change directory' to this path
cd(struc_path); 

% define then load desired data structure 
    %filename = 'S3GOOD_1328_S';
load(struc_name);
srate = str2num(srate{1});
TimeWin = str2num(TimeWin{1})

%% Setting Time

% if the following steps *conceptually* confuse you, refer to 
% (Z:\Circuits projects (CPT)\Working With LFP\Signal-processing basics with sample data)
% then the script 'LFPPracticeScript_SignalProcessing1_FirstStepsAndSettingTime'

% define sampling rate (2000samples/second (Hz))
    %srate = 2000;


% get total time, by dividing length of lfp file (which is in samples) by sampling rate... 
timeEeg = (length(lfp))/(srate); % total time in seconds 

% give me a vector containing 0-->total time, scaled to the size
% of the original LFP file; and this will be your time axis that you plot on 
% run 'open linspace' if still confused 
EEGtimevec = linspace(0, timeEeg, (length(lfp))); 

% Sanity Checks 
% Let's do sanity checks to avoid errors cause errors suck
    % So EEG time vec, is a vector which the end value of should be equal
    % to the length of lfp divided by the srate
        % we already calculated that 
   sanitycheck1 = questdlg('Would you like to perform a sanity check on the scaled LFP time vector correctness?')
    if strcmp(sanitycheck1, 'Yes') == 1
        endTime = timeEeg
        TimeVec = EEGtimevec(end)
        if endTime == TimeVec
            waitfor(msgbox(sprintf('The end value of our rescaled lfp variable, %d\nis equal to the length of the original lfp variable / sampling-rate = %d.\nSanity check succesful!',endTime,TimeVec)))
        end
    else
    end

    % Additionally, the length (number of values) of EEGtimevec, should be 
    % equal to the length of the original lfp variable, cause that was the
    % whole point, to scale the original lfp to time 
sanitycheck1 = questdlg('Would you like to perform a sanity check on the scaled LFP time vector correctness?')
       if strcmp(sanitycheck1, 'Yes') == 1
            TimeVecLength = length(EEGtimevec);
            OriginalLFPlength = length(lfp);
            if TimeVecLength == OriginalLFPlength
                waitfor(msgbox(sprintf('The number of samples in our created time vector (the length): %d\nIs equal to the length of the original lfp variable: %d.\nSanity check successful!', TimeVecLength, OriginalLFPlength)))
            else
                waitfor(msgbox(sprintf('The number of samples in our created time vector (the length): %d\nIs not equal to the length of the original lfp variable: %d.\n There seems to be a problem', TimeVecLength, OriginalLFPlength)))
            end
       else
       end


%% Initial Trim of Signal

seshlengthCell = inputdlg('How long was this CPT session? (automatically in minutes)')
seshlength = str2num(seshlengthCell{1})
    % upon quick glance is quite evident that this LFP recording was left on
    % well after the ABET schedule had finished, and that this signal is too
    % long; Even in cases where it is not left on intentionally the signal will
    % tend to be longer than needed 
    
    
    % Thus, of the timescaled vector, give me 1800s in this case (30 min schedule)
    % think about it as EEGtimevec containing time in seconds within it, as
    % values, so we want 1800s or values up to and equal to 1800
    cpt_schLength = EEGtimevec(EEGtimevec <= (seshlength * 60)) ; % inside the soft brackets run alone will give you boolean responses, then we use that as an index; also we take the length you gave in minutes and convert to seconds
    assignin("base","cpt_schLength", cpt_schLength);
    
    % because the vector of cpt_schLength was sourced from the time-vector scaled 
    % to the # of data points from the EEG recording, we want EEG data points = to the length of our 1800s vector
    lfp = lfp(:,1:(length(cpt_schLength)));


% Sanity Checks 
% Let's do sanity checks to avoid errors cause errors suck
    % In the section above we are slicing for time, or truncating the time
    % scaled lfp signal so that it is only the length of the schedule that
    % was ran
        % We can first check cpt_schLength variable, the last value inside of it
        % should be equal to the length specified by the user 
    sanitycheck2 = questdlg('Would you like to perform a sanity check on the time length of the truncated LFP time vector')
        if strcmp(sanitycheck2,'Yes') == 1
            cptLengthCheck = cpt_schLength(end);
            userTimeSec = (seshlength * 60);
            if cptLengthCheck == userTimeSec
                waitfor(msgbox(sprintf('Because the last value in our scaled CPT schedule length time vector: %d\nIs equal to the user defined length converted to seconds: %d\nSanity check succesful!',cptLengthCheck,userTimeSec)));
            else 
                waitfor(msgbox(sprintf('Because the last value in our scaled CPT schedule length time vector: %d\nIs not equal to the user defined length converted to seconds: %d\nSomething is off...\nConsider re-exporting the the original file to .edf and trying to process again',cptLengthCheck,userTimeSec)));
            end
        else
        end
%}

%% Split LFP channels for clarity 
% currently, our lfp variable contains all channels together, rows: 1-ground, 2-reference-pin, 3-Brain reg.1, 4-Brain reg.2

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


% Sanity Checks 

% Let's do sanity checks to avoid errors cause errors suck
    % Here we can make sure that the split channels we made contain the
    % correct values compared to the original lfp structure
    sanitycheck3 = questdlg('Quick check on the extracted and isolated LFP variable?')
    if strcmp(sanitycheck3,'Yes') == 1
        if savename.ACC.lfp == lfp(4,:);
            waitfor(msgbox(sprintf('Because the values of our extracted ACC lfp, and channel 4 of the original lfp variable match, sanity check successful!')))
        end
    else
    end



%% Grabbing timestamps based LFP 
% For each electrode, and for each type of event, we need to grab the
% lfp, half a second before and after the timestamp... and save this
% as a structure(for ease)


% First, we must up-sample, to match the scale(resolution) we have lfp at
FIRBeam_Onidx = FIRBeam_On * srate; 

FIRBeam_Offidx = FIRBeam_Off * srate; 

Center_ScTouchidx = Center_ScTouch * srate; 

Start_ITIidx =Start_ITI * srate; 

Stimulusidx = Stimulus * srate; 

Hitidx = Hit * srate; 

Missidx = Miss * srate; 

Correct_Rejidx =Correct_Rej * srate; 

False_Alarmidx = False_Alarm * srate; 



% We don't want any decimals 
    % FIRBeam_Onidx =int64(FIRBeam_Onidx); 
    % FIRBeam_Offidx = int64(FIRBeam_Offidx);
    % Center_ScTouchidx = int64(Center_ScTouchidx);
    % Start_ITIidx = int64(Start_ITIidx);
    % Stimulusidx = int64(Stimulusidx);
    % Hitidx = int64(Hitidx);
    % Missidx = int64(Missidx);
    % Correct_Rejidx = int64(Correct_Rejidx);
    % False_Alarmidx = int64(False_Alarmidx);



%% Now we can grab the lfp of each timestamp

% Make it an if... statement, so that when we have empty variables (S2 as
%one case) then we can still run the full script and wont be stopped by
%errors
if sum(size(FIRBeam_On)) >= 2 
    for i = 1:length(FIRBeam_Onidx)
        if (FIRBeam_Onidx(i)+(srate*TimeWin/2))<(length(lfp)) && (FIRBeam_Onidx(i)-(srate*TimeWin/2))>(0)  
            savename.Ground.FIRBeam_On_lfp{i} = savename.Ground.lfp(1,FIRBeam_Onidx(1,i)-(srate*(TimeWin/2)):FIRBeam_Onidx(1,i)+(srate*TimeWin/2));
            savename.Reference.FIRBeam_On_lfp{i} = savename.Reference.lfp(1,FIRBeam_Onidx(1,i)-(srate*TimeWin/2):FIRBeam_Onidx(1,i)+(srate*TimeWin/2));
            savename.LC.FIRBeam_On_lfp{i} = savename.LC.lfp(1,FIRBeam_Onidx(1,i)-(srate*TimeWin/2):FIRBeam_Onidx(1,i)+(srate*TimeWin/2));
            savename.ACC.FIRBeam_On_lfp{i} = savename.ACC.lfp(1,FIRBeam_Onidx(1,i)-(srate*TimeWin/2):FIRBeam_Onidx(1,i)+(srate*TimeWin/2));
        end
    end
end

if sum(size(FIRBeam_Off)) >= 2 
    for i = 1:(length(FIRBeam_Offidx))
        if (FIRBeam_Offidx(i)+(srate*TimeWin/2))<(length(lfp)) && (FIRBeam_Offidx(i)-(srate*TimeWin/2))>(0)        
            savename.Ground.FIRBeam_Off_lfp{i} = savename.Ground.lfp(1,FIRBeam_Offidx(1,i)-(srate*TimeWin/2):FIRBeam_Offidx(1,i)+(srate*TimeWin/2));
            savename.Reference.FIRBeam_Off_lfp{i} = savename.Reference.lfp(1,FIRBeam_Offidx(1,i)-(srate*TimeWin/2):FIRBeam_Offidx(1,i)+(srate*TimeWin/2));
            savename.LC.FIRBeam_Off_lfp{i} = savename.LC.lfp(1,FIRBeam_Offidx(1,i)-(srate*TimeWin/2):FIRBeam_Offidx(1,i)+(srate*TimeWin/2));
            savename.ACC.FIRBeam_Off_lfp{i} = savename.ACC.lfp(1,FIRBeam_Offidx(1,i)-(srate*TimeWin/2):FIRBeam_Offidx(1,i)+(srate*TimeWin/2));
        end
    end
end

if sum(size(Center_ScTouch)) >= 2 
    for i = 1:length(Center_ScTouchidx)
        if (Center_ScTouchidx(i)+(srate*TimeWin/2))<(length(lfp)) && (Center_ScTouchidx(i)-(srate*TimeWin/2))>(0)              
            savename.Ground.Center_ScTouch_lfp{i} = savename.Ground.lfp(1,Center_ScTouchidx(1,i)-(srate*TimeWin/2):Center_ScTouchidx(1,i)+(srate*TimeWin/2));
            savename.Reference.Center_ScTouch_lfp{i} = savename.Reference.lfp(1,Center_ScTouchidx(1,i)-(srate*TimeWin/2):Center_ScTouchidx(1,i)+(srate*TimeWin/2));
            savename.LC.Center_ScTouch_lfp{i} = savename.LC.lfp(1,Center_ScTouchidx(1,i)-(srate*TimeWin/2):Center_ScTouchidx(1,i)+(srate*TimeWin/2));
            savename.ACC.Center_ScTouch_lfp{i} = savename.ACC.lfp(1,Center_ScTouchidx(1,i)-(srate*TimeWin/2):Center_ScTouchidx(1,i)+(srate*TimeWin/2));
        end
    end
end

if sum(size(Start_ITI)) >= 2 
    for i = 1:length(Start_ITIidx)
        if (Start_ITIidx(i)+(srate*TimeWin/2))<(length(lfp)) && (Start_ITIidx(i)-(srate*TimeWin/2))>(0)                        
            savename.Ground.Start_ITI_lfp{i} = savename.Ground.lfp(1,Start_ITIidx(1,i)-(srate*TimeWin/2):Start_ITIidx(1,i)+(srate*TimeWin/2));
            savename.Reference.Start_ITI_lfp{i} = savename.Reference.lfp(1,Start_ITIidx(1,i)-(srate*TimeWin/2):Start_ITIidx(1,i)+(srate*TimeWin/2));
            savename.LC.Start_ITI_lfp{i} = savename.LC.lfp(1,Start_ITIidx(1,i)-(srate*TimeWin/2):Start_ITIidx(1,i)+(srate*TimeWin/2));
            savename.ACC.Start_ITI_lfp{i} = savename.ACC.lfp(1,Start_ITIidx(1,i)-(srate*TimeWin/2):Start_ITIidx(1,i)+(srate*TimeWin/2));
        end
    end
end



if sum(size(Stimulus)) >= 2 
    for i = 1:length(Stimulusidx)
        if (Stimulusidx(i)+(srate*TimeWin/2))<(length(lfp)) && (Stimulusidx(i)-(srate*TimeWin/2))>(0)                      
            savename.Ground.Stimulus_lfp{i} = savename.Ground.lfp(1,Stimulusidx(1,i)-(srate*TimeWin/2):Stimulusidx(1,i)+(srate*TimeWin/2));
            savename.Reference.Stimulus_lfp{i} = savename.Reference.lfp(1,Stimulusidx(1,i)-(srate*TimeWin/2):Stimulusidx(1,i)+(srate*TimeWin/2));
            savename.LC.Stimulus_lfp{i} = savename.LC.lfp(1,Stimulusidx(1,i)-(srate*TimeWin/2):Stimulusidx(1,i)+(srate*TimeWin/2));
            savename.ACC.Stimulus_lfp{i} = savename.ACC.lfp(1,Stimulusidx(1,i)-(srate*TimeWin/2):Stimulusidx(1,i)+(srate*TimeWin/2));
        end
    end
end
if sum(size(Hit)) >= 2
    for i = 1:length(Hitidx(1,:))
        if (Hitidx(i)+(srate*TimeWin/2))<(length(lfp)) && (Hitidx(i)-(srate*TimeWin/2))>(0)                        
            savename.Ground.Hit_lfp{i} = savename.Ground.lfp(1,Hitidx(1,i)-(srate*TimeWin/2):Hitidx(1,i)+(srate*TimeWin/2));
            savename.Reference.Hit_lfp{i} = savename.Reference.lfp(1,Hitidx(1,i)-(srate*TimeWin/2):Hitidx(1,i)+(srate*TimeWin/2));
            savename.LC.Hit_lfp{i} = savename.LC.lfp(1,Hitidx(1,i)-(srate*TimeWin/2):Hitidx(1,i)+(srate*TimeWin/2));
            savename.ACC.Hit_lfp{i} = savename.ACC.lfp(1,Hitidx(1,i)-(srate*TimeWin/2):Hitidx(1,i)+(srate*TimeWin/2));
        end
    end
end    
if sum(size(Miss)) >= 2
    for i = 1:length(Missidx)
        if (Missidx(i)+(srate*TimeWin/2))<(length(lfp)) && (Missidx(i)-(srate*TimeWin/2))>(0)               
            savename.Ground.Miss_lfp{i} = savename.Ground.lfp(1,Missidx(1,i)-(srate*TimeWin/2):Missidx(1,i)+(srate*TimeWin/2));
            savename.Reference.Miss_lfp{i} = savename.Reference.lfp(1,Missidx(1,i)-(srate*TimeWin/2):Missidx(1,i)+(srate*TimeWin/2));
            savename.LC.Miss_lfp{i} = savename.LC.lfp(1,Missidx(1,i)-(srate*TimeWin/2):Missidx(1,i)+(srate*TimeWin/2));
            savename.ACC.Miss_lfp{i} = savename.ACC.lfp(1,Missidx(1,i)-(srate*TimeWin/2):Missidx(1,i)+(srate*TimeWin/2));
        end
    end
end
if sum(size(Correct_Rej)) >= 2
    for i = 1:length(Correct_Rejidx)
        if (Correct_Rejidx(i)+(srate*TimeWin/2))<(length(lfp)) && (Correct_Rejidx(i)-(srate*TimeWin/2))>(0)                      
            savename.Ground.Correct_Rej_lfp{i} = savename.Ground.lfp(1,Correct_Rejidx(1,i)-(srate*TimeWin/2):Correct_Rejidx(1,i)+(srate*TimeWin/2));
            savename.Reference.Correct_Rej_lfp{i} = savename.Reference.lfp(1,Correct_Rejidx(1,i)-(srate*TimeWin/2):Correct_Rejidx(1,i)+(srate*TimeWin/2));
            savename.LC.Correct_Rej_lfp{i} = savename.LC.lfp(1,Correct_Rejidx(1,i)-(srate*TimeWin/2):Correct_Rejidx(1,i)+(srate*TimeWin/2));
            savename.ACC.Correct_Rej_lfp{i} = savename.ACC.lfp(1,Correct_Rejidx(1,i)-(srate*TimeWin/2):Correct_Rejidx(1,i)+(srate*TimeWin/2));
        end
    end
end
if sum(size(False_Alarm)) >= 2
    for i = 1:length(False_Alarmidx)
        if (False_Alarmidx(i)+(srate*TimeWin/2))<(length(lfp)) && (False_Alarmidx(i)-(srate*TimeWin/2))>(0)                     
            savename.Ground.False_Alarm_lfp{i} = savename.Ground.lfp(1,False_Alarmidx(1,i)-(srate*TimeWin/2):False_Alarmidx(1,i)+(srate*TimeWin/2));
            savename.Reference.False_Alarm_lfp{i} = savename.Reference.lfp(1,False_Alarmidx(1,i)-(srate*TimeWin/2):False_Alarmidx(1,i)+(srate*TimeWin/2));
            savename.LC.False_Alarm_lfp{i} = savename.LC.lfp(1,False_Alarmidx(1,i)-(srate*TimeWin/2):False_Alarmidx(1,i)+(srate*TimeWin/2));
            savename.ACC.False_Alarm_lfp{i} = savename.ACC.lfp(1,False_Alarmidx(1,i)-(srate*TimeWin/2):False_Alarmidx(1,i)+(srate*TimeWin/2));
        end
    end
end

% Sanity Checks 

% Let's do sanity checks to avoid errors cause errors suck





%% Get LFP for time windows directly preceding a certain event time (snippet lengths will be variable here)
%{
% For ITIs preceding Hits
        savename.Ground.ITI_preceedingHit_lfp = {};
            for event = 1:length(Hitidx(1,:))
                % index ITIs less than hit event
                Start_ITI_precedingHit = Start_ITIidx < Hitidx(1,event)
                % index stimuli less than hit event
                Stimulus_precedingHit = Stimulusidx < Hitidx(1,event)
                
                % truncate to only include 'yes' values 
                Start_ITI_precedingHittrunc = Start_ITI_precedingHit(Start_ITI_precedingHit == 1)
                % truncate to only include 'yes' values 
                Stimulus_precedingHittrunc = Stimulus_precedingHit(Stimulus_precedingHit == 1)
                
                % get the last value (closest) and make it our y-value
                % (because we truncated to the values equal to 1, the
                % length will be the columnar value of the last/closest
                % timestamps to the event)
                Start_ITIprecedingYvalHit = length(Start_ITI_precedingHittrunc)
                % get the last value (closest) and make it our y-value
                Stimulus_precedingYvalHit = length(Stimulus_precedingHittrunc)
                
                % use our closest y-value to grab timestamp from original timestamps values index
                ITI_precedingHit_stamp = Start_ITIidx(1,Start_ITIprecedingYvalHit)
                % use our closest y-value to grab timestamp from original timestamps values index
                Stimulus_precedingHit_stamp = Stimulusidx(1,Stimulus_precedingYvalHit)
                
                % slice lfp based on window from ITI start and stimulus
                % (columnar values of the closest start ITI to the closest
                % stimulus presentation) 
                savename.Ground.ITI_preceedingHit_lfp{event} = savename.Ground.lfp(1,ITI_precedingHit_stamp:Stimulus_precedingHit_stamp)

            end

for x = 1:length(savename.Ground.ITI_preceedingHit_lfp)
        lengthCells = (cellfun(@length,(savename.Ground.ITI_preceedingHit_lfp(x))))
        if lengthCells > 6001
            ToolongsHits{x} = savename.Ground.ITI_preceedingHit_lfp{x}
        end
end



%% For ITIs Preceding Mistakes
         savename.Ground.ITI_preceedingFalseAlarm_lfp = {};
            for event = 1:length(False_Alarmidx)
                % index ITIs less than hit event
                Start_ITI_precedingFalseAlarm = Start_ITIidx < False_Alarmidx(1,event)
                % index stimuli less than hit event
                Stimulus_precedingFalseAlarm = Stimulusidx < False_Alarmidx(1,event)
                
                % truncate to only include 'yes' values 
                Start_ITI_precedingFalseAlarm = Start_ITI_precedingFalseAlarm(Start_ITI_precedingFalseAlarm == 1)
                % truncate to only include 'yes' values 
                Stimulus_precedingFalseAlarm = Stimulus_precedingFalseAlarm(Stimulus_precedingFalseAlarm == 1)
                
                % get the last value (closest) and make it our y-value
                Start_ITIprecedingYvalFalseAlarm = length(Start_ITI_precedingFalseAlarm)
                % get the last value (closest) and make it our y-value
                Stimulus_precedingYvalFalseAlarm = length(Stimulus_precedingFalseAlarm)
                
                % use our closest y-value to grab timestamp from original index
                ITI_preceding_stampFalseAlarm = Start_ITIidx(1,Start_ITIprecedingYvalFalseAlarm)
                % use our closest y-value to grab timestamp from original index
                Stimulus_preceding_stampFalseAlarm = Stimulusidx(1,Stimulus_precedingYvalFalseAlarm)
                
                % slice lfp based on window from ITI start and stimulus
                savename.Ground.ITI_preceedingFalseAlarm_lfp{event} = savename.Ground.lfp(1,[ITI_preceding_stampFalseAlarm:Stimulus_preceding_stampFalseAlarm])
            end
            
            for x = 1:length(savename.Ground.ITI_preceedingFalseAlarm_lfp)
                lengthCells = (cellfun(@length,(savename.Ground.ITI_preceedingFalseAlarm_lfp(x))))
                if lengthCells > 6001
                    ToolongsFalseAlarms{x} = savename.Ground.ITI_preceedingFalseAlarm_lfp{x}
                end
            end
%}



%% Slicing 3 seconds from Start_ITI Preceding Hits
%{
savename.Ground.ThreeSecond_ITI_HITS_lfp = {};
savename.Reference.ThreeSecond_ITI_HITS_lfp = {};
savename.LC.ThreeSecond_ITI_HITS_lfp = {};
savename.ACC.ThreeSecond_ITI_HITS_lfp = {};

    for event = 1:length(Hitidx(1,:))
        % index ITIs less than hit event
        Start_ITI_precedingHit = Start_ITIidx < Hitidx(1,event);
        % Truncate to only include 1's aka 'True's
        Start_ITI_precedingHit = Start_ITI_precedingHit(Start_ITI_precedingHit == 1);
        % Get the length cause we only want the one closest to the hit we're interested in 
        Start_ITI_yval = length(Start_ITI_precedingHit);
        % Grab timestamps based on this index value 
        ITIstamp = Start_ITIidx(1,Start_ITI_yval);
        % Grab LFP, 3 seconds forward from start ITI for all channels
        savename.Ground.ThreeSecond_ITI_HITS_lfp{event} = savename.Ground.lfp(1,ITIstamp:ITIstamp+6000);
        savename.Reference.ThreeSecond_ITI_HITS_lfp{event} = savename.Reference.lfp(1,ITIstamp:ITIstamp+6000);
        savename.ACC.ThreeSecond_ITI_HITS_lfp{event} = savename.LC.lfp(1,ITIstamp:ITIstamp+6000);
        savename.LC.ThreeSecond_ITI_HITS_lfp{event} = savename.ACC.lfp(1,ITIstamp:ITIstamp+6000);
    end
       
%% Slicing 3 seconds from Start_ITI Preceding False Alarms
savename.Ground.ThreeSecond_ITI_FALSE_ALARMS_lfp = {};
savename.Reference.ThreeSecond_ITI_FALSE_ALARMS_lfp = {};
savename.LC.ThreeSecond_ITI_FALSE_ALARMS_lfp = {};
savename.ACC.ThreeSecond_ITI_FALSE_ALARMS_lfp = {};

    for event = 1:length(False_Alarmidx(1,:))
        % index ITIs less than hit event
        Start_ITI_precedingHit = Start_ITIidx < False_Alarmidx(1,event);
        % Truncate to only include 1's aka 'True's
        Start_ITI_precedingHit = Start_ITI_precedingHit(Start_ITI_precedingHit == 1);
        % Get the length cause we only want the one closest to the hit we're interested in 
        Start_ITI_yval = length(Start_ITI_precedingHit);
        % Grab timestamps based on this index value 
        ITIstamp = Start_ITIidx(1,Start_ITI_yval);
        % Grab LFP, 3 seconds forward from start ITI for all channels
        savename.Ground.ThreeSecond_ITI_FALSE_ALARMS_lfp{event} = savename.Ground.lfp(1,ITIstamp:ITIstamp+6000);
        savename.Reference.ThreeSecond_ITI_FALSE_ALARMS_lfp{event} = savename.Reference.lfp(1,ITIstamp:ITIstamp+6000);
        savename.ACC.ThreeSecond_ITI_FALSE_ALARMS_lfp{event} = savename.LC.lfp(1,ITIstamp:ITIstamp+6000);
        savename.LC.ThreeSecond_ITI_FALSE_ALARMS_lfp{event} = savename.ACC.lfp(1,ITIstamp:ITIstamp+6000);
    end


%}
%%  Add a couple more helpful things
    savename.srate = srate;
    savename.TimeWin = TimeWin;


%% Saving / Moving forward
    waitfor(msgbox(sprintf('Everything has been extracted!\n\nNow you have 4 separate structures (within your main mouse structure)\n\nOne for each channel...\n\nAnd within them\n\nRaw LFP, and event based extracted LFP windows of data!')))
    %x = inputdlg(sprintf('Would you like to save all of these channels automatically?\n\nIt could take a while...\n\n-Or you can move forward with processing the variables you have(right side) and save later.\n\n-Or you can save individual things manually.\n\nInput ''1'' to save all automatically.\nInput ''2'' to handle it on your own.\nInput ''3'' for both\n'))
    %x = str2num(x{1})
    
    cd(saveplace)
    tic
   
    save(mousename,'-struct','savename')

    toc
    waitfor(msgbox(sprintf('Your new structure has been saved in\nPath:\n''%s'',\n\nAs Name:\n''%s''!',saveplace,mousename)))
%{
elseif x == 2
    tic
    assignin('base',mousename{1},savename)
    waitfor(msgbox(sprintf('Your new structure is in the Workspace on the right hand side with\n\nName:\n''%s''',mousename{1})))
    toc
elseif x == 3 
    cd(saveplace)
    tic
    save(mousename{1},'-struct','savename')
%     save('Ground', '-struct','Ground')
%     save('LC', '-struct','LC')
%     save('Reference', '-struct','Reference')
    waitfor(msgbox(sprintf('Your new structure has been saved in\n\nPath:\n''%s'',\n\nAs Name:\n''%s''!',saveplace,mousename{1})))
    assignin('base',mousename{1},savename)
    toc
end
%}
    
vardisplay = questdlg('Would you like to evaluate the variable created?')
    if strcmp(vardisplay,'Yes') == 1 
        waitfor(msgbox(sprintf('When you are finished evaluating the variable\nCLICK INTO THE COMMAND WINDOW (bottom of MATLAB)\n then type in ''dbquit''')))
        openvar('savename')
        sprintf('\n\nTYPE ''dbcont'' BELOW HERE')
        keyboard
    elseif strcmp(vardisplay,'Yes') == 0
    end
end
end

% LabMeetingMouse_4s_sliced = load('LabMeetingMouse_4s_sliced.mat');