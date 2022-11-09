function [slicedSensorStruc] = sliceNTsensors(struc_path, struc_name, srate, TimeWin, saveplace, mousename);
%% DESCRIPTION
% This function is to grab neuro-transmitter sensor detrendTransients surrounding event timestamps
% This function is written assuming the user has followed NTsensors4CPT 1, and
% has the mouse structure with event timestamps saved as a distinct
% variable, along with the bio-sensor imaging, detrendTransients saved in a structure

% - Written by Suhaas S Adiraju

%% INPUTS 

% struc_path = path to folder of saved structure

% struc_name = name of saved structure

% srate = sampling rate of recording 

% TimeWin = user defined time window size of analysis (ie 4s around each
% hit event)

% saveplace = place you'd like to store your new structure

% mousename = name you would like to save it as

%% OUTPUTS 

% structure of detrendTransients sliced based on event-type timestamps



%% Define Required Inputs 

% Previously saved structure 
sprintf('\n\n Press any key to continue, when you do,\n A file selector will pop up,\n Then select your previously saved structure from NTsensors_4CPT1')
pause
[struc_name, struc_path] = uigetfile

% Sampling rate 
sprintf('\n\n Press any key to continue, when you do,\n A window will pop up,\n Then enter WHAT IS THE SAMPLING RATE OF THE RECORDING in Hz')
pause
sratePrompt = {'What is the sampling rate of the data?'}
srateCell = inputdlg(sratePrompt)
srate = str2num(srateCell{1});

% TimeWindow
sprintf('\n\n Press any key to continue, when you do,\n A window will pop up,\n Then enter WHAT SIZE TIME WINDOWS WOULD YOU LIKE TO ASSESS (s)')
pause
TimeWinPrompt = {'How many seconds surrounding each event would you like to take?'}
TimeWinCell = inputdlg(TimeWinPrompt)
TimeWin = str2num(TimeWinCell{1});
saveplace = {'Z:\Circuits projects (CPT)\CPT Recording Data\EXAMPLE SCRIPTS SAMPLE DATA'}; 

%mousename or name to save resulting structure
mousename = struc_name;


% saveplace; where you want to save resulting structure 
sprintf('\n\n Press any key to continue, when you do,\n A file selector will pop up,\n Then select\nWHERE YOU WOULD LIKE TO SAVE YOUR RESULTING STRUCTURE')
pause 
[saveplace] = uigetdir


%% Loading variables

% cd to location of of the structure
cd(struc_path);

% load file of choice
load (struc_name)

%detrendTransients = Ne_detrendTransients;

%% Detrending our signal

detrendMethod = inputdlg((sprintf('Would you like to use detrend method 1, 2, or 3?\n\n1:No detrend\n\n2: Auto curve fitting\n\n 3: Manual curve fitting')));

if str2num(detrendMethod{1}) == 1
    detrendTransients = Transients;
elseif str2num(detrendMethod{1}) == 2
    % create a vector of length (Transients)
    TransientsSamples = linspace(0,length(Transients),length(Transients));
    
    % set polynomial order
    polyorder = 6;
    
    % run polyfit (x, y, polyorder)
    [p,s,mu] = polyfit(TransientsSamples,Transients(1,:),polyorder);
    
    % compute polynomial
    TransientsFit = polyval(p,TransientsSamples,[],mu);
    
    % subtract the computed polynom trend from the original signal
    detrendTransients = Transients - TransientsFit;

