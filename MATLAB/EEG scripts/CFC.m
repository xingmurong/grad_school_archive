% CFC('inFile.txt')
%
% CFC generates cross frequency coherences, plots them and stores them to images and .mat files.
% Multiple sessions will be read from the CSC's specififed in
% 'CSCList.txt'. 'TTList.txt' is necessary for spike data scripts that use
% the same 'infile.txt'.
%
% The input file must be on the following format.
%
% C:\Data\TTList.txt
% C:\Data\CSCList.txt
% C:\Data\Begin 1
% C:\Data\Begin 2
% C:\Data\Begin 3
% C:\Data\Begin 4
% and so on ...
%
% 'CSCList.txt' contains a list of the Neuralynx .csc files to be analyzed.
% All plots will be stored to both bmp and eps imagefiles to a subdirectory in
% the data folder called CFC_plots.

function [CRF] = CFC(inFile,freqVec)

img_text = 'on';

fid = fopen(inFile,'r');
if fid == -1
    msgbox('Could not open the input file! Make sure the filname and path are correct.','ERROR');
end

% Get sessions and csc-file list from input file
fid = fopen(inFile,'r');
ii = -1;     
while ~feof(fid)
    str = fgetl(fid);
    if ii == 0
        cscList = str
    elseif ii == 1
        refList = str;
    elseif ii > 1
        if ~strcmp(str(end),'\')
            str = strcat(str,'\');
        end
        sessions(ii-1) = {str};
    end
    ii = ii+1;
end
numsessions = ii-2;     

% read the file names from the csc-file list
cscid = fopen(cscList,'r')
jj = 1;
while ~feof(cscid)
       str = fgetl(cscid);
       channels(jj) = {str};
       jj = jj+1;
end
numchannels = jj-1;
cscid = fclose('all');

refid = fopen(refList,'r')
jj = 1;
while ~feof(refid)
       str = fgetl(refid);
       refs(jj) = {str};
       jj = jj+1;
end

for ii = 1:numsessions
    disp(sprintf('%s%s','Reading data for session: ',sessions{ii}));
    % Check if subdir for storing images are present. If not, it is
    % created
    dirInfo = dir(sessions{ii});
    found = 0;
    for kk=1:size(dirInfo,1)
        if dirInfo(kk).isdir
            if strcmp(dirInfo(kk).name,strcat('CFCplots','\'))
                found = 1;
            end
        end
    end
    if found==0
        mkdir(sessions{ii},strcat('CFCplots','\'));
    end
    
    % Make Average Reference
    avref = 0;
    for jj=1:numchannels
        file = [sessions{ii},channels{jj}];
        [samples,ts,tt, Fs, bv, ir] = loadEEG2(file);
        ch_X = bv*samples;
        if ~strcmp(refs{jj},'G')
            rfile = [sessions{ii},refs{jj}];
            [samples,ts,tt, Fs, bv, ir] = loadEEG2(rfile);
            ch_X = ch_X + bv*samples;
        end
        avref = avref + ch_X/numchannels;
        clear samples ch_X
    end
    
    % Load data from the .ncs files, make plots, and store them
    for jj=1:numchannels
        disp('Make plots and store them to files');
        disp(sprintf('%s%i',' CSC ',jj, ' of ',numchannels));
        file = [sessions{ii},channels{jj}];
        [samples,ts,tt, Fs, bv, ir] = loadEEG2(file);
        ch_X = bv*samples;
        %set recording channel against ground and then against average reference
        if ~strcmp(refs{jj},'G')
            rfile = [sessions{ii},refs{jj}];
            [samples,ts,tt, Fs, bv, ir] = loadEEG2(rfile);
            ch_X = ch_X + bv*samples;            
        end
        ch_X = ch_X - avref;  
        clear samples
%         rfile = [sessions{ii},'R2.ncs'];
%         [samples,ts,tt, Fs, bv, ir] = loadEEG2(rfile);
%         Ref = bv*samples;
%         ch_X = ch_X + Ref;
        [CRF,freqVec1,freqVec2] = crossfreqCoh(ch_X,ch_X,freqVec,Fs);
        data.freq1 = freqVec1; data.freq2 = freqVec2; data.crf = CRF;   %save data as struct
        filename = sprintf('%s%s%s%s',sessions{ii},strcat('CFCplots','\'),channels{jj}(1:end-4),'_avref.mat');
        save(filename,'-struct','data');
        figure(1);
        imagesc(freqVec1,freqVec2,CRF); axis xy; xlim([0 max(freqVec)]);
        xlabel('Frequency_p_h_a_s_e (Hz)');ylabel('Frequency_a_m_p_l_i_t_u_d_e (Hz)');
        title(strcat('Cross Frequency Coherence: ',file));
        figImage = sprintf('%s%s%s%s',sessions{ii},strcat('CFCplots','\'),channels{jj}(1:end-4),'_avref.fig');
        bmpImage = sprintf('%s%s%s%s',sessions{ii},strcat('CFCplots','\'),channels{jj}(1:end-4),'_avref.bmp');
        epsImage = sprintf('%s%s%s%s',sessions{ii},strcat('CFCplots','\'),channels{jj}(1:end-4),'_avref.eps');
        saveas(gcf,figImage,'fig');
        saveas(gcf,bmpImage,'bmp');
        saveas(gcf,epsImage,'eps');
    end
end




