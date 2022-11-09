%% How many subjects to cycle across
clear;clc;clf;close all
SubsNum = inputdlg('How many subjects would you like to include in averaging across')
SubsNum = str2num(SubsNum{1})
waitfor(msgbox(sprintf('Okay, you have selected to average across %d subjects\na window will pop up %d times\n\nSELECT 1 SUBJECT''s DATA FILE EACH TIME',SubsNum,SubsNum)))

% For total number of subjects, define each one via file selector
for x = 1:(SubsNum)
    if x <= (SubsNum)
        [subname, subpath] = uigetfile('','Select the subject-data you would like to include in the Across-Subjects-Avg')
        cd(subpath); 
        load(subname,'-mat','lfp');
        lfp = lfp(4,1351*2000:2700*2000);
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
        %for event = 1:length(lfp)
            [S,f] = mtspectrumc(lfp,params);
            PowCell = S;
        %end
    
        % Create matrices of all events
        Pow = (PowCell); % the colums are the events, you can verify by looking back into 'PowVals'
        
        % take the mean 
        PowMeanEvents = mean(Pow,2);
        
        % put this mean into a grand matrix (across subjects)
        CrossSubsPower(:,x) = PowMeanEvents;
    else
    end
end

% calculate error (code from H.H.)
GrandPowStd = std(CrossSubsPower,0,2);
GrandPowErr = GrandPowStd/sqrt(size(CrossSubsPower,2));


%take the mean 
GrandPowMean = mean(CrossSubsPower,2);

    
%% PLOT 
plotans = questdlg('Would you like to plot the power spectrum?')
if strcmp(plotans,'Yes') == 1
    F = figure; 
    shadedErrorBar(f,GrandPowMean,GrandPowErr,'b');
    %sgtitle(sprintf('Power Spectrum of 4s Window Surrounding Event (%d subjects)',SubsNum))
    ylabel('Power Value (magnitude of complex coeff. from a fourier transformed signal)')
    xlabel('Frequencies (Hz)')
    xlim([0 30])
    uiwait(F)
else 
end


%%
 F = figure; 
    shadedErrorBar(f,GrandPowMeanBAD,GrandPowErrBAD,'r',.3); hold on 
    shadedErrorBar(f,GrandPowMean,GrandPowErr,'g',.3);
    %sgtitle(sprintf('Power Spectrum of 4s Window Surrounding Event (%d subjects)',SubsNum))
    ylabel('Power Value (magnitude of complex coeff. from a fourier transformed signal)')
    xlabel('Frequencies (Hz)')

%% SAVING
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
    end
waitfor(sprintf('Okay! good to go, power specs for this session saved in\n\n Path: %s\n\nName:%d',saveplace,savename{1}))
