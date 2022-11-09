function [GrandPowMean,f,GrandPowErr] = PowerAcrossSubsFORUNCLEANED
%% Description
    % Basic analysis with behavior-surrounding LFP recordings.
    
    % This function is facilitating the averaging of power across multiple
    % subjects for an event type. This script assumes the user has run through
    % the pipeline and has aquired accepted LFP epoch events for an event-type
    % average power across. 

% - Written by Suhaas S Adiraju



%% How many subjects to cycle across
SubsNum = inputdlg('How many subjects would you like to include in averaging across')
SubsNum = str2num(SubsNum{1})
waitfor(msgbox(sprintf('Okay, you have selected to average across %d subjects\na window will pop up %d times\n\nSELECT 1 SUBJECT''s DATA FILE EACH TIME',SubsNum,SubsNum)))

% For total number of subjects, define each one via file selector
for x = 1:(SubsNum)
    if x <= (SubsNum)
        [subname, subpath] = uigetfile('','Select the subject-data you would like to include in the Across-Subjects-Avg')
        cd(subpath); 
        SubStruc= load(subname, "-mat", 'ACC');
        %% Power Per Epoch Per Subject
        % Set Params for power spectrum calc
            % Standard params (given by H.H.) 
            params.tapers = [5 9];
            params.pad = 0;
            params.Fs = 2000;
            params.fpass = [0 200];
            params.err = [2 0.05];
            params.trialave = 0;

        % Quick check
        length(SubStruc.ACC.False_Alarm_lfp{1,1})

        % loop across events and save em 
        for event = 1:length(SubStruc.ACC.False_Alarm_lfp)
            [Scell,f,Serr] = mtspectrumc(SubStruc.ACC.False_Alarm_lfp{1,event},params)
            PowCell{event} = Scell;
            
            [S(event),f,Serr] = mtspectrumc(SubStruc.ACC.False_Alarm_lfp{1,event},params)
        end

        
    
        % Create matrices of all events
        
        Pow = cell2mat(PowCell) % the colums are the events, you can verify by looking back into 'PowVals'
            % Sanity Check  
             if Pow(:,2) == PowCell{1,2}
                 disp('looks like conversion to a matrix worked as intended')
             end

        % take the mean of output from both methods 
        PowMeanEvents = mean(Pow,2);

        PowMeanEventsCompared = mean(S,1);
        
        % put this mean into a grand matrix (across subjects)
        GrandPow(:,x) = PowMeanEvents
    else
    end
end

% calculate error (code from H.H.)
GrandPowStd = std(GrandPow,0,2);
GrandPowErr = GrandPowStd/sqrt(size(GrandPow,2));


%take the mean 
GrandPowMean = mean(GrandPow,2);

    
%% PLOT 

figure; 
shadedErrorBar(f,GrandPowMean,GrandPowErr,'r')
xlim([0 200])
sgtitle(sprintf('Power Spectrum of 4s Window Surrounding Event (%d subjects)',SubsNum))
ylabel('Power Value (magnitude of complex coeff. from a fourier transformed signal)')
xlabel('Frequencies (Hz)')