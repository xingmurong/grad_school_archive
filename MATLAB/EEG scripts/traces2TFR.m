function [TFR,timeVec,freqVec] = traces2TFR(S,freqVec,Fs,width);
% function [TFR,timeVec,freqVec] = traces2TFR(S,freqVec,Fs,width);
%
% Calculates the average of a time-frequency energy representation of
% multiple trials using a Morlet wavelet method.                            
%
% Input
% -----
% S    : signals = time x Trials      
% freqVec    : frequencies over which to calculate TF energy        
% Fs   : sampling frequency
% width: number of cycles in wavelet (> 5 advisable)  
%
% Output
% ------
% t    : time
% f    : frequency
% B    : energy = frequency x time
%     
%------------------------------------------------------------------------
% Ole Jensen, Brain Resarch Unit, Low Temperature Laboratory,
% Helsinki University of Technology, 02015 HUT, Finland,
% Report bugs to ojensen@neuro.hut.fi
%------------------------------------------------------------------------

%    Copyright (C) 2000 by Ole Jensen 
%    


S = S';
LNR50 = 0; 

timeVec = (1:size(S,2))/Fs;  

B = zeros(length(freqVec),size(S,2)); 

for i=1:size(S,1)          
    %fprintf(1,'%d ',i); 
    for j=1:length(freqVec)
        if LNR50
            B(j,:) = energyvec(freqVec(j),lnr50(detrend(S(i,:)),Fs),Fs,width) + B(j,:);
        else
            B(j,:) = energyvec(freqVec(j),detrend(S(i,:)),Fs,width) + B(j,:);
        end
    end
end
TFR = B/size(S,1);     


function y = energyvec(f,s,Fs,width)
% function y = energyvec(f,s,Fs,width)
%
% Return a vector containing the energy as a
% function of time for frequency f. The energy
% is calculated using Morlet's wavelets. 
% s : signal
% Fs: sampling frequency
% width : width of Morlet wavelet (>= 5 suggested).
%
% 

dt = 1/Fs;
sf = f/width;
st = 1/(2*pi*sf);

t=-3.5*st:dt:3.5*st;
m = morlet(f,t,width);
y = convfft(s,m);
y = (2*abs(y)/Fs).^2;
y = y(ceil(length(m)/2):length(y)-floor(length(m)/2));



function y = morlet(f,t,width)
% function y = morlet(f,t,width)
% 
% Morlet's wavelet for frequency f and time t. 
% The wavelet will be normalized so the total energy is 1.
% width defines the ``width'' of the wavelet. 
% A value >= 5 is suggested.
%
% Ref: Tallon-Baudry et al., J. Neurosci. 15, 722-734 (1997)
%
% See also: PHASEGRAM, PHASEVEC, WAVEGRAM, ENERGY 
%
% Ole Jensen, August 1998 

sf = f/width;
st = 1/(2*pi*sf);
A = (st*sqrt(pi))^(-0.5);

y = A*exp(-t.^2/(2*st^2)).*exp(i*2*pi*f.*t);
