%% Plotting dual event-type AVG, with behavioral markers
% - Written 08.03.22 ~ Suhaas Adiraju
%% Load in desired data
%clc; clear;
waitfor(msgbox('A file selector will pop-up, then select the file containing event-averaged data set'))
[AVGs_dataname_HIT, AVGs_datapath_HIT] = uigetfile('Select the file of event-averaged data you would like to visualize')
cd(AVGs_datapath_HIT);
load(AVGs_dataname_HIT);

waitfor(msgbox('A file selector will pop-up, then select the file containing the corresponding event-timestamps file'))
[Timestamp_dataname_HIT, Timestamp_datapath_HIT] = uigetfile('Select the event-average corresponding timestamps file you would like to visualize')
cd(Timestamp_datapath_HIT);
load(Timestamp_dataname_HIT);


whos


event_name_HIT = inputdlg('Looking at the Workspace to the right, enter the event-type timestamps you are interested in')
if exist(event_name_HIT{1},"var") == 1
    event_data_HIT = eval(event_name_HIT{1})
end




%% Compute timestamps and behavioral markers 

hitlength = linspace(-(length(AllEventAvg)/(srate*2)),(length(AllEventAvg)/(srate*2)),length(AllEventAvg));

% Calculate Avg stimulus presentation in context of Hit event
for z = 1:length(event_data_HIT)
Eventres_HIT= event_data_HIT * 10;
Stimres_HIT = Stimulus * 10;
ITIres_HIT = Start_ITI * 10;
Eventstamp_HIT = Eventres_HIT(z);

StimStampIDX_HIT = (Stimres_HIT) < Eventstamp_HIT;
StimStampIDX_HIT = length(StimStampIDX_HIT(StimStampIDX_HIT == 1));
StimStamp_HIT = Stimres_HIT(1,StimStampIDX_HIT);

ITIStampIDX_HIT = (ITIres_HIT) < Eventstamp_HIT;
ITIStampIDX_HIT = length(ITIStampIDX_HIT(ITIStampIDX_HIT == 1));
ITIpreStamp_HIT = ITIres_HIT(1,ITIStampIDX_HIT);

ITINextIDX_HIT = (ITIres_HIT)> Eventstamp_HIT;
ITINextIDXtotal_HIT = length(ITINextIDX_HIT(ITINextIDX_HIT == 1));
if ITINextIDX_HIT == ITINextIDXtotal_HIT 
    ITIpostStamp_HIT = length(ITINextIDX_HIT) - ITINextIDXtotal_HIT;
else 
    ITIpostStamp_HIT = length(ITINextIDX_HIT) - ITINextIDXtotal_HIT + 1;
end
ITIpostStamp_HIT = ITIres_HIT(1,ITIpostStamp_HIT);


ResponseLatencyStims_HIT(z) = ((Eventstamp_HIT-StimStamp_HIT));
ResponseLatencyITIs_HIT(z) = ((Eventstamp_HIT - ITIpreStamp_HIT));
ResponseLatencyITIPost_HIT(z) = ((Eventstamp_HIT - ITIpostStamp_HIT));
LatencybySecondsStim_HIT = ResponseLatencyStims_HIT./10;
LatencybySecondsITIPre_HIT = ResponseLatencyITIs_HIT./10;
LatencybySecondsITIPost_HIT = ResponseLatencyITIPost_HIT./10;


AvgStimPres_HIT = mean(LatencybySecondsStim_HIT);
AvgITIpre_HIT = mean(LatencybySecondsITIPre_HIT);
AvgITIpost_HIT = mean(LatencybySecondsITIPost_HIT);
end

%% Compute standard error for the mean trace
StdErr_HIT = std(AllEventArray,0,1)/sqrt(size(AllEventArray,1));

%% PLOT 
if startsWith(Event_name{1},'Hit') == 1
    Propps_HIT.Color = [0.4660 0.8740 0.1880];
else
    Propps_HIT.Color = [0.7350 0.0780 0.1840];   
end

EventLine_HIT.Color = [0.8500 0.3250 0.0980];

