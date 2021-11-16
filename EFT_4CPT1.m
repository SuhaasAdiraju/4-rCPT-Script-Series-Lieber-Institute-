%% This script is for slicing and analyzing imaging transients

%% Identify saving variables 
vars = whos;
mousename = 'GRAB_NE_1640.mat';
saveplace = 'Z:\Circuits projects (CPT)\CPT Recording Data\GRAB_NE';


%% Reading in our main files

% cd to your folder containing the event files (timestamps sheet)
cd('D:\08.11.21 ONWARDS\CSV Behavioral Event Files');
% read in the csv file
filename = 'GRABNE_1640_S3_TTL.csv'; %your event sheet file name.csv
[Tstamps,Titles,EventSheet] = xlsread(filename);

% now cd to your imaging output folder (should be coming out of inscopix)
cd('C:\Users\sadiraj1\Desktop\Biosensor Imaging Data\11042021-1640-Good-S3-TTL');
% read in the transients matrix
Ne_transients = xlsread ("GRABNE_1640_CellTraces.csv");
% flip orientation, so time is x axis 
Ne_transients = Ne_transients';

% The rows here are ROIs, set in inscopix, so we can choose the one that
% fit best, in this case the ROI 5 was most optimal in terms of transient
% tracking
% 
% So lets only take the 5th row
Ne_transients = Ne_transients(5,:);

%quick test; does this look like what it should? there are other sanity
%test that could be employed...
figure; plot (Ne_transients(1:4000))

 % now we have our event sheet with corresponding timestamps that we wanna
 % use to grab specific parts of imaging transients, we can do this in a
 % similar fashion to LFP


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

% in loop fashion, we will grab the timestamps event titles and save them seperately 

% For FIRBeam On
pat = 'FIRBeam On'; %event name (this is 'pattern' and used to grab event TStamps based on the title they're under)
for z = 1:length(EventSheet(1,:))
        if (startsWith(EventSheet(1,z),pat)) == 1
            FIRBeam_On{z} = EventSheet(:,z);
            FIRBeam_On = FIRBeam_On{z}(2:end)
        end

        if z == (length(EventSheet(1,:)))
        FIRBeam_On = cell2mat(FIRBeam_On);  %change from cell array to a double for future computational ease
        FIRBeam_On = FIRBeam_On'; %flip the dimension, so instead of a column vector, its a row vector, matching Ne_transients signal
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
        FIRBeam_Off = FIRBeam_Off'; %flip the dimension, so instead of a column vector, its a row vector, matching Ne_transients signal
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
        Center_ScTouch = Center_ScTouch'; %flip the dimension, so instead of a column vector, its a row vector, matching Ne_transients signal
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
        Start_ITI = Start_ITI'; %flip the dimension, so instead of a column vector, its a row vector, matching Ne_transients signal
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
        Stimulus = Stimulus'; %flip the dimension, so instead of a column vector, its a row vector, matching Ne_transients signal
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
            Hit = Hit'; %flip the dimension, so instead of a column vector, its a row vector, matching Ne_transients signal
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
            Miss = Miss'; %flip the dimension, so instead of a column vector, its a row vector, matching Ne_transients signal
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
            Correct_Rej = Correct_Rej'; %flip the dimension, so instead of a column vector, its a row vector, matching Ne_transients signal
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
            False_Alarm = False_Alarm'; %flip the dimension, so instead of a column vector, its a row vector, matching Ne_transients signal
            fprintf([pat,' have been extracted!\n']);
        end
end


%% Sanity Checks
% To check if things are working well, its good practice to open up
% variables and make sure they look right, but there are a couple of sanity
% checks we can implement here 

if length(Hit) == length(EventSheet([2:end],24))
fprintf ('\nIt seems like timestamps have been accurately parsed out!')
else 
    disp ('\nThere may be a problem with separating your event timestamps...')
end

pause


% we can do this also

if (cell2mat(EventSheet(2,24))) == Hit(1)
    fprintf ('\nIt seems like timestamps have been accurately parsed out!')
else 
    disp ('\nThere may be a problem with separating your event timestamps...')
end

pause

%% Create Structures
% remove excess zeros, and add to loaded mousename structure
savename. Ne_transients = Ne_transients;
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


