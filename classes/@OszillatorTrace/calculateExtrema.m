function calculateExtrema(oscTrace)
%CALCULATEEXTREMA

    if (numel(oscTrace) > 1)
        for i=1:numel(oscTrace)
            oscTrace(i).calculateExtrema();
        end
        return
    end
    oscTrace.resetExtrema();

    value = {1};
    peakIndex = 1;
    fipv = oscTrace.filteredValue;
    dataSize = numel(oscTrace.filteredValue);
    if (isnumeric(oscTrace.amplitudeThreshold))
        aThreshold = oscTrace.amplitudeThreshold;
    elseif (isa(oscTrace.amplitudeThreshold, 'function_handle'))
        aThreshold = oscTrace.amplitudeThreshold(oscTrace);
    else
        error('OszillatorTrace:calculatePeaks:wrongAmplitudeThreshold', ...
            'Amplitude threshold is no numeric nor function handle' ...
        );
    end
    aThreshold = aThreshold * 2;

    s = sign(fipv);
    currentSign = s(1);
    lastMaxValue = 0;
    lastWasTooSmall = true;
    maxValue = 0;
    maxPosition = 0;
    for i = 1:dataSize
        if (fipv(i) * currentSign >= maxValue)
            maxValue = fipv(i) * currentSign;
            maxPosition = i;
        end

        if ((s(i) ~= 0 && s(i) ~= currentSign) || i == dataSize)
            maxValue = maxValue * currentSign;
            if (lastWasTooSmall)
                if (maxValue * currentSign > fipv(value{peakIndex}) * currentSign)
                    value{peakIndex} = maxPosition;
                end
                lastMaxValue = fipv(value{peakIndex});
                lastWasTooSmall = false;
            else
                if (abs(maxValue - lastMaxValue) < aThreshold)
                    lastMaxValue = fipv(value{peakIndex});
                    lastWasTooSmall = true;
                else
                    peakIndex = peakIndex + 1;
                    value{peakIndex} = maxPosition;
                    lastMaxValue = maxValue;
                end
            end
            currentSign = s(i);
            maxValue = fipv(i) * currentSign;
            maxPosition = i;
        end

    end
    oscTrace.peaks = cell2mat(value);

end

