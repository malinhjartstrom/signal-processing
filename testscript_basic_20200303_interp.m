%%
clc

close all

%Eko fr?n ultraljud i ett materal
    %A is the signal
    %Timeinterval is the time between samples in seconds
    %Requested length is the number of samples

%Material thickness assumed to be 1 inch
d = 0.0254; %material thickness in meters



%myRequestedlength = 2000;

folder = uigetdir(... 
    'c:\Users\per\Lund University\Experimental acoustofluidics group - AcouPlast - AcouPlast\Material properties\Measurements\20200626_DTU_polymers\' ...
    );
files = dir(folder);


%For steel:
myRequestedlength = 6250;
% myFolder = 'C:\Users\Malin\Documents\Forskningsassistent LTH\Signalbehandling\signal-processing\20200303-0001_'; %Working folder
%myFolder = 'C:\Users\Malin\Documents\Forskningsassistent LTH\Signalbehandling\signal-processing\20200228-0001_'; %Working folder

%For polymer:
%myRequestedlength = 2500;
%myFolder = 'C:\Users\Malin\Documents\Forskningsassistent LTH\Signalbehandling\sp\polymerdata\20191210-0001\20191210-0001_'; %Working folder

%Signal generated in PicoScope:
%myFolder = 'C:\Users\Malin\Documents\Forskningsassistent LTH\Signalbehandling\20200603-0001\20200603-0001_'; %Working folder


for i = 1 : 32
    load([folder '\' files(i+2).name],'A','Length','Tstart','Tinterval');
    As(:,i) = A;
end


%overwrite lenght of data
% RequestedLength = myRequestedlength;

% tsampled = linspace(0,(RequestedLength-1)*Tinterval*1e6,RequestedLength); %time in us
t = linspace(0,(Length-1)*Tinterval*1e6,Length); %time in us

%Plottar alla signaler mot den samlade tiden
figure
% subplot(3,1,1)
plot(t,As)
title('All signals')
xlabel('time (us)')

%%
%f = msgbox('In the next plot, mark the minimum height for a relevant peak. Then mark the relevant peak closest to it.','Message')

%% Mark in figure
tcomp = linspace(Tstart,(Length-1)*Tinterval ,Length);

Amean = mean(As,2); %column vector containing the mean of each row
%Amean = interp1(tsampled,Amean,t,'spline'); %returns the piecewise polynomial form of Amean(tsampled) using the t algorithm
Aabs = abs(Amean);
figure
plot(tcomp,Aabs,'linewidth',2)
title('Mean of all signals: Mark two peaks')
xlabel('time (us)')
axis([0 max(tcomp) min(Aabs) max(Aabs)+0.01])
annotation('textbox', [0.55, 0.65, 0.3, 0.2], 'String', "Please mark the minimum height for a relevant peak. Then mark the relevant peak that is closest to it.")

%Markera den minsta (men fortfarande intressanta) peaken f?r att best?mma
%'MinPeakHeight', samt peaken brevid f?r att best?mma minsta avst?nd mellan
%peaks
[xx, y] = ginput(1);
mph = y;
peak1 = xx;
[xx2, ~] = ginput(1);
peak2 = xx2;
minDist = abs(peak1-peak2)/Tinterval;
%% Interpolation
%Interpolerar t.ex. 10 ggr h?gre samplingshastighet
interpolationRate = 1;
Aabsi = interp(Aabs,interpolationRate);
ti = interp(t,interpolationRate);

%% Time between consecutive peaks
%Plottar interpolerade abs(Amean) mot interpolerad tid
figure
plot(ti,Aabsi,'linewidth',2)
title('Mean of all signals with peaks, interpolated')
xlabel('time (us)')
axis([0 max(ti) min(Aabsi) max(Aabsi)+0.01])
hold on

[pks_2, locs_2] = findpeaks(Aabsi,'MinPeakDistance',minDist*interpolationRate,'NPeaks',2,'MinPeakHeight',mph);
plot(ti(locs_2),pks_2,'x')
diff((locs_2)); %963 samples in original sampling rate

[pks, locs] = findpeaks(Aabsi,'MinPeakDistance',diff(locs_2)-5,'MinPeakHeight',mph);
plot(ti(locs),pks,'o')
format long g
sample_differences = diff(locs)
time_between_peaks = [diff(ti(locs))].'


%% Plotting the mean of the original signal and the (interpolated) peaks

figure
plot(t,Aabs,'linewidth',2)
title('Mean of abs(signal) together with approximated peaks')
xlabel('time (us)')
axis([0 max(t) min(Aabs) max(Aabs)+0.01])
hold on

plot(ti(locs),pks, 'ro')
legend({'Mean of abs(signal)', 'Interpolated peaks'})


m = mean(times)
s = std(times)
cv = s/m