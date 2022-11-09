
[filename, pathname] = uigetfile('Please select the file to load and clean')
cd(pathname)
Struc = load(filename);

%% Whole session + Event Marker Plotting 
mins = 10;
shifti = 1*60;
timevec = linspace(0,(length(Struc.lfp)/2000),length(Struc.lfp));
close all
% plot out the Struc.lfp full session with visual representation of Struc.Hits and FAs
figure;
subplot 411
    plot(timevec,Struc.lfp(1,:)); hold on
    ymax = get(gca,'ytick')
    ylim([ymax(1) ymax(end)])
    xlim([shifti (shifti+mins*60)])
    plot(Struc.Hit,ymax(end)-50,'go','LineWidth',4)    
    plot(Struc.False_Alarm,ymax(end)-78,'ro','LineWidth',4)
    title('Reference')

subplot 412
    plot(timevec,Struc.lfp(2,:)); hold on
    ylim([ymax(1) ymax(end)])
    xlim([shifti (shifti+mins*60)])
    plot(Struc.Hit,ymax(end)-50,'go','LineWidth',4)    
    plot(Struc.False_Alarm,ymax(end)-78,'ro','LineWidth',4)
    title('Ground')


subplot 413
    plot(timevec,Struc.lfp(3,:)); hold on
    ylim([ymax(1) ymax(end)])
    xlim([shifti (shifti+mins*60)])
    plot(Struc.Hit,ymax(end)-50,'go','LineWidth',4)    
    plot(Struc.False_Alarm,ymax(end)-78,'ro','LineWidth',4)
    title('LC')
    
subplot 414
    plot(timevec,Struc.lfp(4,:)); hold on
    ylim([ymax(1) ymax(end)])
    xlim([shifti (shifti+mins*60)])
    plot(Struc.Hit,ymax(end)-50,'go','LineWidth',4)    
    plot(Struc.False_Alarm,ymax(end)-78,'ro','LineWidth',4)
    title('ACC')


%% Just ACC 
% figure;
%     plot(timevec(1:(mins*60*2000)),Struc.lfp(3,1:(mins*60*2000)));hold on
%     ylim([ymax(1) ymax(end)])
%     xlim([shifti (shifti+mins*60)])
%     plot(Struc.Hit,ymax(end)-40,'go','LineWidth',2)    
%     plot(Struc.False_Alarm,ymax(end)-70,'ro','LineWidth',2)
