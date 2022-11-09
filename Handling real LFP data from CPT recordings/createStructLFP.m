function createStructLFP
%% Description
    % This function is for the initial process of handling CPT recorded LFP data. 
    % More specifically how to combine the event data with recordings. It
    % assumes you have completed LFP4CPT 1 or performed the sirenia2mat
    % conversions
    
    
% - Written by Suhaas S. Adiraju 09.30.21


%% INPUTS
    % lfp_path - 
        % path to your lfp file saved after using sirenia2mat

    % lfp_name - 
        % name of the file 

    % Tstamps_path - 
        % path to timestamps sheet that comes out of ABET

    % Tstamps_filename - 
        % name of timestamps file that comes out of ABET

    % mousename - 
        % name of the structure you're gonna make

    % saveplace - 
        % path of location you'd like to save said structure
%% OUTPUTS
    % mouseStruc - 
        % structure containing lfp and timestamps you're gonna make


%% HEADS UP !

% This script assumes the user has already been through the Sirenia 2 Matlab
% example script!!!!

% Thus they now have .mat files within structures for each
% mouse... as well as *ACCESS* the matching CPT behavioral events taken
% from ABET software, and chamber # info


ansmain = questdlg('Do you have your LFP containing structure from the preceeding script, and the behavioral event timestamps for the session on-hand?')
if strcmp(ansmain, 'No') == 1
    warndlg('You will not be able to run this script or the function without a previously saved LFP file, and your ABET II timestamps accessible! Sorry, go back and retrieve those two')
    error('Issue encountered please rerun script')    
