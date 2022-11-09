function [CrossSubsMean] = AcrossSubs4LFP(varargin)
%% Average Across Subjects

% This function, will take average response windows (mean signal collapsed 
% across all events for a specific event type, for a specific session) 
% as the input, and collapse across subjects, yielding a 'across subjects' 
% array as would be done for a study

% Written by Suhaas Adiraju 
% 02.16.22
%% INPUTS 
% User selected average response windows

%% OUTPUTS 
% a 'collapsed across subjects' array

%% User defined inputs 

% Enter number of subjects
SubsValStr = inputdlg('How many subjects will you be averaging across?')
SubsNum = str2num(SubsValStr{1});

waitfor(msgbox(sprintf('Okay, you have selected to average across %d subjects\na window will pop up %d times\n\nSELECT 1 SUBJECT''s DATA FILE EACH TIME',SubsNum,SubsNum)))

% For total number of subjects, define each one via file selector
for x = 1:(SubsNum)
    if x <= (SubsNum)
        [subname, subpath] = uigetfile('','Select the subject-data you would like to include in the Across-Subjects-Avg')
        cd(subpath); 
        SubStruc= load(subname);
        Subs(x,:) = SubStruc.AllEventAvg(:,:)
    else
    end
    %if x> (length(SubsNum))
end

CrossSubsMean = mean(Subs,1)
waitfor(msgbox('Across subjects average created!'))

savequery = questdlg('Would you like to save this across subjects average?')
    if strcmp(savequery,"Yes") == 1
        savename = inputdlg('What would you like to name this file?')
        path2save = uigetdir('','Where would you like to save this file?')
        savename = num2str(savename{1})
        cd(path2save)
        save(savename,'CrossSubsMean')
        waitfor(msgbox(sprintf('Okay saved in\nPATH:\n%s\nNAME:\n%s\n\n',path2save,savename)))
    elseif strcmp(savequery,"No") == 0 
    end

