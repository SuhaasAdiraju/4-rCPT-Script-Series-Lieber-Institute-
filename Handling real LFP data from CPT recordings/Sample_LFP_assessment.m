%% LFP Samples Assessment
% this is quick acting script for assessment of signal quality of ephys
% mice, a user can simply hit "Run" under the "Editor" tab, and select the
% file they wish to assess

% the 'assessment', is via a multi-taper power spectrum analysis, if the
% 1/f power law is followed, it is likely the headstage/electrodes are
% successfully implanted 

% REQUIREMENT: the user MUST have already openened the '.pvfs' file in
% Sirenia software, and exported the data as an '.EDF' file. Next the user
% must have run Stage 1 of the LFP processing and analysis pipeline. Then
% they can come to this script and run assessment (this whole process
% should take well under an hour)

clc; clear
[filename filepath] = uigetfile('')
load(filename)

params.tapers = [5 9];
params.pad = 0;
params.Fs = 2000;
params.fpass = [0 200];
params.err = [2 .05];
params.trialave = 0;
[S_second,f_second] = mtspectrumc(lfp(3,:), params);
[S_acc,f_acc] = mtspectrumc(lfp(4,:), params);


figure;
subplot 121
plot(f_second,S_second)
title('Brain Region 2')
subplot 122
plot(f_acc,S_acc)
title('ACC')