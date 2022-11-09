clc; clear; close all; clf

[filename filepath] = uigetfile;
cd(filepath);
load(filename,'lfp','Hit','False_Alarm');
fs = 2000;
params.tapers = [5 7];
params.Fs = 2000;
%waitfor(msgbox(sprintf('In the next box indicate what frequency range you want to look at')));
%freqlims = inputdlg({'Lower-freq. bound','Upper-freq. bound'})
%params.fpass = [str2num(freqlims{1,1}) str2num(freqlims{2,1})];
params.fpass = [0 60]
params.trialave = 0;
%waitfor(msgbox(sprintf('An important parameter for computing a spectrogram is the window size and step size of the moving window. \n\n Here, your data set is %d seconds long. The next prompt will ask you for window size and step size inputs.\n\nThe dimensions of your sliding window will impact temporal and spectral resolution in a ''tradeoff'' manner,\n\ni.e. larger window will = less available steps, less temporal resolution, but greater spectral resolution\n\nAlternatively, smaller window = more steps available, higher temporal resolution, but smaller window for spectral components to be assessed in --> more spectral leakage/distortion.\n\nThis can be attenuated with having *more overlap* among windows (decreasing step size while maintaining window size), yielding a smoother time-freq. map, but again it is a trade-off and you cannot makeup fully for the effects of a small spectral assessment window\n\n\nA good default window and step size is window: 0.3, step: .05, you can start from there and adapt based-on your data',eventseconds)))
%winparams = inputdlg({'Window size? (in seconds)','Step size? (in seconds)'})        
%movingwin = [str2num(winparams{1,1}) str2num(winparams{2,1})]; % window size is 1000 samples, and step size is 100 samples
movingwin = [15 2];
%% ACC
x2 = lfp(4,1:2700*fs);
[Sgram,tsgram,fgram] = mtspecgramc(x2',movingwin,params);
P = pspectrum(x2,2000);
figure; plot(P)
F = figure; plot_matrix(Sgram,tsgram,fgram'); hold on 
colorbar
colormap default
title(sprintf('Averaged Spectrogram Using Chronux mtspecgramc function\n'))
xlim([0 2700])
ylim([0 20])
plot(Hit,4,'go','LineWidth',3)
plot(False_Alarm,4.5,'ro','LineWidth',3)
%plot(Miss,5,'wo','LineWidth',3)
%plot(Correct_Rej,5.5,'yo','LineWidth',3)
set(gca,'clim',[-5 30])
Figname = erase(filename,'.mat');
Figname = append(Figname,'__AccLFP');
Figname = append(Figname,'FullSessionSpectrogram');
cd('Z:\Circuits projects (CPT)\CPT Recording Data\Ephys Characterization Paper Cohort\PROCESSED DATA\RAW STRUCTURES\S3Good\FULL-SESSION-EVENTS-SPECTROGRAMS');
saveas(F,Figname);

%% LC
x2 = lfp(3,1:2700*fs);
[Sgram,tsgram,fgram] = mtspecgramc(x2',movingwin,params);
P = pspectrum(x2,2000);
figure; plot(P);
F = figure; plot_matrix(Sgram,tsgram,fgram'); hold on 
colorbar
colormap jet
title(sprintf('Averaged Spectrogram Using Chronux mtspecgramc function\n'))
xlim([0 2700])
ylim([0 20])
plot(Hit,4,'go','LineWidth',3)
plot(False_Alarm,4.5,'ro','LineWidth',3)
%plot(Miss,5,'wo','LineWidth',3)
%plot(Correct_Rej,5.5,'yo','LineWidth',3)
set(gca,'clim',[-5 30])
clear Figname
Figname = erase(filename,'.mat');
Figname = append(Figname,'__LcLFP');
Figname = append(Figname,'FullSessionSpectrogram');
cd('Z:\Circuits projects (CPT)\CPT Recording Data\Ephys Characterization Paper Cohort\PROCESSED DATA\RAW STRUCTURES\S3Good\FULL-SESSION-EVENTS-SPECTROGRAMS');
saveas(F,Figname);