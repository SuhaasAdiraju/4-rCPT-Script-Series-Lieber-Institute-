function [heatmap, heatmap_smooth] = cfc_heatmap(signal_data, phase_bins, amplitude_freq_bins, phase_freq_bins, plot)

%   This function creates a co-modulogram of phase-amplitude coupling (MI) values 
%   across frequency for phase and frequency for amplitude pairs.

% Input: 
%   signal_data:            Structure with fields timestamps, phase_EEG, amplitude_EEG,
%                           phase_bandpass, amplitude_bandpass, srate, and
%                           phase_extraction
%
%   timestamps:             1 x n data points array of timestamp values
%                           (microseconds)
%   phase_EEG:              1 x n data points array of continuously sampled data
%                           from signal containing phase information
%   amplitude_EEG:          1 x n data points array of continuously sampled
%                           data from signal containing amplitude information
%   phase_bandpass:         Frequency band for filtering the phase signal
%                           ([fmin fmax])
%   amplitude_bandpass:     Frequency band for filtering the amplitude
%                           signal ([fmin fmax])
%   srate:                  Sampling rate (Hz)
%   phase_extraction:       0 = Hilbert transform, 1 = Phase interpolation,
%                           2 = Morlet wavelet

%   phase_bins:             Number of phase bins
%   amplitude_freq_bins:    Number of co-modulogram bins for amplitude
%                           values
%   phase_freq_bins:        Number of co-modulogram bins for phase values
%   plot:                   1 if plot, 0 if no plot

%Output:
%   heatmap:          Co-modulogram of MI values across phase and amplitude
%                     frequency pairs
%   heatmap_smooth:   Smoothed heatmap (for visualization purposes)

%%

% Create phase and amplitude bandpass filters based on number of desired
% frequency for phase and frequency for amplitude bins
phase_lowpass = (signal_data.phase_bandpass(:,1):phase_freq_bins:(signal_data.phase_bandpass(:,2))-phase_freq_bins);
    % lower limit of phase bandpass parameters, to the
    % higher limit of phase bandpass parameters minus frequency bins % Why minus frequency bins? 
            % in increments of phase_freq_bins... creation of # of bins vector for phase lowpass

phase_highpass = ((signal_data.phase_bandpass(:,1))+phase_freq_bins:phase_freq_bins:signal_data.phase_bandpass(:,2));
    % same thing as above vector-wise, but now we're doing for a highpass
    % it ends up as 2-29 in increments of 1 % Honestly quite confused about
    % this too, why 2-29 for highpass and 1-29 for low???

amplitude_lowpass = (signal_data.amplitude_bandpass(:,1):amplitude_freq_bins:(signal_data.amplitude_bandpass(:,2))-amplitude_freq_bins);
amplitude_highpass = ((signal_data.amplitude_bandpass(:,1))+amplitude_freq_bins:amplitude_freq_bins:signal_data.amplitude_bandpass(:,2));

% Calculate MI value for each desired frequency for phase and frequency for
% amplitude combination
for phasei = 1:length(phase_lowpass)
    for poweri = 1:length(amplitude_lowpass)
        signal_data.phase_bandpass = [phase_lowpass(phasei) phase_highpass(phasei)]; %Almost like a sliding window? high and low in incremental increases
        signal_data.amplitude_bandpass = [amplitude_lowpass(poweri) amplitude_highpass(poweri)]; %Same sliding window idea but now for for amplitude 

        if signal_data.phase_extraction == 0 || signal_data.phase_extraction == 1 %For phase extraction options 0 and 1 (forget what they are)
            [data] = makedatafile(signal_data);
        elseif signal_data.phase_extraction == 2 %For Morelet extraction 
            [data] = makedatafile_morlet(signal_data);
        end
    
    [M] = modindex(data,'n',phase_bins);
    
    heatmap(phasei,poweri) = M.MI;
    
    end
end

% Smooth co-modulogram with Gaussian kernel
% I use a standard deviation of "2", which is the value that I found to be
% the best compromise between integrity of the data and visual appeal
[X,Y] = meshgrid(round(-size(heatmap,1)/2):round(size(heatmap,1)/2), round(-size(heatmap,2)/2):round(size(heatmap,2)/2));
f = exp(-X.^2/(2*2^2)-Y.^2/(2*2^2));
f = f./sum(f(:));

heatmap_smooth = conv2(heatmap,f,'same');

% Plot the co-modulogram
if plot == 1
figurecfc = figure; hold on
pcolor(phase_highpass,amplitude_highpass,heatmap_smooth')
shading interp
colormap(jet)
ylabel('Frequency for Amplitude (Hz)')
xlabel('Frequency for Phase (Hz)')
sgtitle('Co-modulagram of MI values scaled on Phase-freq. and Amplitude-freq.')
end
if plot == 1
uiwait(figurecfc)
end



end

