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

function TFR_orig(inFile,freqVec,width)  % width - number of cycles in wavelet (> 5 advisable); order - whitening

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
    elseif ii > 0
        if ~strcmp(str(end),'\')
            str = strcat(str,'\');
        end
        sessions(ii) = {str};
    end
    ii = ii+1;
end
numsessions = ii-1;     

% read the file names from the csc-file list
cscid = fopen(cscList,'r');
jj = 1;
while ~feof(cscid)
       str = fgetl(cscid);
       channels(jj) = {str};
       jj = jj+1;
end
numchannels = jj-1;

for ii = 1:numsessions
    disp(sprintf('%s%s','Reading data for session: ',sessions{ii}));
    % Check if subdir for storing images are present. If not, it is
    % created
    dirInfo = dir(sessions{ii});
    found = 0;
    for kk=1:size(dirInfo,1)
        if dirInfo(kk).isdir
            if strcmp(dirInfo(kk).name,strcat('TFRplots','\'))
                found = 1;
            end
        end
    end
    if found==0
        mkdir(sessions{ii},strcat('TFRplots','\'));
    end
    
    % Load data from the .ncs files, make plots, and store them
    for jj=1:numchannels
        disp('Make plots and store them to files');
        disp(sprintf('%s%i',' CSC ',jj, ' of ',numchannels));
        file = [sessions{ii},channels{jj}];
        [samples,ts,tt, Fs, bv, ir] = loadEEG2(file);
        ch_X = bv*samples;
%         rfile = [sessions{ii},'R2.ncs'];
%         [samples,ts,tt, Fs, bv, ir] = loadEEG2(rfile);
%         Ref = bv*samples;
%         ch_X = ch_X + Ref;
        %ch_Xw = prewhitening(ch_X,order);   % prewhiten signal for better visualisation
        [TFR,timeVec,freqVec] = traces2TFR([ch_X ch_X],freqVec,Fs,width);
        
%         TFRperc = zeros(size(TFR));
% 
%         for i=1:size(TFR,1)
%             TFRperc(i,:) = tiedrank(TFR(i,:))/size(TFR,2);
%         end
        theta = mean(TFR(freqVec>6 & freqVec<12,:),1); %theta
        delta = mean(TFR(freqVec>1 & freqVec<=4,:),1);%delta
        thetadelta = smooth(theta./delta,1000);
        %TFRz = zscore(TFR,0,2);
        data.tt = tt; data.freqvec = freqVec; data.tfr = TFR; data.td = thetadelta;  %save data as struct
        filename = sprintf('%s%s%s%s',sessions{ii},strcat('TFRplots','\'),channels{jj}(1:end-4),'.mat');
        save(filename,'-struct','data');
%         figure(1)
%         %imagesc(timeVec./60, freqVec, TFR, [0 0.25*max(max(TFR))]); axis xy; xlabel('time (min)'); ylabel('frequency (Hz)');
%         imagesc(timeVec./60, freqVec, TFRz, [-1 1]); axis xy; xlabel('time (min)'); ylabel('frequency (Hz)');
%         title(['Time Frequency Representation: ',file]); colorbar;
%         figImage = sprintf('%s%s%s%s',sessions{ii},strcat('TFRplots','\TFR_'),channels{jj}(1:end-4),'.fig');
%         bmpImage = sprintf('%s%s%s%s',sessions{ii},strcat('TFRplots','\TFR_'),channels{jj}(1:end-4),'.bmp');
%         epsImage = sprintf('%s%s%s%s',sessions{ii},strcat('TFRplots','\TFR_'),channels{jj}(1:end-4),'.eps');
%         saveas(gcf,figImage,'fig');
%         saveas(gcf,bmpImage,'bmp');
%         saveas(gcf,epsImage,'eps');
        clear TFR TFRz data
    end
end



