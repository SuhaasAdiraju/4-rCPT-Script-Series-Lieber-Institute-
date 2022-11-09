%% Analyzing CA transients

% this script is for event-based analyzing of CA2 imaging transients, 
% Included
    % - event-window normalization
    % - event-window heatmaps
    % - event-window population response
    % - full-session event-markers + activity traces

% Written by Suhaas S. Adiraju ~ 08.06.22

%% Set-up
clc; clear; clf; close all;
% make sure we have the function and associated functions accessible for matlab
if ~exist('Z:\Suhaas A\Analysis things\chronux_2_12', 'dir') == 1
    addpath(genpath('Z:\Suhaas A\Analysis things\chronux_2_12'))
end

if ~exist('Z:\Circuits projects (CPT)\Working With LFP\Handling real LFP data from CPT recordings', 'dir') == 1
   addpath(genpath('Z:\Circuits projects (CPT)\Working With LFP\Handling real LFP data from CPT recordings'))
end

if ~exist('Z:\Circuits projects (CPT)\Working With BioSensor Transients', 'dir') == 1
   addpath(genpath('Z:\Circuits projects (CPT)\Working With BioSensor Transients'))
end

% Define and load 
[filename filepath] = uigetfile('','choose the average response saved structure to analyze')

cd(filepath);

load(filename);


%% Alternative normalization methods
%{

%% Per Neuron Avg windows Df/f
%{
AvgNeuronWinsMat = cell2mat(AvgNeuronWins');



% Plot normalized
% lets plot all traces again with normalization
hitlength = linspace(-(length(AvgNeuronWins{1})/TimeWin),(length(AvgNeuronWins{1})/TimeWin),length(AvgNeuronWins{1}));

for neuroni = 1:length(AvgNeuronWins)
    if neuroni ==1 
    figure2 = figure;
    end 
        plot(hitlength, AvgNeuronWins{neuroni}) %'k', 'LineWidth',1)
        xlabel(sprintf('Time(%d s)', TimeWin)); hold on;
        ylabel('dF/F')
        xlim ([-TimeWin/2 TimeWin/2])
        %YTickLabel = get(gca,'YTickLabel')
        %Ymax = (YTickLabel(end))
        %Ymin = (YTickLabel{1}) 
        %plot([0,0], [str2num(Ymin), str2num(Ymax{1})],"LineStyle","--", "Color",'g', 'LineWidth',3);
        %plot([0,0], [str2num(Ymin), str2num(Ymax{1})],"LineStyle","--", "Color",'g', 'LineWidth',3);
        title(sprintf(''))
end




% maxDf = max(AvgNeuronWinsMat)
% minDf = min(AvgNeuronWinsMat)
% clims = ([minDf maxDf])
colormap('jet')
imagesc(AvgNeuronWinsMat)
colorbar
%}


%% Global mean zscore 
%{
% calculate zscore for each average trace with the global mean
    % Compute the global mean for each cell
    for neuroni = 1:length(Transients)
        GlobalMu(neuroni,:) = mean(cell2mat(Transients{neuroni}))
        GlobalSigma(neuroni,:) = std(cell2mat(Transients{neuroni}))
    end

    % get a matrix of the avg neuron wins data 
    AvgNeuronWinsMat = cell2mat(AvgNeuronWins');

    % Compute zscore of average event trace with global mu and sigma
    for neuroni = 1:length(AvgNeuronWinsMat(:,1))
        for timei = 1:length(AvgNeuronWinsMat(1,:))
        GlobalZscoreNeuronWins(neuroni,timei) = (AvgNeuronWinsMat(neuroni,timei) - GlobalMu(neuroni,1))/ GlobalSigma(neuroni,1);
        end
    end


%Plot Zscore

for neuroni = 1:length(ZscoredAvgNeuronWins(:,1))
        if neuroni ==1 
        figure2 = figure;
        end 
        plot(hitlength, GlobalZscoreNeuronWins(neuroni,:),'k'); hold on
        %plot(hitlength, AvgNeuronWins{neuroni}) %'k', 'LineWidth',1)
        xlabel(sprintf('Time(%d s)', TimeWin))
        ylabel('Std Devs from the mean (Zscore)')
        xlim ([-TimeWin/2 TimeWin/2])
        %YTickLabel = get(gca,'YTickLabel')
        %plot([0,0], [-4, 4],"LineStyle","--", "Color",'g', 'LineWidth',3);
        ylim([-4 4])
        title(sprintf('All Neuron Activity Traces Normalized by Zscores'))
end

colormap('default')
clims = ([-2.5 2.5])
imagesc(GlobalZscoreNeuronWins)
colorbar
%}



%% Avg trace mean zscore
%{
% calculate zscore for each average trace with itself
    for neuroni = 1:length(AvgNeuronWins)
        ZscoredAvgNeuronWins(neuroni,:) = zscore(AvgNeuronWins{1,neuroni});
    end


%Plot 

for neuroni = 1:length(ZscoredAvgNeuronWins(:,1))
        figure;
        plot(hitlength, ZscoredAvgNeuronWins(neuroni,:),'k');
        %plot(hitlength, AvgNeuronWins{neuroni}) %'k', 'LineWidth',1)
        xlabel(sprintf('Time(%d s)', TimeWin))
        ylabel('Std Devs from the mean (Zscore)')
        xlim ([-TimeWin/2 TimeWin/2])
        %YTickLabel = get(gca,'YTickLabel')
        %plot([0,0], [-4, 4],"LineStyle","--", "Color",'g', 'LineWidth',3);
        ylim([-4 4])
        title(sprintf('All Neuron Activity Traces Normalized by Zscores'))
end

% Heat Plot 
    colormap('default')
    imagesc(ZscoredAvgNeuronWins)
    colorbar
%}


