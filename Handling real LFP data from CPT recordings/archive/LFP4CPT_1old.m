% This script is a walkthrough of how to handle CPT recorded LFP data. 

% This script assumes the user has already been through the Sirenia to Matlab
% example script, and now have .mat files within structures for each
% mouse... as well as *ACCESS* the matching CPT behavioral events taken from ABET software

% toggle to the folder with the saved mouse structure containing LFP (created using sirenia2mat
% function) 

 %'yourpath'
cd('Z:\Circuits projects (CPT)\CPT Recording Data\LC-mPFC LFP'); %'yourpath' to your .mat file

load ('S3Good_1328S_chamber3'); %load said structure


% name of the mouse structure you want to complete
savename = 'S2Good_1328_S';  



% OPEN your cpt behavioral events file (these are taken off of CPT chamber
% computer in the back-room via hard-drive; and are in the form of .csv
% file) (matching the correct behavioral event data to the proper LFP
% output file takes care in naming and may require some data sleuthing
% using dates etc., so it's a good thing to keep in mind when naming
% behavioral/recording sessions)

cd('G:\08.11.21 ONWARDS\CSV Behavioral Event Files');




disp ('Ok, NOW OPEN THE .CSV BEHAVIORAL SHEET, AND IMPORT AS A STRING ARRAY!')
%in order to load in the .csv, open it using the directory explorer on the
%left hand side, and select the columns you need and import selection as a string array


event_sheet = S2Good1328Sbehavioralevents; %name this the name of the behavioral sheet you loaded in!! NO QUOTES

%% Next
% from the main imported string array, grab columns of interest (row,columns)
Events = event_sheet(:,[1 4 9]);

% initialize variables for events of desire
Start_ITI = [];
Center_ScTouch = [];
ITI_Timer = [];
Hit = [];

% in loop fashion, grab the timestamps for particular events and save them
% seperately 
for z = 1:length(Events)
    if Events(z,2) == "Start ITI"
        Start_ITI(z) = Events(z);
    end
end
for z = 1:length(Events)
    if Events(z,2) == "Centre Screen Touches"
        Center_ScTouch(z) = Events(z);
    end
end
for z = 1:length(Events)
    if Events(z,2) == "ITI_Timer"
        ITI_Timer(z) = Events(z,1);  
    end
end

for z = 1:length(Events)
    if Events(z,2) == "Hit"
        Hit(z) = Events(z,1);       
    end
end

% remove excess zeros, and add to loaded mousename structure (lfp already saved inside using sirenia2mat function)
mousename. Start_ITI = Start_ITI(Start_ITI ~= 0);
mousename. Center_ScTouch = Center_ScTouch(Center_ScTouch ~= 0); 
mousename. ITI_Timer = ITI_Timer(ITI_Timer ~= 0); 
mousename. Hit = Hit(Hit ~= 0); 
mousename. WARNING = 'START ITI VARIABLE IS MISSING ITS INITIAL 0 (SHOULD START AT 0, MAKE SURE YOU FACTOR THIS IN FOR GRABBING LFP'
% resave the structure to the correct folder
cd('Z:\Suhaas A\CPT Data\LC-mPFC LFP');
save(savename, 'mousename');

%% Analysis and using lfp

% now that we have behavioral events in an index, we need to grab LFP based
% on timestamps, namely because our LFP signals endpoint is not accurate at
% all to the behavioral session end. The behavioral timestamps are in
% seconds, so we need our lfp in seconds (this process is elaborated on in
% the LFP basics tutorials)

LC_S2Good_1328_T = S2Good_1328_T.lfp(3:end);
PFC_S2Good_1328_T = S2Good_1328_T.lfp(4:end);

srate = 2000;
timeEeg = (length(LC_S2Good_1328_T))/srate; % total time in seconds
EEGtimePS1 = linspace(0, timeEeg, (length(LC_S2Good_1328_T))); % give me a vector containing 0-->total time, scaled to the origninal size of the LFP file 


% give me lfp signal = to 1800s (time of 30 min CPT recording session)
cpt_schLength = EEGtimePS1(EEGtimePS1 <= 1800); % of the timescaled vector,
                                                 % give me 0-1800s. The 
                                                 % length of the vector is 
                                                 % not corresponding to time; 
                                                 % the values are; so we want the values == 0-1800
LC_S2Good_1328_T = LC_S2Good_1328_T(1:(length(cpt_schLength)));
                                            % because the vector of cpt_schLength was sourced from the time-vector scaled to the
                                            % # of data points from the EEG
                                            % recording, we want EEG data
                                            % points = to the length of our
                                            % 1800s vector
                                            
