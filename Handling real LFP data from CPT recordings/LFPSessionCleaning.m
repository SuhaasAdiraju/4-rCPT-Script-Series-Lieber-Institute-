%% Flag; Clean; Manually inspect RAW LFP; Manually inspect PSD; Accept/Reject
clc; clear
% make sure we have the function and associated functions accessible for matlab
if ~exist('Z:\Suhaas A\Analysis things\chronux_2_12', 'dir') == 1
    addpath(genpath('Z:\Suhaas A\Analysis things\chronux_2_12'))
end

if ~exist('Z:\Circuits projects (CPT)\Working With LFP\Handling real LFP data from CPT recordings', 'dir') == 1
   addpath(genpath('Z:\Circuits projects (CPT)\Working With LFP\Handling real LFP data from CPT recordings'))
end

%% Execute 
% Run criteria function and save outputs 

% how many subjects do you want to execute for? this way we have a
% convenient looping for as many subjects as desired 
subs = inputdlg(sprintf('How many subjects do you want to clean for?\n '))
subs = cell2mat(subs);
subs = str2num(subs);

% load the data and establish some variables that'll be important downstream

Events_Good_lfp = {};
Events_Rejected_lfp = {};
AllSubsAcceptedLFP= {};
AllSubsRejectedLFP= {};
AllSubsAcceptedIdx = {};
AllSubsRejectedIdx = {};


for subs = 1:(subs)
   clearvars -except subs AllSubsDecMat_OG AllSubsIndices_OG AllSubsDecMatCleaned AllSubsIndicesCleaned AllSubsAcceptedLFP AllSubsRejectedLFP AllSubsAcceptedIdx AllSubsRejectedIdx A
   [filename, pathname] = uigetfile('Please select the file to load and clean')
   cd(pathname)
   Struc = load(filename);
   srate = Struc.srate;
   TimeWin = Struc.TimeWin;

    % For the loaded data, what region are we interested in
   Regionfields = fieldnames(Struc);
   UserRegion = inputdlg(sprintf('-%s\n',Regionfields{:}),'WHAT REGION ARE YOU INTERESTED IN !!!',[1 100])
    % UserRegion = {'LC'};
   UserRegion = cell2mat(UserRegion);

   % Within the region, what event?
   Eventfields = fieldnames(Struc.(UserRegion));
   UserEvent = inputdlg(sprintf('-%s\n', Eventfields{2:end,:}),'WHAT EVENT ARE YOU INTERESTED IN !!!',[1 100])
    % UserEvent = {'False_Alarm_lfp'};
    UserEvent = cell2mat(UserEvent);
    
   % Create a matrix of the indicated data set
   Inputdata = cell2mat(Struc.(UserRegion).(UserEvent)');


   % Initialize OG data set 
   Inputdata_OG = Inputdata;

    % Run Henry function on OG data
    [decision_matrix_OG, indices_OG] = lfp_scrubbing(Inputdata_OG,srate);
    AllSubsDecMat_OG{subs} = decision_matrix_OG;
    AllSubsIndices_OG{subs} = indices_OG;

   
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
   
   %{
    if length(NoisyEvents) >= (length(decision_matrix_OG)-5)
            AllSubsRejectedIdx{1,subs} = {};
            AllSubsAcceptedIdx{1,subs} = {};
            AllSubsRejectedLFP{1,subs} = {};
            AllSubsAcceptedLFP{1,subs} = {};
            continue
    else
   %}
        for triali = 1:length(InputdataCleaned(:,1))   
            winlength = linspace(-(length(InputdataCleaned(1,:))/(srate))/2, (length(InputdataCleaned(1,:))/(srate))/2, length(InputdataCleaned(1,:)));
            
            % Single-trial Raw LFP
            f = figure;
            f.Position = [768 950 500 150];
            plot(winlength,InputdataCleaned(triali,:))
            title(sprintf('Event %d',triali))
            uiwait(f)

            % Single-trial PSD params
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
                                f.Position = [780 890 500 150];
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
                                    end
                        end
                    end                
        end              
  % end
    % store indices and raw lfp data
    Events_Goodidx = cellfun(@isempty,Events_Good_lfp)
    Events_Rejectedidx = (Events_Goodidx == 1);
    Events_Rejected = find(Events_Goodidx == 1);
    Events_Accepted = find(Events_Goodidx == 0);

    AllSubsAcceptedLFP{1,subs} = cell2mat(Events_Good_lfp');
    AllSubsRejectedLFP{1,subs} = cell2mat(Events_Rejected_lfp');
    AllSubsAcceptedIdx {1,subs} = Events_Accepted;
        AllSubsAcceptedIdx {2,subs} = length(Events_Accepted)
    AllSubsRejectedIdx {1,subs} = Events_Rejected; 
        AllSubsRejectedIdx {2,subs} = length(Events_Rejected); 
    
end



CleanSessionStructure.AllSubsAcceptedIdx = AllSubsAcceptedIdx;
CleanSessionStructure.AllSubsRejectedIdx = AllSubsRejectedIdx;
CleanSessionStructure.AllSubsAcceptedLFP = AllSubsAcceptedLFP;
CleanSessionStructure.AllSubsRejectedLFP = AllSubsRejectedLFP;
CleanSessionStructure.UserEvent = UserEvent;
CleanSessionStructure.UserRegion = UserRegion;

StageNameCell = inputdlg('How do you want to name this? I would include stage, maybe cohort name, etc...');
StageName = num2str(StageNameCell{1});
StageName = append(StageName, '_CleanedSessionData')
waitfor(msgbox(sprintf('Click ok then select where you want to save the cleaned session structure just made?')))
saveplace = uigetdir();
cd(saveplace);
save(StageName,'-struct','CleanSessionStructure');


