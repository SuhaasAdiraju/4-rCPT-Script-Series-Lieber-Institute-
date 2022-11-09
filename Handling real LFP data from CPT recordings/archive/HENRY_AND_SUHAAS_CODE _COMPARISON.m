%% Henry and Suhaas Code Comparison

%% HENRY
%clear;
HitsHENRY = Hit*2000;

for i = 1:length(HitsHENRY)
%i = 5;
acc_HitsHENRY(i,:) = lfp(4,HitsHENRY(i)-4000:HitsHENRY(i)+4000);
end


% Set Params for power spectrum calc
% Standard params (given by H.H.) 
params.tapers = [5 9];
params.pad = 0;
params.Fs = 2000;
params.fpass = [0 200];
params.err = [2 .05];
params.trialave = 0;


for event = 1:length(acc_HitsHENRY(:,1))
    [S(event,:),f,Serr] = mtspectrumc(acc_HitsHENRY(event,:),params);
end
PowMeanHENRY = mean(S,1);


%% SUHAAS 
params.tapers = [5 9];
params.pad = 0;
params.Fs = 2000;
params.fpass = [0 200];
params.err = [2 .05];
params.trialave = 0;
srate = 2000;
TimeWin = 4;

HitidxSUHAAS = Hit * srate; 
HitidxSUHAAS = int64(HitidxSUHAAS);
 
if sum(size(Hit)) >= 2
    for i = 1:length(HitidxSUHAAS)
        if (HitidxSUHAAS(i)+(srate*TimeWin/2))<(length(lfp)) && (HitidxSUHAAS(i)-(srate*TimeWin/2))>(0)                       
            ACC.Hit_lfp{i} = lfp(4,[HitidxSUHAAS(1,i)-(srate*TimeWin/2):HitidxSUHAAS(1,i)+(srate*TimeWin/2)]);
        end
    end
end    



for event = 1:length(ACC.Hit_lfp)
    [Scell,f,Serr] = mtspectrumc(ACC.Hit_lfp{1,event},params)
    PowCell{event} = Scell;
end


% Create matrices of all events

Pow = cell2mat(PowCell) % the columns are the events, you can verify by looking back into 'PowVals'
    % Sanity Check  
    randpowEvent = randi(length(PowCell))
     if Pow(:,randpowEvent) == PowCell{1,randpowEvent}
         sprintf('\n\nseems like conversion to a matrix worked as intended')
     end
% take the mean of output 
PowMeanSUHAASHits4 = mean(Pow,2);

clearvars -except PowMeanSUHAASHits* params

grandpow(:,1) = PowMeanSUHAASHits1(:)
grandpow(:,2) = PowMeanSUHAASHits2(:)
grandpow(:,3) = PowMeanSUHAASHits3(:)
grandpow(:,4) = PowMeanSUHAASHits4(:)

grandpowmean = mean(grandpow,2)

