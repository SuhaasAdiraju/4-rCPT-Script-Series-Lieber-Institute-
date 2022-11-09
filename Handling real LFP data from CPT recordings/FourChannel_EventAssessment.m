% Plotting 4 channels a few hit events for LFP artifact assessment
[sessionname, sessionpath] = uigetfile()
cd(sessionpath);
load(sessionname);

Event = 'Hit'
Event = append(Event,'_lfp')

Channel{1} = 'Reference';
Channel{2} = 'Ground';
Channel{3} = 'ACC';
Channel{4} = 'LC';


sessionname = erase(sessionname,'_4s_sliced.mat')
sessionname = append(sessionname,'4Channel_Hit_example')
%% Plot it
cd('Z:\Circuits projects (CPT)\CPT Recording Data\Ephys Characterization Paper Cohort\HitTrialExamplePanels')
for i = 1:8
    clear sessionstyle
    F = figure;
    subplot 411
        ChannelVal = (eval(Channel{1}));
        plot(ChannelVal.(Event){i})
        ylim([-300 300])
    subplot 412
        ChannelVal = (eval(Channel{2}));
        plot(ChannelVal.(Event){i})
        ylim([-300 300])
    subplot 413
        ChannelVal = (eval(Channel{3}));
        plot(ChannelVal.(Event){i})
        ylim([-300 300])
    subplot 414
        ChannelVal = (eval(Channel{4}));
        plot(ChannelVal.(Event){i})
        ylim([-300 300])

sessionstyle = append(sessionname,num2str(i))
saveas(F,sessionstyle,'tif')
saveas(F,sessionstyle,'fig')
end

