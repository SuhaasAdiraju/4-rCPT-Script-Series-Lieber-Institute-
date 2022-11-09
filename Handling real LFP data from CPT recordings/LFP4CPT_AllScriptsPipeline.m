%% 4CPT basic analysis pipeline, stringing together all of the existing LFP4CPT scripts


%% Set/Add paths necessary
clear all;
startupans = questdlg('Is this the first time you are running this script today?');
                    if strcmp(startupans,'Yes') == 1
                        disp('OK making sure you have all the necessary directories')
                        mkdir('Z:\Circuits projects (CPT)\Working With LFP\Handling real LFP data from CPT recordings')
                        addpath(genpath('Z:\Circuits projects (CPT)\Working With LFP\Handling real LFP data from CPT recordings'))
                    
                        mkdir('Z:\Suhaas A\Analysis things\chronux_2_12\chronux_2_12')
                        addpath(genpath('Z:\Suhaas A\Analysis things\chronux_2_12\chronux_2_12'))
                    
                        mkdir('Z:\Suhaas A\Analysis things\HH_PAC_FunctionFiles')
                        addpath(genpath('Z:\Suhaas A\Analysis things\HH_PAC_FunctionFiles'))
                    
                    
                        mkdir('Z:\Circuits projects (CPT)\CPT Recording Data')
                        addpath(genpath('Z:\Circuits projects (CPT)\CPT Recording Data'))
                    else 
                    end


% -- All scripts associated and functions written by Suhaas Adiraju 01.2022



%% Define where you want to start from
%clear; clc;

waitfor(msgbox(sprintf('This script will be a one-stop-shop for the LFP4CPT processing pipeline, combining all the basic processing scripts together in one script that can be simply run using ''Editor(tab)-Run''')))
stepCell = inputdlg(sprintf('What step do you need to start from?\n\n1- for the beginning,\n\n2- for creating a structure with Tstamps,\n\n3- for slicing based on Tstamps\n\n4- for cleaning data based on event-type\n\n5- for straight to basic analysis of data\n\n6- for plotting PAC across subjects\n'))
if (isempty(stepCell)==1)
        waitfor(warndlg('You did not indicate what step you would like to start from, please try again. Or if you would like to stop the script, press the stop button under the editor tab at the top of MATLAB'))
        stepCell = inputdlg(sprintf('What step do you need to start from?\n\n1- for the beginning,\n\n2- for creating a structure with Tstamps,\n\n3- for slicing based on Tstamps\n\n4- for cleaning data based on event-type\n\n5- for straight to basic analysis of data\n\n6- for plotting PAC across subjects\n'))
end
step = str2num(stepCell{1})
while isempty(step) == 1
    waitfor(warndlg('You did not indicate what step you would like to start from, please try again. Or if you would like to stop the script, press the stop button under the editor tab at the top of MATLAB'))
    stepCell = inputdlg(sprintf('What step do you need to start from?\n\n1- for the beginning,\n\n2- for creating a structure with Tstamps,\n\n3- for slicing based on Tstamps\n\n4- for cleaning data based on event-type\n\n5- for straight to basic analysis of data\n\n6- for plotting power across subjects\n'))
    if (isempty(stepCell)==1)
        waitfor(warndlg('You did not indicate what step you would like to start from, please try again. Or if you would like to stop the script, press the stop button under the editor tab at the top of MATLAB'))
        stepCell = inputdlg(sprintf('What step do you need to start from?\n\n1- for the beginning,\n\n2- for creating a structure with Tstamps,\n\n3- for slicing based on Tstamps\n\n4- for cleaning data based on event-type\n\n5- for straight to basic analysis of data\n\n6- for plotting PAC across subjects\n'))
    end
    step = str2num(stepCell{1})
end

%% For starting at step 1
if step == 1
            % 1
            run sirenia2mat.m
        waitfor(msgbox(sprintf('Okay, this function is complete, moving on to the next function')))
        
            % 2
            run createStructLFP.m
        waitfor(msgbox(sprintf('Okay, this function is complete, moving on to the next function')))
        
            % 3
            run sliceLFP.m
        waitfor(msgbox(sprintf('Okay, this function is complete, moving on to the next function')))
        
            % 4
           run LFPSessionCleaning.m
        waitfor(msgbox(sprintf('Okay, this function is complete, moving on to the next function')))
            
            step = 1;
        
end    


%% For starting at step 2
if step == 2 
            % 2nd
            run createStructLFP.m
        waitfor(msgbox(sprintf('Okay, this function is complete, moving on to the next function')))
        
            % 3rd
            run sliceLFP.m
        waitfor(msgbox(sprintf('Okay, this function is complete, moving on to the next function')))
        
            % 4th
           run LFPSessionCleaning.m
        waitfor(msgbox(sprintf('Okay, this function is complete, moving on to the next function')))
            
            step = 2;