plot(f,grandpowmean')


%% Comparison Testing

% Range of timewindows to grab 
for i = 1:length(HitsHENRY)
    HenryTimeRange = HitsHENRY(i)-4000:HitsHENRY(i)+4000;
    SuhaasTimeRange = [HitidxSUHAAS(1,i)-(srate*TimeWin/2):HitidxSUHAAS(1,i)+(srate*TimeWin/2)];
end


% Indexing syntax  
matrix1 = randn(3,30); 
GrabHHstyle = matrix1(3,10-5:10+5);
GrabSAstyle = matrix1(3,[10-5:10+5]);




% Range of timewindows to grab 
if HenryTimeRange == SuhaasTimeRange
    sprintf('\n\nThe time window definitions for slicing match')
end

% Indexing Syntax   
if GrabSAstyle == GrabHHstyle
    sprintf('\n\nThere shouldnt be a problem with the syntax of indexing')
end


% Timestamp resolution scaling
if HitsHENRY == HitidxSUHAAS
    sprintf ('\n\nThe timestamps match')
else
    mismatches = HitsHENRY == HitidxSUHAAS;
    mismatchesIdx = find(mismatches == 0);
    mismatchesSUHAAS = HitidxSUHAAS(1,mismatchesIdx);
    mismatchesHENRY = HitsHENRY(1,mismatchesIdx);
        for i = 1:length(mismatchesHENRY)
            sprintf('\nThe timestamps that dont match are \nSuhaas: %d Henry : %d',mismatchesSUHAAS(i), mismatchesHENRY(i))
        end
end


% Resulting LFP slice 
for i = 1:length(acc_HitsHENRY(:,1))
    if (acc_HitsHENRY(i,:) == ACC.Hit_lfp{i})
        LFPeventsEqual(i) = i;
        LFPeventsUnequal(i) = NaN;
    else
        LFPeventsUnequal(i) = i;
        LFPeventsEqual(i) = NaN;
    end
end
LFPeventsEqual = LFPeventsEqual((isnan(LFPeventsEqual)) == 0)
LFPeventsUnequal = LFPeventsUnequal((isnan(LFPeventsUnequal))== 0)

if length(LFPeventsEqual) == length(HitsHENRY)
    sprintf('\n\nAll Event LFP slices match')
else
    sprintf('Event %d, LFP slices are unequal\n',LFPeventsUnequal)
end


% Power Across Events (SINGLE SUBJECT)
if PowMeanSUHAAS == PowMeanHENRY'
    sprintf('Power across events means match')
else 
    sprintf('Power across events means dont match')
end

shadedErrorBar(f,PowMeanSUHAAS); hold on
p = plot(f,PowMeanSUHAASHits,'g',f,PowMeanSUHAAS,'r')
p.LineWidth = 2


clear; clc



%%  Lets do power across subjects, because everything  for a single subject seems to match

%% HENRY
subs = 6;

% Set Params for power spectrum calc
% Standard params (given by H.H.) 
params.tapers = [5 9];
params.pad = 0;
params.Fs = 2000;
params.fpass = [0 200];
params.err = [2 .05];
params.trialave = 0;

for subsi = 1:(subs)
        file = uigetfile('select the subject')
        load(file)
    
        HitsHENRY = Hit*2000;
        
        for i = 1:length(HitsHENRY)
        %i = 5;
        acc_HitsHENRY(i,:) = lfp(4,HitsHENRY(i)-4000:HitsHENRY(i)+4000);
        end
        
        
        for event = 1:length(acc_HitsHENRY(:,1))
            [S(event,:),f,Serr] = mtspectrumc(acc_HitsHENRY(event,:),params);
        end
        PowMeanHENRY = mean(S,1);
GrandPowHENRY(subsi,:) = PowMeanHENRY
end

% calculate error (code from H.H.)
GrandPowStdHENRY = std(GrandPowHENRY,0,1);
GrandPowErrHENRY = GrandPowStdHENRY/sqrt(size(GrandPowHENRY,1));

% Take Mean 
GrandPowMeanHENRY = mean(GrandPowHENRY,1)



%% SUHAAS 
subs = 4; %6
for subsi = 1:(subs)
    file = uigetfile('select the subject')
    load(file)
    srate = 2000;
    TimeWin = 4;
    
    HitidxSUHAAS = Hit * srate; 
    HitidxSUHAAS = int64(HitidxSUHAAS);
     
    if sum(size(Hit)) >= 2
        for i = 1:length(HitidxSUHAAS)
            if (HitidxSUHAAS(i)+(srate*TimeWin/2))<(length(lfp)) && (HitidxSUHAAS(i)-(srate*TimeWin/2))>(0)                       
                ACC.Hit_lfp{i} = lfp(4,[HitidxSUHAAS(1,i)-(srate*TimeWin/2):HitidxSUHAAS(1,i)+(srate*TimeWin/2)]);
            end
        end
    end 
    
        for event = 1:length(ACC.Hit_lfp)
            [Scell,f,Serr] = mtspectrumc(ACC.Hit_lfp{1,event},params)
            PowCell{event} = Scell;
        end
        
        
        % Create matrices of all events
        Pow = cell2mat(PowCell) % the colums are the events, you can verify by looking back into 'PowVals'
            % Sanity Check  
             if Pow(:,2) == PowCell{1,2}
                 sprintf('\n\nseems like conversion to a matrix worked as intended')
             end
        % take the mean of output 
        PowMeanSUHAAS = mean(Pow,2);
GrandPowSUHAAS(:,subsi) = PowMeanSUHAAS
end

% calculate error (code from H.H.)
GrandPowStdSUHAAS = std(GrandPowSUHAAS,0,2);
GrandPowErrSUHAAS = GrandPowStdSUHAAS/sqrt(size(GrandPowSUHAAS,2));

% Take Mean 
GrandPowMeanSUHAAS = mean(GrandPowSUHAAS,2)



%% Now we can compare 
% the orginal all subjects grand matrix 
if GrandPowSUHAAS == GrandPowHENRY'
    sprintf('\n\nThe grand all-subject matrices are the same')
end
if GrandPowMeanSUHAAS == GrandPowMeanHENRY'
    sprintf('\n\nPower averaged across trials, then subjects is the same')
end
if GrandPowErrSUHAAS == GrandPowErrHENRY'
    sprintf('\n\nStandard error calculated across subjects is the same')
end

henry = figure;
shadedErrorBar(f,GrandPowMeanHENRY,GrandPowErrHENRY,'r'); 
title('Henry')
xlim([0 90])
suhaas = figure;
shadedErrorBar(f,GrandPowMeanSUHAAS,GrandPowErrSUHAAS,'g')
title('Suhaas')
xlim([0 90])


%% Power Cross Subs Hits vs False Alarms (save the output of the above, change the variable name, do it again, come back here to plot)
clear;



subplot 121;
shadedErrorBar(f,GrandPowMeanHENRY,GrandPowErrHENRY,'g', .4);
legend({'Hits'})
xlim([0 40])
hold on 
shadedErrorBar(f,GrandPowMeanHENRY_FA,GrandPowErrHENRY_FA,'r',.4); 
legend({'False Alarms'})
title('Henry')
xlim([0 90])

subplot 122
shadedErrorBar(f,GrandPowMean',GrandPowErr','g', .4); 
legend({'False Alarms'})
hold on 
shadedErrorBar(f,GrandPowMeanSUHAAS',GrandPowErrSUHAAS','r', .4)
legend({'Hits'})
title('Suhaas')
xlim([0 90])