elseif str2num(detrendMethod{1}) == 3

    % CUSTOM DETREND METHOD
    
    figure, plot(Transients); hold on
    n = 0;
    while true
       [x, y, button] = ginput(1);
       if isempty(x) || button(1) ~= 1; break; end
       n = n+1;
       x_n(n) = x(1); % save all points you continue getting
       y_n(n) = y(1);
       hold on
       plot(x(1), y(1), 'o','Color','r')
       drawnow
    end
    hold off
    
    % compute interpolated polynomial
    pTrend = pchip(x_n(1,:),y_n(1,:),(linspace(0,length(Transients),length(Transients))));
    
    %show subtracting with original
    figure('units','normalized','outerposition',[0 0 1 1]); plot(Transients); hold on; plot(pTrend,'LineStyle','-','LineWidth',2,'Color','r')
    
    %all set or try again?
    trendOK = questdlg('Are you satisfied with your custom fit trend?')
    
    if startsWith(trendOK,'Yes') == 1
        %subtract if all set
        detrendTransients = Transients - pTrend;
        figure; subplot 211; plot(Transients); hold on; plot (pTrend,'LineWidth',1,'Color','r'); legend({'Raw Trace','Subtracted trend'}); title('Raw Full Session')
        subplot 212; plot(detrendTransients); title('Detrended Full Session')
    else
        while startsWith(trendOK,'Yes') == 0    
        % retry if not satisfied
            figure, plot(Transients); hold on
            n = 0;
            while true
               [x, y, button] = ginput(1);
               if isempty(x) || button(1) ~= 1; break; end
               n = n+1;
               x_n(n) = x(1); % save all points you continue getting
               y_n(n) = y(1);
               hold on
               plot(x(1), y(1), 'o','Color','r')
               drawnow
            end
            hold off 
            
            % compute interpolated polynomial
            pTrend = pchip(x_n(1,:),y_n(1,:),(linspace(0,length(Transients),length(Transients))));
            
            %show subtracting with original
            figure; plot(Transients); hold on; plot(pTrend,'LineStyle','-','LineWidth',1,'Color','r')
            
            %all set or try again?
            trendOK = questdlg('Are you satisfied with your custom fit trend?')
        end
    end
end

%% Trimming our signal (optional)

% Set detrendTransients on the proper timescale, ("give me a vector of 0-total
% seconds in value, but with a length of the total # of samples in the original matrix")
detrendTransients_TimeVec = linspace(0, ((length(detrendTransients))/srate), (length(detrendTransients)));

% you can see right away that the detrendTransients length is too long, and we
% know the cpt schedule is only 1800s (30min), and we know that our
% 0seconds in the signal is true zero of the cpt task cause we use a TTL
% so we can trim the detrendTransients signal to the length of the cpt
cpt_length = detrendTransients_TimeVec(detrendTransients_TimeVec <= 2700);
assignin("base","cpt_length", cpt_length);
cpt_detrendTransients = Transients(:,1:(length(cpt_length)));

%ylabel('dF/F (change in fluorescent expression)')
%}
%% Equalizing Resolutions

% Now we can grab detrendTransients = the length of the cpt schedule
% detrendTransients = detrendTransients(\);


% First, we must up-sample, to match the scale(resolution) at which we have detrendTransients
% i.e. event timestamps 
FIRBeam_Onidx = FIRBeam_On * srate; 
% FIRBeam_Onidx =int64(FIRBeam_Onidx); % here im converting the class of the IDX values because as a double certain vals were not integers (ie 10385.00000 became 1.0385x10e6)


FIRBeam_Offidx = FIRBeam_Off * srate; 
% FIRBeam_Offidx = int64(FIRBeam_Offidx);

Center_ScTouchidx = Center_ScTouch * srate; 
% Center_ScTouchidx = int64(Center_ScTouchidx);

Start_ITIidx =Start_ITI * srate; 
% Start_ITIidx = int64(Start_ITIidx);

Stimulusidx = Stimulus * srate; 
% Stimulusidx = int64(Stimulusidx);

Hitidx = Hit * srate; 
% Hitidx = int64(Hitidx);

Missidx = Miss * srate; 
% Missidx = int64(Missidx);

Correct_Rejidx =Correct_Rej * srate; 
% Correct_Rejidx = int64(Correct_Rejidx);