end




%% For starting at step 3
if step == 3
            % 3rd
            run sliceLFP.m
        waitfor(msgbox(sprintf('Okay, this function is complete, moving on to the next function')))
        
            % 4th
           run LFPSessionCleaning.m
        waitfor(msgbox(sprintf('Okay, this function is complete, moving on to the next function')))
        
            step = 3;

end          


%% For starting at step 4
if step == 4
             % 4th
           run LFPSessionCleaning.m
        waitfor(msgbox(sprintf('Okay, this function is complete, moving on to the next function')))
            
            step = 4;

end


%% For step 5
if step == 5  
        % Power Spectrum 
        ansAnalysis = questdlg('Do you want to perform power spectrum analysis?')
            if (strcmp(ansAnalysis,'Yes')) == 1
                 % Power Spectrum Function
                 [CrossSubsPower,f,GrandPowErr] = PowerAcrossSubs
                 waitfor(msgbox(sprintf('Ok moving on to next analysis function option')))
            elseif (strcmp(ansAnalysis,'Yes')) == 0
            end
            
        ansAnalysis = questdlg('Do you want to perform Phase-Amplitude Coupling analysis?')
            if (strcmp(ansAnalysis,'Yes')) == 1
                % Phase amplitude coupling
                run PAC_4CPT.m
                waitfor(msgbox(sprintf('Ok moving on to next analysis function option')))
            elseif (strcmp(ansAnalysis,'Yes')) == 0
            end 
    
        ansAnalysis = questdlg('Do you want to create an ERP?')
            if (strcmp(ansAnalysis,'Yes')) == 1
                % ERP analysis
                    run LFP_ERP.m
                    waitfor(msgbox(sprintf('Ok moving on to next analysis function option')))
            elseif (strcmp(ansAnalysis,'Yes')) == 0
            end 
        ansAnalysis = questdlg('Do you want to compute a spectrogram?')
            if(strcmp(ansAnalysis,'Yes')) == 1
                run AvgSpectogram4CPT.m
                waitfor(msgbox(sprintf('Ok ')))
            elseif (strcmp(ansAnalysis,'Yes')) == 0
            end
end


%% For plotting
if step == 6
    ansPlotBetweenSubs = questdlg('Do you want to plot PAC Mod. Index value data between subjects? (typically only if you''ve finished processing and analyzing for all subjects.')
    if strcmp(ansPlotBetweenSubs, 'Yes') == 1
        %% Plot all subjects
        % Enter number of subjects
        SubsValStr = inputdlg('How many subjects will you be plotting?')
        SubsNum = str2num(SubsValStr{1});
    
        GroupValStr = inputdlg('How many conditions will you be plotting for')
        GroupsNum = str2num(GroupValStr{1})
    
        waitfor(msgbox(sprintf('Okay, you have selected to plot for %d subjects, and for %d groups\n\nCRITICAL: MAKE SURE YOU SELECT DATA FROM EACH GROUP ONE AFTER ANOTHER\ni.e. mouse1_Hits then mouse2_Hits, *NOT* mouse1_Hits then mouse1_Misses\n\nA window will pop up %d times\n\nAs you have indicated to plot %d Subjects x %d Groups',SubsNum,GroupsNum,(SubsNum*GroupsNum),SubsNum,GroupsNum)))
        
        % For total number of subjects, define each one via file selector
        for i = 1:(SubsNum*GroupsNum)
            [subname, subpath] = uigetfile('','Select the subject/condition-data you would like to include in the box-plot')
            cd(subpath); 
            SubStruc= load(subname);
                if i <= (SubsNum)
                    Subjects(i) = SubStruc.ModVal;
                    Groups(i) = NaN;
                end
                if i > (SubsNum)
                    Subjects(i) = NaN;
                    Groups(i) = SubStruc.ModVal
                end
        end
        Subjects = Subjects(~isnan(Subjects))
        Groups = Groups(~isnan(Groups))
        AllSubsGroups = vertcat(Subjects,Groups);
        %GroupNames = inputdlg(sprintf('What are the names of the group/conditions you are comparing subjects across?\n\nINPUT STYLE: [condition1; condition2...]'))
        boxplot((AllSubsGroups'),'Labels',{'False-Alarms','Hits'},'BoxStyle','outline'); hold on 
        scatter([1:2],AllSubsGroups(:,:),'filled')
        %bar(AllSubsGroups)
        xlabel('Conditions')
        ylabel('Modulation Index Value')
    else 
    end
       
end