%}

%% Peak-of-Trace Normalization

% Find the max of the avg trace of each neuron 
for neuroni = 1:length(AvgNeuronWins)
    TracePeak(1,neuroni) = max(cell2mat(Transients{neuroni}));
end

% Divide all values of average trace by peak normalizing factor 
for neuroni = 1:length(AvgNeuronWins)
    PeakNormalizedNeuronTraces{1,neuroni} = AllCell_array{:,neuroni}./TracePeak(1,neuroni);
end

for neuroni = 1:length(PeakNormalizedNeuronTraces)
    NormAvgNeuronWins{neuroni} = (mean(PeakNormalizedNeuronTraces{1,neuroni},2)').* 100;
end


NormAvgNeuronWins = cell2mat(NormAvgNeuronWins');

for neuroni = 1:length(NormAvgNeuronWins(:,1))
    NormAvgPeaks(neuroni,:) = max(NormAvgNeuronWins(neuroni,:));
end


%% Plot all normalized event-traces
% lets plot all traces with normalization

hitlength = linspace(-(length(AvgNeuronWins{1})/TimeWin),(length(AvgNeuronWins{1})/TimeWin),length(AvgNeuronWins{1}));

clear figgie figname
for neuroni = 1:length(NormAvgNeuronWins(:,1))
    if neuroni ==1 
    figgie = figure;
    end 
    plot(hitlength, NormAvgNeuronWins(neuroni,:)); hold on
    xlabel(sprintf('Time(%d s)', TimeWin)); 
    ylabel('% df/F relative to global peak')
    xlim ([-TimeWin/2 TimeWin/2])
    yvals = get(gca,'Ytick')
    title(sprintf('Single Neuron Avg Activity Traces Normalized to Peak Factor'))
end
    plot([0,0],[0 yvals(end)], "LineStyle","--", "Color",[0.8500 0.3250 0.0980], 'LineWidth',4);
    hold off;


 figname = erase(filename,'AllCellAvgResponses.mat')
 figname = append(figname,'PeakNormalized_AvgTraces_ALLNEURONS')
 cd(filepath)
 saveas(figgie,figname,'fig')
 saveas(figgie,figname,'tif')



%% Sorting neurons based on activity
SortQuest = inputdlg(sprintf(['Input one of the options:' ...
    '\n\n 1 = I have loaded Hit averaged activity, and want to sort by neurons most responsive during Hits. ' ...
    '\n\n 2 = I have loaded Hit averaged activity, and want to sort by neurons most responsive during False Alarms. ' ...
    '\n\n 3 = I have loaded False Alarm averaged activity, and want to sort by neurons most responsive during Hits. ' ...
    '\n\n 4 = I have loaded False Alarm averaged activity, and want to sort by neurons most responsive during False Alarms. ' ...
    ]))

% For Option 1 (Hits loaded Hits sorting desired)
if str2num(SortQuest{1}) == 1
    [B_AvgResponse,I_AvgResponse] = sort(NormAvgPeaks,1,"descend");
    NormAvgNeuronWinsSorted = NormAvgNeuronWins(I_AvgResponse,:);
    sortStyle = '_HitSorted'



% For Option 2 (Hits loaded False Alarms sorting desired)
elseif str2num(SortQuest{1}) == 2
    [ordername, orderpath] = uigetfile('','Please load False Alarms averaged data-set')
    cd(orderpath);
    False_Alarms_Struc = load(ordername);

        % Find the max of the avg trace of each neuron 
        for neuroni = 1:length(False_Alarms_Struc.AvgNeuronWins)
            FATracePeak(1,neuroni) = max(cell2mat(False_Alarms_Struc.Transients{neuroni}));
        end
        
        % Divide all values of average trace by peak normalizing factor 
        for neuroni = 1:length(False_Alarms_Struc.AvgNeuronWins)
            FAPeakNormalizedNeuronTraces{1,neuroni} = False_Alarms_Struc.AllCell_array{:,neuroni}./FATracePeak(1,neuroni);
        end
        
        for neuroni = 1:length(FAPeakNormalizedNeuronTraces)
            FANormAvgNeuronWins{neuroni} = (mean(FAPeakNormalizedNeuronTraces{1,neuroni},2)').* 100;
        end
        
        
        FANormAvgNeuronWins = cell2mat(FANormAvgNeuronWins');
        
        for neuroni = 1:length(FANormAvgNeuronWins(:,1))
            FANormAvgPeaks(neuroni,:) = max(FANormAvgNeuronWins(neuroni,:))
        end


    [B_AvgResponse,I_AvgResponse] = sort(FANormAvgPeaks,1,"descend");
    NormAvgNeuronWinsSorted = NormAvgNeuronWins(I_AvgResponse,:)
    sortStyle = '_FASorted'



% For Option 3 (False alarms loaded Hits sorting desired)
elseif str2num(SortQuest{1}) == 3
    [ordername, orderpath] = uigetfile('','Please load Hits averaged data-set')
    cd(orderpath);
    Hits_Struc = load(ordername);

        % Find the max of the avg trace of each neuron 
        for neuroni = 1:length(Hits_Struc.AvgNeuronWins)
            HitTracePeak(1,neuroni) = max(cell2mat(Hits_Struc.Transients{neuroni}));
        end
        
        % Divide all values of average trace by peak normalizing factor 
        for neuroni = 1:length(Hits_Struc.AvgNeuronWins)
            HitPeakNormalizedNeuronTraces{1,neuroni} = Hits_Struc.AllCell_array{:,neuroni}./HitTracePeak(1,neuroni);
        end
        
        for neuroni = 1:length(HitPeakNormalizedNeuronTraces)
            HitNormAvgNeuronWins{neuroni} = (mean(HitPeakNormalizedNeuronTraces{1,neuroni},2)').* 100;
        end
        
        
        HitNormAvgNeuronWins = cell2mat(HitNormAvgNeuronWins');
        
        for neuroni = 1:length(HitNormAvgNeuronWins(:,1))
            HitNormAvgPeaks(neuroni,:) = max(HitNormAvgNeuronWins(neuroni,:))
        end


    [B_AvgResponse,I_AvgResponse] = sort(HitNormAvgPeaks,1,"descend");
    NormAvgNeuronWinsSorted = NormAvgNeuronWins(I_AvgResponse,:)
    sortStyle = "_HitSorted"


% For Option 4 (FalseAlarms loaded FalseAlarms sorting desired)
elseif str2num(SortQuest{1}) == 4
    [B_AvgResponse,I_AvgResponse] = sort(NormAvgPeaks,1,"descend");
    NormAvgNeuronWinsSorted = NormAvgNeuronWins(I_AvgResponse,:);
    sortStyle = '_FASorted'
        
        else
            msgbox('You didnt choose a valid option for sorting! Rerun the script and try again selecting options 1-4')
        end



%% Event-Avg Heatmap 
clear figgie figname clf

% Plot Heatmap
figgie = figure;
colormap('jet'); 
imagesc((NormAvgNeuronWinsSorted(:,:))); hold on
yvals = get(gca,'Ytick')
xvals = get(gca,'Xtick')
plot([length(NormAvgNeuronWinsSorted(1,:))/(TimeWin*2)*10,length(NormAvgNeuronWinsSorted(1,:))/(TimeWin*2)*10],[0 yvals(end)], "LineStyle","--", "Color",'w', 'LineWidth',4);
set(gca,'Clim',[0 55])
zaxis = colorbar;
zaxis.Label.String = '% df/F relative to global peak'
ylim([0 yvals(end)])
xlabel('Samples (seconds * 10)')
ylabel('Neuron #')
title('Heatmap of Peak-Normalized Hit-Averaged Cell Traces'); hold off

figname = erase(filename,'AllCellAvgResponses.mat')
figname = append(figname,'PeakNormalized_AvgTraces_Heatmap_ALLNEURONS')
figname = append(figname, sortStyle);
cd(filepath);
saveas(figgie,figname,'fig');
saveas(figgie,figname,'tif');


% Heatmap of top 10 active neurons
figgie = figure; 
colormap('jet');
imagesc((NormAvgNeuronWinsSorted(1:10,:)));
zaxis = colorbar; hold on
yvals = get(gca,'Ytick')
xvals = get(gca,'Xtick')
plot([length(NormAvgNeuronWinsSorted(1,:))/(TimeWin*2)*10,length(NormAvgNeuronWinsSorted(1,:))/(TimeWin*2)*10],[0 yvals(end)], "LineStyle","--", "Color",'w', 'LineWidth',4);
zaxis.Label.String = '% df/F relative to global peak'
%xlim([xvals(1) xvals(end)])
ylim([yvals(1) yvals(end)])
set(gca,'Clim',[0 55])
xlabel('Samples (seconds * 10)')
ylabel('Neuron #')
title('Heatmap of Peak-Normalized Event-Averaged Cell Traces'); 
plot([length(NormAvgNeuronWinsSorted)/(TimeWin)*10,length(NormAvgNeuronWinsSorted)/(TimeWin)*10],[0 yvals(end)], "LineStyle","--", "Color",'w', 'LineWidth',4);

hold off;


figname = erase(filename,'AllCellAvgResponses.mat')
figname = append(figname,'PeakNormalized_AvgTraces_Heatmap_Zoomed')
figname = append(figname, sortStyle);
cd(filepath);
saveas(figgie,figname,'fig');
saveas(figgie,figname,'tif');




%% Heatmap of all response-centered traces of single neuron
singleneuronplotquest = questdlg('Would you like to plot a heatmap of single neuron, pre-averaged, event-centered responses?')

while strcmp(singleneuronplotquest,'Yes') == 1
    % to get the cells with the highest responses from the average traces
    % figure
    neuronNum = inputdlg('From 1 - # of neurons, 1 being the largest response, input the neuron you would like to visualize the pre-averaged traces centered around the behavioral response')
    neuron = I_AvgResponse((str2num(neuronNum{1})));
    
    
    % Plot normalized
    % lets plot all traces again with normalization
    hitlength = linspace(-(length(AvgNeuronWins{1})/TimeWin),(length(AvgNeuronWins{1})/TimeWin),length(AvgNeuronWins{1}));
    
    clear figgie figname
    
    figgie = figure;
    plot(hitlength,(PeakNormalizedNeuronTraces{neuron})); hold on
    xlabel(sprintf('Time(%d s)', TimeWin)); 
    ylabel('% df/F relative to global peak')
    xlim ([-TimeWin/2 TimeWin/2])
    yvals = get(gca,'Ytick')
    title(sprintf('Neuron %s Activity Traces Normalized to Peak Factor',num2str(neuron)))
    plot([0,0],[0 yvals(end)], "LineStyle","--", "Color",[0.8500 0.3250 0.0980], 'LineWidth',4);
    hold off;

     figname = erase(filename,'AllCellAvgResponses.mat');
     figname = append(figname,'PeakNormalized_Traces_PreAvg_NEURON');
     figname = append(figname,num2str(neuron));
    cd(filepath)
     saveas(figgie,figname,'fig')
     saveas(figgie,figname,'tif')

    
    
    % Get a matrix of the normalized traces of a single neuron pre averaging
    PeakNormalizedSingleNeuron = (PeakNormalizedNeuronTraces{neuron}');
    


    NormNeuronTraceSorted = PeakNormalizedSingleNeuron(:,:);
    NormNeuronTraceSorted = NormNeuronTraceSorted .* 100;
    
    clear figgie figname
    % Plot
    figgie = figure;
    colormap('jet'); 
    imagesc((NormNeuronTraceSorted(:,:)))
    zaxis = colorbar; hold on
    yvals = get(gca,'Ytick')
    xvals = get(gca,'Xtick')
    set(gca,'Clim',[0 55])
    zaxis.Label.String = '% df/F relative to global peak'
    xlabel('Samples (seconds * 10)')
    ylabel('Neuron #')
    title('Heatmap of Peak-Normalized Hit Event Traces (Pre-Averaging)')
    plot([length(NormAvgNeuronWinsSorted)/(TimeWin)*10,length(NormAvgNeuronWinsSorted)/(TimeWin)*10],[0 yvals(end)], "LineStyle","--", "Color",'w', 'LineWidth',4);
    
    figname = erase(filename,'AllCellAvgResponses.mat');
    figname = append(figname,'PeakNormalized_HeatMap_PreAvg_NEURON_');
    figname = append(figname, sortStyle);
    figname = append(figname, num2str(neuron));
   cd(filepath)
    saveas(figgie,figname,'fig')
    saveas(figgie,figname,'tif')
singleneuronplotquest = questdlg('Would you like to plot a heatmap of single neuron, pre-averaged, event-centered responses?')
end


%% Population Activity (mean of means) for top 10 neurons
%compute avg of avgs traces of the neurons that fired 
PopTrace = mean(NormAvgNeuronWinsSorted(1:10,:),1);

% compute standard error of the trace
PopTrace_StdErr = (std(NormAvgNeuronWins,0,1)/sqrt(size(NormAvgNeuronWins,2)));


%make an x axis to plot
PopTraceAxis = linspace((-length(PopTrace)/TimeWin),(length(PopTrace)/TimeWin),length(PopTrace));

%event_type = inputdlg('What event type is this? Hits or False Alarms? If other, essentially Hits will return a green graph, and False Alarms will return red')
if (str2num(SortQuest{1})) == 1 | (str2num(SortQuest{1})) == 2;
        %plot
        clear figgie figname
        figgie = figure;
        shadedErrorBar(PopTraceAxis,PopTrace,PopTrace_StdErr,{'Color','g','LineWidth',2},.4); hold on
        ylim([0 30])
        yvals = get(gca,'Ytick')
        plot([0,0],[yvals(1) yvals(end)], "LineStyle","--", "Color",[0.8500 0.3250 0.0980], 'LineWidth',4);
        xlim([PopTraceAxis(1) PopTraceAxis(end)])
        %ylim([yvals(1) yvals(end)])
        ylabel('% df/F Relative to Global Peak')
        xlabel('Time (s)'); 
        title('Population Response Surrounding Behavioral Event'); hold off;
        
       cd(filepath)
        figname = erase(filename,'AllCellAvgResponses.mat');
        figname = append(figname,'PeakNormalized_ActivePopulationResponse');
        figname = append(figname, sortStyle);
        saveas(figgie,figname,'fig')
        saveas(figgie,figname,'tif')

elseif (str2num(SortQuest{1})) == 3 | (str2num(SortQuest{1})) == 4;
        %plot
        clear figgie figname
        figgie = figure;
        shadedErrorBar(PopTraceAxis,PopTrace,PopTrace_StdErr,{'Color','r','LineWidth',2},.4); hold on
        ylim([0 30])
        yvals = get(gca,'Ytick')
        plot([0,0],[yvals(1) yvals(end)], "LineStyle","--", "Color",[0.8500 0.3250 0.0980], 'LineWidth',4);
        xlim([PopTraceAxis(1) PopTraceAxis(end)])
        %ylim([yvals(1) yvals(end)])
        ylabel('% df/F Relative to Global Peak')
        xlabel('Time (s)'); 
        ylim([0 30])        
        title('Population Response Surrounding Behavioral Event'); hold off;
        
       cd(filepath)
        figname = erase(filename,'AllCellAvgResponses.mat');
        figname = append(figname,'PeakNormalized_ActivePopulationResponse');
        figname = append(figname, sortStyle);
        saveas(figgie,figname,'fig')
        saveas(figgie,figname,'tif')


else      
        %plot
        clear figgie figname
        figgie = figure;
        shadedErrorBar(PopTraceAxis,PopTrace,PopTrace_StdErr,{'Color','b','LineWidth',2},.4); hold on
        ylim([0 30])
        yvals = get(gca,'Ytick')
        plot([0,0],[yvals(1) yvals(end)], "LineStyle","--", "Color",[0.8500 0.3250 0.0980], 'LineWidth',4);
        xlim([PopTraceAxis(1) PopTraceAxis(end)])
        %ylim([yvals(1) yvals(end)])
        ylabel('% df/F Relative to Global Peak')
        xlabel('Time (s)'); 
        ylim([0 30])       
        title('Population Response Surrounding Behavioral Event'); hold off;
        
       cd(filepath)
        figname = erase(filename,'AllCellAvgResponses.mat');
        figname = append(figname,'PeakNormalized_ActivePopulationResponse');
        figname = append(figname, sortStyle);
        saveas(figgie,figname,'fig')
        saveas(figgie,figname,'tif')
end



%% Whole Session Neuron Heatmaps
eventplots = questdlg('Do you want to plot behavioral events overlaying the whole session calcium activity')
if strcmp(eventplots,'Yes') == 1
    stagenum = inputdlg('Is this stage 2 or 3?')
        if strcmp('2',stagenum{1}) == 1
            [ordername, orderpath] = uigetfile('','Please load the RAW DATA STRUCTURE, (PRE-SLICED)')
            cd(orderpath);
            load(ordername,'Hit');
        
            % Divide all values of raw trace by cell-specific global peak normalizing factor 
            for neuroni = 1:length(AvgNeuronWins)
                PeakNormalizedNeurons_FullSession{1,neuroni} = (cell2mat(Transients{:,neuroni}))./TracePeak(1,neuroni);
            end
            
            for neuroni = 1:length(PeakNormalizedNeurons_FullSession)
                PeakNormalizedNeurons_FullSessionMat(neuroni,:) = (PeakNormalizedNeurons_FullSession{1,neuroni});
            end
            
            PeakNormalizedNeurons_FullSessionMat(end+1,:) = zeros(1,length(PeakNormalizedNeurons_FullSessionMat));
            PeakNormalizedNeurons_FullSessionMat(end+1,:) = zeros(1,length(PeakNormalizedNeurons_FullSessionMat));
            PeakNormalizedNeurons_FullSessionMat(end+1,:) = zeros(1,length(PeakNormalizedNeurons_FullSessionMat));
            PeakNormalizedNeurons_FullSessionMat(end+1,:) = zeros(1,length(PeakNormalizedNeurons_FullSessionMat));
            PeakNormalizedNeurons_FullSessionMat(end+1,:) = zeros(1,length(PeakNormalizedNeurons_FullSessionMat));
            PeakNormalizedNeurons_FullSessionMat(end+1,:) = zeros(1,length(PeakNormalizedNeurons_FullSessionMat));
            PeakNormalizedNeurons_FullSessionMat(end+1,:) = zeros(1,length(PeakNormalizedNeurons_FullSessionMat));
            PeakNormalizedNeurons_FullSessionMat(end+1,:) = zeros(1,length(PeakNormalizedNeurons_FullSessionMat));
            PeakNormalizedNeurons_FullSessionMat(end+1,:) = zeros(1,length(PeakNormalizedNeurons_FullSessionMat));
            PeakNormalizedNeurons_FullSessionMat(end+1,:) = zeros(1,length(PeakNormalizedNeurons_FullSessionMat));
            PeakNormalizedNeurons_FullSessionMat(end+1,:) = zeros(1,length(PeakNormalizedNeurons_FullSessionMat));
            PeakNormalizedNeurons_FullSessionMat(end+1,:) = zeros(1,length(PeakNormalizedNeurons_FullSessionMat));
            PeakNormalizedNeurons_FullSessionMat(end+1,:) = zeros(1,length(PeakNormalizedNeurons_FullSessionMat));
            PeakNormalizedNeurons_FullSessionMat(end+1,:) = zeros(1,length(PeakNormalizedNeurons_FullSessionMat));
            PeakNormalizedNeurons_FullSessionMat(end+1,:) = zeros(1,length(PeakNormalizedNeurons_FullSessionMat));
            PeakNormalizedNeurons_FullSessionMat(end+1,:) = zeros(1,length(PeakNormalizedNeurons_FullSessionMat));
            PeakNormalizedNeurons_FullSessionMat(end+1,:) = zeros(1,length(PeakNormalizedNeurons_FullSessionMat));
            PeakNormalizedNeurons_FullSessionMat(end+1,:) = zeros(1,length(PeakNormalizedNeurons_FullSessionMat));
            PeakNormalizedNeurons_FullSessionMat(end+1,:) = zeros(1,length(PeakNormalizedNeurons_FullSessionMat));
        
            % Plotting
            clear figgie figname
            
            % Plot Heatmap
            figgie = figure('Units','normalized','Position',[0 0 1 1]);
            colormap('jet');
            imagesc(PeakNormalizedNeurons_FullSessionMat(:,1:27000));
            zaxis = colorbar; hold on
            yvals = get(gca,'Ytick')
            axes = get(gca)
            plot(Hit.*10,yvals(end)+10,'go','LineWidth',3)
            zaxis.Label.String = '% df/F relative to global peak'
            %ylim([0 yvals(end)])
            xlabel('Samples')
            ylabel('Neuron #')
            title('Heatmap of Peak-Normalized Full Session Cell Traces (All Neurons)'); 
            hold off;
            
             cd('Z:\Circuits projects (CPT)\CPT Recording Data\GCaMP6f\FULL-SESSION_BEHAVIORAL-EVENT_NEURONAL-ACTIVITY')
             figname = erase(filename,'AllCellAvgResponses.mat')
             figname = erase(figname,'Hit_Transients')
             figname = append(figname,'PeakNormalized_FullSession_Heatmap_ALLNEURONS_BehavioralEvents')
             saveas(figgie,figname,'fig');
             saveas(figgie,figname,'tif');
            
        
        % Event sorted plotting
            
            % Now sorted, use index of sorted normalized average windows
            FullSessionNeuronsSorted = PeakNormalizedNeurons_FullSessionMat(I_AvgResponse,:);
            
            %add columns for behavioral event plotting space
            FullSessionNeuronsSorted(end+1,:) = zeros(1,length(FullSessionNeuronsSorted));
            FullSessionNeuronsSorted(end+1,:) = zeros(1,length(FullSessionNeuronsSorted));
            FullSessionNeuronsSorted(end+1,:) = zeros(1,length(FullSessionNeuronsSorted));
            FullSessionNeuronsSorted(end+1,:) = zeros(1,length(FullSessionNeuronsSorted));
            FullSessionNeuronsSorted(end+1,:) = zeros(1,length(FullSessionNeuronsSorted));
            FullSessionNeuronsSorted(end+1,:) = zeros(1,length(FullSessionNeuronsSorted));
            FullSessionNeuronsSorted(end+1,:) = zeros(1,length(FullSessionNeuronsSorted));
            FullSessionNeuronsSorted(end+1,:) = zeros(1,length(FullSessionNeuronsSorted));
            FullSessionNeuronsSorted(end+1,:) = zeros(1,length(FullSessionNeuronsSorted));
            FullSessionNeuronsSorted(end+1,:) = zeros(1,length(FullSessionNeuronsSorted));
            FullSessionNeuronsSorted(end+1,:) = zeros(1,length(FullSessionNeuronsSorted));
            FullSessionNeuronsSorted(end+1,:) = zeros(1,length(FullSessionNeuronsSorted));
            FullSessionNeuronsSorted(end+1,:) = zeros(1,length(FullSessionNeuronsSorted));
            FullSessionNeuronsSorted(end+1,:) = zeros(1,length(FullSessionNeuronsSorted));
            FullSessionNeuronsSorted(end+1,:) = zeros(1,length(FullSessionNeuronsSorted));
            clear figgie figname
            % Plot Heatmap
            figgie = figure;
            colormap('jet');
            imagesc((FullSessionNeuronsSorted(:,:)));
            zaxis = colorbar; hold on
            yvals = get(gca,'Ytick')
            xvals = get(gca,'Xtick')
            plot(Hit.*10,yvals(end),'go','LineWidth',3)
            zaxis.Label.String = '% df/F relative to global peak'
            %ylim([0 yvals(end)])
            xlabel('Samples')
            ylabel('Neuron #')
            title('Heatmap of Peak-Normalized Full Session Cell Traces (All Neurons)(Sorted)'); 
            hold off;
        
        
            % line plotting of events
            hitplotzeros = zeros(1,(length(Hit)));
            faplotzeros = zeros(1,length(False_Alarm));
            clear figgie figname
            % Plot Heatmap
            figgie = figure;
            colormap('jet');
            imagesc((FullSessionNeuronsSorted(:,27000)));
            zaxis = colorbar; hold on
            yvals = get(gca,'Ytick')
            xvals = get(gca,'Xtick')
            for z = 1:length(Hit)
            plot([Hit(z).*10,Hit(z).*10],[hitplotzeros(z),(hitplotzeros(z)+yvals(end)+10)],'g','LineWidth',1)
            end
            zaxis.Label.String = '% df/F relative to global peak'
            %ylim([0 yvals(end)])
            xlabel('Samples')
            ylabel('Neuron #')
            title('Heatmap of Peak-Normalized Full Session Cell Traces (All Neurons)(Sorted)'); 
            hold off;
    elseif strcmp('3',stagenum{1}) == 1
            [ordername, orderpath] = uigetfile('','Please load the RAW DATA STRUCTURE, (PRE-SLICED)')
            cd(orderpath);
            load(ordername,'Hit');
            load(ordername,'False_Alarm');
        
            % Divide all values of raw trace by cell-specific global peak normalizing factor 
            for neuroni = 1:length(AvgNeuronWins)
                PeakNormalizedNeurons_FullSession{1,neuroni} = (cell2mat(Transients{:,neuroni}))./TracePeak(1,neuroni);
            end
            
            for neuroni = 1:length(PeakNormalizedNeurons_FullSession)
                PeakNormalizedNeurons_FullSessionMat(neuroni,:) = (PeakNormalizedNeurons_FullSession{1,neuroni});
            end
            
            PeakNormalizedNeurons_FullSessionMat(end+1,:) = zeros(1,length(PeakNormalizedNeurons_FullSessionMat));
            PeakNormalizedNeurons_FullSessionMat(end+1,:) = zeros(1,length(PeakNormalizedNeurons_FullSessionMat));
            PeakNormalizedNeurons_FullSessionMat(end+1,:) = zeros(1,length(PeakNormalizedNeurons_FullSessionMat));
            PeakNormalizedNeurons_FullSessionMat(end+1,:) = zeros(1,length(PeakNormalizedNeurons_FullSessionMat));
            PeakNormalizedNeurons_FullSessionMat(end+1,:) = zeros(1,length(PeakNormalizedNeurons_FullSessionMat));
            PeakNormalizedNeurons_FullSessionMat(end+1,:) = zeros(1,length(PeakNormalizedNeurons_FullSessionMat));
            PeakNormalizedNeurons_FullSessionMat(end+1,:) = zeros(1,length(PeakNormalizedNeurons_FullSessionMat));
            PeakNormalizedNeurons_FullSessionMat(end+1,:) = zeros(1,length(PeakNormalizedNeurons_FullSessionMat));
            PeakNormalizedNeurons_FullSessionMat(end+1,:) = zeros(1,length(PeakNormalizedNeurons_FullSessionMat));
            PeakNormalizedNeurons_FullSessionMat(end+1,:) = zeros(1,length(PeakNormalizedNeurons_FullSessionMat));
            PeakNormalizedNeurons_FullSessionMat(end+1,:) = zeros(1,length(PeakNormalizedNeurons_FullSessionMat));
            PeakNormalizedNeurons_FullSessionMat(end+1,:) = zeros(1,length(PeakNormalizedNeurons_FullSessionMat));
            PeakNormalizedNeurons_FullSessionMat(end+1,:) = zeros(1,length(PeakNormalizedNeurons_FullSessionMat));
            PeakNormalizedNeurons_FullSessionMat(end+1,:) = zeros(1,length(PeakNormalizedNeurons_FullSessionMat));
            PeakNormalizedNeurons_FullSessionMat(end+1,:) = zeros(1,length(PeakNormalizedNeurons_FullSessionMat));
            PeakNormalizedNeurons_FullSessionMat(end+1,:) = zeros(1,length(PeakNormalizedNeurons_FullSessionMat));
            PeakNormalizedNeurons_FullSessionMat(end+1,:) = zeros(1,length(PeakNormalizedNeurons_FullSessionMat));
            PeakNormalizedNeurons_FullSessionMat(end+1,:) = zeros(1,length(PeakNormalizedNeurons_FullSessionMat));
            PeakNormalizedNeurons_FullSessionMat(end+1,:) = zeros(1,length(PeakNormalizedNeurons_FullSessionMat));
        
            % Plotting
            clear figgie figname
            
            % Plot Heatmap
            figgie = figure('Units','normalized','Position',[0 0 1 1]);
            colormap('jet');
            imagesc(PeakNormalizedNeurons_FullSessionMat(:,1:27000));
            zaxis = colorbar; hold on
            yvals = get(gca,'Ytick')
            axes = get(gca)
            plot(Hit.*10,yvals(end)+10,'go','LineWidth',3)
            plot(False_Alarm.*10,yvals(end)-3,'ro','LineWidth',3)
            zaxis.Label.String = '% df/F relative to global peak'
            %ylim([0 yvals(end)])
            xlabel('Samples')
            ylabel('Neuron #')
            title('Heatmap of Peak-Normalized Full Session Cell Traces (All Neurons)'); 
            hold off;
            
             cd('Z:\Circuits projects (CPT)\CPT Recording Data\GCaMP6f\FULL-SESSION_BEHAVIORAL-EVENT_NEURONAL-ACTIVITY')
             figname = erase(filename,'AllCellAvgResponses.mat')
             figname = erase(figname,'Hit_Transients')
             figname = append(figname,'PeakNormalized_FullSession_Heatmap_ALLNEURONS_BehavioralEvents')
             saveas(figgie,figname,'fig');
             saveas(figgie,figname,'tif');
            
        
            % Event sorted plotting
            
            % Now sorted, use index of sorted normalized average windows
            FullSessionNeuronsSorted = PeakNormalizedNeurons_FullSessionMat(I_AvgResponse,:);
            
            %add columns for behavioral event plotting space
            FullSessionNeuronsSorted(end+1,:) = zeros(1,length(FullSessionNeuronsSorted));
            FullSessionNeuronsSorted(end+1,:) = zeros(1,length(FullSessionNeuronsSorted));
            FullSessionNeuronsSorted(end+1,:) = zeros(1,length(FullSessionNeuronsSorted));
            FullSessionNeuronsSorted(end+1,:) = zeros(1,length(FullSessionNeuronsSorted));
            FullSessionNeuronsSorted(end+1,:) = zeros(1,length(FullSessionNeuronsSorted));
            FullSessionNeuronsSorted(end+1,:) = zeros(1,length(FullSessionNeuronsSorted));
            FullSessionNeuronsSorted(end+1,:) = zeros(1,length(FullSessionNeuronsSorted));
            FullSessionNeuronsSorted(end+1,:) = zeros(1,length(FullSessionNeuronsSorted));
            FullSessionNeuronsSorted(end+1,:) = zeros(1,length(FullSessionNeuronsSorted));
            FullSessionNeuronsSorted(end+1,:) = zeros(1,length(FullSessionNeuronsSorted));
            FullSessionNeuronsSorted(end+1,:) = zeros(1,length(FullSessionNeuronsSorted));
            FullSessionNeuronsSorted(end+1,:) = zeros(1,length(FullSessionNeuronsSorted));
            FullSessionNeuronsSorted(end+1,:) = zeros(1,length(FullSessionNeuronsSorted));
            FullSessionNeuronsSorted(end+1,:) = zeros(1,length(FullSessionNeuronsSorted));
            FullSessionNeuronsSorted(end+1,:) = zeros(1,length(FullSessionNeuronsSorted));
            clear figgie figname
            % Plot Heatmap
            figgie = figure;
            colormap('jet');
            imagesc((FullSessionNeuronsSorted(:,:)));
            zaxis = colorbar; hold on
            yvals = get(gca,'Ytick')
            xvals = get(gca,'Xtick')
            plot(Hit.*10,yvals(end),'go','LineWidth',3)
            plot(False_Alarm.*10,yvals(end)-3,'ro','LineWidth',3)
            zaxis.Label.String = '% df/F relative to global peak'
            %ylim([0 yvals(end)])
            xlabel('Samples')
            ylabel('Neuron #')
            title('Heatmap of Peak-Normalized Full Session Cell Traces (All Neurons)(Sorted)'); 
            hold off;
        
        
            % line plotting of events
            hitplotzeros = zeros(1,(length(Hit)));
            faplotzeros = zeros(1,length(False_Alarm));
            clear figgie figname
            % Plot Heatmap
            figgie = figure;
            colormap('jet');
            imagesc((FullSessionNeuronsSorted(:,27000)));
            zaxis = colorbar; hold on
            yvals = get(gca,'Ytick')
            xvals = get(gca,'Xtick')
            for z = 1:length(Hit)
            plot([Hit(z).*10,Hit(z).*10],[hitplotzeros(z),(hitplotzeros(z)+yvals(end)+10)],'g','LineWidth',1)
            end
            for z = 1:length(False_Alarm)
            plot([False_Alarm(z).*10,False_Alarm(z).*10],[faplotzeros(z),(faplotzeros(z)+yvals(end)+10)],'r','LineWidth',1)
            end
            zaxis.Label.String = '% df/F relative to global peak'
            %ylim([0 yvals(end)])
            xlabel('Samples')
            ylabel('Neuron #')
            title('Heatmap of Peak-Normalized Full Session Cell Traces (All Neurons)(Sorted)'); 
            hold off;
        end
end


%% Full Session, Binned, Activity Traces 

FullSessionNeuronsSorted = PeakNormalizedNeurons_FullSessionMat(I_AvgResponse,:);

clear figgie figname
% Plot Heatmap
figgie = figure; hold on
colormap('jet');
bins = 45/3;

colorlims = [.4 1.0];


tiledlayout(5,3)
for bini = 1:bins
    if bini == 1
        nexttile
        imagesc((FullSessionNeuronsSorted(1:10,bini:(bini*1800))));
        set(gca,'Clim',colorlims)
    else
        nexttile
        imagesc((FullSessionNeuronsSorted(1:10,((bini-1)*1800):(bini*1800))));
        set(gca,'Clim',colorlims)
    end
end
cb = colorbar;
cb.Layout.Tile = 'east';
sgtitle('Three Minute Binned Top 10 Neuron Activity')

 figname = erase(filename,'AllCellAvgResponses.mat')
 figname = append(figname,'PeakNormalized_FullSessionBinned_Heatmaps_Sorted')
 figname = append(figname, sortStyle);
cd(filepath)
 saveas(figgie,figname,'fig');
 saveas(figgie,figname,'tif');





