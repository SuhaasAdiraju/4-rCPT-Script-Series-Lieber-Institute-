%% SignalValidity_NTsensor
function [Prob,PercentFlucts,PercentMean, zTransients] = SignalValidity_NTsensor(varargin)
% NT Sensor data processing, exponential trend removal and dF / f
% distribution, session signal validity
    
%% make sure paths are set to access functions
clear; clc; close all
if ~exist('Z:\Suhaas A\Analysis things\chronux_2_12', 'dir') == 1
   addpath(genpath('Z:\Circuits projects (CPT)\rCPT_Analyses'))
end


% loop across multiple subjects for efficiency
subs = inputdlg('How many subjects would you like to apply this analysis for in this session?')
subs = str2num(subs{1});
for subsnum = 1:length(subs)
    %% Define and load your data     
        [filename, filepath] = uigetfile ('.mat','Please select the mat file containing your raw NT sensor session recording data');
        cd(filepath);
        load(filename);
        saveplace = uigetdir('','Where do you want to save the signal validity assessment figures')
    %% Fit and subtract a low-order ploynomial from the signal now preformed in preprocessing
            
    % create a vector of length (Transients)
    TransientsSamples = linspace(0,length(Transients),length(Transients));
    
    % set polynomial order
    polyorder = 6;
    
    % run polyfit (x, y, polyorder)
    [p,s,mu] = polyfit(TransientsSamples,Transients(1,:),polyorder);
    
    % compute polynomial
    TransientsFit = polyval(p,TransientsSamples,[],mu);
    
    % subtract the computed polynom trend from the original signal
    detrendTransients = Transients - TransientsFit;
        
    %% plot to visualize normalized baseline
        f1 = figure; 
        subplot 211
        plot(TransientsSamples,Transients,'k');
        xlabel('Samples')
        ylabel('df / F')
        title('Raw Transients')
        subplot 212
        plot(TransientsSamples,detrendTransients,'b');
        ylabel('df / F')
        xlabel('Samples')
        title('Detrended Transients')
        sgtitle('RAW vs Detrended Transients')
        
        
    %% Compute PDF (probability range of values deviating from mean) and set global threshold for signal validity
    Signal = detrendTransients;
    pd = fitdist(Signal','Normal');
    meanTrans = pd.mu;
    stdDev = pd.sigma;
    pdfTransients = normpdf(Signal,meanTrans,stdDev);
    
    % find the integral of a range of values to assess probability for
    % range of df/f values using normcdf
    lims = [(meanTrans) (meanTrans+.02)];
    cp = normcdf(lims, meanTrans, stdDev);
    Prob =  cp(2) - cp(1);         
    
    txt = sprintf('Probability of df/f being between 0 and .02 is %.2f%% ',Prob*100);
    
    f2 = figure; 
    %plot(Signal,pdfTransients); 
    histfit(Signal); hold on
    set(gcf, 'Position', get(0, 'Screensize'));
    DetrendYvals = get(gca,'Ytick');
    xlabel('df / F');
    ylabel('pdf');
    sgtitle('Probability Density of df / F values');
    %plot([stdDev+meanTrans stdDev+meanTrans],[DetrendYvals.TickValues(1) DetrendYvals.TickValues(end)],'LineStyle','--','Color','r');
    %plot([((2*stdDev)+meanTrans) ((2*stdDev)+meanTrans)],[DetrendYvals.TickValues(1) DetrendYvals.TickValues(end)],'LineStyle','--','Color','g'); 
    %plot([meanTrans meanTrans],[DetrendYvals(1) DetrendYvals(end)],'LineStyle','--','Color','b'); 
    %text(meanTrans, DetrendYvals.TickValues(end)/2, txt); hold off
    legend({'df/f distribution','1 Std Dev from the mean','Mean of signal'});
    
    fignameTrace = erase(filename,'.mat');
    fignameTrace = erase(fignameTrace,'RAW');
    fignameTrace = append(fignameTrace,'CorrectedTrace')
    
    fignamePDF = erase(filename,'.mat');
    fignamePDF = erase(fignamePDF,'RAW');
    fignamePDF = append(fignamePDF,'PDF')
    
    cd(saveplace);
    saveas(f2,fignamePDF,'fig')
    saveas(f2,fignamePDF,'tif')
    % 
    saveas(f1,fignameTrace,'fig')
    saveas(f1,fignameTrace,'tif')
    % 
    
    %% Also assess using z scores
    zTransients = zscore(detrendTransients);
    fluctTransients = zTransients >= 1;
    fluctTransients(fluctTransients == 0) = [];
    PercentFlucts = length(fluctTransients)/length(Transients);
    MeanTransients = zTransients <= 0.5;
    MeanTransients(MeanTransients == 0) = [];
    PercentMean = length(MeanTransients)/length(Transients);
    
    
    txt = sprintf('%% of signal <= .5 SD is %.2f%%\n\n%% of signal >= 1 SD is %.2f%%',PercentMean*100,PercentFlucts*100);
    
    xTransients = linspace(0,(length(Signal)/10)/60,length(zTransients))
    FigZ = figure; plot(xTransients, zTransients)
    Yvalues = get(gca,'YAxis');
    Xvalues = get(gca,'XAxis');
    text(Xvalues.TickValues(end)/1.85, Yvalues.TickValues(1)+1, txt);
    set(gcf, 'Position', get(0, 'Screensize'));
    xlabel('Time (minutes)')
    title('Z-scored Signal')
    
    cd(saveplace);
    figname = erase(fignamePDF,'PDF')
    Zscorefigname = append(figname,'ZscoreAssessment')
    saveas(FigZ,Zscorefigname,'fig')
    saveas(FigZ,Zscorefigname,'tif')
    
    %% Show me the average of the signals to further investigate a global value
    %{
        subsnum = 5;
            for z = 1:subsnum
                load(uigetfile,"-mat",'Transients')
                AllTransients(z,:) = Transients(1,1:27000);
                AvgSignal = mean(AllTransients,1);
            end
    %}
subsnum = subs + 1;
end

end