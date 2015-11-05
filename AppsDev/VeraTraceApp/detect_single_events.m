function results=detect_single_events(DataArray,params)

peakOn = [];
peakOff = [];
peakHeight = [];
peakWidth = [];

g = 0;  %number of the current peak and position of the information of the g-th peak in all output files
l = 0;
basePoints = params.basePoints;

schwellwert_on = params.th_mult_on * params.stdev;   %defines an offset for the trigger level by a multiple of the standard deviation derived in the m-File "StdDevBaseline"
schwellwert_off = params.th_mult_off * params.stdev;

    %create moving baseline%%%%%%%%%%%%%%%%%
    
    if (params.useMedian)
        k = Filter.median1d(DataArray, basePoints / 2);
    else
        k = Filter.average(DataArray, basePoints / 2);
    end
    k = k(basePoints/2:(end-basePoints/2));
%     k = ones(numel(DataArray), 1) * median(DataArray);
    
%     k = zeros(length(DataArray),1); %creates a single coloum array to speed up the creation of the moving baseline k(i)
% 
%     k(1) = sum(DataArray(1:basePoints)) / basePoints;   %creates first entry in the moving baseline k(i)
% 
%     for i = 2:length(DataArray) - basePoints
%     
%         k(i) = k(i-1) - DataArray(i-1)/basePoints + DataArray(i+basePoints-1)/basePoints;   %moving baseline k(i) for every data point "j+1"
% 
%     end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i = basePoints;   


endcut=numel(DataArray)-2;

while i < endcut-basePoints-2    %major loop of the peak finding algorithm starting at i and ending with a user defined buffer from the DataArray end: avoids problems when DataArray ends within a peak

    
    i = i + 1;  %aktueller Datenpunkt außerhalb des Peaks
    j = i + basePoints-1;  %data point preceding "basePoints"-1 data points i
   
    
      
    if DataArray(j+1) < k(i) - schwellwert_on %if true a peak is found and the peak evaluation starts 
    
%filer set to decide whether the peak has to be withdrwan or not%%%%%%%%%%

        if params.u == 0                       %(u = flag of Slope-Evaluation), if false: there is a local maximum within the slope of the last peak
%             if params.peakWidth2 >= 100        %filter to exclude peaks with a width smaller than a user defined value 
%                  if params.peakHeight2 <=20
%                 if params.peakSumm >= 2750    %filter to exclude peaks with a sum (integral of peak) smaller than a user defined value 
                   if params.spike == 0
                     g = g + 1;         %only when the last peak passes all three filters the information of the last peak is not replaced by the information of the current peak 
%                  

                   end
%                    end
%                   end
%            end
        end
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        h = 0;
        t = 0;          %pointer to find the beginning of the peak
        u = 0;
        b = 0;
        r = j + 1;      %pointer to find the data point left from the data point "j+1". ("j+1" ignites the peak evaluation)

%find the beginning of the peak%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        while DataArray(r) < k(i)   %loop to find the data point r (left from j+1) which reaches the baseline k(i) 
            r = r - 1;
        end

        for t = r:j+1               %loop to find the beginning of the peak: peakOn 
            if DataArray(t) >= DataArray(t-1)   %if there is a local maximum (also next line)
                if DataArray(t) >= DataArray(t+1)
                    if DataArray(t)>= k(i) - params.stdev  %and the current value is above the baseline-standard deviation
                
                        b = b + 1;                      %flag non zero when there is a local maximum found
                        peakOn(g,1) = t+1;              %peakOn is a two dimenional array where in the first column the position in DataArray is saved
                        peakOn(g,2) = DataArray(t+1);   %...and in the secon column the current value at this position
                    
                    end
                end
            end
        end

        
        if b == 0       %if there was no local maximum found in the foregoing loop then peakOn position is set to r+1     
            peakOn(g,1) = r+1;
            peakOn(g,2) = DataArray(r+1);    
        end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

       if g > 1
            
            peakGap(g-1,1) =  g-1;
            peakGap(g,1) =  g;
            peakGap(g,2) =  (peakOn(g,1)-peakOff(g-1,1))*5;
                    
        end



        b = 0;
        l = j + 1;  %pointer to find the data point right from the data point "j+1". ("j+1" ignites the peak evaluation) 
        f = 1;      %counts the number of data points within the peak
                     

