%% Ca2Imaging_4CPT1
% this is a companion/example/template script for running the fuction
% createStrucCA2. The end result is a structure containing inscopix derived
% CA2 transients, and ABET ....

% Written by Suhaas S Adiraju

%% First things first...

% The function we will be using here is called 'createStrucCA2'

% You need to have the correct paths added for whatever you work on in
% matlab so it knows where to source from 
% This can be permanantly set, but for now, this method works smoothest
    % path for the function used in this script
functionpath = {'Z:\Circuits projects (CPT)\Working With BioSensor Transients'}
addpath(functionpath{1});


%% Identify Required Variables

% Read the function description to understand the required inputs 
open createStrucCA2

%% Define required input variables 

 sprintf('\n\n Press any key to continue, when you do,\n A file selector will pop up,\n Then select your behavioral Timestamps file from ABET')
 pause
 [Tstamps_name, Tstamps_path] = uigetfile
        % Tstamps_path = {'Z:\Circuits projects (CPT)\CPT Recording Data\EXAMPLE SCRIPTS SAMPLE DATA'};

        %Tstamps_name = {'CA2_1855_Timestamps_Ca2.csv'};

 sprintf('\n\n Press any key to continue, when you do,\n A file selector will pop up,\n Then select your calcium imaging transients file from Inscopix')
 pause
 [transients_name, transients_path] = uigetfile
        %transients_path = {'Z:\Circuits projects (CPT)\CPT Recording Data\EXAMPLE SCRIPTS SAMPLE DATA'};

        %transients_name = {'CA2_1855_good_S3_TTL_Cell_Traces.csv'}; % dont forget .csv!!
sprintf('\n\n Press any key to continue, when you do,\n A window will pop up,\n Then enter WHAT WOULD YOU LIKE TO NAME YOUR RESULTING STRUCTURE')
pause
prompt = {'Enter mousename, aka what you would like to name the output structure from this function?'}
mousename = inputdlg(prompt);        %{'CA2_1855_good_S3_TTL_Cell_Traces'}; %name of mouse/what you want to save the struc. as, must start w a letter;

sprintf('\n\n Press any key to continue, when you do,\n A file selector will pop up,\n Then select the the path to where you would like to save your new structure')
pause
saveplace = uigetdir
        %saveplace = {'Z:\Circuits projects (CPT)\CPT Recording Data\EXAMPLE SCRIPTS SAMPLE DATA'}; %where are you saving your data

%% All set! Run your function
% Run
sprintf('All necessary inputs have been recieved, running createStrucCA2 function!')
createStrucCA2(Tstamps_path, Tstamps_name, transients_path, transients_name, mousename, saveplace)


%% THE FUNCTION 
function [Ca2Struct] = createStrucCA2(Tstamps_path, Tstamps_name, transients_path, transients_name, mousename, saveplace);
%% Description 

% This function is for compiling the necessary components for analysis of
% calcium imaging transients yielded from inscopix software

% We will combine these transients with behavioral event timestamps yielded
% from ABET software

% Written by Suhaas S Adiraju
%% INPUTS
% Tstamps_path - 
    % the path to your Tstamps file (coming out of ABET)

% Tstamps_name - 
    % the name of your timestamps file 

% transients_path - 
    % path to the file containing your Calcium imaging transients 

% mousename - 
    % name of the subject and how you want your structure to be saved

% saveplace - 
    % path to location of where you want your new structure to be saved 


%% OUTPUTS
% Ca2Struct - 
    % your calcium transients and associated event-based timestamps structure

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
Ca_transients = (EventSheet_transients([2:end],[2:end])');

patCell = ' accepted';
for z = 1:length(Ca_transients(:,1))
        if (startsWith((Ca_transients(z,1)),patCell))==1
            Accept_transients{z} = Ca_transients(z,[2:end]);
        elseif (startsWith((Ca_transients(z,1)),patCell))==0
            Accept_transients{z} = [];
        end
end

% desiredtransients = cellfun(@isempty, Accept_transients);
% desiredtransients = Accept_transients(desiredtransients == 0);
% cell2mat(desiredtransients);

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

%% Now in loop fashion, we will grab the timestamps event titles and save them seperately 

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
        fprintf([pat,'s have been extracted!\n']);
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
    sprintf(('SANITY CHECK:\n\nBecause the length of hits grabbed from the Event sheet, %d,\n accurately matches the length of hit events on the original Event Sheet,\n %d, \nIt seems like timestamps have been accurately parsed out! \nPress any key to continue'),length(Hit),length(EventSheet([2:end],24)))
else 
    sprintf(('SANITY CHECK:\nThe length of hits, %d, does not match the length of hit events on the original Event Sheet, %d, \nThere may be a problem with separating your event timestamps...\nPress any key and check back on your variables'),length(Hit),length(EventSheet([2:end],24)))
end
pause


% we can do this also
sanitycheckval = cell2mat(EventSheet(2,24));
if (sanitycheckval) == Hit(1)
    sprintf(('SANITY CHECK:\n\nBecause your first extracted Hit event, %d, \nmatches the first hit event on the original Event Sheet, %d, \nIt seems like timestamps have been accurately parsed out! \nPress any key to continue...'),Hit(1),sanitycheckval)
else 
    sprintf(('SANITY CHECK:\nYour first extracted hit event, %d, \ndoes not match the first event of the original timesheet, %d, \nThere may be a problem with separating your event timestamps...\nPress any key to continue but check back on your work'),Hit(1),sanitycheckval)
end

pause

%% Create Structures
% index to include only accepted transients in the final structure
desiredtransients = cellfun(@isempty, Accept_transients);

% remove excess zeros, and add to loaded mousename structure
savename. Transients = Accept_transients(desiredtransients == 0);
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
save(mousename{1},'-struct', 'savename');
sprintf('Your new structure has been saved with in path:\n''%s'', with name:\n ''%s''',num2str(saveplace),num2str(mousename{1}))
end

