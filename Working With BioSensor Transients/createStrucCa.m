function [Ca2Struct] = createStrucCA2;
%% Description 

% This function is for compiling the necessary components for analysis of
% calcium imaging transients yielded from inscopix software

% We will combine these transients with behavioral event timestamps yielded
% from ABET software

% Written by Suhaas S Adiraju

%% OUTPUTS
% Ca2Struct - 
    % your calcium transients and associated event-based timestamps structure

%% Begin

prepans = questdlg('Do you have your calcium imaging transients as an excel file exported from Inscopix, as well as the behavioral event-timestamps exported from ABET II?')
if strcmp(prepans, 'Yes') == 1
    %% Define required input variables 
    % Purpose Statement;
    waitfor(msgbox(sprintf('Welcome to Calcium Imaging 4 CPT script 1; CreateStrucCa2\n\nPURPOSE:\nThe purpose of this script is to clearly walk the user through defining the required inputs to run the function createStrucCA2, which will combine the behavioral event timestamps and dF/F transient traces exported from Inscopix\n\nINPUTS:\n-Timestamps file: the behavioral timestamps that come out of ABET II software\n-Transients file: the transients file coming out of Inscopix\n-mousename: what the resulting structure will be named\n-saveplace: what folder would you like to save your resulting structure in\n\n')))
    
    % Transients file
    waitfor(msgbox(sprintf('\nA file selector will pop up,\nThen select your calcium imaging transients file from Inscopix')))
    [transients_name, transients_path] = uigetfile('*.csv*','Select the Ca2 imaging transients containing csv file')
    while ((transients_name)) == 0
        waitfor(warndlg(sprintf('You did not select an imaging transients file. Press okay to try again.\n\nOR if you would like to exit this script, press the stop button at the top of MATLAB under the editor tab')))
        [transients_name, transients_path] = uigetfile('*.csv*','Select the Ca2 imaging transients containing csv file')
    end
    
    
    % Timestamps file
    waitfor(msgbox(sprintf('\nA file selector will pop up,\nThen select your behavioral timestamps file from ABET')))
    [Tstamps_name, Tstamps_path] = uigetfile ('*.csv*','Please select your behavioral timestamps file')
    while ((transients_name)) == 0
        waitfor(warndlg(sprintf('You did not select an behavioral timestamps file. Press okay to try again.\n\nOR if you would like to exit this script, press the stop button at the top of MATLAB under the editor tab')))
        [transients_name, transients_path] = uigetfile('*.csv*','Select the Ca2 imaging transients containing csv file')
    end
    
    
    % Mousename
        mousename = erase(transients_name,'.csv');
        mousename = append(mousename,'_CA2');
    
    
    % Save location path 
    waitfor(msgbox(sprintf('\nA file selector will pop up,\nThen select the the path to where you would like to save your new structure')))
    saveplace = uigetdir('','Select the Folder, where you would like to save your resulting structure')
    while saveplace == 0
        waitfor(warndlg(sprintf('You did not select a place to save your output structure. Press okay to try again.\n\nOR if you would like to exit this script, press the stop button at the top of MATLAB under the editor tab')))
        saveplace = uigetdir('','Select the Folder, where you would like to save your resulting structure')
    end
    
    
    
    %% Reading in our main files
    
    % cd to your folder containing the event files (TIMESTAMPS sheet)
    %addpath('D:\08.11.21 ONWARDS\CSV Behavioral Event Files');
    cd(Tstamps_path);
    
    
    % read in the csv file
    [Tstamps,Titles,EventSheet] = xlsread(Tstamps_name);
    
    % now cd to your imaging output folder (THIS IS THE TRANSIENTS FILE coming out of inscopix)
    cd(transients_path);
    
    
    % read in the csv file data 
    [Tstamps_transients,Titles_transients,EventSheet_transients] = xlsread(transients_name);
    
    % read in the transients matrix (in case xlsread is not working)
    % Ne_transients = readmatrix('1855_good_S3_TTL_Cell_Traces.csv',opts);
    
    
    %% Grabbing accepted cells only 
    % remove unusable first row; then flip orientation, so time is x axis 
    Ca_transients = (EventSheet_transients(2:end,2:end)');
    
    patCellUndecided = ' undecided';
    patCellAccepted = ' accepted';
    for z = 1:length(Ca_transients(:,1))
            if (startsWith((Ca_transients(z,1)),patCellUndecided))==1 | (startsWith((Ca_transients(z,1)),patCellAccepted))==1
                Accept_transients{z} = Ca_transients(z,2:end);
            elseif (startsWith((Ca_transients(z,1)),patCellAccepted))==0 && (startsWith((Ca_transients(z,1)),patCellUndecided))==0
                Accept_transients{z} = [];
            end
    end
    
    % Interpolate corrupted timestamp transients with preceeding transients value
    for neuroni = 1:length(Accept_transients)
        cellclass = class(Accept_transients{neuroni}{1});
        TransClasses = cellfun('isclass',Accept_transients{neuroni}(:,:),cellclass);
        FlaggedTransients = find(TransClasses == 0);
        if isempty(FlaggedTransients) == 0;
        Accept_transients{neuroni}(1,FlaggedTransients) = Accept_transients{neuroni}(1,FlaggedTransients-1)
        end
    end
    %% Separating our events
    
    % This loop will go through your events sheet, see if there is both
    % chambers 3 and 4, or just 3, or just 4, let you know what it found, and
    % create distinct variables with the associated timestamps for chambers 3
    % and 4 
    parCh1 = 'Chamber1';
    parCh2 = 'Chamber2';
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
        % eventually will have user input a structure of desired variables, so
        % this is mutable, but for now will leave it as set list 
    FIRBeam_On = {};
    FIRBeam_Off = {};
    Center_ScTouch = {}; 
    Start_ITI = {};
    Stimulus = {};
    Hit = {};
    Miss = {};
    Correct_Rej = {};
    False_Alarm = {};
    
    %% Now in loop fashion, we will grab the timestamps based on event-titles and save them seperately 
    
    % For FIRBeam On
    patFIRBeamON = 'FIRBeam On'; %event name (this is 'pattern' and used to grab event TStamps based on the title they're under)
    for z = 1:length(EventSheet(1,:)) %go across event sheet row 1, and look for 'FIRBeam On'
            if (startsWith(EventSheet(1,z),patFIRBeamON)) == 1
                FIRBeam_On{z} = EventSheet(:,z); % grab all the timestamps if the column heading is 'FIRBeam On'
                FIRBeam_On = FIRBeam_On{z}(2:end) % lose the heading and save the values 
            end
    
            if z == (length(EventSheet(1,:))) % at the last iteration of the loop
            FIRBeam_On = cell2mat(FIRBeam_On);  % change from cell array to a double for future computational ease
            FIRBeam_On = FIRBeam_On'; % flip the dimension, so instead of a column vector, its a row vector, matching Transients signal
            fprintf([patFIRBeamON,'s have been extracted!\n']); %let the user know this event has been sourced and saved!
            end
    end
    
    % For FIRBeam Off
    patFIRBeamOFF = 'FIRBeam Off';
    for z = 1:length(EventSheet(1,:))
            if (startsWith(EventSheet(1,z),patFIRBeamOFF)) == 1
                FIRBeam_Off{z} = EventSheet(:,z);
                FIRBeam_Off = FIRBeam_Off{z}(2:end)
            end
        
            if z == (length(EventSheet(1,:)))
            FIRBeam_Off = cell2mat(FIRBeam_Off);  %change from cell array to a double for future computational ease
            FIRBeam_Off = FIRBeam_Off'; %flip the dimension, so instead of a column vector, its a row vector, matching Transients signal
            fprintf([patFIRBeamOFF,'''s have been extracted!\n']);
            end
    end
    
    
    % For Center screen touch 
    patCenterScreenTouch = 'Center Screen Touch';
    for z = 1:length(EventSheet(1,:))
            if (startsWith(EventSheet(1,z),patCenterScreenTouch)) == 1
                Center_ScTouch{z} = EventSheet(:,z);
                Center_ScTouch = Center_ScTouch{z}(2:end);
            end
            
            if z == (length(EventSheet(1,:)))
            Center_ScTouch = cell2mat(Center_ScTouch);  %change from cell array to a double for future computational ease
            Center_ScTouch = Center_ScTouch'; %flip the dimension, so instead of a column vector, its a row vector, matching Transients signal
            fprintf([patCenterScreenTouch,'es have been extracted!\n']);
            end
    end
    
    % For Start ITI
    patStartITI = 'Start ITI';
    for z = 1:length(EventSheet(1,:))
            if (startsWith(EventSheet(1,z),patStartITI)) == 1
                Start_ITI{z} = EventSheet(:,z);
                Start_ITI = Start_ITI{z}(2:end)
            end
            %
            if z == (length(EventSheet(1,:)))
            Start_ITI = cell2mat(Start_ITI);  %change from cell array to a double for future computational ease
            Start_ITI = Start_ITI'; %flip the dimension, so instead of a column vector, its a row vector, matching Transients signal
            fprintf([patStartITI,'es have been extracted!\n']);
            end
    end
    
    % For Stimulus (stimulus presentation)
    patStimONSET = 'Stim Onset';
    for z = 1:length(EventSheet(1,:))
            if (startsWith(EventSheet(1,z),patStimONSET)) == 1
                Stimulus{z} = EventSheet(:,z);
                Stimulus = Stimulus{z}(2:end)
            end
        
            if z == (length(EventSheet(1,:)))
            Stimulus = cell2mat(Stimulus);  %change from cell array to a double for future computational ease
            Stimulus = Stimulus'; %flip the dimension, so instead of a column vector, its a row vector, matching Transients signal
            fprintf([patStimONSET,'es have been extracted!\n']);
            end
    end
    
    
    % Hit
    patHIT = 'Hit';
    for z = 1:length(EventSheet(1,:))
            if (startsWith(EventSheet(1,z),patHIT)) == 1
                Hit{z} = EventSheet(:,z);
                Hit = Hit{z}(2:end)
            end
    
            if z == (length(EventSheet(1,:)))
                Hit = cell2mat(Hit);  %change from cell array to a double for future computational ease
                Hit = Hit'; %flip the dimension, so instead of a column vector, its a row vector, matching Transients signal
                fprintf([patHIT,'es have been extracted!\n']);
            end
    end
    
    
    % Miss
    patMISS = 'Misses';
    for z = 1:length(EventSheet(1,:))
            if (startsWith(EventSheet(1,z),patMISS)) == 1
                Miss{z} = EventSheet(:,z);
                Miss = Miss{z}(2:end)
            end
        
            if z == (length(EventSheet(1,:)))
                Miss = cell2mat(Miss);  %change from cell array to a double for future computational ease
                Miss = Miss'; %flip the dimension, so instead of a column vector, its a row vector, matching Transients signal
                fprintf([patMISS,'es have been extracted!\n']);
            end
    end
    
    % Correct_Rej
    patCorrRejection = 'Correct Rejection';
    for z = 1:length(EventSheet(1,:))
            if (startsWith(EventSheet(1,z),patCorrRejection)) == 1
                Correct_Rej{z} = EventSheet(:,z);
                Correct_Rej = Correct_Rej{z}(2:end)
            end
        
            if z == (length(EventSheet(1,:)))
                Correct_Rej = cell2mat(Correct_Rej);  %change from cell array to a double for future computational ease
                Correct_Rej = Correct_Rej'; %flip the dimension, so instead of a column vector, its a row vector, matching Transients signal
                fprintf([patCorrRejection,'es have been extracted!\n']);
            end
    end
    
    % False_Alarm
    patMistake = 'Mistakes'; %in abet an S- miss is called 'mistake', but we call it a FAlarm
    for z = 1:length(EventSheet(1,:))
            if (startsWith(EventSheet(1,z),patMistake)) == 1
                False_Alarm{z} = EventSheet(:,z);
                False_Alarm = False_Alarm{z}(2:end)
            end
        
            if z == (length(EventSheet(1,:)))
                False_Alarm = cell2mat(False_Alarm);  %change from cell array to a double for future computational ease
                False_Alarm = False_Alarm'; %flip the dimension, so instead of a column vector, its a row vector, matching Transients signal
                fprintf([patMistake,' have been extracted!\n']);
            end
    end
    
    waitfor(msgbox(sprintf('%s,\n%s,\n%s,\n%s,\n%s,\n%s,\n%s,\n%s,\n%s,\n\nhave been extracted!',patFIRBeamON,patFIRBeamOFF,patCenterScreenTouch,patStartITI,patStimONSET,patHIT,patMISS,patCorrRejection,patMistake)))
    
    %% Sanity Checks
    % To check if things are working well, its good practice to open up
    % variables and make sure they look right, but there are a couple of sanity
    % checks we can implement here 
    sanitycheck1ans = questdlg(sprintf('Would you like to perform a sanity check here to verify that your event-types have been extracted/saved correctly?\n\nOne simple way we can do this, is by comparing the lengths of the original excel sheet timestamps list for a particular event, and the length of the extracted timestamps list for that same event-type.\n\nWe will look at ''Hits'', which I have visually verified as being in column 2. So we can then compare the length of the original sheet column 2 and the length of the isolated ''Hits'' variable we have extracted from the excel sheet.'))  
       if strcmp(sanitycheck1ans,'Yes') == 1 
            if length(Hit) == length(EventSheet([2:end],24))
                waitfor(msgbox(sprintf(('SANITY CHECK:\n\n Because the length of hits extracted and saved as a discrete variable: %d,\n accurately matches the length of hit events on the original Event Sheet:\n %d, \nIt seems like timestamps have been accurately parsed out!'),length(Hit),length(EventSheet([2:end],24)))))
            else 
                waitfor(msgbox(sprintf(('SANITY CHECK:\n\nBecause the length of extracted hits: %d, does not match the length of hit events on the original Event Sheet: %d, \nThere may be a problem with separating your event timestamps...\nPress any key and check back on your variables'),length(Hit),length(EventSheet([2:end],24)))))
            end
       end
        
    % A deeper check
    sanitycheck2ans = questdlg(sprintf('Would you like to perform another deeper-level check?\n\nWe can do this by randomizing an event number, for the Hits event-type, and comparing the value on the original excel sheet and the value of the same randomized event-number in our isolated/extracted Hits variable'))
    while strcmp(sanitycheck2ans,'Yes') == 1
        EventsValidHits = cell2mat(EventSheet([2:end],24));
        EventsValidHitsidx = isnan(EventsValidHits);
        EventsValidHits = (EventsValidHits(EventsValidHitsidx == 0)');
        randEvent = randi(length(EventsValidHits));
        sanitycheckval = cell2mat(EventSheet((randEvent+1),24));
        if (sanitycheckval) == Hit(randEvent)
            waitfor(msgbox(sprintf(('SANITY CHECK:\n\nBecause your randomized Hit event: event # %d,\nOf the hit events column in the original Event Sheet, timestamp-value: %d,\n\nMatches the same randomized event number timestamp-value in the extraced Hits variable: %d\n\nIt seems like timestamps have been accurately parsed out!.'),randEvent,sanitycheckval, Hit(randEvent))))
        else 
            waitfor(msgbox(sprintf(('SANITY CHECK:\nYour randomized extracted hit event, %d, \ndoes not match the first event of the original timesheet, %d, \nThere may be a problem with separating your event timestamps...'),Hit(randEvent),sanitycheckval)))
        end
        sanitycheck2ans = questdlg('Would you like to perform another randomized event check between the original ABET II Hit timestamps sheet and the extracted/created Hits variable')
    end
    
    
    
    
    %% Create Structures
    % index to include only accepted transients in the final structure
    desiredtransients = cellfun(@isempty, Accept_transients);
    
    % remove excess zeros, and add to loaded mousename structure
    savename. Transients = Accept_transients(desiredtransients == 0);
    
    %savename. Transients = Transients;
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
    
    % resave the structure to the correct folder
    cd(saveplace);
    save(mousename,'-struct', 'savename');
    waitfor(sprintf('Your new structure has been saved with in path:\n''%s'', with name:\n ''%s''',num2str(saveplace),num2str(mousename)))
    
    % Vars display?
    vardisplay = questdlg('Would you like to evaluate the variable created?')
        if strcmp(vardisplay,'Yes') == 1 
            waitfor(msgbox(sprintf('When you are finished evaluating the variable\nCLICK INTO THE COMMAND WINDOW (bottom of MATLAB)\n then type in ''dbcont''')))
            openvar('savename')
            sprintf('\n\nTYPE ''dbcont'' BELOW HERE')
            keyboard
        elseif strcmp(vardisplay,'Yes') == 0
        end
elseif strcmp(prepans, 'Yes') == 0 
    warndlg(sprintf('You will your calcium imaging transients as an excel file exported from Inscopix, as well as the behavioral event-timestamps exported from ABET II'))

end

