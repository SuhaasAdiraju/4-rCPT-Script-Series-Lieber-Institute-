%% Basic analysis with behavior-surrounding NTsensor transients 
% This script is beginning the basic analyses with Neurotransmitter sensor imaging such as
% collapsing across trials;

% Written assuming the user has:
    % 1) followed NTsensors 4 CPT 1, saved a
    % structure with raw data and timestamps
    
    % 2) followed NTsensors 4 CPT 2, produced the 'CutTransients' structure,
    % and now is coming over to start analysis using this script 

% This also uses the example of the Event "Hits", but can be implemented
% for any event type

% - Written by Suhaas S Adiraju

%% Loading in your data (SKIP IF STRUCTURE IN WORKSPACE ALREADY)
% Typically, the user should carry over the data and variables generated
% from NTsensors_4CPT2, but, if you saved the outputs of that script, you
% should load them in via...

cd('Z:\Circuits projects (CPT)\CPT Recording Data\EXAMPLE SCRIPTS SAMPLE DATA'); 
load('GRAB_NE_1640_sample.mat'); 

%% Define some necessary variables
strucname = GRAB_NE_1640_sample; % enter the name of the structure 
Event_Type = strucname.Center_ScTouch_Transients; % enter the name of the event-type of desire
srate = strucname.srate;
TimeWin = strucname.TimeWin;

%% Create a new array...

% We need a new array which contains, from each event, the
% timestamp-associated transient value, in columns, stacked, so like (1,1)
% should be from event one, then (1,2) should be the first
% timestamp-associated transient value from event two;

for eventi = 1:length(Event_Type)
    for stampi = 1:length(Event_Type{1,1})
        AllEventArray(eventi,stampi) = Event_Type{1,eventi}(1,stampi);
    end
end

% Now we can average...
AllEventAvg = mean(AllEventArray,1);

%% Now we can plot...

hitlength = linspace(-(length(Event_Type{1})/(srate*(TimeWin/2))),(length(Event_Type{1})/(srate*(TimeWin/2))),length(Event_Type{1}));

figure;
plot(hitlength, AllEventAvg,'k', 'LineWidth',1)
%ylim([0.04 0.05])
title (sprintf('Avg Response Window (%d s)',TimeWin))
xlim([-TimeWin TimeWin])


