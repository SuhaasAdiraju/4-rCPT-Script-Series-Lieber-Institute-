function [GrandPowMean,f,GrandPowErr] = PowerAcrossSubs
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
        SubStruc= load(subname);
        %% Power Per Epoch Per Subject
            % Set Params for power spectrum calc
                % Standard params (given by H.H.) 
                params.tapers = [5 9];
                params.pad = 0;
                params.Fs = 2000;
                params.fpass = [0 200];
                params.err = [2 .05];
                params.trialave = 0;
        % loop across events and save em 
        for event = 1:length(SubStruc.Events_Accepted_lfp)
            [S,f,Serr] = mtspectrumc(SubStruc.Events_Accepted_lfp{1,event},params)
            PowCell{event} = S;
        end
    
        % Create matrices of all events
        Pow = cell2mat(PowCell) % the colums are the events, you can verify by looking back into 'PowVals'
        
        % take the mean 
        PowMeanEvents = mean(Pow,2)
        
        % put this mean into a grand matrix (across subjects)
        CrossSubsPower(:,x) = PowMeanEvents
    else
    end
end

% calculate error (code from H.H.)
if SubsNum > 1
    GrandPowStd = std(CrossSubsPower,0); 
    GrandPowErr = GrandPowStd./sqrt(size(CrossSubsPower,1));
elseif SubsNum == 1 
    GrandPowErr = Serr;
end

%take the mean 
GrandPowMean = mean(CrossSubsPower,2);

    
%% PLOT 
plotans = questdlg('Would you like to plot the power spectrum?')
if strcmp(plotans,'Yes') == 1
    if SubsNum > 1
        F = figure; 
        shadedErrorBar(f,GrandPowMean,GrandPowErr,'r')
        sgtitle(sprintf('Power Spectrum of 4s Window Surrounding Event (%d subjects)',SubsNum))
        ylabel('Power Value (magnitude of complex coeff. from a fourier transformed signal)')
        xlabel('Frequencies (Hz)')
        uiwait(F)
    elseif SubsNum == 1
        F = figure; 
        shadedErrorBar(f,GrandPowMean,GrandPowErr(1,:),'r')
        sgtitle(sprintf('Power Spectrum of 4s Window Surrounding Event (%d subjects)',SubsNum))
        ylabel('Power Value (magnitude of complex coeff. from a fourier transformed signal)')
        xlabel('Frequencies (Hz)')
        uiwait(F)
    end
else 
end



%% SAVE
        saveans = questdlg('Would you like to save the power analysis outcomes?')
    if strcmp(saveans, "Yes") == 1
        [saveplace] = uigetdir('Where do you want to save the structure?')
        cd(saveplace);
        stagename = inputdlg('What is the stage of these mice?')
        eventname = inputdlg('Across what type of event is this power analysis?')
        savename = append (stagename,'_',eventname,'_PowerAnalysis')
        powerSpecs. GrandPowMean = GrandPowMean;
        powerSpecs. GrandPowErr = GrandPowErr;
        powerSpecs. f = f;
        save(savename{1},'-struct','powerSpecs')
        waitfor(sprintf('Okay! good to go, power specs for this session saved in\n\n Path: %s\n\nName:%d',saveplace,savename{1}))
    end

end










