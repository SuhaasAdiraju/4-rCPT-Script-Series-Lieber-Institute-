function [mu, sigma, MI, z, p] = shuffle_MI(signal_data, phase_bins, plot)

%   This function creates a bootstrapped distribution of shuffled
%   modulation index scores, and calculates a z-score and corresponding
%   p-value for the observed modulation index value against the
%   bootstrapped distribution of shuffled modulation index values.

% Input:   
%   signal_data:            Structure with fields timestamps, phase_EEG, amplitude_EEG,
%                           phase_bandpass, amplitude_bandpass, and srate
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
%   phase_extraction:       Phase extraction method - binary, takes values of 0 or 1
%                           If phase_extraction = 0, Hilbert transformation
%                           is used
%                           If phase_extraction = 1, phase interpolation is
%                           used
%                           Phase interpolation accounts for asymmetries
%                           within an oscillatory cycle, but should only be used
%                           when the phase highpass is < 60 Hz
%   phase_bins:             Number of phase bins
%   plot:                   1 if plot, 0 if no plot
%   

% Output:
%   mu:                     Mean modulation index value from bootstrapped
%                           distribution
%   sigma:                  Standard deviation of bootstrapped distribution
%   MI:                     Observed modulation index value
%   z:                      Z-score for observed modulation index value,
%                           assuming the null hypothesis that the observed
%                           value originated from the bootstrapped
%                           distribution
%   p:                      Probability that the observed modulation index
%                           value originated from the bootstrapped distribution

%%

if signal_data.phase_extraction ~= 1 & signal_data.phase_extraction ~= 0
    error ('Phase_extraction value must be either a 0 or 1');
end

% Calculate observed modulation index value
[data] = makedatafile(signal_data);

[M] = modindex(data,'n',phase_bins);

MI = M.MI;

permnum = 100;

% Randomly shuffle signal values and re-calculate modulation index value
% Do this 1000 times (if this is taking too long, change "permnum" variable
% above)
for k = 1:permnum
    shuffle_index_phase = randperm(length(signal_data.phase_EEG));
    shuffled_phase = signal_data.phase_EEG(shuffle_index_phase);
    shuffle_index_amplitude = randperm(length(signal_data.amplitude_EEG));
    shuffled_amplitude = signal_data.amplitude_EEG(shuffle_index_amplitude);
    signal_data_shuffled.phase_EEG = shuffled_phase;
    signal_data_shuffled.amplitude_EEG = shuffled_amplitude;
    signal_data_shuffled.timestamps = signal_data.timestamps;
    signal_data_shuffled.phase_bandpass = signal_data.phase_bandpass;
    signal_data_shuffled.amplitude_bandpass = signal_data.amplitude_bandpass;
    signal_data_shuffled.srate = signal_data.srate;
    signal_data_shuffled.phase_extraction = signal_data.phase_extraction;
    
    [data_shuffled] = makedatafile(signal_data_shuffled);
    
    M_shuffled = modindex(data_shuffled,'n',phase_bins);
    
    MI_shuffled(k) = M_shuffled.MI;
end

% Calculate mean and standard deviation of bootstrapped distribution
% Perform z-test for observed value versus mean of bootstrapped
% distribution
mu = mean(MI_shuffled);
sigma = std(MI_shuffled);
ZMI_Shuffled = zscore(MI_shuffled);
z = bsxfun(@rdivide, bsxfun(@minus, M.MI, mu), sigma);
    % (MI value of the observed two signals (phase&amplitude) minus
    % the mean of the boostrapped shuffled MI distribution)
        % Divided by 
    % Standard Deviation of the boostrapped shuffled distribution of MI
    % values 

    % Equals, Z-score of the observed MI assuming it comes from the
    % shuffled distribution (aka compared to the shuffled distribution);
    % z-score is basically standard deviation

[h p] = ztest(M.MI,mu,sigma);

if plot == 1
figureshuffle = figure()
hist(ZMI_Shuffled,phase_bins)
hold on
yL = get(gca,'YLim');
line([z z],yL,'Color','r');
legend('Distribution of std. dev. of shuffled MI values','Z-score of observed-signals'' MI value compared to shuffled distribution')
xlabel('Z-Score')
ylabel('f(x)')
sgtitle('Distribution and Significance Comparison of MIval against a Boostrapped-Shuffled MI distribution')
end
if plot == 1
uiwait(figureshuffle)
end
end

