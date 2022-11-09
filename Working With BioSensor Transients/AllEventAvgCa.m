function AllEventAvgCa;

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


prepans3 = questdlg('Have you run CaImaging4CPT scripts 1 and 2, or have a previously saved MATLAB data structure containing sliced transients based on behavioral event timestamps?')
if strcmp(prepans3,'Yes') == 1
    clear; clc;
    % Purpose Statement 
    waitfor(msgbox(sprintf('Welcome to CaImaging4CPT script 3: All Event Avg Ca!\n\nPurpose: Simply walk the user through loading in the previously saved data-structure, defining what event-type, and averaging across all events for a user-defined event-type in order to create an ''average response window''\n')))
    %% Define your previously saved structure
    waitfor(msgbox(sprintf('A window will pop up\nThen select the sliced transients structure you made in Ca2imaging_4CPT2_sliceCa2')))
    
    [strucname, strucpath] = uigetfile('','Please select the sliced transients structure you made in Ca2imaging_4CPT2_sliceCa2')
    while strucname == 0
        waitfor(warndlg('You did not successfully select the previously made file, click okay to try again. OR press stop at the top of the page to quit the script'))
        [strucname, strucpath] = uigetfile('','Please select the sliced transients structure you made in Ca2imaging_4CPT2_sliceCa2')
    end
    
    % Load
    cd(strucpath);
    load (strucname) %load your structure
    
    
    %% What event type would you like to look at?
    
    %sprintf('%s\n',vars{:})
    who -regexp Transients$
    waitfor(msgbox(sprintf('The Event types stored in the region you selected are printed above in the command window.\n\nCOPY THE TITLE TEXT TO THE ONE YOU DESIRE TO CHECK OUT!\n\nPress any key to continue when you have looked at them')))
    pause(3)
    Eventprompt = {'What event type would you like to look at?'}
    Event_name = inputdlg(Eventprompt)
    while isempty(Event_name) == 1
        waitfor(warndlg('You didnt type in an event-type, please try again. Or if you are trying to quit the script, press the stop button under the editor tab at the top of MATLAB'))
        Event_name = inputdlg(Eventprompt)
    end
    Event_Type = (eval(Event_name{1})); 
    
    
    %% For calcium imaging, something we want is to average across events and neurons
    % just for a reminder, clarify your window of analysis 
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
    sanitychecks1 = questdlg(sprintf('Would you like to perform a randomized sanity check for the method of extracting corresponding timestamps across events and cells?\n\nHere we have extracted the 1st timestamp across all events, for the 1st cell, as a small-scale test. Using a random number generator, we can perform a sanity check testing whether the event # timestamp in our extracted sample, matches the timestamp value in the original cell array that we extracted it from'))
    
    while strcmp(sanitychecks1,'Yes') == 1
        % we will take the 1st timestamp of the first neuron, random event (arbitrary testing)
        randEvent = randi(length(Event_Type(1,:)),[1 1]);
        test1 = Event_Type{1,randEvent}{1,1};
        groundtest1 = exampleCellStamps(1,randEvent);
        % and now compare it to the same neuron same event of the example cell
        % stamps variable we made
        if  groundtest1 == test1;
               exampleAvg = mean(exampleCellStamps)
               waitfor(msgbox(sprintf('SANITY CHECK:\nLooks like the grabbing the first timestamp from each event for one neuron worked out!\n\nGiven our randomized Event #: %d\nFrom our one-neuron example extracted array: %d.\n\nIs the same as the ground-truth structure''s value for the same event: %d\n\nWe know our extraction method is good!',randEvent,groundtest1,test1)))
        else 
               waitfor(warndlg(sprintf('SANITY CHECK:\nSomethings up here...try to check your work')))
        end
        sanitychecks1 = questdlg('Would you like to perform another randomized check?')
    end
    
    
    
    %% Using our example as a reference, lets now work on it for all events all timestamps
    waitfor(msgbox(sprintf('We will now apply our extraction method verified in a ''single-cell'' setting, to the whole matrix.\n\nFor all %d cells\nHit okay to commence!',(length(Event_Type(:,1))))))
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
   

    % Now if you open AllCell_Array, each row is a neuron, and each column
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
    
    % Execute sanity check
    sanitychecks2 = questdlg(sprintf('Would you like to perform randomized sanity checks on the All-Cell data array that was just extracted?\n\nWe can do this by randomizing the cell we look at, and the event number we look at, then compare the extracted vs original (where it was extracted from) to see if everything came-over correctly'))
    while strcmp(sanitychecks2,'Yes') == 1
        % Test value generators; Random Neuron 1//Transients of the 8 second time window//For a random event
        randEvent = randi(length(AllCell_array{1,1}(1,:)),[1 1]);
        randCell = randi(length(AllCell_array(1,:)),[1 1])
    
        testAllEvent = cell2mat(AllCell_array(1,randCell)); % first neuron, all events all 8 second windows
        testAllEvent = (testAllEvent(:,randEvent)');
        testOG = cell2mat(Event_Type{randCell,randEvent}); % first neuron, first event's 8 second window
        testAllEventsum = sum(testAllEvent,2);
        testOGsum = sum(testOG);
    
    
        if testOGsum == testAllEventsum 
            waitfor(msgbox(sprintf('SANITY CHECK:\n\nOur event-based transients for Cell: %d, Event: %d (randomized), saved in our new structure,\n\nAnd our original event transients from Cell: %d, Event: %d, match...\n\nSo we''re good to go!\n\nIn this analysis we were assessing whether each array (%d values in length) had equal values, which is hard to display\n\nWe can also sum the event-values extracted and see if they''re equal for visual affirmation\n\n-Sum of the ground-truth event values from randomized Cell:%d, randomized Event:%d\n=%d\n\nSum of the extracted values event values for the same randomized cell and event\n=%d \n',randCell, randEvent, randCell, randEvent,(length(testOG)),randCell, randEvent,testOGsum,testAllEventsum)))
        else 
            waitfor(msgbox(sprintf('SANITY CHECK:\nSomething is off between your original transients x (neuron,event) array and your new transients x (timestamps,event) array')))
        end
        sanitychecks2 = questdlg('Would you like to do another randomized check?')
    end
    
 
    %% Compute the average response window
    % Mean of the transients
    % Now we can simply use the matlab mean(A) function, which takes the mean across the
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
  %    
%% Plotting
plotans = questdlg('Would you like to plot the All Cell traces together?')
    if strcmp(plotans,'Yes')
        % this plots the averaged across-events traces for every neuron
        
        hitlength = linspace(-(length(Event_Type{1})/TimeWin),(length(Event_Type{1})/TimeWin),length(Event_Type{1}));
        
        % All neurons together (Non Normalized)
        
        for neuroni = 1:length(AvgNeuronWins)
            if neuroni ==1 
            figure1 = figure;
            end 
                plot(hitlength, AvgNeuronWins{neuroni}); hold on;
                %plot(hitlength, AvgNeuronWins{neuroni}) %'k', 'LineWidth',1)
                xlabel(sprintf('Time(%d s)', TimeWin))
                ylabel('dF/F')
                xlim ([-TimeWin/2 TimeWin/2])
                YTickLabel = get(gca,'YTickLabel')
                Ymax = (YTickLabel(end))
                Ymin = (YTickLabel{1}) 
                plot([0,0], [str2num(Ymin), str2num(Ymax{1})],"LineStyle","--", "Color",'g', 'LineWidth',3);
                title(sprintf('All Neuron Activity Traces (Non-normalized)'))
        end
        

       uiwait(figure1)
       waitfor(msgbox(sprintf('This is cool, but if you look at the baselines they''re all over the place which doesnt make total sense, and is a result of varying baseline activities.\nIn order to accurately assess activity in the context of the behavioral event.\n\nWe need to normalize the baseline activity across traces by calculating each neuron''s mean activity and subtracting that from its trace\n\nThis gives us a common ''zero'' across neurons and makes activity comparisons more meaningful')))
     
        %% Normalizing a baseline
        
        % we can normalize a baseline by finding the meanval df/f for each average time window for each neuron and
        % then subtracting that mean val from each mean timestamp
        
        for neuroni = 1:length(AvgNeuronWins)
            % find the meanval for each neuron
            NeuronMeanval{neuroni} = mean(AvgNeuronWins{neuroni}(1,:),2); 
            % subtract meannval from avg window trace values
            NormalizedNeuronWins{neuroni} = (AvgNeuronWins{neuroni} - NeuronMeanval{neuroni});
        end
        
        
        %% Re-examine Results 
        % lets plot all traces again with normalization
        for neuroni = 1:length(AvgNeuronWins)
            if neuroni ==1 
            figure2 = figure;
            end 
                plot(hitlength, NormalizedNeuronWins{neuroni}); hold on;
                %plot(hitlength, AvgNeuronWins{neuroni}) %'k', 'LineWidth',1)
                xlabel(sprintf('Time(%d s)', TimeWin))
                ylabel('dF/F')
                xlim ([-TimeWin/2 TimeWin/2])
                YTickLabel = get(gca,'YTickLabel')
                Ymax = (YTickLabel(end))
                Ymin = (YTickLabel{1}) 
                plot([0,0], [str2num(Ymin), str2num(Ymax{1})],"LineStyle","--", "Color",'g', 'LineWidth',3);
                plot([0,0], [str2num(Ymin), str2num(Ymax{1})],"LineStyle","--", "Color",'g', 'LineWidth',3);
                title(sprintf('All Neuron Activity Traces Normalized for Baseline Activity'))
        end
        uiwait(figure2)
    end

    
%% Saving
saveans = questdlg('Would you like to save this all cell averaged response windows across events array?')
    if strcmp(saveans,'Yes') == 1
        cd(uigetdir('', 'Where do you wanna save it'))
        mousename = erase(strucname, 'sliced')
        mousename = erase(mousename,'.mat')
        mousename = append(mousename,Event_name{1},'_AllCellAvgResponses')
        savename.Transients = Transients;
        savename.AllCell_array = AllCell_array
        savename.AvgNeuronWins = AvgNeuronWins
        savenam.srate = srate
        savename.TimeWin = TimeWin
        save(mousename,"-struct","savename")
    else
    end

pause();

elseif strcmp(prepans3,'Yes') == 0 
    waitfor(warndlg('You must have a MATLAB data-structure containing sliced transients based on event timestamps to succesfully average across events'))
end


