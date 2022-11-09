function varargout = LFP_ERP
%% Basic analysis with behavior-surrounding LFP recordings 

% This function is for creation of an average signal window across events
% or an ERP, event related potential essentially.


% - Script written by Suhaas S Adiraju, statistics and method from Henry Hallock
 

%% Define and load your previously saved structure (data set) (SKIP IF STRUCTURE IN WORKSPACE ALREADY)
    waitfor(msgbox(sprintf('Welcome to LFP4CPT 3: Avg Response Window creation!\n\nPURPOSE: This script, using the required inputs, will average across corresponding matrix values in the sliced windows of the raw LFP data for a user-defined event type. The result will be an average response window (across events) for the event type\n\nINPUTS:-An existing structure created using LFP4CPT 1 and 2, with timestamps-sliced transients based on event-type')))
    
%% Load-In Existing Structure
    waitfor(msgbox({'A file selector will pop up. Then select the path to your existing cleaned data structure'}))
    [struc_name1, struc_path1] = uigetfile('','Please select the previously saved structure containing event-timestamp based transient slices')
    while struc_name1 == 0     
        waitfor(warndlg('Sorry, you did not correctly select a saved data-structure. Press okay to try again. Or if you would like to stop execution of this script hit the ''stop'' button at the top of MATLAB'))
        [struc_name1, struc_path1] = uigetfile('','Please select the previously saved structure containing event-timestamp based transient slices')
    end
    tic
    cd(struc_path1);
    data1 = load (struc_name1) %load your structure
    toc

    OneorTwo = questdlg('Do you want to compute/compare two sessions (result is two ERPs that can be compared)')
    if strcmp(OneorTwo,'Yes')
        waitfor(msgbox({'A file selector will pop up. Then select the path to the second data structure you wish to compare with'}))
        [struc_name2, struc_path2] = uigetfile('','Please select the previously saved structure containing event-timestamp based transient slices')
        while struc_name2 == 0     
            waitfor(warndlg('Sorry, you did not correctly select a saved data-structure. Press okay to try again. Or if you would like to stop execution of this script hit the ''stop'' button at the top of MATLAB'))
            [struc_name2, struc_path2] = uigetfile('','Please select the previously saved structure containing event-timestamp based transient slices')
        end
        tic
        cd(struc_path2);
        data2 = load (struc_name2) %load your structure
        toc
    end

    %% Create the new array...
    
    % We need a new array which contains, from each event, the
    % timestamp-associated recording values stacked up, so we can later
    % collapse aka average across them
    
    % so we want all the recording values from timestamp 1 in column 1
    
    % (1,1) 
    % should be the first timestamp-associated value from event one, 
    % 
    % then (2,1) should be the first
    % timestamp-associated transient value from event two;
    
    % we will then aim to avg across columns, leaving 1 row of X columns
    % (correspondent to the window) giving us an average 'response' window
    

    % Matrix for data 1
    for eventi = 1:length(data1.Events_Accepted)
        for stampi = 1:length((data1.Events_Accepted{1,1}))
            %if isempty(Event_Type{1,eventi}) == 0
            AllEventArray_data1(eventi,stampi) = data1.Events_Accepted{1,eventi}(1,stampi);
            %end
        end
    end


    if exist('data2', 'var')
        data1matrx = AllEventArray_data1;
        
            % Matrix for data 2
            for eventi = 1:length(data2.Events_Accepted)
                for stampi = 1:length((data2.Events_Accepted{1,1}))
                    %if isempty(Event_Type{1,eventi}) == 0
                    AllEventArray_data2(eventi,stampi) = data2.Events_Accepted{1,eventi}(1,stampi);
                    %end
                end
            end
        
        data2matrx = AllEventArray_data2;
    end


%% Generate ERP

    mean_first = mean(data1matrx,1); % Mean across trials
    std_first = std(data1matrx,1);   % Standard deviation    
    sem_first = std_first/sqrt(size(data1matrx,1));  % Standard error of the mean
    
    % Check for second dataset
    if exist('data2','var')
        mean_second = mean(data2matrx,1);
        std_second = std(data2matrx,1);
        sem_second = std_second/sqrt(size(data2matrx,1));
    end

