%% Clean Data
% Testing HLH Cleaning and Trial Rejection code 
% SSA Visualization and Adaptation

%--SSA 05.26.22

%% Run criteria function and save outputs of flagged trial totals 
% make sure we have the function accessible for matlab
% addpath('Z:\Circuits projects (CPT)\Working With LFP\Handling real LFP data from CPT recordings');

% how many subjects do you want to execute for? this way we have a
% convenient looping for as many subjects as desired 
subs = inputdlg(sprintf('How many subjects do you want to clean for?\n '))
subs = cell2mat(subs);
subs = str2num(subs);

% load the data and establish some variables that'll be important
% downstream
for subs = 1:(subs)
   clearvars -except subs AllSubsDecMat_OG AllSubsIndices_OG AllSubsDecMatCleaned AllSubsIndicesCleaned
   [filename, pathname] = uigetfile('Please select the file to load and clean')
   cd(pathname)
   Struc = load(filename);
   srate = Struc.srate;
   TimeWin = Struc.TimeWin;

    % For the loaded data, what region are we interested in
   Regionfields = fieldnames(Struc);
%    UserRegion = inputdlg(sprintf('-%s\n',Regionfields{:}),'WHAT REGION ARE YOU INTERESTED IN !!!',[1 100])
%    UserRegion = cell2mat(UserRegion);
    UserRegion = {'ACC'};
    UserRegion = cell2mat(UserRegion);

   % Within the region, what event?
   Eventfields = fieldnames(Struc.(UserRegion));
