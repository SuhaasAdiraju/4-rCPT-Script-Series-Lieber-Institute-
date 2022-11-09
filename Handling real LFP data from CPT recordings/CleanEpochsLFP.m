function CleanEpochsLFP
%% Description
    % this function is written to allow a user to simply identify and clean
    % LFP. The outputs will be a cell array of accepted and rejected
    % events, to be able to refer back to. The outputs automatically will
    % be named for the mouse and then event type selected

%% Define and load your previously saved structure (data set) (SKIP IF STRUCTURE IN WORKSPACE ALREADY)
    waitfor(msgbox(sprintf('Welcome to CleanEpochsLFP: Basic LFP snippet cleaning!\n\nPURPOSE: This script and associated function, using the required inputs, will present the sliced windows of the raw LFP data for a user-defined event type and query the option of reject or accept\n\nINPUTS:-An existing structure created using LFP4CPT 1 and 2, with timestamps-sliced transients based on event-type')))
 

%% Load-In Existing Structure   
 clearvars -except stage; clc

 waitfor(msgbox({'A file selector will pop up. Then select the path to your existing sliced data structure (that you made in LFP4CPT3)'}))
 
    [struc_name, struc_path] = uigetfile('','Please select the previously saved structure containing event-timestamp based transient slices')
    while struc_name == 0     
        waitfor(warndlg('Sorry, you did not correctly select a saved data-structure. Press okay to try again. Or if you would like to stop execution of this script hit the ''stop'' button at the top of MATLAB'))
        [struc_name, struc_path] = uigetfile('','Please select the previously saved structure containing event-timestamp based transient slices')
    end
    tic
    cd(struc_path);
    load (struc_name) %load your structure
    toc


