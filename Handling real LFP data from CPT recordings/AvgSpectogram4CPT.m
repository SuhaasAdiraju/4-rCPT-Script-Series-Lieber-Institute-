function AvgSpectogram4CPT
%% Spectrogram4CPT 
% a quick function for plotting spectrogram plots using the Chronux
% function, and built-in capability for averaging across trials

  
%% Chronux across trials
%clearvars -except stage
SubsNum = inputdlg('How many subjects would you like to compute this spectrogram across?')
SubsNum = str2num(cell2mat(SubsNum));


% make the matrix of all the trials and subjects you wanna include
uiwait(msgbox(sprintf('A window selector will pop-up %d times, each time select the data-set you would like to perform, time-retained spectral analysis averaged across trials',SubsNum)));

for z = 1:(SubsNum)
                clearvars -except z EventsMatx SubsNum 
                % define then load data 
                [struc_name, struc_loc] = uigetfile('Select the data-set')
                cd (struc_loc);
                load(struc_name);
                

                % make a matrix of events and format correctly 
                EventsMatx{z} = cell2mat(Events_Accepted_lfp') 

                if z == SubsNum
                    GrandMatx = cell2mat(EventsMatx')
                end
end
                eventseconds = length(Eventlength)/srate;


againAns = 'Yes';                
% set params and plot 
while strcmp(againAns,'Yes') == 1 
            clf; close all; clear Ylength
            figgie = figure;
                params.tapers = [5 7];
                params.Fs = 2000;
                waitfor(msgbox(sprintf('In the next box indicate what frequency range you want to look at')));
                freqlims = inputdlg({'Lower-freq. bound','Upper-freq. bound'})
                params.fpass = [str2num(freqlims{1,1}) str2num(freqlims{2,1})];
                params.trialave = 1;
                waitfor(msgbox(sprintf('An important parameter for computing a spectrogram is the window size and step size of the moving window. \n\n Here, your data set is %d seconds long. The next prompt will ask you for window size and step size inputs.\n\nThe dimensions of your sliding window will impact temporal and spectral resolution in a ''tradeoff'' manner,\n\ni.e. larger window will = less available steps, less temporal resolution, but greater spectral resolution\n\nAlternatively, smaller window = more steps available, higher temporal resolution, but smaller window for spectral components to be assessed in --> more spectral leakage/distortion.\n\nThis can be attenuated with having *more overlap* among windows (decreasing step size while maintaining window size), yielding a smoother time-freq. map, but again it is a trade-off and you cannot makeup fully for the effects of a small spectral assessment window\n\n\nA good default window and step size is window: 0.3, step: .05, you can start from there and adapt based-on your data',eventseconds)))
                winparams = inputdlg({'Window size? (in seconds)','Step size? (in seconds)'})        
                movingwin = [str2num(winparams{1,1}) str2num(winparams{2,1})]; % window size is 1000 samples, and step size is 100 samples
                [S,t,f] = mtspecgramc(GrandMatx',movingwin,params)
                plot_matrix(S,t,f); hold on 
                Xaxis = get(gca,'XTick');
                Xaxis = median(Xaxis);
                Ylength = get(gca,'Ytick');
                Ylength = Ylength(end);
                ylim([0 Ylength])
                plot([Xaxis Xaxis],[0 (Ylength+5)],'w', 'LineWidth',3, 'LineStyle','--')
                colorbar
                colormap default
                legend({'Event'},"Box","off","TextColor",'w')
                c1 = get(gca,'Clim')
                %set(gca,'Clim',[-2 5])
                xlabel('Time (seconds)')
                %get(gca,'XTickLabel',{'-1.5','-1','-.5','0','.5','1','1.5'})
                ylabel('Frequency (Hz)')
                title(sprintf('Averaged Spectrogram Using Chronux mtspecgramc function\n'))
                uiwait(figgie)
                againAns = questdlg('Would you like to compute the spectrogram again with new parameters?')
end

end

