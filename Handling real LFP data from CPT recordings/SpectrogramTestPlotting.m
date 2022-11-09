%% Spectrogram testing

% load in some data, did it manually

% For clarity on tapers and their effect on spectrograms
%{
% https://www.researchgate.net/post/How-do-you-choose-your-taper-value-for-multi-taper-spectral-analysis
%}


%% Single Trial Style, comparing chronux and MATLAB functions
for z = 1:length(Events_Accepted_lfp)
%     [S,F,T,P] = spectrogram((Events_Accepted_lfp{z})',rectwin(512),256,1:20,2000);
    figgie = figure;

    %mono-tapered 
    params.tapers = [1 1];
    params.Fs = 2000;
    params.fpass = [0 110];
    movingwin = [0.3 .05];
    [S,t,f] = mtspecgramc(Events_Accepted_lfp{z},movingwin,params)  
    subplot 131
        plot_matrix(S,t,f)
        colorbar
        c1 = get(gca,'Clim')
        xlabel('Time (seconds)')
        ylabel('Frequency (Hz)')
        title ('Trial %d using Chronux mono-tapered,TB-Prod: window 300samples, steps 100samples',z)

    %multi-tapered
    params.tapers = [5 9];
    params.Fs = 2000;
    params.fpass = [0 110];
    movingwin = [0.3 .05];
    [S2,t2,f2] = mtspecgramc(Events_Accepted_lfp{z},movingwin,params)  
    subplot 132
        plot_matrix(S2,t2,f2)
        colorbar
        c1 = get(gca,'Clim')
        xlabel('Time (seconds)')
        ylabel('Frequency (Hz)')
        title ('Trial %d using Chronux multi-tapered,TB-Prod: window 600samples, steps 100samples',z)

    subplot 212 
        Fs = 2000;
        [S2,F2,T2,P2] = spectrogram(Events_Accepted_lfp{z},512,380,0:110,Fs);
        imagesc(T2,F2,10*log10(P2)); %
        colorbar
        set(gca,'Clim',c1)
        set(gca,'YDir','normal')
        xlabel('Time (seconds)')
        ylabel('Frequency (Hz)')
        title(sprintf('Trial %d Using MATLAB function (and normalized power)',z))
    uiwait(figgie)
end

%% Chronux across trials
% make a matrix of events 
EventsMat = cell2mat(Events_Accepted')

figgie2 = figure;
    params.tapers = [5 9]
    params.Fs = 2000;
    params.fpass = [0 150];
    params.trialave = 1;
    movingwin = [0.5 .05]; % window size is 1000 samples, and step size is 100 samples
    [S,t,f] = mtspecgramc(EventsMat,movingwin,params)  
    plot_matrix(S,t,f)
    colorbar
    c1 = get(gca,'Clim')
    xlabel('Time (seconds)')
    ylabel('Frequency (Hz)')
    title(sprintf('Trials AVG Spectrogram Using Chronux function'))

%% Spectrogram Across Trials 
for z = 1:length(Events_Accepted)   
    Fs = 2000;
    [S2,F2,T2,P2] = spectrogram(Events_Accepted{z},512,380,0:30,Fs);
    specArray{z} = P2; 
end
    specMatrix = cell2mat(specMatrix);
    specMatrixMean = mean(specMatrix,2)
    
    
    
    
    imagesc(T2,F2,10*log10(P2)); 
    colorbar
    set(gca,'Clim',c1)
    set(gca,'YDir','normal')
    xlabel('Time (seconds)')
    ylabel('Frequency (Hz)')
    title(sprintf('Trial %d Using MATLAB function (and normalized power)',z))
    uiwait(figgie)