%clf; close all
AllEventAvg_HIT = AllEventAvg;
    annotatedfig = figure;
    Propps_HIT.LineWidth = 3;
    shadedErrorBar(hitlength,AllEventAvg_HIT,StdErr_HIT,{'Color',Propps_HIT.Color,'LineWidth',Propps_HIT.LineWidth}',.7); hold on %
    %plot(hitlength, AllEventAvg,'k', 'LineWidth',3); hold on
    yvals = get(gca,'YTick');
    plot([0,0],[.85 1.2], "LineStyle","--", "Color",[0.8500 0.3250 0.0980], 'LineWidth',4);
    plot([0-AvgITIpre_HIT 0-AvgITIpre_HIT],[.85 1.2], "LineStyle","--", "Color",'b', 'LineWidth',4);
    plot([0-AvgStimPres_HIT 0-AvgStimPres_HIT],[.85 1.2], "LineStyle","--", "Color",[0.3010 0.7450 0.9330]	, 'LineWidth',4);
    plot([0-AvgITIpost_HIT 0-AvgITIpost_HIT],[.85 1.2], "LineStyle","--", "Color",[0.9890 0.9940 0.1000], 'LineWidth',4);            % [yvals(1), yvals(end)]
    set(gcf,'position',[800,200,950,800])
    %rectangle('Position',[1.2 yvals(1) 2.1 yvals(end)],'LineWidth',2,'EdgeColor','c')
    legend({'SEM','','','Avg Fluorescent Trace','Behavioral Response','Avg Start of ITI','Avg Stimulus Presentation','Avg Start of next ITI'})
    title (sprintf('%s Avg Response Window (%d s)',event_name_HIT{1}, TimeWin))
    xlim([-(TimeWin) (TimeWin)])
    ylabel('dF/F')
    xlabel('Time (s)')
    ylim([.85 1.2]); hold off

    fig1 = figure;
    plot(hitlength,AllEventArray_HIT,'LineWidth',.2,'Color',[.6,0,0,0.2]); hold on
    plot(hitlength, AllEventAvg,Propps_HIT);
    yvals = get(gca,'YTick');
    plot([0,0],[yvals(1), yvals(end)], "LineStyle","--", 'LineWidth',3, 'Color',[0.8500 0.3250 0.0980]);
    plot([0-AvgITIpre_HIT 0-AvgITIpre_HIT],[yvals(1), yvals(end)], "LineStyle","--", "Color",'b', 'LineWidth',4);
    plot([0-AvgStimPres_HIT 0-AvgStimPres_HIT],[yvals(1), yvals(end)], "LineStyle","--", "Color",[0.3010 0.7450 0.9330]	, 'LineWidth',4);
    plot([0-AvgITIpost_HIT 0-AvgITIpost_HIT],[yvals(1), yvals(end)], "LineStyle","--", "Color",[0.9890 0.9940 0.1000], 'LineWidth',4);
    %legend({'Avg Fluorescent Trace','Behavioral Response','Avg Start of ITI','Avg Stimulus Presentation','Avg Start of next ITI'})
    set(gcf,'position',[800,200,850,700])
    title (sprintf('%s Avg Response Window (%d s)',event_name_HIT{1}, TimeWin))
    xlim([-(TimeWin) (TimeWin)])
    ylabel('dF/F')
    xlabel('Time (s)')
    ylim([yvals(1) yvals(end)])













clear AllEventArray AllEventAvg

waitfor(msgbox('A file selector will pop-up, then select the file containing event-averaged data set'))
[AVGs_dataname_FA, AVGs_datapath_FA] = uigetfile('Select the file of event-averaged data you would like to visualize')
cd(AVGs_datapath_FA);
load(AVGs_dataname_FA);

waitfor(msgbox('A file selector will pop-up, then select the file containing the corresponding event-timestamps file'))
[Timestamp_dataname_FA, Timestamp_datapath_FA] = uigetfile('Select the event-average corresponding timestamps file you would like to visualize')
cd(Timestamp_datapath_FA);
load(Timestamp_dataname_FA);


whos


event_name_FA = inputdlg('Looking at the Workspace to the right, enter the event-type timestamps you are interested in')
if exist(event_name_FA{1},"var") == 1
    event_data_FA = eval(event_name_FA{1})
end




%% Compute timestamps and behavioral markers 

hitlength = linspace(-(length(AllEventAvg)/(srate*2)),(length(AllEventAvg)/(srate*2)),length(AllEventAvg));

% Calculate Avg stimulus presentation in context of Hit event
for z = 1:length(event_data_FA)
Eventres_FA= event_data_FA * 10;
Stimres_FA = Stimulus * 10;
ITIres_FA = Start_ITI * 10;
Eventstamp_FA = Eventres_FA(z);

StimStampIDX_FA = (Stimres_FA) < Eventstamp_FA;
StimStampIDX_FA = length(StimStampIDX_FA(StimStampIDX_FA == 1));
StimStamp_FA = Stimres_FA(1,StimStampIDX_FA);

ITIStampIDX_FA = (ITIres_FA) < Eventstamp_FA;
ITIStampIDX_FA = length(ITIStampIDX_FA(ITIStampIDX_FA == 1));
ITIpreStamp_FA = ITIres_FA(1,ITIStampIDX_FA);

ITINextIDX_FA = (ITIres_FA)> Eventstamp_FA;
ITINextIDXtotal_FA = length(ITINextIDX_FA(ITINextIDX_FA == 1));
if ITINextIDX_FA == ITINextIDXtotal_FA 
    ITIpostStamp_FA = length(ITINextIDX_FA) - ITINextIDXtotal_FA;
else 
    ITIpostStamp_FA = length(ITINextIDX_FA) - ITINextIDXtotal_FA + 1;
end
ITIpostStamp_FA = ITIres_FA(1,ITIpostStamp_FA);


ResponseLatencyStims_FA(z) = ((Eventstamp_FA-StimStamp_FA));
ResponseLatencyITIs_FA(z) = ((Eventstamp_FA - ITIpreStamp_FA));
ResponseLatencyITIPost_FA(z) = ((Eventstamp_FA - ITIpostStamp_FA));
LatencybySecondsStim_FA = ResponseLatencyStims_FA./10;
LatencybySecondsITIPre_FA = ResponseLatencyITIs_FA./10;
LatencybySecondsITIPost_FA = ResponseLatencyITIPost_FA./10;


AvgStimPres_FA = mean(LatencybySecondsStim_FA);
AvgITIpre_FA = mean(LatencybySecondsITIPre_FA);
AvgITIpost_FA = mean(LatencybySecondsITIPost_FA);
end

%% Compute standard error for the mean trace
StdErr_FA = std(AllEventArray,0,1)/sqrt(size(AllEventArray,1));

%% PLOT 
if startsWith(Event_name{1},'Hit') == 1
    Propps_FA.Color = [0.4660 0.8740 0.1880];
else
    Propps_FA.Color = [0.7350 0.0780 0.1840];   
end

EventLine_FA.Color = [0.8500 0.3250 0.0980];

%clf; close all
AllEventAvg_FA = AllEventAvg;
    annotatedfig = figure;
    Propps_FA.LineWidth = 3;
    shadedErrorBar(hitlength,AllEventAvg_FA,StdErr_FA,{'Color',Propps_FA.Color,'LineWidth',Propps_FA.LineWidth}',.7); hold on %
    %plot(hitlength, AllEventAvg,'k', 'LineWidth',3); hold on
    yvals = get(gca,'YTick');
    plot([0,0],[.85 1.2], "LineStyle","--", "Color",[0.8500 0.3250 0.0980], 'LineWidth',4);
    plot([0-AvgITIpre_FA 0-AvgITIpre_FA],[.85 1.2], "LineStyle","--", "Color",'b', 'LineWidth',4);
    plot([0-AvgStimPres_FA 0-AvgStimPres_FA],[.85 1.2], "LineStyle","--", "Color",[0.3010 0.7450 0.9330]	, 'LineWidth',4);
    plot([0-AvgITIpost_FA 0-AvgITIpost_FA],[.85 1.2], "LineStyle","--", "Color",[0.9890 0.9940 0.1000], 'LineWidth',4);            % [yvals(1), yvals(end)]
    set(gcf,'position',[800,200,950,800])
    %rectangle('Position',[1.2 yvals(1) 2.1 yvals(end)],'LineWidth',2,'EdgeColor','c')
    legend({'SEM','','','Avg Fluorescent Trace','Behavioral Response','Avg Start of ITI','Avg Stimulus Presentation','Avg Start of next ITI'})
    title (sprintf('%s Avg Response Window (%d s)',event_name_FA{1}, TimeWin))
    xlim([-(TimeWin) (TimeWin)])
    ylabel('dF/F')
    xlabel('Time (s)')
    ylim([.85 1.2]); hold off

    fig1 = figure;
    plot(hitlength,AllEventArray_FA,'LineWidth',.2,'Color',[.6,0,0,0.2]); hold on
    plot(hitlength, AllEventAvg,Propps_FA);
    yvals = get(gca,'YTick');
    plot([0,0],[yvals(1), yvals(end)], "LineStyle","--", 'LineWidth',3, 'Color',[0.8500 0.3250 0.0980]);
    plot([0-AvgITIpre_FA 0-AvgITIpre_FA],[yvals(1), yvals(end)], "LineStyle","--", "Color",'b', 'LineWidth',4);
    plot([0-AvgStimPres_FA 0-AvgStimPres_FA],[yvals(1), yvals(end)], "LineStyle","--", "Color",[0.3010 0.7450 0.9330]	, 'LineWidth',4);
    plot([0-AvgITIpost_FA 0-AvgITIpost_FA],[yvals(1), yvals(end)], "LineStyle","--", "Color",[0.9890 0.9940 0.1000], 'LineWidth',4);
    %legend({'Avg Fluorescent Trace','Behavioral Response','Avg Start of ITI','Avg Stimulus Presentation','Avg Start of next ITI'})
    set(gcf,'position',[800,200,850,700])
    title (sprintf('%s Avg Response Window (%d s)',event_name_FA{1}, TimeWin))
    xlim([-(TimeWin) (TimeWin)])
    ylabel('dF/F')
    xlabel('Time (s)')
    ylim([yvals(1) yvals(end)])

%% Plot together
figure;
    Propps_HIT.LineWidth = 3;
    shadedErrorBar(hitlength,AllEventAvg_HIT,StdErr_HIT,{'Color',Propps_HIT.Color,'LineWidth',Propps_HIT.LineWidth}',.7); hold on %
    %plot(hitlength, AllEventAvg,'k', 'LineWidth',3); hold on
    yvals = get(gca,'YTick');
    plot([0-AvgITIpre_HIT 0-AvgITIpre_HIT],[.85 1.2], "LineStyle","--", "Color",'b', 'LineWidth',2);    
    plot([0-AvgStimPres_HIT 0-AvgStimPres_HIT],[.85 1.2], "LineStyle","--", "Color",[0.3010 0.7450 0.9330]	, 'LineWidth',2);    
    plot([0,0],[.85 1.2], "LineStyle","--", "Color",[0.8500 0.3250 0.0980], 'LineWidth',2);
    plot([0-AvgITIpost_HIT 0-AvgITIpost_HIT],[.85 1.2], "LineStyle","--", "Color",'g', 'LineWidth',2);            % [yvals(1), yvals(end)]
    set(gcf,'position',[800,200,950,800])
    %rectangle('Position',[1.2 yvals(1) 2.1 yvals(end)],'LineWidth',2,'EdgeColor','c')
    %legend({'SEM','','','Avg Fluorescent Trace','Behavioral Response','Avg Start of ITI','Avg Stimulus Presentation','Avg Start of next ITI'})
    


    Propps_FA.LineWidth = 3;
    shadedErrorBar(hitlength,AllEventAvg_FA,StdErr_FA,{'Color',Propps_FA.Color,'LineWidth',Propps_FA.LineWidth}',.7);%
    %plot(hitlength, AllEventAvg,'k', 'LineWidth',3); hold on
    yvals = get(gca,'YTick');
    plot([0-AvgStimPres_FA 0-AvgStimPres_FA],[.85 1.2], "LineStyle","--", "Color",[0.3010 0.7450 0.9330]	, 'LineWidth',2);    
    plot([0-AvgITIpre_FA 0-AvgITIpre_FA],[.85 1.2], "LineStyle","--", "Color",'b', 'LineWidth',2);    
    plot([0,0],[.85 1.2], "LineStyle","--", "Color",[0.8500 0.3250 0.0980], 'LineWidth',2);
    plot([0-AvgITIpost_FA 0-AvgITIpost_FA],[.85 1.2], "LineStyle","--", "Color",'r', 'LineWidth',2);            % [yvals(1), yvals(end)]
    set(gcf,'position',[800,200,950,800])
    %rectangle('Position',[1.2 yvals(1) 2.1 yvals(end)],'LineWidth',2,'EdgeColor','c')
    legend({'','','','','Avg Start of ITI','Avg Stimulus Presentation','Behavioral Response','Avg Start of next ITI Post Hit','','','','','','','','Avg Start of next ITI F.Alarm'})
    title (sprintf('%s Avg Response Window (%d s)',event_name_FA{1}, TimeWin))
    xlim([-(TimeWin) (TimeWin)])
    ylabel('dF/F')
    xlabel('Time (s)')
    ylim([.85 1.2]); hold off