False_Alarmidx = False_Alarm * srate; 
% False_Alarmidx = int64(False_Alarmidx);

%% Now we can grab the detrendTransients of each timestamp

% Make it an if... statement, so that when we have empty variables then we can still run the full script and wont be stopped by
%errors
if isempty(FIRBeam_On) == 0
    if sum(size(FIRBeam_On)) >= 2 
        for i = 1:length(FIRBeam_Onidx)
            if (FIRBeam_Onidx(i)+(srate*TimeWin))<(length(detrendTransients)) && (FIRBeam_Onidx(i)-(srate*TimeWin))>(0)  
                CutTransients.FIRBeam_On_detrendTransients{i} = detrendTransients(1,FIRBeam_Onidx(1,i)-(srate*TimeWin):FIRBeam_Onidx(1,i)+(srate*TimeWin));
            end
        end
    end
end

if isempty(FIRBeam_Off) == 0
    if sum(size(FIRBeam_Off)) >= 2 
        for i = 1:(length(FIRBeam_Offidx))
            if (FIRBeam_Offidx(i)+(srate*TimeWin))<(length(detrendTransients)) && (FIRBeam_Offidx(i)-(srate*TimeWin))>(0)        
                CutTransients.FIRBeam_Off_detrendTransients{i} = detrendTransients(1,FIRBeam_Offidx(1,i)-(srate*TimeWin):FIRBeam_Offidx(1,i)+(srate*TimeWin));
                
            end
        end
    end
end

if isempty(Center_ScTouch) == 0
    if sum(size(Center_ScTouch)) >= 2 
        for i = 1:length(Center_ScTouchidx)
            if (Center_ScTouchidx(i)+(srate*TimeWin))<(length(detrendTransients)) && (Center_ScTouchidx(i)-(srate*TimeWin))>(0)              
                CutTransients.Center_ScTouch_detrendTransients{i} = detrendTransients(1,Center_ScTouchidx(1,i)-(srate*TimeWin):Center_ScTouchidx(1,i)+(srate*TimeWin));
                             
            end
        end
    end
end


if isempty(Start_ITI) == 0
    if sum(size(Start_ITI)) >= 2 
        for i = 1:length(Start_ITIidx)
            if (Start_ITIidx(i)+(srate*TimeWin))<(length(detrendTransients)) && (Start_ITIidx(i)-(srate*TimeWin))>(0)                        
                CutTransients.Start_ITI_detrendTransients{i} = detrendTransients(1,Start_ITIidx(1,i)-(srate*TimeWin):Start_ITIidx(1,i)+(srate*TimeWin));
                            
            end
        end
    end
end


if isempty(Stimulus) == 0
    if sum(size(Stimulus)) >= 2 
        for i = 1:length(Stimulusidx)
            if (Stimulusidx(i)+(srate*TimeWin))<(length(detrendTransients)) && (Stimulusidx(i)-(srate*TimeWin))>(0)                      
                CutTransients.Stimulus_detrendTransients{i} = detrendTransients(1,Stimulusidx(1,i)-(srate*TimeWin):Stimulusidx(1,i)+(srate*TimeWin));
                                   
            end
        end
    end
end


if isempty(Hit) == 0
    if sum(size(Hit)) >= 2
        for i = 1:length(Hitidx)
            if (Hitidx(i)+(srate*TimeWin))<(length(detrendTransients)) && (Hitidx(i)-(srate*TimeWin))>(0)                        
                CutTransients.Hit_detrendTransients{i} = detrendTransients(1,Hitidx(1,i)-(srate*TimeWin):Hitidx(1,i)+(srate*TimeWin));
            end
        end
    end
end

if isempty(Miss) == 0
    if sum(size(Miss)) >= 2
        for i = 1:length(Missidx)
            if (Missidx(i)+(srate*TimeWin))<(length(detrendTransients)) && (Missidx(i)-(srate*TimeWin))>(0)               
                CutTransients.Miss_detrendTransients{i} = detrendTransients(1,Missidx(1,i)-(srate*TimeWin):Missidx(1,i)+(srate*TimeWin));
                                                
            end
        end
    end