%find the end of the peak%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        while DataArray(l) < k(i) %loop to find the data point l (right from j+1) which reaches the baseline k(i)
            l = l + 1;
            f = f + 1;         
        end

        peakOff(g,1) = l;   %...this point marks not yet the end of the peak, but is actually used to find the real peakOff (end of the peak);  so the values peakOff(g,1) and peakOff(g,2) will be overwritten later on
        peakOff(g,2) = DataArray(l);      
        
        peakMin = l;
        
        for t = peakOn(g,1):peakOff(g,1)    %loop to find the end of the peak          
                        
            if DataArray(t) <=  peakMin %finds the minimum peakMin within the peak
                peakMin = DataArray(t);  
            end

%find all local minima within the peak which have to be below the trigger level "k(i)-schwellwert" and save them in peakMeanTrig
            
            if DataArray(t) <= DataArray(t-1)
                if DataArray(t+1) >= DataArray(t) 
                    if DataArray(t) < k(i)-schwellwert_off
                
                        h = h + 1;  %number of local minima within the peak
                        peakMeanTrig(h) = t; 
                        
                    end           
                end  
            end
        end
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if h < 2    %if there is only one local minimum within the peak then set the plateau of the peak "peakMean" to the minimum peakMin within the peak             
            peakMean = peakMin;
            spike = 1;
        else
            peakMean = min(DataArray(peakMeanTrig(1):peakMeanTrig(h)));  %if there are at least two local minima within the peak then set the plateau of the peak "peakMean" to average current value between the firs and last local minimum                     
            spike = 0;
        end
        

        peakSum(g,1) = 6.25e18 * params.sampleTime * (   (k(peakOn(g,1)) * (peakOff(g,1) - peakOn(g,1) + 1)) - sum(DataArray(peakOn(g,1):peakOff(g,1)))); %Area of the peak in units of the elementary charge
        peakSumm = peakSum(g,1); %variable to check whether the current peak has to be withdrawn or not
                
        peakOff(g,1) = peakMeanTrig(h); %end of the peak is set to the last (or only) local minimum within the peak
        peakOff(g,2) = DataArray(peakMeanTrig(h));
        
        peakWidth(g) = (peakOff(g,1) - peakOn(g,1))*params.sampleTime*1e6; %calculates the width of the peak: peakWidth
       
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        

        peakHeight(g) = (k(peakOn(g,1) - basePoints) - peakMean);  %the peak height is calculated from the plateau of the peak an the moving baseline value at the beginning of the peak (in units of pA)
     
      
        


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        

        peakScatter(g,1) = peakWidth(g);   %in peakScatter peak width and height are stored     
        peakScatter(g,2) = peakHeight(g);


        DataArray(peakOn(g,1):l) = k(peakOn(g,1)-basePoints); %set all current values within the peak to k(i) in order not make the reference peak finding algorithm in "FindPeakRef_07_os" possible
        
        i = i + f;

    end    
end %end of major loop of the peak finding algorithm

if g<2
    peakGap(g+1,2)=0;
    peakOn(g+1,:)=0;
    peakOff(g+1,:)=0;
    peakScatter(g+1,:)=0;
    peakSum(g+1,:)=0;
    if g<1
     peakGap(g+2,2)=0;
    peakOn(g+2,:)=0;
    peakOff(g+2,:)=0;
    peakScatter(g+2,:)=0;
    peakSum(g+2,:)=0;   
    end
end


results=struct('peakOn',peakOn,'peakOff',peakOff,'peakHeight',peakHeight,'peakWidth',peakWidth);


% not used: peakGap,peakSum

end
