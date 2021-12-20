%% Basic analysis with behavior-surrounding Ca2 transients 
% This function is beginning the basic analyses with CA2 imaging such as
% collapsing across trials;

% Written assuming the user has:
    % 1) followed NTsensors 4 CPT 1, saved a
    % structure with raw data and timestamps
    
    % 2) followed Ca2imaging 4 CPT 2, produced the 'CutTransients' structure,
    % and now is coming over to start analysis using this script 

% This also uses the example of the Event "Hits", but can be implemented
% for any event type

% - Written by Suhaas S Adiraju

%% Loading in your data
% Typically, the user should carry over the data and variables generated
% from NTsensors_4CPT2, but, if you saved the outputs of that script, you
% should load them in via...

cd('path');
load('variablename.mat'); %should be the CutTransients structure

%% Create a new array...

% We need a new array which contains, from each event, the
% timestamp-associated transient value, in columns, stacked, so like (1,1)
% should be from event one, then (1,2) should be the first
% timestamp-associated transient value from event two;

for eventi = 1:length(CutTransients.Hit_Transients)
    for stampi = 1:length(CutTransients.Hit_Transients{1,1})
        AllEventArray(eventi,stampi) = CutTransients.Hit_Transients{1,eventi}(1,stampi);
    end
end

% Now we can average...
AllEventAvg = mean(AllEventArray,1);

%% Now we can plot...

hitlength = linspace(-(length(CutTransients.Hit_Transients{1})/(srate*(TimeWin/2))),(length(CutTransients.Hit_Transients{1})/(srate*(TimeWin/2))),length(CutTransients.Hit_Transients{1}));

figure;
plot(hitlength, AllEventAvg,'k', 'LineWidth',1)
ylim([0.04 0.05])
xlim([-4 4])