else
      CutTransients.Miss_detrendTransients = {};
end

if isempty(Correct_Rej) == 0
    if sum(size(Correct_Rej)) >= 2
        for i = 1:length(Correct_Rejidx)
            if (Correct_Rejidx(i)+(srate*TimeWin))<(length(detrendTransients)) && (Correct_Rejidx(i)-(srate*TimeWin))>(0)                      
                CutTransients.Correct_Rej_detrendTransients{i} = detrendTransients(1,Correct_Rejidx(1,i)-(srate*TimeWin):Correct_Rejidx(1,i)+(srate*TimeWin));
                                                     
            end
        end
    end
else 
    CutTransients.Correct_Rej_detrendTransients = {};
end

if isempty(False_Alarm) == 0
    if sum(size(False_Alarm)) >= 2
        for i = 1:length(False_Alarmidx)
            if (False_Alarmidx(i)+(srate*TimeWin))<(length(detrendTransients)) && (False_Alarmidx(i)-(srate*TimeWin))>(0)                     
                CutTransients.False_Alarm_detrendTransients{i} = detrendTransients(1,False_Alarmidx(1,i)-(srate*TimeWin):False_Alarmidx(1,i)+(srate*TimeWin));
                                                             
            end
        end
    end
else 
        CutTransients.False_Alarm_detrendTransients = {};
end

%% Get rid of non-numerical cells, and add some useful info
CutTransients.detrendTransients = detrendTransients;
CutTransients.FIRBeam_On_detrendTransients = CutTransients.FIRBeam_On_detrendTransients((cellfun(@isempty,CutTransients.FIRBeam_On_detrendTransients))==0)
CutTransients.FIRBeam_Off_detrendTransients = CutTransients.FIRBeam_Off_detrendTransients((cellfun(@isempty,CutTransients.FIRBeam_Off_detrendTransients))==0)
CutTransients.Center_ScTouch_detrendTransients = CutTransients.Center_ScTouch_detrendTransients((cellfun(@isempty,CutTransients.Center_ScTouch_detrendTransients))==0)
CutTransients.Start_ITI_detrendTransients = CutTransients.Start_ITI_detrendTransients((cellfun(@isempty,CutTransients.Start_ITI_detrendTransients))==0)
CutTransients.Stimulus_detrendTransients = CutTransients.Stimulus_detrendTransients((cellfun(@isempty,CutTransients.Stimulus_detrendTransients))==0)
CutTransients.Hit_detrendTransients = CutTransients.Hit_detrendTransients((cellfun(@isempty,CutTransients.Hit_detrendTransients))==0)                        
CutTransients.Miss_detrendTransients = CutTransients.Miss_detrendTransients((cellfun(@isempty,CutTransients.Miss_detrendTransients))==0)
CutTransients.Correct_Rej_detrendTransients = CutTransients.Correct_Rej_detrendTransients((cellfun(@isempty,CutTransients.Correct_Rej_detrendTransients))==0)
CutTransients.False_Alarm_detrendTransients = CutTransients.False_Alarm_detrendTransients((cellfun(@isempty,CutTransients.False_Alarm_detrendTransients))==0)

CutTransients.srate = srate;
CutTransients.TimeWin = TimeWin;
%% Can save this structure of sliced detrendTransients as well or continue straight into script #3
cd(saveplace);
mousename = erase(mousename,'.mat');
mousename = erase(mousename,'_RAW');
mousename = append(mousename,'_SLICED');
save(mousename, '-struct', 'CutTransients')
sprintf('Your new structure has been saved!\nPath: ''%s'',\nName: ''%s''\nAs well as in the Workspace, for immediate use...',saveplace,mousename)
end

