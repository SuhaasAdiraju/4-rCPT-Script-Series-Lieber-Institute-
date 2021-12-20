function [NTmouseStruc] = createStrucNTsensors(Tstamps_path, Tstamps_name, transients_path, transients_name, ROI, saveplace, mousename)
%% Description
% This function is for trimming, formatting, and combining neural activity
% recording data with CPT behavioral timestamps. In order to create a
% structure of the mouse with the saved timestamps and neural activity data

%% INPUTS 
% Tstamps_path - 
    % path to your ABET event timestamps .csv file 

% Tstamps_name - 
    % name of the .csv file

% transients_path - 
    % path to your Inscopix derived transients file 

% ROI - 
    % optimal region of interest given Inscopix view

% saveplace - 
    % where do you want to save your structure??

% mousename - 
    % what would you like to name this structure??

%% OUTPUTS

% the structure containing transient data and event timestamps data
% separated into distinct variables

%% Reading in our main files

% cd to your folder containing the event files (timestamps sheet)
cd(Tstamps_path{1});

% read in the csv file
[Tstamps,Titles,EventSheet] = xlsread(Tstamps_name{1});

% now cd to your imaging output folder (should be coming out of inscopix)
cd(transients_path{1});


% read in the csv file data 
[Tstamps_transients,Titles_transients,EventSheet_transients] = xlsread(transients_name{1});

% read in the transients matrix (in case xlsread is not working)
% Ne_transients = readmatrix('1855_good_S3_TTL_Cell_Traces.csv',opts);


%% 
% flip orientation, so time is x axis 
Transients = (EventSheet_transients');
Transients = (Transients([2:end],[3:end]));

% The rows here are ROIs, set in inscopix, so we can choose the one that
% fit best, in this case the ROI 5 was most optimal in terms of transient
% tracking, you should know what ROI you want from inscopix 

% So lets only take the 5th row or ROI of interest
ROIval = cell2mat(ROI);

ROItransients = Transients(ROIval,:);


 % now we have our event sheet with corresponding timestamps that we wanna
 % use to grab specific parts of imaging transients

%% Separating our behavioral events sheet 

% This loop will go through your events sheet, see if there is both
% chambers 3 and 4, or just 3, or just 4, let you know what it found, and
% create distinct variables with the associated timestamps for chambers 3
% and 4 

parCh1 = 'Chamber1';
parCh2 = 'Chamber2';
%Currently inactive for the output csv (has no chamber indications)
for z = 1:length(EventSheet(:,3))
        if (startsWith((EventSheet(z,3)),parCh1))==1
            while z == 1
                fprintf ('\nCreating timestamp sheet for Chamber 1...');
            end
            Ch1Events = EventSheet(:,:); 
            chamber = Ch1Events;
        end
        if (startsWith((EventSheet(z,3)),parCh2))==1
            while z == 1
                fprintf ('\nCreating timestamp sheet for Chamber 2...');
            end
            Ch2Events = EventSheet(:,:);
            chamber = Ch2Events;
        end
        
        if z == length(EventSheet(:,3))
            if (exist('Ch1Events')) == 1
                fprintf('\n\nChamber 1 data extracted!')
            end
            if (exist ('Ch1Events')) == 0
                fprintf('\n\nChamber 1 not found.')
            end
            if (exist ('Ch2Events')) == 1 
                fprintf('\n\nChamber 2 data extracted!')
            end
            if (exist ('Ch2Events')) == 0
                fprintf('\n\nChamber 2 not found.')
            end
        end
end
%}

% initialize variables for events of desire (good practice to predefine)
FIRBeam_On = {};
FIRBeam_Off = {};
Center_ScTouch = {}; 
Start_ITI = {};
Stimulus = {};
Hit = {};
Miss = {};
Correct_Rej = {};
False_Alarm = {};

%% in loop fashion, we will grab the timestamps event titles and save them seperately 

