function trOut = normaliseData(trIn, baselineSelect)
    if (nargin < 2)
        baselineSelect = false;
    end
    
    if (numel(trIn) > 1)
        trOut = Cary.normaliseData(trIn(1), baselineSelect);
        for i = 2:numel(trIn)
            trOut(i) = Cary.normaliseData(trIn(i), baselineSelect);
        end
    else
        if (baselineSelect)
            baseLineTr = trIn.guiSlice('select baseline region');
            baseLine = mean(baseLineTr.value);
            trOut = trIn.guiSlice('select data region');
            
            startTime = trOut.time(1);
            trOut = ShiftedTrace(trOut);
            trOut.timeShift = -startTime;
            trOut.valueShift = -baseLine;
        else
            filtered = trIn.filter(trIn.time(3) - trIn.time(1), 'median');
            noise = trIn.value - filtered.value;
            [~, idx] = max(noise);

            baseLine = mean(trIn.value(1:(idx - 1)));
            startTime = trIn.time(idx + 1);

            trOut = trIn.slice(startTime);
            trOut = ShiftedTrace(trOut);
            trOut.timeShift = -startTime;
            trOut.valueShift = -baseLine;
        end
        
        factorTrace = trOut.guiSlice('select normalisation region');
        
        factor = mean([factorTrace.value]);
        
        trOut = RescaledTrace(trOut);
        trOut.valueFactor = factor;
        trOut.isValueFactorInverse = true;
    end
    
end