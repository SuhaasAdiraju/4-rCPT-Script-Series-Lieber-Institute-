function BehavioralAvgPlot_NTsensor(varargin)
clear; clc
%% Plotting AVG across event-type, with behavioral markers plotted
% - Written 06.25.22 ~ Suhaas Adiraju



%% Load in desired data
waitfor(msgbox('A file selector will pop-up, then select the file containing event-averaged data set'))
[AVGs_dataname, AVGs_datapath] = uigetfile('Select the file of event-averaged data you would like to visualize')
cd(AVGs_datapath);
load(AVGs_dataname);

waitfor(msgbox('A file selector will pop-up, then select the file containing the corresponding event-timestamps file'))
[Timestamp_dataname, Timestamp_datapath] = uigetfile('Select the event-average corresponding timestamps file you would like to visualize')
cd(Timestamp_datapath);
load(Timestamp_dataname);


whos


event_name = inputdlg('Looking at the Workspace to the right, enter the event-type timestamps you are interested in')
if exist(event_name{1},"var") == 1
    event_data = eval(event_name{1})
end




%% Compute timestamps and behavioral markers 

hitlength = linspace(-(length(AllEventAvg)/(TimeWin*2)),(length(AllEventAvg)/(TimeWin*2)),length(AllEventAvg));

% Calculate Avg stimulus presentation in context of Hit event
for z = 1:length(event_data)
Eventres= event_data * 10;
Stimres = Stimulus * 10;
ITIres = Start_ITI * 10;
Eventstamp = Eventres(z);

StimStampIDX = (Stimres) < Eventstamp;
StimStampIDX = length(StimStampIDX(StimStampIDX == 1));
StimStamp = Stimres(1,StimStampIDX);

ITIStampIDX = (ITIres) < Eventstamp;
ITIStampIDX = length(ITIStampIDX(ITIStampIDX == 1));
ITIpreStamp = ITIres(1,ITIStampIDX);

ITINextIDX = (ITIres)> Eventstamp;
ITINextIDXtotal = length(ITINextIDX(ITINextIDX == 1));
if ITINextIDX == ITINextIDXtotal 
    ITIpostStamp = length(ITINextIDX) - ITINextIDXtotal;
else 
    ITIpostStamp = length(ITINextIDX) - ITINextIDXtotal + 1;
end
ITIpostStamp = ITIres(1,ITIpostStamp);


ResponseLatencyStims(z) = ((Eventstamp-StimStamp));
ResponseLatencyITIs(z) = ((Eventstamp - ITIpreStamp));
ResponseLatencyITIPost(z) = ((Eventstamp - ITIpostStamp));
LatencybySecondsStim = ResponseLatencyStims./10;
LatencybySecondsITIPre = ResponseLatencyITIs./10;
LatencybySecondsITIPost = ResponseLatencyITIPost./10;


AvgStimPres = mean(LatencybySecondsStim);
AvgITIpre = mean(LatencybySecondsITIPre);
AvgITIpost = mean(LatencybySecondsITIPost);
end

%% Compute standard error for the mean traces
% Normalized 
StdErr_Normalized = std(AllEventArray_Normalized,0,1)/sqrt(size(AllEventArray_Normalized,1));

% Zscored
AllEventArray_Z = zscore(AllEventArray);
StdErr_Z = std(AllEventArray_Z,0,1)/sqrt(size(AllEventArray_Z,1));

%% PLOT NORMALIZED
if startsWith(event_name{1},'Hit') == 1
    Propps.Color = [0.4660 0.8740 0.1880];
else
    Propps.Color = [0.7350 0.0780 0.1840];   
end

EventLine.Color = [0.8500 0.3250 0.0980];

