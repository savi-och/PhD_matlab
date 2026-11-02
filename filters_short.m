function Sout=func_filterSVG(Sin,time,filter_time) %signal, time and 60
    Fs=round(1/(mean(diff(time))));
    %Fs=1/mode(diff(t));
    N=round(filter_time*Fs)-1;   % number of points required for a filter of length 60 seconds.
    Sout=sgolayfilt(Sin,1,N);
