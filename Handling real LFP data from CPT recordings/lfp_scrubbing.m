function [decision_matrix, indices] = lfp_scrubbing(sample, Fs)

indices = {};

for i = 1:size(sample,1)

    sample_temp = sample(i,:);

    % Look for clipping - search for repeating values
    % Gotta be a more elegant way than this, but this is best I could think
    % of right now

    count = 1;

    for j = 2:length(sample_temp)
        if sample_temp(1,j) == sample_temp(1,j-1)
            repeat_idx(1,count) = j;
            count = count+1;
        end
    end

    if exist('repeat_idx') == 1
        repeat_diff = diff(repeat_idx);
        repeats = find(repeat_diff == 1);
        diff_idx = diff(repeats);
        all_repeats = find(diff_idx == 1);
        if length(all_repeats) > Fs/10
           decision_matrix(1,i) = 1;
        else
           decision_matrix(1,i) = 0;
        end
    else 
        decision_matrix(1,i) = 0;
        repeats = 0
    end

    indices{1,i} = repeats;

    % Now, de-trend the sample

    sample_temp = detrend_LFP(sample_temp');
    sample_temp = sample_temp';

    % Let's look for 60 cycle noise artifacts

    time = linspace(0,length(sample_temp)/Fs,length(sample_temp));
    dt = time(2)-time(1);
    T = dt*length(sample_temp);
    
    % Fast Fourier transform

    xf = fft(sample_temp-mean(sample_temp));
    Sxx = 2*dt^2/T*(xf.*conj(xf));
    Sxx = Sxx(1:length(sample_temp)/2+1);

    mean_theta = mean(Sxx(1,2:12));
    mean_noise = mean(Sxx(1,55:65));

    if mean_noise > mean_theta*0.25
        decision_matrix(2,i) = 1;
    else
        decision_matrix(2,i) = 0;
    end

    indices{2,i} = Sxx(1,1:100);

    % Lastly, let's just look for abnormally large spikes in amplitude

    sample_z = zscore(sample_temp);
    amp_idx = find(sample_z > 4.5 | sample_z < -4.5);

    if length(amp_idx) > 1
        decision_matrix(3,i) = 1;
    else
        decision_matrix(3,i) = 0;
    end

    indices{3,i} = amp_idx;

end

    










end