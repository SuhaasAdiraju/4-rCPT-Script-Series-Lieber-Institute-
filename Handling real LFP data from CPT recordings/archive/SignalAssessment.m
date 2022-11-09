%% SIGNAL CHECK
% This script is designed to input a signal of desire, and be able to
% assess its frequency and spectral components for confirmation you have a
% sufficient connection/recording

% Script written by Suhaas Adiraju; Code/parameters for plotting provided by Henry Hallock

%% Choose your signal for assessment 
% clear; clc;
waitfor(msgbox(sprintf('A file selector will pop-up, then SELECT THE .mat FILE CONTAINING THE SIGNAL YOU WOULD LIKE TO ASSESS')))
[lfp_name, lfp_path] = uigetfile('','What is the data you would like to perform signal assessment on?');
while (lfp_name) == 0
    waitfor(warndlg('You didn''t select the lfp file you would like to perform signal assessment on. Please try again. Or if you are trying to quit press the stop button under the editor tab at the top of MATLAB'))
    [lfp_name, lfp_path] = uigetfile('','What is the data you would like to perform signal assessment on?');
end
%% Load 

cd(lfp_path);
lfp_struct = load (lfp_name);
lfp_Cell = struct2cell(lfp_struct);
lfp_mat = cell2mat(lfp_Cell);

%% Assess/Plot
% Power spectrum 
params.tapers = [5 9];
params.pad = 0;
params.Fs = 2000;
params.fpass = [0 200];
params.err = [2 0.05];
params.trialave = 0;

% varslist = who;
% varslistQuery = sprintf('%s\n',varslist{:});
% varTitle = 'Please re-type which variable corresponds to the loaded in data you would like to perform signal assessment on'
% lfpname = inputdlg(varslistQuery,varTitle)


waitfor(msgbox(sprintf('THIS THE POWER SPECTRUM FOR ''%s''',lfp_name)))

    for i = length(lfp_mat(:,1))
    [S,f,Serr] = mtspectrumc(lfp_mat(i,:),params);
    figure1 = figure; hold on
    subplot(i,1,i)
    plot(f,S, 'LineWidth',1.5); hold on 
        if i == 1          
            %title(['GROUND;'])
        elseif i == 2
            %title(['STRAIGHT PIN'])
        elseif i == 3
             %title(['LC/VTA'])
        elseif i == 4
            %title(['ACC'])
        end
        sgtitle(lfp_name)
    end

uiwait(figure1)

waitfor(msgbox(sprintf('THIS THE SPECTRAL PLOT FOR ''%s''',lfp_name)))

% Spectrogram/Spectral plot
interval = 0.25*2000;
overlap = 0.95*interval;
nfft = 2000;
figure2 = figure; hold on
    for i = (length(lfp_mat(:,1)))
    [S,F,T,P] = spectrogram(lfp_mat(i,:),interval,overlap,nfft,nfft);
    subplot(i,1,i)
    imagesc(T,F,P)
    axis xy
    ylim([0 100])
    colormap jet
        if i == 1
            %title(['GROUND;'])
        elseif i == 2
            %title(['STRAIGHT PIN'])
        elseif i == 3
            % title(['LC/VTA'])
        elseif i == 4
            %title(['ACC'])
        end
        sgtitle(lfp_name)
    end

uiwait(figure2)

waitfor(msgbox('Signal assessment complete!'))
%% Save if wanted 
%{
Figure 2 = fig_Power;
saveprompt = {'Wanna Save? 1 for Yes, 0 for No'}
saveAns = inputdlg(saveprompt)
namePrompt = {'What would you like to name this structure you''re saving (ie mousename_signal_test)'}
name = inputdlg(name)
if saveAns == 1
    save(name,fig_Specgram, fig_Power, '-struct')
elseif saveAns == 0
end
%}
