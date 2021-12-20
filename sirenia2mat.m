function [varargout] = sirenia2mat(edfpath, edf, saveplace);
    %% Description
        % This function is designed to take the .edf file outputs that are exported
        % from Sirenia, and produce a structure of recorded LFP signals in the format 
        % of 4/mouse{corresponding to headstage construction} x number of samples{will be
        % converted to time} 
        % input : edf (a cell array containing the name of the one edf file
        % youd like to aquire the data from)
    % - Written by Suhaas S. Adiraju 08.31.21
    
    %% Inputs
    
    % edfpath - 
        % path to the location of your edf file, defined as such {'yourpath'}
    
    % edf - 
        % cell array '{filename.edf}', of the .edf name desired to be converted to .mat file, in order corresponding to 'mousenames'
    
    % saveplace - 
        % a path of where you want your ouput structure to be saved {'path'}
    
    %% Output 
    
    % -Structure of the LFP signals(4 x length), for each mouse
    
    %%
    disp('WARNING, YOU WILL NEED NAMES OF MICE, AS WELL AS WHAT CHAMBER THEY CORRESPOND TO!');
    
    cd (edfpath{1});
    
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
        %assignin ('base',mousenames{1},mouse1);
        %assignin ('base',mousenames{2},mouse2);
        disp ('LFPs sorted!')
    elseif ans1 == 0
        chambernum = input(prompt3);
        mousenames = input(prompt4);
        if chambernum == 3
            mouse1.lfp = signals(1:end, 1:4);
            %assignin ('base',mousenames{1},mouse1);        
            disp ('LFP sorted!')
        elseif chambernum == 4
            mouse2.lfp = signals(1:end,5:8);
            %assignin ('base',mousenames{1},mouse2);
            disp ('LFP sorted!')
        end
    else
        error('please accurately follow prompts and reponse options');
    end
    
    
    
    % now you can work with these data as desired!
    
    %% Save 
    
    % once you have successfully converted all of your .edf's, define your
    % saveplace, and and use this sourced code loop to go
    % through and save all your structures taken from:
        % (https://superuser.com/questions/1190023/matlab-save-all-variables-separately)
    
    % saveplace = {'pathofwhereyouwanttosave'};
    cd(saveplace{1});
    
    % now run this chunk of code, to save your structures in saveplace and
    % delete the other variables we dont want
    clearvars -except mousenames mouse* %prompt1 prompt2 prompt3 prompt4 hdrs edfpath chambernum ans1 saveplace
    % vars=who;
    % vars = vars(1:(end-2),:)
    if length(mousenames) == 1
        fprintf('\nSaving %s...',(mousenames{1}))
        save(mousenames{1},'-struct', 'mouse1') 
    elseif length(mousenames) == 2
        fprintf('\nSaving %s...',(mousenames{1}))
        save(mousenames{1},'-struct', 'mouse1') 
        fprintf('\nSaving %s...',(mousenames{1}))
        save(mousenames{2},'-struct', 'mouse2') 
    end
    %}
end
