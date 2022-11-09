%% Epiflourescent Average Response Window Transients Heatmap 
% This script will create a heatmap of the average response activity
% patterns created in '___'4CPT3. Currently this would be applied to either
% Ca2 imaging or GRABsensor imaging

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

%% Peak Normalized sorted avg response heat map
AvgNeuronWinsMat = cell2mat(AvgNeuronWins');

for neuroni = 1:length(AvgNeuronWinsMat(:,1))
    AvgNeuronWinsMaxs(neuroni,:) = max(AvgNeuronWinsMat(neuroni,:))
end

[B,I] = sort(AvgNeuronWinsMaxs,1,"descend");
AvgNeuronWinsMat = AvgNeuronWinsMat(I,:)
AvgNeuronWinsMat = AvgNeuronWinsMat .* 100;
% Plot
colormap('jet')
imagesc((AvgNeuronWinsMat(1:30,:)))
xlabel('Samples (seconds * 10)')
ylabel('Neuron #')
title('Heatmap of Peak-Normalized Hit-Averaged Cell Traces')
colorbar
%}


%% Things to develop

% mean of means (population activity)

% thresholding  of activity type