%% Plot ERPs
Fs1 = data1.srate;
    % Plot first ERP with 95% confidence intervals
    num_seconds1 = length(data1matrx)/Fs1;
    x1 = linspace(-(num_seconds1/2),num_seconds1/2,length(data1matrx));  % Assume LFP data are evenly centered around event onset
    error_bars_1(1,:) = mean_first+2*sem_first;
    error_bars_1(2,:) = mean_first-2*sem_first;
    error_bars1(1,:) = error_bars_1(1,:)-mean_first;
    error_bars1(2,:) = mean_first-error_bars_1(2,:);
    shadedErrorBar(x1,mean_first,error_bars1,'k',1);
    hold on
    xlabel('Time (seconds)');
    ylabel('Amplitude (mV)');
    box off
    set(gca,'TickDir','out');
    ax = gca;
    ax.LineWidth = 2;
    ax.FontSize = 20;
    title('Trial-Averaged ERP from First Dataset')
    yline(0,'r');
    axis tight

% Plot second ERP with 95% confidence intervals
if exist('data2','var')
    Fs2 = data2.srate;
    figure
    num_seconds2 = length(data2matrx)/Fs2;
    x2 = linspace(-(num_seconds2/2),num_seconds2/2,length(data2matrx));  % Assume LFP data are evenly centered around event onset
    error_bars2(1,:) = mean_second+2*sem_second;
    error_bars2(2,:) = mean_second-2*sem_second;
    error_bars2(1,:) = error_bars2(1,:)-mean_second;
    error_bars2(2,:) = mean_second-error_bars2(2,:);
    shadedErrorBar(x2,mean_second,error_bars2,'k',1);
    hold on
    xlabel('Time (seconds)');
    ylabel('Amplitude (mV)');
    box off
    set(gca,'TickDir','out');
    ax = gca;
    ax.LineWidth = 2;
    ax.FontSize = 20;
    title('Trial-Averaged ERP from Second Dataset')
    yline(0,'r');
    axis tight
end

%% Compare two ERPs with confidence intervals

if exist('data2','var')
    mean_btw = mean_first - mean_second;
    sem_btw = sqrt(sem_first.^2 + sem_second.^2);
    error_bars_btw(1,:) = sem_btw-mean_btw;
    error_bars_btw(2,:) = mean_btw-sem_btw;
    figure
    shadedErrorBar(x2,mean_btw,sem_btw,'k',1);
    hold on
    xlabel('Time (seconds)');
    ylabel('Delta Amplitude (mV)');
    box off
    set(gca,'TickDir','out');
    ax = gca;
    ax.LineWidth = 2;
    ax.FontSize = 20;
    title('ERP Difference')
    yline(0,'r');
    axis tight
end

%% Compare two ERPs with bootstrapping

if exist('data2','var')
    ntrials = size(data1matrx,1)+size(data2matrx,1);
    lfp = [data1matrx; data2matrx];   % Merge two LFP datasets
    statD = zeros(3000,1);  % 3,000 permutations
    for k = 1:3000
        i = randsample(ntrials,round(ntrials/2),1); % Randomly choose rows of merged LFP
        lfp0 = lfp(i,:);    
        mean_A = mean(lfp,1);   % Make new ERP from randomly chosen distribution

        i = randsample(ntrials,round(ntrials/2),1); % Do it again
        lfp0 = lfp(i,:);
        mean_B = mean(lfp0,1);

        mean_C = mean_A-mean_B; % Make delta ERP from bootstrapped ERPs
        statD(k) = max(abs(mean_C));    % Calculate max value of delta ERP
    end

    statD_obs = max(abs(mean_btw)); % Calculate max value of real ERP difference
    figure
    histogram(statD);   % Plot bootstrapped values
    hold on
    xline(statD_obs,'r');   % Plot observed value
    xlabel('Maximum ERP Difference');
    ylabel('Frequency');
    title('Distribution of Bootstrapped ERP Differences');
end


      
waitfor(msgbox(sprintf('Okay, this script is finished, moving on to the next option in the pipeline')))

