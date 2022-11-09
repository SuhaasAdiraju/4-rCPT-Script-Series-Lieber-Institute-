%% Calculating Response latency

%% For Hits 
clc; clear;
cd('Z:\Circuits projects (CPT)\CPT Recording Data\Ephys Characterization Paper Cohort\PROCESSED DATA\RAW STRUCTURES\S3Good')
[strucname] = uigetfile('','Load in cleaned session structure')
load(strucname)
subs = 6;
for subsi = 1:subs
    clear ResponseLatency z Hit False_Alarm EventStamp StimStamp Stimulus
    [mouseraw] = uigetfile('','Load Raw file N times for each subject')
    load(mouseraw)
    for z = 1:length(cell2mat(AllSubsAcceptedIdx_amend(1,subsi)))
        if subsi == 5
            if z <= 13 
            StimulusGrandtoTake = StimulusGrand(1,1:441)   
            AcceptTrial = (AllSubsAcceptedIdx_amend{1,subsi}(z))
            EventStamp = HitGrand(AcceptTrial)
            StimStamp = StimulusGrandtoTake < EventStamp
            StimStamp = StimulusGrandtoTake(StimStamp == 1)
            StimStamp = StimulusGrandtoTake(length(StimStamp))
            ResponseLatency(z) = EventStamp - StimStamp
            elseif z >= 14 && z <= 24
            StimulusGrandtoTake = StimulusGrand(1,442:884)   
            AcceptTrial = (AllSubsAcceptedIdx_amend{1,subsi}(z))
            EventStamp = HitGrand(AcceptTrial)
            StimStamp = StimulusGrandtoTake < EventStamp
            StimStamp = StimulusGrandtoTake(StimStamp == 1)
            StimStamp = StimulusGrandtoTake(length(StimStamp))
            ResponseLatency(z) = EventStamp - StimStamp  
            elseif z >= 25 && z <= 33
            StimulusGrandtoTake = StimulusGrand(1,885:1331)   
            AcceptTrial = (AllSubsAcceptedIdx_amend{1,subsi}(z))
            EventStamp = HitGrand(AcceptTrial)
            StimStamp = StimulusGrandtoTake < EventStamp
            StimStamp = StimulusGrandtoTake(StimStamp == 1)
            StimStamp = StimulusGrandtoTake(length(StimStamp))
            ResponseLatency(z) = EventStamp - StimStamp  
            elseif z >= 34 && z <= 75
            StimulusGrandtoTake = StimulusGrand(1,1332:1764)   
            AcceptTrial = (AllSubsAcceptedIdx_amend{1,subsi}(z))
            EventStamp = HitGrand(AcceptTrial)
            StimStamp = StimulusGrandtoTake < EventStamp
            StimStamp = StimulusGrandtoTake(StimStamp == 1)
            StimStamp = StimulusGrandtoTake(length(StimStamp))
            ResponseLatency(z) = EventStamp - StimStamp 
            end
        else
        AcceptTrial = (AllSubsAcceptedIdx_amend{1,subsi}(z))
        EventStamp = Hit(AcceptTrial)
        StimStamp = Stimulus < EventStamp
        StimStamp = Stimulus(StimStamp == 1)
        StimStamp = Stimulus(length(StimStamp))
        ResponseLatency(z) = EventStamp - StimStamp    
        end

    end
    CrossMiceHitLatencies{subsi} = ResponseLatency
    
end

% Calculate Avg
for subsi = 1:subs
    CrossMiceAvgLatency(subsi) = mean(cell2mat(CrossMiceHitLatencies(subsi)))
    GrandAvgLatency = mean(CrossMiceAvgLatency(1,2:end))
end

mean(CrossMiceAvgLatency(1,2:end))


%% For False Alarms 


%% for 4471 being multiple
%{
    HitGrand = [HitGrand,Hit];
    False_AlarmGrand = [False_AlarmGrand,False_Alarm];
    StimulusGrand = [StimulusGrand,Stimulus]
%}