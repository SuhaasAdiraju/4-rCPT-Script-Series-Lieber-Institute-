% Load your data in by double clicking it in the file selector on the left

% Plot n stuff
Eventlength = linspace(-(length(AllEventAvg)/(srate*(TimeWin/4))),(length(AllEventAvg)/(srate*(TimeWin/4))),length(AllEventAvg));
for x = 1:length(Events_Accepted)
    figure; 
    plot(Eventlength,Events_Accepted{x},'LineWidth',.8,'Color','k')
    ylim([-100 100])
    sgtitle ('ACC Raw LFP Surrounding Hit Event')
    ylabel('Voltage (mV)')
    xlabel('Time (s)')
end
ExampleMatrx = cell2mat(Events_Accepted(1,12))
csvwrite('EXAMPLE RAW LFP DATA ACC HIT SURROUNDING', ExampleMatrx)