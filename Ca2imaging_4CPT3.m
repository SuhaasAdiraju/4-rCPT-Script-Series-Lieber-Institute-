%% DESCRIPTION
% Basic analysis with behavior-surrounding Ca2 transients 
% This function begins the basic analyses with CA2 imaging such as
% collapsing across trials;

% Written assuming the user has:
    % 1) followed Ca2imaging 4 CPT 1, saved a
    % structure with raw data and timestamps

    % 2) followed Ca2imaging 4 CPT 2, produced the 'CutTransients' structure,
    % and now is coming over to start analysis using this script 

% You may simply 'Run' this script (editor tab top left). After input of strucpath and strucname
% Or run piece by piece if trying to learn

% - Written by Suhaas S Adiraju

%% Define and load your previously saved structure (data set)
strucpath = {'Z:\Circuits projects (CPT)\CPT Recording Data\EXAMPLE SCRIPTS SAMPLE DATA'};
strucname = {'S3Good_1855_Ca2'}; % enter the name of the structure

cd(strucpath{1});
load (strucname{1}) %load your structure


%% What event type would you like to look at?

vars = who;
sprintf('%s\n',vars{:})
x = input ('Above includes display of the event types. What event type would you like to look at?(Type with no quotes)\n');
Event_Type = x; 


%% For calcium imaging, something we want is to average across events and neurons
% just for a reminder, identify your window of analysis 
TimeWin


% Now i want to average across hit events, and have a vector of one
% averaged hit 'event', so add up each timestamp-based transient across
% events and divide by the number of events 