%clf; close all

    annotatedfig = figure;
    Propps.LineWidth = 3;
    shadedErrorBar(hitlength,AllEventAvg_Normalized,StdErr_Normalized,{'Color',Propps.Color,'LineWidth',Propps.LineWidth}',.7); hold on %
    %plot(hitlength, AllEventAvg,'k', 'LineWidth',3); hold on
    %yvals = get(gca,'YTick');
    plot([0,0],[.85 1.2], "LineStyle","--", "Color",[0.8500 0.3250 0.0980], 'LineWidth',4);
    plot([0-AvgITIpre 0-AvgITIpre],[.85 1.2], "LineStyle","--", "Color",'b', 'LineWidth',4);
    plot([0-AvgStimPres 0-AvgStimPres],[.85 1.2], "LineStyle","--", "Color",[0.3010 0.7450 0.9330]	, 'LineWidth',4);
    plot([0-AvgITIpost 0-AvgITIpost],[.85 1.2], "LineStyle","--", "Color",[0.9890 0.9940 0.1000], 'LineWidth',4);          
    %rectangle('Position',[1.2 yvals(1) 2.1 yvals(end)],'LineWidth',2,'EdgeColor','c')
    legend({'SEM','','','Avg Fluorescent Trace','Behavioral Response','Avg Start of ITI','Avg Stimulus Presentation','Avg Start of next ITI'})
    title (sprintf('%s Avg Response Window (%d s)',event_name{1}, TimeWin))
    xlim([-(TimeWin) (TimeWin)]);
    ylabel('dF/F')
    xlabel('Time (s)')
    ylim([.85 1.2]);

    fig1 = figure;
    plot(hitlength,AllEventArray_Normalized,'LineWidth',.2,'Color',[.6,0,0,0.2]); hold on
    plot(hitlength, AllEventAvg_Normalized,Propps);
    yvals = get(gca,'YTick');
    plot([0,0],[yvals(1), yvals(end)], "LineStyle","--", 'LineWidth',3, 'Color',[0.8500 0.3250 0.0980]);
    plot([0-AvgITIpre 0-AvgITIpre],[yvals(1), yvals(end)], "LineStyle","--", "Color",'b', 'LineWidth',4);
    plot([0-AvgStimPres 0-AvgStimPres],[yvals(1), yvals(end)], "LineStyle","--", "Color",[0.3010 0.7450 0.9330]	, 'LineWidth',4);
    plot([0-AvgITIpost 0-AvgITIpost],[yvals(1), yvals(end)], "LineStyle","--", "Color",[0.9890 0.9940 0.1000], 'LineWidth',4);
    %legend({'Avg Fluorescent Trace','Behavioral Response','Avg Start of ITI','Avg Stimulus Presentation','Avg Start of next ITI'})
    set(gcf,'position',[800,200,850,700])
    title (sprintf('%s Avg Response Window (%d s)',event_name{1}, TimeWin))
    xlim([-(TimeWin) (TimeWin)])
    ylabel('dF/F')
    xlabel('Time (s)')
    ylim([yvals(1) yvals(end)]); hold off
    %ylim([-150 150])




%% PLOT ZSCORED

 ZscoredFig = figure;
    Propps.LineWidth = 3;
    shadedErrorBar(hitlength,AllEventAvg_Zscored,StdErr_Z,{'Color',Propps.Color,'LineWidth',Propps.LineWidth}',.7); hold on %
    %plot(hitlength, AllEventAvg,'k', 'LineWidth',3); hold on
    yvals = get(gca,'YTick');
    plot([0,0],[yvals(1) yvals(end)], "LineStyle","--", "Color",[0.8500 0.3250 0.0980], 'LineWidth',4);
    plot([0-AvgITIpre 0-AvgITIpre],[yvals(1) yvals(end)], "LineStyle","--", "Color",'b', 'LineWidth',4);
    plot([0-AvgStimPres 0-AvgStimPres],[yvals(1) yvals(end)], "LineStyle","--", "Color",[0.3010 0.7450 0.9330]	, 'LineWidth',4);
    plot([0-AvgITIpost 0-AvgITIpost],[yvals(1) yvals(end)], "LineStyle","--", "Color",[0.9890 0.9940 0.1000], 'LineWidth',4);          
    %rectangle('Position',[1.2 yvals(1) 2.1 yvals(end)],'LineWidth',2,'EdgeColor','c')
    legend({'SEM','','','Avg Fluorescent Trace','Behavioral Response','Avg Start of ITI','Avg Stimulus Presentation','Avg Start of next ITI'})
    title (sprintf('%s Avg Response Window (%d s)',event_name{1}, TimeWin))
    xlim([-(TimeWin) (TimeWin)]);
    ylabel('dF/F')
    xlabel('Time (s)')
    %ylim([.85 1.2]);



%% Naming and Saving 



% auto save place
%{
Timestamp_dataname = erase(Timestamp_dataname,'.mat');
Timestamp_datapath = append(Timestamp_datapath,['AVGs'])
Timestamp_datapath = append(Timestamp_datapath,'\',event_name{1})
cd(Timestamp_datapath)
%}

% manual saveplace 
saveplaceprompt = (sprintf('Where would you like to save the event-average plot created?'))
saveplace = uigetdir('',saveplaceprompt);
cd(saveplace)

figtitlePrep = (sprintf('_%ds',TimeWin));
AVGs_dataname = erase(AVGs_dataname,'.mat')
figtitle = append(AVGs_dataname,figtitlePrep);

saveas(annotatedfig,figtitle,'fig');
saveas(annotatedfig,figtitle,'tiff');
figtitle = append(figtitle,'_alltraces');
saveas(fig1,figtitle,'tiff');

figtitle = erase(figtitle,'AVG')
saveas(fig1,figtitle,'fig')
saveas(fig1,figtitle,'tiff')

figtitle = erase(figtitle,'alltraces');
figtitle = append(figtitle,'zscore')
saveas(ZscoredFig,figtitle,'fig')
saveas(ZscoredFig,figtitle,'tiff')


% Resave structure with behavioral event average data
cd(AVGs_datapath);

updatedStruc.AllEventArray = AllEventArray;
updatedStruc.AllEventAvg = AllEventAvg;
updatedStruc.AllEventArray_Normalized = AllEventArray_Normalized;
updatedStruc.AllEventAvg_Normalized = AllEventAvg_Normalized;
updatedStruc.AllEventAvg_Zscored = AllEventAvg_Zscored;
updatedStruc.AvgITIpre = AvgITIpre;
updatedStruc.AvgITIpost = AvgITIpost;
updatedStruc.AvgStimPres = AvgStimPres;
updatedStruc.TimeWin = TimeWin;
updatedStruc.srate = srate;


save(AVGs_dataname,'-struct','updatedStruc');


%% Event x Transients plotting full trace 
%{
% create a vector of length (Transients)
TransientsSamples = linspace(0,length(Transients)/srate,length(Transients));
    
% Plot untrended transients w behavioral events
fulltracepanel= figure;
subplot 211
plot(TransientsSamples,Transients); hold on
yvals = get(gca,'YTick');
xvals = get(gca,'Xtick');
%plot(TransientsSamples,TransientsFit,'LineWidth',2,'Color','r')
plot(False_Alarm,yvals(end)-(yvals(end)/10),'ro','LineWidth',3)
plot(Hit,yvals(end),'go','LineWidth',3)
xlim([0 xvals(end)])
ylim([yvals(1) yvals(end)])
title('Raw Full session')

% Plot detrended transients w behavioral events
subplot 212
plot(TransientsSamples,detrendTransients); hold on
yvals = get(gca,'YTick');
xvals = get(gca,'Xtick');
plot(Hit,yvals(end),'go','LineWidth',3)
plot(False_Alarm,yvals(end)-(yvals(end)/10),'ro','LineWidth',3)
xlim([0 xvals(end)])
ylim([yvals(1) yvals(end)])
title('Detrended Full session')
sgtitle('FULL SESSION TRACES')


cd(saveplace);

figtitle = erase(figtitle,'Avg Response Window (10s)_alltraces')
figtitle = erase(figtitle,'alltraces');
figtitle = append(figtitle,'FulltracePanel')
saveas(fulltracepanel,figtitle,'tiff');
saveas(fulltracepanel,figtitle,'fig');



avgspanel= figure;
subplot 211
plot(hitlength,AllEventArray)
ylim([-50 50])
xlim([-TimeWin TimeWin])
title('All Sliced Events')
subplot 212
shadedErrorBar(hitlength,AllEventAvg,StdErr,{'Color',Propps.Color,'LineWidth',Propps.LineWidth-2}',.7); hold on %
ylim([-50 50])
xlim([-TimeWin TimeWin])
title('Avg of Sliced Events')

cd(Timestamp_datapath)
figtitle = erase(figtitle,' Avg ')
figtitle = erase(figtitle,'Response Window')
figtitle = erase(figtitle,'(10 s)_alltraces')
figtitle = erase(figtitle,'FullTracePanel')
figtitle = append(figtitle,'AllTrace_Average_Comaparison_Panel')
saveas(avgspanel,figtitle,'tiff');
saveas(avgspanel,figtitle,'fig');
%}
end
