%% Basic analysis with behavioral surrounding Ca2 transients 
% This script is beginning the basic analyses with CA2 imaging such as
% collapsing across trials and neurons;
% written assuming the user has
% 1) followed Ca2imaging 4 CPT 1, saved a
% structure with raw data and timestamps
% 2) followed Ca2imaging 4 CPT 1, produced the 'CutTransients' structure,
% and now is coming over to start analysis using this script 

% This also uses the example of the Event "Hits", but can be implemented
% for any event type

% - Written by Suhaas S Adiraju

%% Load in our existing data to work with 
% (for now the data is too large, so just complete script 2, and move to script 3, dont try to save and reload)

%cd('Z:\Circuits projects (CPT)\CPT Recording Data\GCaMP6f');
%load ('CutTransients.mat') %load your structure

%% For calcium imaging, something we want is to average across events and neurons
% just for a reminder, identify your window of analysis 
win = length(CutTransients.Hit_Transients{1})
win/2
% the sampling rate was ~30, so we have 4 seconds of transient before and after each hit

% Now i want to average across hit events, and have a vector of one
% averaged hit 'event', so add up each timestamp-based transient across
% events and divide by the number of events 

% We can compute an example for the first timestamps across all events (of
% a specific category...like 'the first hit timestamp transient value for 1 neuron, all events'

% so we grab the first timestamp transient value of all events for 1 neuron like so 
   for eventi = 1:length(CutTransients.Hit_Transients(1,:))
       exampleCellStamps(1,eventi) = CutTransients.Hit_Transients{1,eventi}{1,1};
   end

%% Sanity check, do things match-up? 
% we will take the 1st timestamp of the 1st neuron 3rd event (arbitrary testing)
test1 = CutTransients.Hit_Transients{1,3}{1,1};

% and now compare it to the same neuron same event of the example cell
% stamps variable we made
if exampleCellStamps(1,3) == test1;
       exampleAvg = sum(exampleCellStamps)
       sprintf('Looks like the grabbing the first timestamp from each event for one neuron worked out! now you have an example average also')
else 
       disp('Somethings up here...try to check your work')
end

% if yes, lets move forward, and we have a 1neuron example to check our
% full matrix with!


%% Using our example as a reference, lets now work on it for all events all timestamps

% This may help if the syntax is really confusing here
% CutTransients.Hit_Transients is organized as such
    % CutTransients.Hit_Transients(neuron,event#){timestamp based transients}

% this gets quite confusing, the key is understanding how your data being 
% used is organized, refer above for some help with this

% Every neuron, every transient, organized by timestamp, for every event
    % so cell array is neuron, row is timestamp, and column is event 
for neuroni = 1:length(CutTransients.Hit_Transients(:,1))
    for eventi = 1:length(CutTransients.Hit_Transients(1,:))
        for stampi = 1:length(CutTransients.Hit_Transients{1,1})
           AllCell_array{neuroni}(stampi,eventi) = CutTransients.Hit_Transients{neuroni,eventi}{1,stampi};
           
        end
    end
end


%% Lets do some sanity checks... 

% We can verify that the first column of our All Cell matrix 
% (all timestamp associated transients in the defined window for each event) is correctly brought over

% so within the CutTransients.Hit_Transients(1,1), that's our original, and representative of 8 seconds
% of transient from one neuron for 1 event

% AllCell_array(1,1){:,1}, or within one cell array(neuron), all rows in the first column (8 second timewindow)
% should be the same

% I know this can be confusing, but I am going to validity for multiple
% neurons and events

% we first need to break out of cell array structure for '==' type
% comparisons, done by converting to doubles (that's what cell2mat does),
% you cant compare cell arrays in a logical manner 

% Test 1; Neuron 1//Transients of the 8 second time window//For Event #1
testAllCell = cell2mat(AllCell_array(1,1)); % first neuron, all events all 8 second windows
testOG = cell2mat(CutTransients.Hit_Transients{1,1}); % first neuron, first event's 8 second window

if testOG == (testAllCell(:,1)')
    sprintf('Because our event-based time-window transients for Neuron 1 saved in our new structure,\n (AllCell_array) \nand our original event-based time window transients match...\nWere good to go!')
end
pause
clear testAllCell testOG

% Test 2; Neuron 1//Transients of the 8 second time window//For Event #2
testAllCell = cell2mat(AllCell_array(1,1)); % first neuron, all events all 8 second windows
testOG = cell2mat(CutTransients.Hit_Transients{1,2}); % first neuron, SECOND event's 8 second window

if testOG == (testAllCell(:,2)')
    sprintf('Because our event-based time-window transients for Neuron 1 saved in our new structure,\n (AllCell_array) \nand our original event-based time window transients match...\nWere good to go!')
else 
    sprintf('Something is off between your original transients x (neuron,event) array and your new transients x (timestamps,event) array')
end

pause
clear testAllCell testOG


% Test 3; Neuron 2//Transients of the 8 second time window//For Event #3
% (to make it arbitrary for safety)
% 
testAllCell = cell2mat(AllCell_array(1,2)); % Now second neuron, all events all 8s time windows
testOG = cell2mat(CutTransients.Hit_Transients{2,3}); % Now 2nd neuron, 3rd event's 8 second window

if testOG == (testAllCell(:,3)') %because we took all events all windows from AllCell, the column # here indicates what event to assess
    sprintf('Because our event-based timestamp transients for Neuron 1 grabbed from our original structure,\n (saved in AllCell_array) \nand our original event-based time window transients match...\nWere good to go!')
else 
    sprintf('Something went wrong here...')
end
pause
clear testAllCell testOG
%% Summing the transients
% Now we can simply use the matlab sum(A) function, which sums across the
% dimension of choice in a matrix; the default is the sum of each column,
% which is what we want! So...
for neuroni = 1:length(AllCell_array)
    AvgNeuronWins{neuroni} = sum(AllCell_array{neuroni},2);   
end

% lets flip everything to be row vectors after we finish summing cause its
% best for plotting

for neuroni = 1:length(AllCell_array)
    AllCell_array{neuroni} = AllCell_array{neuroni}';
end

%% A couple sanity checks here too!

% Test 1, the length of our Averaged Hit Window
if length(AvgNeuronWins{1}) == length(CutTransients.Hit_Transients{1})
    sprintf('\nYour original array neuron 1 event one window length\nand the length of your neuron 1 averaged window match!')
else
    sprintf('\nyou need to check out your averaging step, the length of your average window is incorrect')
end

% 2, is using our handy example average! 
% Remember, we made the average of timestamp 1 associated transients, across all the events, for Neuron 1
% So...
if exampleAvg == AvgNeuronWins{1,1}(1,1)
    sprintf('\nBecause your 1st timestamp average across events (for Neuron 1) \nmatches between your original example average \nand your All cell averaging,\nYour AllCell array looks good!')
else
    sprintf('\nyou need to check out your averaging step,\nyour first timestamp across events for neuron 1 average,\nand your original example don''t match')
end


%% Plotting

% this plots the averaged across events traces for every neuron 
srate = 30.0136; % for now 
hitlength = linspace(-(length(CutTransients.Hit_Transients{1})/(srate*2)),(length(CutTransients.Hit_Transients{1})/(srate*2)),length(CutTransients.Hit_Transients{1}));
% Check it out
for neuroni = 1:length(AvgNeuronWins)
    figure; 
    plot(hitlength,AvgNeuronWins{neuroni}, 'k', 'LineWidth',1)
    xlabel('Time(s)')
    ylabel('dF/F')
    xlim ([-4 4])
    title(sprintf('Neuron %d, Hit Averaged Activity',neuroni))
end

%% Directions to consider

% I think now could start to attempt some computational things, for
% starters, thresholding averages, and identifying a few common motifs

% If we move out of just hits, we can model neural activity predicting
% stimulus (i think this is possible in calcium imaging 