% We can compute an example for the first timestamps across all events (of
% a specific category...like 'the first hit timestamp transient value for 1 neuron, all events'

% so we grab the first timestamp transient value of all events for 1 neuron like so 
   for eventi = 1:length(Event_Type(1,:))
       exampleCellStamps(1,eventi) = Event_Type{1,eventi}{1,1};
   end

%% Sanity check, do things match-up? 
% we will take the 1st timestamp of the 1st neuron 3rd event (arbitrary testing)
test1 = Event_Type{1,3}{1,1};

% and now compare it to the same neuron same event of the example cell
% stamps variable we made
if exampleCellStamps(1,3) == test1;
       exampleAvg = mean(exampleCellStamps)
       sprintf('Looks like the grabbing the first timestamp from each event for one neuron worked out! \nnow you have an example average also')
else 
       disp('Somethings up here...try to check your work')
end

% if yes, lets move forward, and we have a 1 neuron example to check our
% full matrix with!


%% Using our example as a reference, lets now work on it for all events all timestamps

% This may help if the syntax is really confusing here
% Event_Type is organized as such
    % Event_Type(neuron,event#){8 second window of timestamp based transients}

% this gets quite confusing, the key is understanding how your data being 
% used is organized, refer above for some help with this

% Every neuron, every transient, organized by timestamp, for every event
    % so cell array is neuron, row is timestamp, and column is event 
for neuroni = 1:length(Event_Type(:,1))
    for eventi = 1:length(Event_Type(1,:))
        for stampi = 1:length(Event_Type{1,1})
           AllCell_array{neuroni}(stampi,eventi) = Event_Type{neuroni,eventi}{1,stampi};
           
        end
    end
end

% Now if you open AllCell_Array, each row is a timestamp, and each column
% is an event. So you should have (for 8 second window), 241 rows and 43
% columns for (events (in this example case)) 
%% Lets do some sanity checks... 

% We can verify that the first column of our All Cell matrix 
% (all timestamp associated transients in the defined window for each event) is correctly brought over

% so within the Event_Type(1,1), that's our original, and representative of 8 seconds
% of transient from one neuron for 1 event

% AllCell_array(1,1){:,1}, or within one cell array(neuron), all rows in the first column (first event) (8 second timewindow)
% should be the same

% I know this can be confusing, but I am going to check validity for multiple
% neurons and events

% we first need to break out of cell array structure for '==' type
% comparisons, done by converting to doubles (that's what cell2mat does),
    % you cant compare cell arrays in a logical manner 

%% Test 1; Neuron 1//Transients of the 8 second time window//For Event #1
testAllCell = cell2mat(AllCell_array(1,1)); % first neuron, all events all 8 second windows
testOG = cell2mat(Event_Type{1,1}); % first neuron, first event's 8 second window

if testOG == (testAllCell(:,1)')
    sprintf('Because our 1st event-based transients for Neuron 1 saved in our new structure,\n(AllCell_array) \nand our original 1st event transients match...\nWere good to go!')
else 
    sprintf('Something is off between your original transients x (neuron,event) array and your new transients x (timestamps,event) array')
end


clear testAllCell testOG

%% Test 2; Neuron 1//Transients of the 8 second time window//For Event #2
testAllCell = cell2mat(AllCell_array(1,1)); % first neuron, all events all 8 second windows
testOG = cell2mat(Event_Type{1,2}); % first neuron, SECOND event's 8 second window

if testOG == (testAllCell(:,2)')
    sprintf('Because our 2nd event-based transients for Neuron 1 saved in our new structure,\n (AllCell_array) \nand our original 2nd event-based time window transients match...\nWere good to go!')
    sprintf('Press any key to continue')
else 
    sprintf('Something is off between your original transients x (neuron,event) array and your new transients x (timestamps,event) array')
end


clear testAllCell testOG


%% Test 3; Neuron 2//Transients of the 8 second time window//For Event #3
% (to make it arbitrary for safety)
% 
testAllCell = cell2mat(AllCell_array(1,2)); % Now second neuron, all events all 8s time windows
testOG = cell2mat(Event_Type{2,3}); % Now 2nd neuron, 3rd event's 8 second window

if testOG == (testAllCell(:,3)') %because we took all events all windows from AllCell, the column # here indicates what event to assess
    sprintf('Because our 3rd event-based transients for Neuron 1 grabbed from our original structure,\n (saved in AllCell_array) \nand our original 3rd event-based transients match...\nWere good to go!')
else 
    sprintf('Something went wrong here...')
end


clear testAllCell testOG
%% Summing the transients
% Now we can simply use the matlab sum(A) function, which sums across the
% dimension of choice in a matrix; the default is the sum of each column,
% which is what we want! So...
for neuroni = 1:length(AllCell_array)
    AvgNeuronWins{neuroni} = mean(AllCell_array{neuroni},2);   
end

% lets flip everything to be row vectors after we finish summing cause its
% best for plotting

for neuroni = 1:length(AvgNeuronWins)
    AvgNeuronWins{neuroni} = AvgNeuronWins{neuroni}';
end

%% A couple sanity checks here too!

% Test 1, the length of our Averaged Hit Window
if length(AvgNeuronWins{1}) == length(Event_Type{1})
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


% this plots the averaged across-events traces for every neuron

hitlength = linspace(-(length(Event_Type{1})/(srate*(TimeWin/2))),(length(Event_Type{1})/(srate*(TimeWin/2))),length(Event_Type{1}));

% All neurons together (Non Normalized)

for neuroni = 1:length(AvgNeuronWins)
    if neuroni ==1 
    figure;
    end 
        plot(hitlength, AvgNeuronWins{neuroni}); hold on;
        %plot(hitlength, AvgNeuronWins{neuroni}) %'k', 'LineWidth',1)
        xlabel(sprintf('Time(%s s)', TimeWin))
        ylabel('dF/F')
        xlim ([-TimeWin TimeWin])
        %ylim ([-10 40])
        title(sprintf('All Neuron Activity Traces (non-normalized)'))
end


% Individual neurons
%{
for neuroni = 1:length(AvgNeuronWins)
        figure;
        plot(hitlength, AvgNeuronWins{neuroni},'k', 'LineWidth',1)
        xlabel(sprintf('Time(%s s)', TimeWin))
        ylabel('dF/F')
        xlim ([-TimeWin TimeWin])
        ylim ([-10 40])
        title(sprintf('Neuron %d, Hit Averaged Activity',neuroni))
end
%}

disp('This is cool, but if you look at the baselines they''re all over the place which doesnt make total sense,\nRather, we need to correct for this...')

%% Normalizing a baseline

% we can normalize a baseline by finding the meanval df/f for each average time window for each neuron and
% then subtracting that mean val from each mean timestamp

for neuroni = 1:length(AvgNeuronWins)
    % find the meanval for each neuron
    NeuronMeanval{neuroni} = mean(AvgNeuronWins{neuroni},2); 
    % subtract meannval from avg window trace values
    NormalizedNeuronWins{neuroni} = (AvgNeuronWins{neuroni} - NeuronMeanval{neuroni});
end


%% Re-examine Results 
% lets plot all traces again with normalization
for neuroni = 1:length(AvgNeuronWins)
    if neuroni ==1 
    figure;
    end 
        plot(hitlength, NormalizedNeuronWins{neuroni}); hold on;
        %plot(hitlength, AvgNeuronWins{neuroni}) %'k', 'LineWidth',1)
        xlabel(sprintf('Time(%s s)', TimeWin))
        ylabel('dF/F')
        xlim ([-TimeWin TimeWin])
        %ylim ([-10 40])
        title(sprintf('All Neuron Activity Traces'))
end



%% Directions to consider

% I think now could start to attempt some computational things, for
% starters, thresholding averages, and identifying a few common motifs

% If we move out of just hits, we can model neural activity predicting
% stimulus...