%% So that we don't have to rerun for the same mouse
cleantimes = inputdlg(sprintf('How many event-types (Hits, False Alarms, etc.) do you want to clean for this subject?\n '))
cleantimes = cell2mat(cleantimes);
cleantimes = str2num(cleantimes);
for event_typei = 1:(cleantimes)
    clear Events_Accepted Events_Rejected region Event_name Event_Type Events_Goodidx Events_Rejectedidx Events_Accepted_lfp Events_Rejected_lfp mousename Events_Good_lfp 
        %% What event type would you like to look at? (MANUALLY DEFINE 'Event_Type IF STRUCTURE IN WORKSPACE ALREADY)
            vars = who;
            sprintf('Here''s a list of the channels for reminder')
            sprintf('%s\n',vars{:})
            waitfor(msgbox({'A window will pop up containing LFP recordings from regions, you may choose 1 by typing it into the response'}))
            
            regionprompt = (sprintf('%s\n',vars{:}))
            titleRegionprompt = ('What brain region / channel do you want to look at?') 
            region = inputdlg(regionprompt, titleRegionprompt, [1 100])
            while exist(region{1},"var") == 0
                waitfor(warndlg(sprintf('%s, doesn''t seem to exist. Please try again, or, if you are trying to quit the script, press the stop button under the editor tab at the top of MATLAB',region{1})))
                region = inputdlg(regionprompt, titleRegionprompt, [1 100])
            end
            if exist(region{1},"var") == 1
                eval(region{1})
            end
            waitfor(msgbox({'The Event types stored in the region you selected are printed below in the command window.';' ';'COPY THE TITLE TEXT TO THE ONE YOU DESIRE TO CHECK OUT!';' ';'Then, IN THE COMMAND WINDOW (BOTTOM OF THE PAGE), PRESS ANY KEY TO CONTINUE'}))
            who -regexp Transients$
            pause
            Eventprompt = {'What event type would you like to look at?'}
            Event_name = inputdlg(Eventprompt)
            while isempty(Event_name) == 1
                waitfor(warndlg('You didnt type in an event-type, please try again. Or if you are trying to quit the script, press the stop button under the editor tab at the top of MATLAB'))
                Event_name = inputdlg(Eventprompt)
            end
            Event_Type = (eval(region{1}).(Event_name{1})); 
        
        
        %% Manual removal of clipping events
            Eventlength = linspace(-(length(Event_Type{1,1})/(srate*(TimeWin/2))),(length(Event_Type{1,1})/(srate*(TimeWin/2))),length(Event_Type{1,1}));
            waitfor(msgbox(sprintf('Okay, now we will cycle through the timestamp-based LFP snippets and you will choose to include or exclude each event based on visual observation\n\nClipping is when the amplitude of the signal recorded increases in such a drastic way that it flatlines, and should be considered as an artifact')))
            for event = 1:length(Event_Type)
                figureEvent = figure;
                plot(Eventlength,Event_Type{1,event})
                xlabel('Time (s)')
                ylabel('Voltage')
                sgtitle(sprintf('Event %d, LFP snippet | Assess for clipping, then exit the figure !!',event))
                uiwait(figureEvent)
                plotKeep = questdlg('Include this snippet in analysis?')
                if strcmp(plotKeep,'Yes') == 1
                    Events_Good_lfp{1,event} = Event_Type{1,event};
                elseif strcmp(plotKeep,'No') == 1
                    Events_Good_lfp{1,event} = []; 
                elseif strcmp(plotKeep,'Cancel') == 1
                    while strcmp(plotKeep,'Cancel') == 1
                        Events_Good_lfp{1,event} = Event_Type{1,event};
                        waitfor(warndlg(sprintf('You chose cancel for the inclusion/exclusion question. If you would like to quit the script press the stop button at the top of MATLAB\n\nIf you would like to take a second-look at the Event just displayed, press ''okay'' here')))
                        figureEvent = figure;
                        plot(Eventlength,Event_Type{1,event})
                        xlabel('Time (s)')
                        ylabel('Voltage')
                        sgtitle(sprintf('Event %d, LFP snippet | Assess for clipping, then exit the figure !!',event))
                        uiwait(figureEvent)
                        plotKeep = questdlg('Include this snippet in analysis?')
                    end
                end
            end
            Events_Goodidx = cellfun(@isempty,Events_Good_lfp)
            Events_Rejectedidx = (Events_Goodidx == 1);
            Events_Rejected = find(Events_Goodidx == 1);
            Events_Accepted = find(Events_Goodidx == 0);
        
            assignin ('base',append("GoodIdx",Event_name{1}),Events_Accepted)
            assignin ('base',append("BadIdx",Event_name{1}),Events_Rejected)
            
           
    
    
            Events_Accepted_lfp = Events_Good_lfp(Events_Goodidx == 0);
            Events_Rejected_lfp = Event_Type(Events_Rejectedidx == 1);
            
            assignin ('base',append("GoodTraces_",Event_name{1},region{1}),Events_Accepted_lfp);
            assignin ('base',append("BadTraces_",Event_name{1},region{1}),Events_Rejected_lfp);
            
           
        
        %% Save if you want  
        savenot = questdlg(sprintf('Would you like to save the event-data for those accepted and rejected events??'))
            if strcmp(savenot,'Yes') == 1    
                savename.Events_Accepted_lfp = Events_Accepted_lfp;
                savename.Events_Rejected_lfp = Events_Rejected_lfp;
                savename.Events_Acceptedidx = Events_Accepted;
                savename.Events_Rejectedidx = Events_Rejected;
                savename.srate = srate;
                savename.TimeWin = TimeWin;
                savename.Eventlength = Eventlength;
           
                waitfor(msgbox({'A file selector will pop up.';' ';'Then select the the path, YOU WOULD LIKE TO SAVE YOUR All Event Avg'}))
                saveplace = uigetdir('','Please select the folder you would like to save your all-event average in')
                cd (saveplace)
    
                mousename = append((erase(struc_name,'_sliced.mat')),"Events_Cleaned_",(erase(Event_name{1},'lfp')),region{1});
                save(mousename,'-struct','savename')
                waitfor(msgbox(sprintf('Okay your cleaned epochs structure has been saved in\n\nPath: %s\n\nAs Name: %s',saveplace,mousename)))
            elseif strcmp(savenot,'Yes') == 0
            end
       
        vardisplay = questdlg('Would you like to evaluate the variable created?')
            if strcmp(vardisplay,'Yes') == 1 
                waitfor(msgbox(sprintf('When you are finished evaluating the variable\nCLICK INTO THE COMMAND WINDOW (bottom of MATLAB)\n then type in ''dbquit''')))
                openvar('savename')
                sprintf('\n\nTYPE ''dbcont'' BELOW HERE')
                keyboard
            elseif strcmp(vardisplay,'Yes') == 0
            end
end
end

% LabMeetingMouse_4sEvents_Cleaned_Hit_ACC = load('LabMeeting_4sEvents_Cleaned_Hit_ACC')
