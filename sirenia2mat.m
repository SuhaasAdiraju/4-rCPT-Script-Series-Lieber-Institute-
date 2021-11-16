function [varargout] = sirenia2mat(edf);
%% Description
    % This function is designed to take the .edf file outputs that are exported
    % from Sirenia, and produce a structure of recorded LFP signals in the format 
    % of 4/mouse{corresponding to headstage construction} x number of samples{will be
    % converted to time} 
    % input : edf (a cell array containing the name of the one edf file
    % youd like to aquire the data from)
% - Written by Suhaas S. Adiraju 08.31.21

%% Inputs
            % when recording EPhys, there are currently (08.2021) only 2 ephys chambers, so one edf file houses two mice for a double recording, 
    
% -edf: cell array '{filename.edf}', of the .edf name desired to be converted to .mat file, in order corresponding to 'mousenames'

%% Output 

% -Structure of the LFP signals(4 x length), for each mouse

%%
disp('WARNING, YOU WILL NEED NAMES OF MICE, AS WELL AS WHAT CHAMBER THEY CORRESPOND TO!');

prompt1 = '\n\nWould you like recordings from both chambers? (1 -yes, 0 -no)\n';
ans1 = input(prompt1);
prompt2 = '\n\nWhat are the identifying values of your mice? \n\nFORM: {''name1'', ''name2''} **CORRESPONDING TO CHAMBER3 AND CHAMBER4**,\n\nNAMES MUST START WITH LETTERS  (generally corresponds to stage) \n*dont forget your curly brackets and single-quotes!\n';
prompt3 = '\n\nYou have selected to only source data from one chamber ; \nwhich chamber is this? (3 or 4)\n';
prompt4 = '\n\nOK.  What is the name of this mouse? \nFORM:{''name''},\n\nNAMES MUST START WITH LETTERS   (generally corresponds to stage) \n*dont forget your curly brackets and single-quotes!\n';

[signals, hdrs] = edfread(edf{1});
if ans1 == 1
    mousenames = input(prompt2)
    mouse1.lfp = signals(1:end, 1:4);
    mouse2.lfp = signals(1:end,5:8);
    assignin ('base',mousenames{1},mouse1);
    assignin ('base',mousenames{2},mouse2);
    disp ('LFPs sorted!')
elseif ans1 == 0
    chambernum = input(prompt3);
    mousenames = input(prompt4);
    if chambernum == 3
        mouse1.lfp = signals(1:end, 1:4);
        assignin ('base',mousenames{1},mouse1);        
        disp ('LFP sorted!')
    elseif chambernum == 4
        mouse2.lfp = signals(1:end,5:8);
        assignin ('base',mousenames{1},mouse2);
        disp ('LFP sorted!')
    end
else
    error('please accurately follow prompts and reponse options');
end


end

% now you can work with these data as desired!

%%