%    UserEvent = inputdlg(sprintf('-%s\n', Eventfields{2:end,:}),'WHAT EVENT ARE YOU INTERESTED IN !!!',[1 100])
%    UserEvent = cell2mat(UserEvent);
    UserEvent = {'Hit_lfp'};
    UserEvent = cell2mat(UserEvent);
    
   % Create a matrix of the indicated data set
   Inputdata = cell2mat(Struc.(UserRegion).(UserEvent)');


   % Initialize OG data set 
   Inputdata_OG = Inputdata;


   
   % detrend data set for signal bias stemming from slow drift, noise
   % buildup, using subtraction of a local linear regression
        %InputdataCleaned = locdetrend(Inputdata', 2000, [.5 .05]);
   
   % Flip the orientation of the output back to standard form, channels x time
%         InputdataCleaned = InputdataCleaned';
   
   % Remove noisy frequencies using rmlinesc function (cleaned data set)
   % set params 
   params.tapers = [5 9];
   params.Fs = 2000;
   params.fpass = [0 200]

   %run rmlinesc
%    InputdataCleaned = rmlinesc(Inputdata',params, .05/(length(Inputdata_OG)),'y',58);
%    InputdataCleaned = rmlinesc(InputdataCleaned,params,.05/(length(Inputdata_OG)),'y',59);
%    InputdataCleaned = rmlinesc(InputdataCleaned,params,.05/(length(Inputdata_OG)),'y',60);
%    InputdataCleaned = rmlinesc(InputdataCleaned,params,.05/(length(Inputdata_OG)),'y',61);
%    InputdataCleaned = rmlinesc(InputdataCleaned,params,.05/(length(Inputdata_OG)),'y',62);


   InputdataCleaned = InputdataCleaned';
   Inputdata_OG == InputdataCleaned;
    
   % Run HLH rejection criteria function on both the OG and cleaned sets

   % OG
   [decision_matrix_OG, indices_OG] = lfp_scrubbing(Inputdata_OG,srate);
   AllSubsDecMat_OG{subs} = decision_matrix_OG;
   AllSubsIndices_OG{subs} = indices_OG;


   %Cleaned
   [decision_matrix_clean, indices_clean] = lfp_scrubbing(InputdataCleaned,srate);
   AllSubsDecMatCleaned{subs} = decision_matrix_clean;
   AllSubsIndicesCleaned{subs} = indices_clean;

end

%% Get metrics from all subjects matrix | for OG and Cleaned

% OG
CriteriaTotals_OG = {};
for arrayi = 1:length(AllSubsDecMat_OG)
    CriteriaTotals_OG{arrayi}(1,:) = length(AllSubsDecMat_OG{1,arrayi});
    CriteriaTotals_OG{arrayi}(2,:) = length(AllSubsDecMat_OG{1,arrayi}(AllSubsDecMat_OG{1,arrayi}(1,:) == 1));
    CriteriaTotals_OG{arrayi}(3,:) = length(AllSubsDecMat_OG{1,arrayi}(AllSubsDecMat_OG{1,arrayi}(2,:) == 1));
    CriteriaTotals_OG{arrayi}(4,:) = length(AllSubsDecMat_OG{1,arrayi}(AllSubsDecMat_OG{1,arrayi}(3,:) == 1));
end


% Cleaned
totalClippingCleaned = {};
total60HzCleaned = {};
totalSpksCleaned = {};
CleanedCriteriaTotals = {};
for arrayi = 1:length(AllSubsDecMatCleaned)
    CleanedCriteriaTotals{arrayi}(1,:) = length(AllSubsDecMatCleaned{1,arrayi});
    CleanedCriteriaTotals{arrayi}(2,:) = length(AllSubsDecMatCleaned{1,arrayi}(AllSubsDecMatCleaned{1,arrayi}(1,:) == 1));
    CleanedCriteriaTotals{arrayi}(3,:) = length(AllSubsDecMatCleaned{1,arrayi}(AllSubsDecMatCleaned{1,arrayi}(2,:) == 1));
    CleanedCriteriaTotals{arrayi}(4,:) = length(AllSubsDecMatCleaned{1,arrayi}(AllSubsDecMatCleaned{1,arrayi}(3,:) == 1));
end


%% Session Avg Power Spectrum and visualization

% OG 
SessionPows_OG = {};
SessionPowMat_OG = [];
SessionPowMean_OG = [];
for arrayi = 1:length(AllSubsIndices_OG)
    SessionPows_OG = AllSubsIndices_OG{1,arrayi}(2,:);
    SessionPowMat_OG = cell2mat(SessionPows_OG');
    SessionPowMean_OG{arrayi} = mean(SessionPowMat_OG);
end


% Cleaned
SessionPowsCleaned = {};
SessionPowMatCleaned = [];
SessionPowMeanCleaned = [];
for arrayi = 1:length(AllSubsIndicesCleaned)
    SessionPowsCleaned = AllSubsIndicesCleaned{1,arrayi}(2,:);
    SessionPowMatCleaned = cell2mat(SessionPowsCleaned');
    SessionPowMeanCleaned{arrayi} = mean(SessionPowMatCleaned);
end

% PLOT Clean vs OG Session Average Power Spectrums
for sessioni = 1:length(SessionPowMeanCleaned)
    f = figure; 
    subplot 121
        plot(SessionPowMean_OG{1,sessioni}); hold on 
        ytick = get(gca,'YTick');
        xlim([0 100])
        rectangle('Position',[55 0 10 ytick(end)],'EdgeColor','r','LineWidth',2); hold off 
        title('Session Power Spectrum OG')

    subplot 122  
        plot(SessionPowMeanCleaned{1,sessioni}); hold on 
        ytick = get(gca,'YTick');
        xlim([0 100])
        rectangle('Position',[55 0 10 ytick(end)],'EdgeColor','r','LineWidth',2); hold off 
        title('Session Power Spectrum Cleaned')
    uiwait(f)
   
end





%% How many acceptable trials?? non-visualizing
clc; clear

% Run criteria function and save outputs 
% make sure we have the function accessible for matlab
% addpath('Z:\Circuits projects (CPT)\Working With LFP\Handling real LFP data from CPT recordings');

% how many subjects do you want to execute for? this way we have a
% convenient looping for as many subjects as desired 
subs = inputdlg(sprintf('How many subjects do you want to clean for?\n '))
subs = cell2mat(subs);
subs = str2num(subs);

% load the data and establish some variables that'll be important
% downstream
for subs = 1:(subs)
   clearvars -except subs AllSubsDecMat_OG AllSubsIndices_OG AllSubsDecMatCleaned AllSubsIndicesCleaned
   [filename, pathname] = uigetfile('Please select the file to load and clean')
   cd(pathname)
   Struc = load(filename);
   srate = Struc.srate;
   TimeWin = Struc.TimeWin;

    % For the loaded data, what region are we interested in
   Regionfields = fieldnames(Struc);
%    UserRegion = inputdlg(sprintf('-%s\n',Regionfields{:}),'WHAT REGION ARE YOU INTERESTED IN !!!',[1 100])
%    UserRegion = cell2mat(UserRegion);
    UserRegion = {'ACC'};
    UserRegion = cell2mat(UserRegion);

   % Within the region, what event?
   Eventfields = fieldnames(Struc.(UserRegion));
%    UserEvent = inputdlg(sprintf('-%s\n', Eventfields{2:end,:}),'WHAT EVENT ARE YOU INTERESTED IN !!!',[1 100])
%    UserEvent = cell2mat(UserEvent);
    UserEvent = {'Hit_lfp'};
    UserEvent = cell2mat(UserEvent);
    
   % Create a matrix of the indicated data set
   Inputdata = cell2mat(Struc.(UserRegion).(UserEvent)');


   % Initialize OG data set 
   Inputdata_OG = Inputdata;


   
   % detrend data set for signal bias stemming from slow drift, noise
   % buildup, using subtraction of a local linear regression
       
        %InputdataCleaned = locdetrend(Inputdata', 2000, [.5 .05]);
   
   % Flip the orientation of the output back to standard form, channels x time
%         InputdataCleaned = InputdataCleaned';
   
   % Remove noisy frequencies using rmlinesc function (cleaned data set)
   % set params 
   params.tapers = [5 9];
   params.Fs = 2000;
   params.fpass = [0 200]

   %run rmlinesc
        %InputdataCleaned = rmlinesc(Inputdata',params);

   InputdataCleaned = rmlinesc(Inputdata',params, .05/(length(Inputdata_OG)),'y',58);
   InputdataCleaned = rmlinesc(InputdataCleaned,params,.05/(length(Inputdata_OG)),'y',59);
   InputdataCleaned = rmlinesc(InputdataCleaned,params,.05/(length(Inputdata_OG)),'y',60);
   InputdataCleaned = rmlinesc(InputdataCleaned,params,.05/(length(Inputdata_OG)),'y',61);
   InputdataCleaned = rmlinesc(InputdataCleaned,params,.05/(length(Inputdata_OG)),'y',62);


   InputdataCleaned = InputdataCleaned';
%    Inputdata_OG == InputdataCleaned;
    

   % Run HLH rejection criteria function on both the OG and cleaned sets

    % OG
    [decision_matrix_OG, indices_OG] = lfp_scrubbing(Inputdata_OG,srate);
    AllSubsDecMat_OG{subs} = decision_matrix_OG;
    AllSubsIndices_OG{subs} = indices_OG;

    %Cleaned
    [decision_matrix_clean, indices_clean] = lfp_scrubbing(InputdataCleaned,srate);
    AllSubsDecMatCleaned{subs} = decision_matrix_clean;
    AllSubsIndicesCleaned{subs} = indices_clean;


    % Store what events were considered rejection worthy, so the user can visually verify
    ClippingEvents = find(decision_matrix_clean(1,:) == 1);
    NoisyEvents = find(decision_matrix_clean(2,:) == 1);
    HighSpikeEvents = find(decision_matrix_clean(3,:) == 1); 


    if length(NoisyEvents) >= (length(decision_matrix_clean)-4)
        % as seen through inspection, if most of the trials are flagged for
        % noisiness, the session is invalid signal; so exclude
           AllSubsDecMatCleaned{subs} = []; 
    else

    % make a single variable of all excludeable events; remove duplicates
    CrossCriteriaRejects = [ClippingEvents NoisyEvents HighSpikeEvents];
    CrossCriteriaRejects = sort(CrossCriteriaRejects);
    CrossCriteriaRejects = unique(CrossCriteriaRejects);


    % exclude events from main DecisionMatrix
    AllSubsDecMatCleaned{subs}(:, CrossCriteriaRejects) = [];

    % Compute Acceptable Trial Totals
    AcceptableTrials(subs) = length(AllSubsDecMatCleaned{subs})

    end
end






%% Visualize single trial power specs before and after cleaning
clc; clear

% Run criteria function and save outputs 
% make sure we have the function accessible for matlab
% addpath('Z:\Circuits projects (CPT)\Working With LFP\Handling real LFP data from CPT recordings');

% how many subjects do you want to execute for? this way we have a
% convenient looping for as many subjects as desired 
subs = inputdlg(sprintf('How many subjects do you want to clean for?\n '))
subs = cell2mat(subs);
subs = str2num(subs);

% load the data and establish some variables that'll be important
% downstream
for subs = 1:(subs)
   clearvars -except subs AllSubsDecMat_OG AllSubsIndices_OG AllSubsDecMatCleaned AllSubsIndicesCleaned
   [filename, pathname] = uigetfile('Please select the file to load and clean')
   cd(pathname)
   Struc = load(filename);
   srate = Struc.srate;
   TimeWin = Struc.TimeWin;

    % For the loaded data, what region are we interested in
   Regionfields = fieldnames(Struc);
%    UserRegion = inputdlg(sprintf('-%s\n',Regionfields{:}),'WHAT REGION ARE YOU INTERESTED IN !!!',[1 100])
%    UserRegion = cell2mat(UserRegion);
    UserRegion = {'ACC'};
    UserRegion = cell2mat(UserRegion);

   % Within the region, what event?
   Eventfields = fieldnames(Struc.(UserRegion));
%    UserEvent = inputdlg(sprintf('-%s\n', Eventfields{2:end,:}),'WHAT EVENT ARE YOU INTERESTED IN !!!',[1 100])
%    UserEvent = cell2mat(UserEvent);
    UserEvent = {'Hit_lfp'};
    UserEvent = cell2mat(UserEvent);
    
   % Create a matrix of the indicated data set
   Inputdata = cell2mat(Struc.(UserRegion).(UserEvent)');


   % Initialize OG data set 
   Inputdata_OG = Inputdata;


   
   % detrend data set for signal bias stemming from slow drift, noise
   % buildup, using subtraction of a local linear regression
       
            %InputdataCleaned = locdetrend(Inputdata', 2000, [.5 .05]);
   
   % Flip the orientation of the output back to standard form, channels x time
%         InputdataCleaned = InputdataCleaned';
   
   % Remove noisy frequencies using rmlinesc function (cleaned data set)
   % set params 
   params.tapers = [5 9];
   params.Fs = 2000;
   params.fpass = [0 200]

   %run rmlinesc
   %InputdataCleaned = rmlinesc(Inputdata',params);
   
   InputdataCleaned = rmlinesc(Inputdata',params, .05/(length(Inputdata_OG)),'n',55);
   InputdataCleaned = rmlinesc(Inputdata',params, .05/(length(Inputdata_OG)),'n',55);
   InputdataCleaned = rmlinesc(Inputdata',params, .05/(length(Inputdata_OG)),'n',56);
   InputdataCleaned = rmlinesc(Inputdata',params, .05/(length(Inputdata_OG)),'n',57);
   InputdataCleaned = rmlinesc(Inputdata',params, .05/(length(Inputdata_OG)),'n',58);
   InputdataCleaned = rmlinesc(InputdataCleaned,params,.05/(length(Inputdata_OG)),'n',59);
   InputdataCleaned = rmlinesc(InputdataCleaned,params,.05/(length(Inputdata_OG)),'n',60);
   InputdataCleaned = rmlinesc(InputdataCleaned,params,.05/(length(Inputdata_OG)),'n',61);
   InputdataCleaned = rmlinesc(InputdataCleaned,params,.05/(length(Inputdata_OG)),'n',62);
   InputdataCleaned = rmlinesc(InputdataCleaned,params,.05/(length(Inputdata_OG)),'n',63);
   InputdataCleaned = rmlinesc(InputdataCleaned,params,.05/(length(Inputdata_OG)),'n',64);
   InputdataCleaned = rmlinesc(InputdataCleaned,params,.05/(length(Inputdata_OG)),'n',65);

   InputdataCleaned = InputdataCleaned';
    

   % Run HLH rejection criteria function on both the OG and cleaned sets

    % OG
    [decision_matrix_OG, indices_OG] = lfp_scrubbing(Inputdata_OG,srate);
    AllSubsDecMat_OG{subs} = decision_matrix_OG;
    AllSubsIndices_OG{subs} = indices_OG;

    %Cleaned
    [decision_matrix_clean, indices_clean] = lfp_scrubbing(InputdataCleaned,srate);
    AllSubsDecMatCleaned{subs} = decision_matrix_clean;
    AllSubsIndicesCleaned{subs} = indices_clean;


    % Store what events were considered rejection worthy, so the user can visually verify
    ClippingEvents = find(decision_matrix_clean(1,:) == 1);
    NoisyEvents = find(decision_matrix_OG(2,:) == 1);
    HighSpikeEvents = find(decision_matrix_clean(3,:) == 1);


    (msgbox({(sprintf('The events considered as clipping were...(If nothing is here it means no events)')) ; (sprintf('%d\n', ClippingEvents))} ));
    (msgbox({(sprintf('The events considered as 60Hz noisy were...(If nothing is here it means no events)')) ; (sprintf('%d\n', NoisyEvents))} ));
    (msgbox({(sprintf('The events considered as high amplitude spikes were...(If nothing is here it means no events)')) ; (sprintf('%d\n', HighSpikeEvents))} ));
        if length(NoisyEvents) >= (length(decision_matrix_OG)-5)
        continue 
        else

        paramsSpec.tapers = [5 9];
        paramsSpec.pad = 0;
        paramsSpec.Fs = 2000;
        paramsSpec.fpass = [0 100];
        paramsSpec.err = [2 0.05];
        paramsSpec.trialave = 0;
        [powerOG,f] = mtspectrumc(Inputdata_OG',params);
        [powerClean,f] = mtspectrumc(InputdataCleaned',params);
powerOG = powerOG';
powerClean = powerClean';
        for event = 1:length((powerOG(:,1)))
                figureEvent = figure;
                subplot 121
                    plot(f,powerOG(event,:))
                    xlabel('Freq')
                    xlim([0 100])
                    ylabel('Power')
                    title('OG')
                subplot 122
                     plot(f,powerClean(event,:))
                     xlabel('Freq')
                     xlim([0 100])
                     ylabel('Power')
                     title('Cleaned')
                sgtitle(sprintf('Event %d, LFP snippet',event)) %| Assess for clipping, then exit the figure !!',event))
                uiwait(figureEvent)
        end
        end
end







%% Flag; Clean; Manually inspect RAW LFP; Manually inspect PSD; Accept/Reject
clc; clear
addpath('Z:\Circuits projects (CPT)\Working With LFP\Handling real LFP data from CPT recordings');

% Run criteria function and save outputs 
% make sure we have the function accessible for matlab
% addpath('Z:\Circuits projects (CPT)\Working With LFP\Handling real LFP data from CPT recordings');

% how many subjects do you want to execute for? this way we have a
% convenient looping for as many subjects as desired 
subs = inputdlg(sprintf('How many subjects do you want to clean for?\n '))
subs = cell2mat(subs);
subs = str2num(subs);

% load the data and establish some variables that'll be important
% downstream
for subs = 1:(subs)
   clearvars -except subs AllSubsDecMat_OG AllSubsIndices_OG AllSubsDecMatCleaned AllSubsIndicesCleaned
   [filename, pathname] = uigetfile('Please select the file to load and clean')
   cd(pathname)
   Struc = load(filename);
   srate = Struc.srate;
   TimeWin = Struc.TimeWin;

    % For the loaded data, what region are we interested in
   Regionfields = fieldnames(Struc);
%    UserRegion = inputdlg(sprintf('-%s\n',Regionfields{:}),'WHAT REGION ARE YOU INTERESTED IN !!!',[1 100])
%    UserRegion = cell2mat(UserRegion);
   UserRegion = {'ACC'};
   UserRegion = cell2mat(UserRegion);

   % Within the region, what event?
   Eventfields = fieldnames(Struc.(UserRegion));
%    UserEvent = inputdlg(sprintf('-%s\n', Eventfields{2:end,:}),'WHAT EVENT ARE YOU INTERESTED IN !!!',[1 100])
%    UserEvent = cell2mat(UserEvent);
    UserEvent = {'Hit_lfp'};
    UserEvent = cell2mat(UserEvent);
    
   % Create a matrix of the indicated data set
   Inputdata = cell2mat(Struc.(UserRegion).(UserEvent)');


   % Initialize OG data set 
   Inputdata_OG = Inputdata;

    % Run Henry function on OG data
    [decision_matrix_OG, indices_OG] = lfp_scrubbing(Inputdata_OG,srate);
    AllSubsDecMat_OG{subs} = decision_matrix_OG;
    AllSubsIndices_OG{subs} = indices_OG;

    % Only look at flagged trials
        %{
   % Store what events were considered rejection worthy, so the user can visually verify
    ClippingEvents = find(decision_matrix_OG(1,:) == 1);
    NoisyEvents = find(decision_matrix_OG(2,:) == 1);
    HighSpikeEvents = find(decision_matrix_OG(3,:) == 1);

  % make a single vector of all excludeable events w/ removed duplicates
    CrossCriteriaRejects = [ClippingEvents NoisyEvents HighSpikeEvents];
    CrossCriteriaRejects = sort(CrossCriteriaRejects);
    CrossCriteriaRejects = unique(CrossCriteriaRejects);


    % Grab flagged trials 
    Inputdata_OG_flagged = Inputdata_OG{subs}(:, CrossCriteriaRejects);
%}
   
   % Remove noisy frequencies using rmlinesc function (cleaned data set)
   % set params 
   params.tapers = [5 9];
   params.Fs = 2000;
   params.fpass = [0 200];

   %run rmlinesc for freqs 55-65
   InputdataCleaned = rmlinesc(Inputdata',params, .05/(length(Inputdata_OG)),'n',55);
   InputdataCleaned = rmlinesc(Inputdata',params, .05/(length(Inputdata_OG)),'n',55);
   InputdataCleaned = rmlinesc(Inputdata',params, .05/(length(Inputdata_OG)),'n',56);
   InputdataCleaned = rmlinesc(Inputdata',params, .05/(length(Inputdata_OG)),'n',57);
   InputdataCleaned = rmlinesc(Inputdata',params, .05/(length(Inputdata_OG)),'n',58);
   InputdataCleaned = rmlinesc(InputdataCleaned,params,.05/(length(Inputdata_OG)),'n',59);
   InputdataCleaned = rmlinesc(InputdataCleaned,params,.05/(length(Inputdata_OG)),'n',60);
   InputdataCleaned = rmlinesc(InputdataCleaned,params,.05/(length(Inputdata_OG)),'n',61);
   InputdataCleaned = rmlinesc(InputdataCleaned,params,.05/(length(Inputdata_OG)),'n',62);
   InputdataCleaned = rmlinesc(InputdataCleaned,params,.05/(length(Inputdata_OG)),'n',63);
   InputdataCleaned = rmlinesc(InputdataCleaned,params,.05/(length(Inputdata_OG)),'n',64);
   InputdataCleaned = rmlinesc(InputdataCleaned,params,.05/(length(Inputdata_OG)),'n',65);

   % flip orientation
   InputdataCleaned = InputdataCleaned';
    

   % Run HLH rejection criteria function on cleaned set
    %Cleaned
    [decision_matrix_clean, indices_clean] = lfp_scrubbing(InputdataCleaned,srate);
    AllSubsDecMatCleaned{subs} = decision_matrix_clean;
    AllSubsIndicesCleaned{subs} = indices_clean;


    % Store what events were considered rejection worthy, so the user can visually verify
    ClippingEvents = find(decision_matrix_clean(1,:) == 1);
    NoisyEvents = find(decision_matrix_clean(2,:) == 1);
    HighSpikeEvents = find(decision_matrix_clean(3,:) == 1);


    (msgbox({(sprintf('The events considered as clipping were...(If nothing is here it means no events)')) ; (sprintf('%d\n', ClippingEvents))} ));
    (msgbox({(sprintf('The events considered as 60Hz noisy were...(If nothing is here it means no events)')) ; (sprintf('%d\n', NoisyEvents))} ));
    (msgbox({(sprintf('The events considered as high amplitude spikes were...(If nothing is here it means no events)')) ; (sprintf('%d\n', HighSpikeEvents))} ));
   
    Events_Good_lfp = {};
    Events_Rejected_lfp = {};

    if length(NoisyEvents) >= (length(decision_matrix_OG)-5)
            continue 
    else
        
        % Single-trial Raw LFP
        winlength = linspace(-(length(InputdataCleaned(1,:))/(srate))/2, (length(InputdataCleaned(1,:))/(srate))/2, length(InputdataCleaned(1,:)));
        for triali = 1:length(InputdataCleaned(:,1))   
            f = figure;
            f.Position = [700 800 500 150];
            plot(winlength,InputdataCleaned(triali,:))
            title(sprintf('Event %d',triali))
            uiwait(f)
          
    
            % Single-trial PSD 
            paramsSpec.tapers = [5 9];
            paramsSpec.pad = 0;
            paramsSpec.Fs = 2000;
            paramsSpec.fpass = [0 100];
            paramsSpec.err = [2 0.05];
            paramsSpec.trialave = 0;
            [powerOG,f] = mtspectrumc(Inputdata_OG',params);
            [powerClean,f] = mtspectrumc(InputdataCleaned',params);
            powerOG = powerOG';
            powerClean = powerClean';
                    fpower = figure;
                    subplot 121
                        plot(f,powerOG(triali,:))
                        xlabel('Freq')
                        xlim([0 100])
                        ylabel('Power')
                        title('OG')
                    subplot 122
                         plot(f,powerClean(triali,:))
                         xlabel('Freq')
                         xlim([0 100])
                         ylabel('Power')
                         title('Cleaned')
                    sgtitle(sprintf('Event %d, LFP snippet',triali)) %| Assess for clipping, then exit the figure !!',event))
                    uiwait(fpower)
    
                    plotKeep = questdlg('Include this snippet in analysis?')
                    if strcmp(plotKeep,'Yes') == 1
                        Events_Good_lfp{1,triali} = InputdataCleaned(triali,:);
                        Events_Rejected_lfp{1,triali} = [];
                    elseif strcmp(plotKeep,'No') == 1
                        Events_Good_lfp{1,triali} = [];  
                        Events_Rejected_lfp{1,triali} = InputdataCleaned(triali,:);
                    else
                        while strcmp(plotKeep,'Cancel') == 1
                                f = figure;
                                plot(winlength,InputdataCleaned(triali,:));
                                f.Position = [800 500 500 150];
                                title(sprintf('Event %d',triali))
                                uiwait(f)
                              
                        
                                % Single-trial PSD 
                                paramsSpec.tapers = [5 9];
                                paramsSpec.pad = 0;
                                paramsSpec.Fs = 2000;
                                paramsSpec.fpass = [0 100];
                                paramsSpec.err = [2 0.05];
                                paramsSpec.trialave = 0;
                                [powerOG,f] = mtspectrumc(Inputdata_OG',params);
                                [powerClean,f] = mtspectrumc(InputdataCleaned',params);
                                powerOG = powerOG';
                                powerClean = powerClean';
                                        fpower = figure;
                                        subplot 121
                                            plot(f,powerOG(triali,:))
                                            xlabel('Freq')
                                            xlim([0 100])
                                            ylabel('Power')
                                            title('OG')
                                        subplot 122
                                             plot(f,powerClean(triali,:))
                                             xlabel('Freq')
                                             xlim([0 100])
                                             ylabel('Power')
                                             title('Cleaned')
                                        sgtitle(sprintf('Event %d, LFP snippet',triali)) %| Assess for clipping, then exit the figure !!',event))
                                        uiwait(fpower)
                        
                                 plotKeep = questdlg('Include this snippet in analysis?')
                                    if strcmp(plotKeep,'Yes') == 1
                                        Events_Good_lfp{1,triali} = InputdataCleaned(triali,:);
                                        Events_Rejected_lfp{1,triali} = [];
                                    elseif strcmp(plotKeep,'No') == 1
                                        Events_Good_lfp{1,triali} = [];  
                                        Events_Rejected_lfp = InputdataCleaned(triali,:);
                                    end
                        end
                        % store indices and raw lfp data
                        Events_Goodidx = cellfun(@isempty,Events_Good_lfp)
                        Events_Rejectedidx = (Events_Goodidx == 1);
                        Events_Rejected = find(Events_Goodidx == 1);
                        Events_Accepted = find(Events_Goodidx == 0);
            
                        AllSubsAcceptedLFP{1,subs} = cell2mat(Events_Good_lfp');
                        AllSubsRejectedLFP{1,subs} = cell2mat(Events_Rejected_lfp');
                        AllSubsAcceptedIdx {1,subs} = Events_Accepted;
                        AllSubsRejectedIdx {1,subs} = Events_Rejected;
                    end
            
        end
    end
    
            
end

CleanSessionStructure.AllSubsAcceptedIdx = AllSubsAcceptedIdx;
CleanSessionStructure.AllSubsRejectedIdx = AllSubsRejectedIdx;
CleanSessionStructure.AllSubsAcceptedLFP = AllSubsAcceptedLFP;
CleanSessionStructure.AllSubsRejectedLFP = AllSubsRejectedLFP;

StageNameCell = inputdlg('What stage of CPT?');
StageName = num2str(StageNameCell{1});
StageName = append(StageName, '_CleanedSessionData')
save(StageName,'-struct','CleanSessionStructure');



