function sirenia2mat
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
    



%% Define in necessary variables
clc; clearvars -except stage
ansmain = questdlg('Have you opened the ephys file, in Sirenia, and exported as a .edf file, so now you have the .edf the session on-hand?')
if strcmp(ansmain, 'No') == 1
    warndlg('You will not be able to run this script or the function without the .edf file accessible! Sorry! Please open the original file in Sirenia, and export as an .edf, then come back')
    error('Issue encountered please rerun script')
elseif strcmp(ansmain,'Yes') == 1
    waitfor(msgbox(sprintf('Welcome to sirenia 2 mat function!\n\nPURPOSE:\nWalk the user through defining necessary inputs for the sirenia2mat function IN ORDER TO READ AND CONVERT LFP DATA FROM THE ORIGINAL .edf FORMAT TO .mat FORMAT SO THAT A USER CAN BEGIN TO PROCESS AND ANALYZE THEIR LFP/EPHYS DATA.\n\nINPUTS:\n\n-User-defined premade .edf file: Created via opening the original .pvs file in Sirenia, and exporting as a .edf\n\n-User-defined saveplace: location of saving the output structure\n\n\nOUTPUTS:\n\n-mouse structure: A new data structure containing the lfp for the corresponding chamber, with a user-defined name, that we will build on in subsequent scripts of the LFP4CPT series'))) 

        % runstyle = input('\n\nWould you like to be walked through defining each input?\nOr define them manually...\n''1'' for walkthrough, ''2'' for manually\n')
        % 
        % if runstyle == 1
    % This is the function and the necessary variables are in soft brackets
    % (...)
    
        % function [varargout] = sirenia2mat(edfpath, edf, saveplace);
    
    % edfpath
    waitfor(msgbox(sprintf('A file selector will pop up,\n Then select your .edf file exported from Sirenia\n\n')))
      
    [edfname,edfpath]= uigetfile('*.edf*','Please select the .edf file of the mouse you want to process/analyze')
    while ((edfname)) == 0
        %error('You did not properly select an .edf file. Please try again')
        waitfor(warndlg('You did not properly select an .edf file. Press okay try again. Or if you are trying to get out of the script, press ''Stop'' in the Editor tab next to Run'))
        [edfname,edfpath]= uigetfile('*.*','Please select the .edf file of the mouse you want to process/analyze')
    end
        % input('\n\nWhat is the path to your .edf file? \n INDICATE IN FORMAT: {''path''}\n')
        % {'Z:\Circuits projects (CPT)\CPT Recording Data\EXAMPLE SCRIPTS SAMPLE DATA'};
    
    % edf 
        % edf should be defined as such
        %edf = {'NameOfyour.EDF'}; dont forget the .edf
            % = input('\n\nWhat is the name of the .edf file in indicated path? \n INDICATE IN FORMAT: {''path''}\n')
        % {'1700S_S3good_TTLrecording_EDF.edf'};    
    
    % saveplace
    waitfor(msgbox(sprintf('A path selector will pop up,\n\nThen select the folder to where you would like to save your new structure')))
    
    [saveplace] = uigetdir('','Please select the folder in which you would like to save your resulting structure')
 

    while (saveplace) == 0
        waitfor(warndlg('You did not properly select an place to save. Press okay try again. Or hit the stop button at the top of the screen (found under editor tab)'))
        [saveplace] = uigetdir('','Please select the folder in which you would like to save your resulting structure')
    end

    waitfor(msgbox(sprintf('All necessary inputs recieved! Click Okay ''sirenia2mat function!''')))


 %%
    cd (edfpath);
    
   
    prompt4 = 'OK.  Please enter SessionStage_MouseID# (name to save structure under)';
    
    [signals, hdrs] = edfread(edfname);
    signalsFin = cell2mat(signals{:,:});
    % signalsFin = (signalsFin')
    %{
    if ans1 == 1
        dlgtitle = 'Identifying Names?'
        mousenames = (inputdlg(prompt2, dlgtitle)); 
        mouse1.lfp = signalsFin([1:end], [1:4]);
        mouse1.lfp = (mouse1.lfp')
        mouse2.lfp = signalsFin([1:end],[5:8]);
        mouse2.lfp = (mouse2.lfp')
        %assignin ('base',mousenames{1},mouse1);
        %assignin ('base',mousenames{2},mouse2);
        disp ('LFPs sorted!')
    %}
    %elseif ans1 == 0
            %chambernumCell = (inputdlg(prompt3))
            %chambernum = str2num(chambernumCell{1})
            % clear chambernumCell
        mousenames = (inputdlg(prompt4)); 
        while contains(mousenames,'-') | contains(mousenames,' ') | contains(mousenames,'\') | contains(mousenames,'/')
            waitfor(warndlg(sprintf('Your variable name cannot have dashes, or spaces, or slashes \n\nPlease try to name again')))
            mousenames = (inputdlg(prompt4)); 
        end
       % if chambernum == 3
        mouse1.lfp = signalsFin(1:end, 1:4);
        mouse1.lfp = (mouse1.lfp');
        %assignin ('base',mousenames{1},mouse1);        
        disp ('LFP sorted!')
        %{
        elseif chambernum == 4
            mouse2.lfp = signalsFin([1:end],[5:8]);
            mouse2.lfp = (mouse2.lfp')
            %assignin ('base',mousenames{1},mouse2);
            disp ('LFP sorted!')
        end
    else
        error('please rerun and accurately follow prompts and reponse options');
    end
        %}
    
    
    % now you can work with these data as desired!
    
    %% Save 
    
    % once you have successfully converted all of your .edf's, define your
    % saveplace, and and use this sourced code loop to go
    % through and save all your structures taken from:
        % (https://superuser.com/questions/1190023/matlab-save-all-variables-separately)
    
    % saveplace = {'pathofwhereyouwanttosave'};
    cd(saveplace);
    
    % now run this chunk of code, to save your structures in saveplace and
    % delete the other variables we dont want
    clearvars -except mousenames mouse* saveplace stage %prompt1 prompt2 prompt3 prompt4 hdrs edfpath chambernum ans1 saveplace
    % vars=who;
    % vars = vars(1:(end-2),:)
    if length(mousenames) == 1
        sprintf('\nSaving %s...',(mousenames{1}))
        assignin('base',mousenames{1},mouse1.lfp)        
        save(mousenames{1},'-struct', 'mouse1') 
%     elseif length(mousenames) == 2
%         sprintf('\nSaving %s...',(mousenames{1}))
%         assignin('base',mousenames{1},mouse1.lfp)        
%         assignin('base',mousenames{2},mouse2.lfp)             
%         save(mousenames{1},'-struct', 'mouse1') 
%         sprintf('\nSaving %s...',(mousenames{1}))
%         save(mousenames{2},'-struct', 'mouse2') 
    end
  

    waitfor(msgbox(sprintf('OK, function complete and output saved\n\nAs Name: %s\n\nIn Location: %s,\n\nNow you can move on!',mousenames{1},saveplace)))

    vardisplay = questdlg('Would you like to evaluate the variable created?');
    if strcmp(vardisplay,'Yes') == 1 
        waitfor(msgbox(sprintf('When you are finished evaluating the variable\nCLICK INTO THE COMMAND WINDOW (bottom of MATLAB)\n then type in ''dbcont''')))
        openvar('mouse1')
        sprintf('\n\nTYPE ''dbcont'' BELOW HERE')
        
        keyboard
    elseif strcmp(vardisplay,'Yes') == 0
    end
end

% figure; plot(mouse1.lfp(4,:),'k','LineWidth',.6); title('Full CPT Session LFP Recording'); xlabel('Samples'); ylabel('Voltage (mV)')