% For FIRBeam On
pat = 'FIRBeam On'; %event name (this is 'pattern' and used to grab event TStamps based on the title they're under)
for z = 1:length(EventSheet(1,:))
        if (startsWith(EventSheet(1,z),pat)) == 1
            FIRBeam_On{z} = EventSheet(:,z);
            FIRBeam_On = FIRBeam_On{z}(2:end)
        end

        if z == (length(EventSheet(1,:)))
        FIRBeam_On = cell2mat(FIRBeam_On);  %change from cell array to a double for future computational ease
        FIRBeam_On = FIRBeam_On'; %flip the dimension, so instead of a column vector, its a row vector, matching Transients signal
        fprintf([pat,'''s have been extracted!\n']);
        end
end

% For FIRBeam Off
pat = 'FIRBeam Off';
for z = 1:length(EventSheet(1,:))
        if (startsWith(EventSheet(1,z),pat)) == 1
            FIRBeam_Off{z} = EventSheet(:,z);
            FIRBeam_Off = FIRBeam_Off{z}(2:end)
        end
    
        if z == (length(EventSheet(1,:)))
        FIRBeam_Off = cell2mat(FIRBeam_Off);  %change from cell array to a double for future computational ease
        FIRBeam_Off = FIRBeam_Off'; %flip the dimension, so instead of a column vector, its a row vector, matching Transients signal
        fprintf([pat,'''s have been extracted!\n']);
        end
end


% For Center screen touch 
pat = 'Center Screen Touch';
for z = 1:length(EventSheet(1,:))
        if (startsWith(EventSheet(1,z),pat)) == 1
            Center_ScTouch{z} = EventSheet(:,z);
            Center_ScTouch = Center_ScTouch{z}(2:end);
        end
        
        if z == (length(EventSheet(1,:)))
        Center_ScTouch = cell2mat(Center_ScTouch);  %change from cell array to a double for future computational ease
        Center_ScTouch = Center_ScTouch'; %flip the dimension, so instead of a column vector, its a row vector, matching Transients signal
        fprintf([pat,'es have been extracted!\n']);
        end
end

% For Start ITI
pat = 'Start ITI';
for z = 1:length(EventSheet(1,:))
        if (startsWith(EventSheet(1,z),pat)) == 1
            Start_ITI{z} = EventSheet(:,z);
            Start_ITI = Start_ITI{z}(2:end)
        end
        %
        if z == (length(EventSheet(1,:)))
        Start_ITI = cell2mat(Start_ITI);  %change from cell array to a double for future computational ease
        Start_ITI = Start_ITI'; %flip the dimension, so instead of a column vector, its a row vector, matching Transients signal
        fprintf([pat,'es have been extracted!\n']);
        end
end

% For Stimulus (stimulus presentation)
pat = 'Stim Onset';
for z = 1:length(EventSheet(1,:))
        if (startsWith(EventSheet(1,z),pat)) == 1
            Stimulus{z} = EventSheet(:,z);
            Stimulus = Stimulus{z}(2:end)
        end
    
        if z == (length(EventSheet(1,:)))
        Stimulus = cell2mat(Stimulus);  %change from cell array to a double for future computational ease
        Stimulus = Stimulus'; %flip the dimension, so instead of a column vector, its a row vector, matching Transients signal
        fprintf([pat,'es have been extracted!\n']);
        end
end


% Hit
pat = 'Hit';
for z = 1:length(EventSheet(1,:))
        if (startsWith(EventSheet(1,z),pat)) == 1
            Hit{z} = EventSheet(:,z);
            Hit = Hit{z}(2:end)
        end

        if z == (length(EventSheet(1,:)))
            Hit = cell2mat(Hit);  %change from cell array to a double for future computational ease
            Hit = Hit'; %flip the dimension, so instead of a column vector, its a row vector, matching Transients signal
            fprintf([pat,'es have been extracted!\n']);
        end
end


% Miss
pat = 'Misses';
for z = 1:length(EventSheet(1,:))
        if (startsWith(EventSheet(1,z),pat)) == 1
            Miss{z} = EventSheet(:,z);
            Miss = Miss{z}(2:end)
        end
    
        if z == (length(EventSheet(1,:)))
            Miss = cell2mat(Miss);  %change from cell array to a double for future computational ease
            Miss = Miss'; %flip the dimension, so instead of a column vector, its a row vector, matching Transients signal
            fprintf([pat,'es have been extracted!\n']);
        end
end

% Correct_Rej
pat = 'Correct Rejection';
for z = 1:length(EventSheet(1,:))
        if (startsWith(EventSheet(1,z),pat)) == 1
            Correct_Rej{z} = EventSheet(:,z);
            Correct_Rej = Correct_Rej{z}(2:end)
        end
    
        if z == (length(EventSheet(1,:)))
            Correct_Rej = cell2mat(Correct_Rej);  %change from cell array to a double for future computational ease
            Correct_Rej = Correct_Rej'; %flip the dimension, so instead of a column vector, its a row vector, matching Transients signal
            fprintf([pat,'es have been extracted!\n']);
        end
end

% False_Alarm
pat = 'Mistakes'; %in abet an S- miss is called 'mistake', but we call it a FAlarm
for z = 1:length(EventSheet(1,:))
        if (startsWith(EventSheet(1,z),pat)) == 1
            False_Alarm{z} = EventSheet(:,z);
            False_Alarm = False_Alarm{z}(2:end)
        end
    
        if z == (length(EventSheet(1,:)))
            False_Alarm = cell2mat(False_Alarm);  %change from cell array to a double for future computational ease
            False_Alarm = False_Alarm'; %flip the dimension, so instead of a column vector, its a row vector, matching Transients signal
            fprintf([pat,' have been extracted!\n']);
        end
end


%% Sanity Checks
% To check if things are working well, its good practice to open up
% variables and make sure they look right, but there are a couple of sanity
% checks we can implement here 

if length(Hit) == length(EventSheet([2:end],24))
fprintf ('\nIt seems like timestamps have been accurately parsed out! Press any key to continue!')
else 
    disp ('\nThere may be a problem with separating your event timestamps...')
end

pause


% we can do this also

if (cell2mat(EventSheet(2,24))) == Hit(1)
    fprintf ('\nIt seems like timestamps have been accurately parsed out! Press any key to continue!')
else 
    disp ('\nThere may be a problem with separating your event timestamps...')
end

pause

%% Create Structures
% remove excess zeros, and add to loaded mousename structure
savename. Transients = cell2mat(ROItransients);
savename. FIRBeam_On = FIRBeam_On(isnan(FIRBeam_On) == 0);
savename. FIRBeam_Off = FIRBeam_Off(isnan(FIRBeam_Off) == 0);
savename. Center_ScTouch = Center_ScTouch(isnan(Center_ScTouch) == 0);
savename. Start_ITI = Start_ITI(isnan(Start_ITI(2:end)) == 0);
savename. Stimulus = Stimulus(isnan(Stimulus(2:end)) == 0);
savename. Hit = Hit(isnan(Hit) == 0);
savename. Miss = Miss(isnan(Miss) == 0);
savename. Correct_Rej = Correct_Rej(isnan(Correct_Rej) == 0);
savename. False_Alarm = False_Alarm(isnan(False_Alarm) == 0);
savename. Chamber = cell2mat(chamber(2,3));

%% resave the structure to the correct folder
cd(saveplace{1});
save(mousename{1},'-struct', 'savename');
sprintf('Your new structure has been saved with in path ''%d'', with name ''%d''',saveplace{1},mousename{1});

end
