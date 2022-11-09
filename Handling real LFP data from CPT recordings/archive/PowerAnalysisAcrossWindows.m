% Power spectrum across subjects For Hits 
clear; clc
% Load and Enter number of subjects
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

% Set Params for power spectrum calc
% Power spectrum 
params.tapers = [5 9];
params.pad = 0;
params.Fs = 2000;
params.fpass = [0 200];
params.err = [1 .05];
params.trialave = 1;

Subs4Pow = Subs'; %(must be in the form of samples as rows and channels as columns
% Compute cross subs power
[S,f,Serr]= mtspectrumc(Subs4Pow,params)

PowMat(1,:) = Serr(1,:);
PowMat(2,:) = S';
PowMat(3,:) = Serr(2,:);

    %plot(f,S,f,Serr,'MarkerMode','manual','LineWidth',1)
    %xlim([0 100])
px=[f,fliplr(f)];
py=[PowMat(1,:), fliplr(PowMat(3,:))];

powErr= patch(px,py,1,'FaceColor','r','EdgeColor','none','FaceAlpha',.4)
figure; 
plot(f,PowMat(2,:),'r',f,PowMat(1,:),'b',f,PowMat(3,:),'g');


figure; 
plot(f,PowMat(2,:),'b', 'LineWidth',1.5,'MarkerEdgeColor','auto');
patch(px,py,1,'FaceColor','r','EdgeColor','none','FaceAlpha',.4);
xlim([0 100])
sgtitle('Power Spectrum of 4s Window Surrounding Hits (Across 6 subjects)')
ylabel('Power Value (magnitude of complex coeff. from a fourier transformed signal)')
xlabel('Frequencies (Hz)')

%http://jvoigts.scripts.mit.edu/blog/nice-shaded-plots/ 
% adapted code taken from ^ for help on patch and coloring for shaded error bars





%%
% Power spectrum across subjects For False Alarms
clear; clc
% Load and Enter number of subjects
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

% Set Params for power spectrum calc
% Power spectrum 
params.tapers = [5 9];
params.pad = 0;
params.Fs = 2000;
params.fpass = [0 200];
params.err = [1 .05];
params.trialave = 1;

Subs4Pow = Subs'; %(must be in the form of samples as rows and channels as columns
% Compute cross subs power
[S,f,Serr]= mtspectrumc(Subs4Pow,params)

PowMat(1,:) = Serr(1,:);
PowMat(2,:) = S';
PowMat(3,:) = Serr(2,:);

    %plot(f,S,f,Serr,'MarkerMode','manual','LineWidth',1)
    %xlim([0 100])
px=[f,fliplr(f)];
py=[PowMat(1,:), fliplr(PowMat(3,:))];

powErr= patch(px,py,1,'FaceColor','r','EdgeColor','none','FaceAlpha',.4)
figure; 
plot(f,PowMat(2,:),'r',f,PowMat(1,:),'b',f,PowMat(3,:),'g');


figure; 
plot(f,PowMat(2,:),'b', 'LineWidth',1.5,'MarkerEdgeColor','auto');
patch(px,py,1,'FaceColor','r','EdgeColor','none','FaceAlpha',.4);
xlim([0 100])
sgtitle('Power Spectrum of 4s Window Surrounding False-Alarms (Across 6 subjects)')
ylabel('Power Value (magnitude of complex coeff. from a fourier transformed signal)')
xlabel('Frequencies (Hz)')