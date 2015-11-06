function result = detectEvent(trace, settings)
%RANDOMPOINTS
    result = struct( ...
        'peakOn', [], ...
        'peakEnd', [], ...
        'peakOff', [], ...
        'upperBaseline', [], ...
        'lowerBaseline', [] ...
    );
    result.peakData = {};
    
    if (settings.useMedian)
        baseline = Filter.median1d(trace, settings.smoothWindowSize);
    else
        baseline = Filter.average(trace, settings.smoothWindowSize);
    end
    
    backwardBaseline = trace;
    backwardBaseline((1 + settings.basePoints):end) = ...
        baseline(1:(end - settings.basePoints));
    
    onThreshold  = settings.stdev * settings.th_mult_on;
    offThreshold = settings.stdev * settings.th_mult_off;
    
    backwardPoints = find(backwardBaseline - trace > onThreshold);
    
%     ax = Paper.Axes();
%     ax.plot(trace);
%     ax.plot(backwardBaseline);
%     ax.plot(backwardPoints, trace(backwardPoints), 'og');
    
    if (~isempty(backwardPoints))
        running = true;

        onIdx = 1;
        eventIdx = 1;
        while (running)
            peakOn = backwardPoints(onIdx);
            upperBaseline = backwardBaseline(peakOn);

            peakOff = peakOn - 1 + ...
                find( ...
                    upperBaseline - trace(peakOn:end) < offThreshold, ...
                    1, ...
                    'first' ...
                );

            if (isempty(peakOff))
                running = false;
            else
                % rewind peakOn
                peakOn = find(trace(1:peakOn) >= upperBaseline, 1, 'last');

                result.peakOn(eventIdx, :) = [peakOn, trace(peakOn)];
                result.peakOff(eventIdx, :) = [peakOff, trace(peakOff)];
                result.upperBaseline(eventIdx) = upperBaseline;

                peakTrace = trace(peakOn:peakOff);
                lowerBaseline = min( ...
                    quantile(peakTrace, settings.lowerBaselineQuantile), ...
                    mean(peakTrace) ...
                );

                peakEnd = peakOn - 1 + find( ...
                    peakTrace < lowerBaseline * settings.peakEndBaselineRatio + upperBaseline * (1 - settings.peakEndBaselineRatio), ...
                    1, ...
                    'last' ...
                );
                result.peakEnd(eventIdx, :) = [peakEnd, trace(peakEnd)];
                result.lowerBaseline(eventIdx) = lowerBaseline;

                result.peakData{eventIdx} = trace( ...
                    max(1, peakOn - 2*settings.basePoints):min(end, peakOff + 2*settings.basePoints) ...
                );

                eventIdx = eventIdx + 1;

                onIdx = find(backwardPoints > peakOff, 1, 'first');

                if (isempty(onIdx))
                    running = false;
                end
            end
        end
    end
    
    result.settings = copy(settings);
    result.domainData = numel(trace);
end

