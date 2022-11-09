%% Description
    % this script assumes you have completed processes from sirenia2mat, and createStructLFP, and thus have
    % structures containing lfp combined with event TStamps for the subject. Now, using the function sliceLFP, 
    % we can cut windows of lfp around event-types. This is an example/template script for using sliceLFP

%--Written by Suhaas S. Adiraju 10/05/2021



        sliceLFP(struc_path, struc_name, srate, TimeWin, saveplace, mousename);
    
end

    
    %% Some previous plotting and playing with the data (unnecessary for analysis)
    %{
        % total time on task
        figure;
        box off;
        plot(cpt_schLength,test31700s.ACC.lfp,'k');
        xlabel('Time(s)')
        ylabel('Voltage')
        title('ACC LFP Full Session')
        
        % surrounding hit example 
        % x axis for plot
        hitlength = linspace(-((length(test31700s.ACC.Hit_lfp{1})/srate{1})),(length(test31700s.ACC.Hit_lfp{1})/srate{1}),length(test31700s.ACC.Hit_lfp{1}));
        figure;
        box off;
        plot(hitlength, test31700s.ACC.Hit_lfp{1}, 'k')
        xlim ([-4 4])
        xlabel('Time(s)')
        ylabel('Voltage')
        title('ACC LFP surrounding Hit event')
        
        % % filter for theta 
        % thetasample = bandpass(ACC.Hit_lfp{1},[5 12], 2000);
        % figure; plot(ACC.Hit_lfp{1}(1:1000))
        % hiberttheta = hilbert(thetasample);
        % hiberttheta = abs(hiberttheta);
        % gammasample = bandpass(ACC.Hit_lfp{1}, [40 80], 2000);    
        % 
        % figure
        % box off;
        % subplot 211;
        % plot(hitlength,thetasample,LineWidth=.2,Color='r'); hold on
        % plot(hitlength,hiberttheta,LineWidth=2, Color='b'); % hitlength, hiberttheta,'b');
        % xlim ([-4 4])
        % xlabel('Time(s)')
        % ylabel('Voltage (mV)')
        % title('Theta Filtered (5-11Hz) Surrounding Hit Event') 
        % subplot 212;
        % plot(hitlength, gammasample, 'g')
        % xlim ([-4 4])
        % xlabel('Time(s)')
        % ylabel('Voltage (mV)')
        % title('Slow-Gamma Filtered (30-80 Hz) Surrounding Hit Event')
        
        % power spec 
        params.tapers = [5 9];
        params.pad = 0;
        params.Fs = 2000; % srate{1}
        params.fpass = [0 200];
        params.err = 0;
        params.trialave = 0;
        
        [S,t] = mtspectrumc(test31700s.ACC.lfp, params);
        [S_hit,t_hit] = mtspectrumc(test31700s.ACC.Hit_lfp{1}, params);
        
        figure;
        box off;
        p1 = plot (t,S);
        p1.LineWidth = 2;
        p1.Color = [0 .4 0]
        xlim ([0 60]);
        xlabel('Frequencies (Hz)');
        title('Power Spectrum analysis of total task time LFP');
        
        figure;
        p2 = plot(t_hit, S_hit);
        p2.LineWidth = 1;
        p2.Color = [0 .4 0]
        xlim ([0 200]);
        xlabel('Frequencies (Hz)');
        title('Power Spectrum analysis of Hit-Centered LFP');
    else 
    end
    
    %}  


