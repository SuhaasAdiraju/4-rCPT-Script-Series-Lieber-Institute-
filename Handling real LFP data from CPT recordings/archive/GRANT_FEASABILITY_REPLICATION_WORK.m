        
%% Power Across subjects for multiple conditions and cleaned versus uncleaned (written for replication and grant feasibility data)

% Suhaas Adiraju 03.22.2022


[CrossSubsPowerFalseAlarms,fFalseAlarms,GrandPowErrFalseAlarms] = PowerAcrossSubs
[CrossSubsPowerHits,fHits,GrandPowErrHits] = PowerAcrossSubs
figure;
shadedErrorBar(fHits,CrossSubsPowerHits,GrandPowErrHits,'r', .4); hold on
shadedErrorBar(fFalseAlarms,CrossSubsPowerFalseAlarms,GrandPowErrFalseAlarms,'b', .4);
sgtitle(sprintf('Power Spectrum of 4s Window Surrounding Event (5 subjects)'))
ylabel('Power Value (magnitude of complex coeff. from a fourier transformed signal)')
xlabel('Frequencies (Hz)')
xlim([0 100])


[CrossSubsPowerFalseAlarms,fFalseAlarms,CrossSubsPowerErrFalseAlarms] = PowerAcrossSubsUNCLEANED
[CrossSubsPowerHits,fHits,CrossSubsPowerErrHits] = PowerAcrossSubsUNCLEANED
figure;
shadedErrorBar(f,GrandPowMean_HITS,GrandPowErr_HITS,'k', .4); hold on
shadedErrorBar(f,GrandPowMean,GrandPowErr,'b', .4);
legend({'Hits', 'False Alarms'})
sgtitle(sprintf('Power Spectrum of 4s Window Surrounding Event (6 subjects)'))
ylabel('Power Value (magnitude of complex coeff. from a fourier transformed signal)')
xlabel('Frequencies (Hz)')
xlim([0 90])
