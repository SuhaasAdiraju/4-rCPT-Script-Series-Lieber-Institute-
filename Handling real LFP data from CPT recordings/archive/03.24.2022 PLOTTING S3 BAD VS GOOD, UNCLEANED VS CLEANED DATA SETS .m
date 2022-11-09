% 03.24.2022 PLOTTING S3 BAD VS GOOD, UNCLEANED VS CLEANED DATA SETS 
% 6 MICE from cohort '2' compared to when Suhaas and Jorge started (06.2022)

%data sets found in CPT recording data folder
%--Suhaas Adiraju

subplot 221
shadedErrorBar(f,S3BADGrandPowMeanFAUNCLEANED,S3BADGrandPowErrFAUNCLEANED,'r',.6); hold on
    shadedErrorBar(f,S3BADGrandPowMeanHITSUNCLEANED,S3BADGrandPowErrHITSUNCLEANED,'g',.6);
    title('UNCLEANED S3 BAD')
    xlim([0 50])
    ylim([0 200])
    
subplot 222
    shadedErrorBar(f,S3BADGrandPowMeanFACLEANED,S3BADGrandPowErrFACLEANED,'r',.6); hold on
    shadedErrorBar(f,S3BADGrandPowMeanHITSCLEANED,S3BADGrandPowErrHITSCLEANED,'g',.6);
    title('CLEANED S3 BAD')
    xlim([0 50])
    ylim([0 200])


subplot 223
    shadedErrorBar(f,GrandPowMeanS3GOODFAsUNCLEAN,GrandPowErrS3GOODFAsUNCLEAN,'r',.6); hold on
    shadedErrorBar(f,GrandPowMeanS3GOODHITSUNCLEAN,GrandPowErrS3GOODHITSUNCLEAN,'g',.6);
    title('UNCLEANED S3 GOOD')
    xlim([0 100])
    ylim([0 200])


subplot 224
    shadedErrorBar(f,S3GOODGrandPowMean_FASCLEANED,S3GOODGrandPowErr_FASCLEANED,'r',.6); hold on
    shadedErrorBar(f,S3GOODGrandPowMean_HITSCLEANED,S3GOODGrandPowErr_HITSCLEANED,'g',.6);
    title('CLEANED S3 GOOD')
    xlim([0 50])
    ylim([0 200])
    
sgtitle('S3 BAD and GOOD CLEANED VERSUS UNCLEANED')


S3BadGoodClean = ...
figure; 
subplot 121
    shadedErrorBar(f,S3BADGrandPowMeanFACLEANED,S3BADGrandPowErrFACLEANED,'r',.6); hold on
    shadedErrorBar(f,S3BADGrandPowMeanHITSCLEANED,S3BADGrandPowErrHITSCLEANED,'g',.6);
    title('CLEANED S3 BAD')
    xlim([0 50])
    ylim([0 80])
subplot 122
    shadedErrorBar(f,S3GOODGrandPowMean_FASCLEANED,S3GOODGrandPowErr_FASCLEANED,'r',.6); hold on
    shadedErrorBar(f,S3GOODGrandPowMean_HITSCLEANED,S3GOODGrandPowErr_HITSCLEANED,'g',.6);
    title('CLEANED S3 GOOD')
    xlim([0 50])
    ylim([0 80])

%sgtitle('S3 BAD VS GOOD CLEANED')

[data,S3BadGoodCleanExport] = export_fig(S3BadGoodClean); 

l = imagesc(data)