elseif strcmp(ansmain, 'Yes') == 1
    waitfor(msgbox(sprintf('Welcome to createStrucLFP function!\n\n\nPURPOSE:\nWalk the user through defining necessary inputs for the createStructLFP function made to create a structure for the given mouse combining raw LFP data, with behavioral event timestamps from ABET II.\n\n\nINPUTS:\n-lfp_name & lfp_path: User-selected LFP file structure created in the previous script\n\n-mousename: a name for the new structure that will be mad\n\n-Tstamps_name &Tstamps_path: User-selected behavioral timestamps excel file that comes out of ABET II\n\n\nOUTPUT:\n-mousename_struct: A user-named structure containing the timestamps and raw lfp')))
    
    % Thus they now have .mat files within structures for each
    % mouse... as well as *ACCESS* to the matching CPT behavioral events taken
    % from ABET software, and chamber # info
    
    %% Define in all necessary inputs
    
    clearvars -except stage

    
        % Below is the function indicating the necessary inputs
        % [mouseStruct] = createStructLFP(lfp_path,lfp_name, mousename, saveplace, Tstamps_path, Tstamps_filename)
        
        % if confused about the inputs, you can open the function ('open func. name)
        % or ('help func. name')
        
        % lfp_path
        waitfor(msgbox('A file selector will pop up, then select the the path to your existing LFP containing structure'))
        
        [lfp_name, lfp_path] = uigetfile % input ('What is the path to your existing LFP containing structure?  INDICATE IN FORMAT: {''path''}')
        while (lfp_name) == 0
             %error('You did not properly select an lfp file. Please try again')
             waitfor(warndlg('You did not properly select an lfp file. Please try again'))
             [lfp_name, lfp_path] = uigetfile('','Please select the lfp file previously created for the desired mouse')
        end
    
        
        % Set mousename to save with later
        mousename = erase (lfp_name, '.mat');
            
            
        % Tstamps_path
        waitfor(msgbox({'A file selector will pop up, Then SELECT THE PATH TO YOUR EXISTING BEHAVIORAL EVENTS TIMESTAMPS EXCEL FILE.'}))
        [Tstamps_filename, Tstamps_path] = uigetfile('*.csv*', 'Please select the Timestamps file for the mouse you are analyzing')
           while (Tstamps_filename) == 0
             %error('You did not properly select a timestamps file. Please try again')
             waitfor(warndlg('You did not properly select a timestamps file. Please try again. Please try again. Or if you are trying to quit the script, press Stop, in the editor tab of MATLAB'))
             [Tstamps_filename, Tstamps_path] = uigetfile('*.*', 'Please select the Timestamps file for the mouse you are analyzing')
           end  
    

        % saveplace
        waitfor(msgbox({'A file selector will pop up.';' ';'Then select the the folder in which you would like to save your output structure'}))
        saveplace = uigetdir('','Please select the folder you would like to save your resulting structure in')
            while (saveplace) == 0
                % error('You did not properly select an place to save. Please try again')
                waitfor(warndlg('You did not properly select an place to save. Please try again. Or if you are trying to quit the script, press Stop, in the editor tab of MATLAB'))
                saveplace = uigetdir('','Please select the folder you would like to save your resulting structure in')
            end
    
        waitfor(msgbox('All necessary inputs recieved! All set to run ''createStructLFP function!''.'))


%% Execution 

% toggle to the folder with the saved mouse structure containing LFP (created using sirenia2mat function) 
cd(lfp_path);

% set savename == to the lfp structure variable loaded in so it can be
% flexibly resaved 
savename  = load (lfp_name); %load said structure, you need '.mat'

%{

% rename the mouse structure you want to complete so we can add to it.
        %savename = lfp_name; % you dont need '.mat'
        % saveplace = ['Z:\Circuits projects (CPT)\CPT Recording Data\LC-mPFC LFP']% path to folder you'd like to save resulting structure in

% BUT, also define a mousename, so we can re-save the structure w/ the
% correct name 
    % vars= whos;
    % mousename = vars.name;


% OPEN your cpt behavioral events file (these are taken off of CPT chamber
% computer in the back-room via hard-drive; and are in the form of .csv
% file) (matching the correct behavioral event data to the proper LFP
% output file takes care in naming and may require some data sleuthing
% using dates etc., so it's a good thing to keep in mind when naming
% behavioral/recording sessions)

cd(Tstamps_path);

%}

% Next
cd(Tstamps_path);
[Tstamps,Titles,EventsFull] = xlsread(Tstamps_filename); % convert to cell arrays
% this pops out three things to work with, just the TStamp values, just the
% titles, and both together 


parCh3 = 'Chamber3';
parCh4 = 'Chamber4';


% This loop will go through your events sheet, see if there is both
% chambers 3 and 4, or just 3, or just 4, let you know what it found, and
% create distinct variables with the associated timestamps for chambers 3
% and 4 

for z = 1:length(EventsFull(:,3))
        if (startsWith((EventsFull(z,3)),parCh3))==1
            while z == 1
                fprintf ('\nCreating timestamp sheet for Chamber 3...');
            end
            Ch3Events = EventsFull(:,:); 
            chamber = Ch3Events;
        end
        if (startsWith((EventsFull(z,3)),parCh4))==1
            while z == 1
                fprintf ('\nCreating timestamp sheet for Chamber 4...');
            end
            Ch4Events = EventsFull(:,:);
            chamber = Ch4Events;
        end
        
        if z == length(EventsFull(:,3))
            if (exist('Ch3Events')) == 1
                fprintf('\n\nChamber 3 data extracted!')
            end
            if (exist ('Ch3Events')) == 0
                fprintf('\n\nChamber 3 not found.')
            end
            if (exist ('Ch4Events')) == 1 
                fprintf('\n\nChamber 4 data extracted!')
            end
            if (exist ('Ch4Events')) == 0
                fprintf('\n\nChamber 4 not found.')
            end
        end
end
    
            

% Initialize variables for events of desire (good practice to predefine)
    % Eventually, we can have the user input what variables they desire,
    % and whatever/however many will be pre-allocated for
FIRBeam_On = {};
FIRBeam_Off = {};
Center_ScTouch = {}; 
Start_ITI = {};
Stimulus = {};
Hit = {};
Miss = {};
Correct_Rej = {};
False_Alarm = {};


%% In loop fashion, grab the timestamps event titles and save them seperately 

%(if you are confident in the applicability of this section to your dataset, you can 'run section' for speed)

% just dont forget to choose the correct chamber (%chamber = Ch3Events;) 
    % EDIT ON THIS: now, the loop in the ^ prev. section will automatically
    % define chamber for you. if for some rzn you need to, you could
    % hard-code 'chamber = whatever;'

% event array of given chamber; define based on what chamber you want data from (aka what ch. your mouse was in) 

% For FIRBeam On
pat1 = 'FIRBeam On'; %event name (this is 'pattern' and used to grab event TStamps based on the title they're under)
for z = 1:length(chamber(1,:))
        if (startsWith(chamber(1,z),pat1)) == 1
            FIRBeam_On{z} = chamber(:,z);
            FIRBeam_On = FIRBeam_On{z}(2:end)
        end

        if z == (length(chamber(1,:)))
        FIRBeam_On = cell2mat(FIRBeam_On);  %change from cell array to a double for future computational ease
        FIRBeam_On = FIRBeam_On'; %flip the dimension, so instead of a column vector, its a row vector, matching lfp signal
        fprintf([pat1,'''s have been extracted!\n']);
        end
end

% For FIRBeam Off
pat2 = 'FIRBeam Off';
for z = 1:length(chamber(1,:))
        if (startsWith(chamber(1,z),pat2)) == 1
            FIRBeam_Off{z} = chamber(:,z);
            FIRBeam_Off = FIRBeam_Off{z}(2:end)
        end
    
        if z == (length(chamber(1,:)))
        FIRBeam_Off = cell2mat(FIRBeam_Off);  %change from cell array to a double for future computational ease
        FIRBeam_Off = FIRBeam_Off'; %flip the dimension, so instead of a column vector, its a row vector, matching lfp signal
        fprintf([pat2,'''s have been extracted!\n']);
        end
end


% For Center screen touch 
pat3 = 'Center Screen Touch';
for z = 1:length(chamber(1,:))
        if (startsWith(chamber(1,z),pat3)) == 1
            Center_ScTouch{z} = chamber(:,z);
            Center_ScTouch = Center_ScTouch{z}(2:end);
        end
        
        if z == (length(chamber(1,:)))
        Center_ScTouch = cell2mat(Center_ScTouch);  %change from cell array to a double for future computational ease
        Center_ScTouch = Center_ScTouch'; %flip the dimension, so instead of a column vector, its a row vector, matching lfp signal
        fprintf([pat3,'es have been extracted!\n']);
        end
end

% For Start ITI
pat4 = 'Start ITI';
for z = 1:length(chamber(1,:))
        if (startsWith(chamber(1,z),pat4)) == 1
            Start_ITI{z} = chamber(:,z);
            Start_ITI = Start_ITI{z}(2:end)
        end
        %
        if z == (length(chamber(1,:)))
        Start_ITI = cell2mat(Start_ITI);  %change from cell array to a double for future computational ease
        Start_ITI = Start_ITI'; %flip the dimension, so instead of a column vector, its a row vector, matching lfp signal
        fprintf([pat4,'es have been extracted!\n']);
        end
end

% For Stimulus (stimulus presentation)
pat5 = 'Stim Onset';
for z = 1:length(chamber(1,:))
        if (startsWith(chamber(1,z),pat5)) == 1
            Stimulus{z} = chamber(:,z);
            Stimulus = Stimulus{z}(2:end)
        end
    
        if z == (length(chamber(1,:)))
        Stimulus = cell2mat(Stimulus);  %change from cell array to a double for future computational ease
        Stimulus = Stimulus'; %flip the dimension, so instead of a column vector, its a row vector, matching lfp signal
        fprintf([pat5,'es have been extracted!\n']);
        end
end


% Hit
pat6 = 'Hit';
for z = 1:length(chamber(1,:))
        if (startsWith(chamber(1,z),pat6)) == 1
            Hit{z} = chamber(:,z);
            Hit = Hit{z}(2:end)
        end

        if z == (length(chamber(1,:)))
            Hit = cell2mat(Hit);  %change from cell array to a double for future computational ease
            Hit = Hit'; %flip the dimension, so instead of a column vector, its a row vector, matching lfp signal
            fprintf([pat6,'es have been extracted!\n']);
        end
end


% Miss
pat7 = 'Misses';
for z = 1:length(chamber(1,:))
        if (startsWith(chamber(1,z),pat7)) == 1
            Miss{z} = chamber(:,z);
            Miss = Miss{z}(2:end)
        end
    
        if z == (length(chamber(1,:)))
            Miss = cell2mat(Miss);  %change from cell array to a double for future computational ease
            Miss = Miss'; %flip the dimension, so instead of a column vector, its a row vector, matching lfp signal
            fprintf([pat7,'es have been extracted!\n']);
        end
end

% Correct_Rej
pat8 = 'Correct Rejection';
for z = 1:length(chamber(1,:))
        if (startsWith(chamber(1,z),pat8)) == 1
            Correct_Rej{z} = chamber(:,z);
            Correct_Rej = Correct_Rej{z}(2:end)
        end
    
        if z == (length(chamber(1,:)))
            Correct_Rej = cell2mat(Correct_Rej);  %change from cell array to a double for future computational ease
            Correct_Rej = Correct_Rej'; %flip the dimension, so instead of a column vector, its a row vector, matching lfp signal
            fprintf([pat8,'es have been extracted!\n']);
        end
end

% False_Alarm
pat9 = 'Mistakes'; %in abet an S- miss is called 'mistake', but we call it a FAlarm
for z = 1:length(chamber(1,:))
        if (startsWith(chamber(1,z),pat9)) == 1
            False_Alarm{z} = chamber(:,z);
            False_Alarm = False_Alarm{z}(2:end)
        end
    
        if z == (length(chamber(1,:)))
            False_Alarm = cell2mat(False_Alarm);  %change from cell array to a double for future computational ease
            False_Alarm = False_Alarm'; %flip the dimension, so instead of a column vector, its a row vector, matching lfp signal
            fprintf([pat9,' have been extracted!\n']);
        end
end
fprintf([pat1, pat2, pat3, pat4, pat5, pat6, pat7, pat8, pat9,' have been extracted!\n']);


%% Sanity Check 
sanity1  = questdlg('Would you like to perform a sanity check on the method for extracting event timestamps?')
    if strcmp(sanity1,'Yes') == 1
        waitfor(msgbox(sprintf('Here I am doing a ''sanity-check'' to make sure things are correct, not just working.\n\nI have visually verified that the Hits variable on the original timestamps sheet is the 24th row, to cross check our identification and extraction process for event-types, we can compare our newly isolated Hits variable and the original column of hits.')))
        eventTest = randi(12)
        if isequaln(cell2mat(EventsFull(2:end,24)), Hit(:,:)') == 1
                waitfor(msgbox(sprintf('For randomized event: %d, our original Event sheet value: %d, and our extracted Hit event value: %d, match!\n\nAdditionally the entire vectors are equivalent',eventTest,(cell2mat(EventsFull(eventTest+1,24))),Hit(1,eventTest))))
        end
    else
    end
%% lfp formatting 
% Previously necessary when lfp autosaved as a timetable 
    % for now, need to convert lfp from timetable to matrix; and flip it into
    % the desired orientation
            % lfp = table2cell(savename.lfp);
            % lfp = cell2mat(lfp);
            % lfp = lfp';

% %%
% remove excess zeros, and add to loaded mousename structure
%savename. lfp = lfp;
savename. FIRBeam_On = FIRBeam_On(isnan(FIRBeam_On) == 0);
savename. FIRBeam_Off = FIRBeam_Off(isnan(FIRBeam_Off) == 0);
savename. Center_ScTouch = Center_ScTouch(isnan(Center_ScTouch) == 0);
savename. Start_ITI = Start_ITI(isnan(Start_ITI(2:end)) == 0);
savename. Stimulus = Stimulus(isnan(Stimulus(2:end)) == 0);
savename. Hit = Hit(isnan(Hit) == 0);
savename. Miss = Miss(isnan(Miss) == 0);
savename. Correct_Rej = Correct_Rej(isnan(Correct_Rej) == 0);
savename. False_Alarm = False_Alarm(isnan(False_Alarm) == 0);
savename. ChamberSource  = chamber(3,3);

% resave the structure to the correct folder
cd(saveplace);

%assignin('base',mousename,savename)        

save(mousename,'-struct','savename');

waitfor(msgbox(sprintf('Your new structure has been saved\n\nAs Name:\n''%s'', \n\nin Path:\n''%s'' !',mousename,saveplace)))

vardisplay = questdlg('Would you like to evaluate the variable created?')
    if strcmp(vardisplay,'Yes') == 1 
        waitfor(msgbox(sprintf('When you are finished evaluating the variable\nCLICK INTO THE COMMAND WINDOW (bottom of MATLAB)\n then type in ''dbquit''')))
        openvar('savename')
        sprintf('\n\nTYPE ''dbcont'' BELOW HERE')
        keyboard
    elseif strcmp(vardisplay,'Yes') == 0
    end


end

% LabMeetingmouse_struct = load('LabMeetingMouse.mat');