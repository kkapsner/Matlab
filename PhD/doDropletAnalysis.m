function droplets = doDropletAnalysis(segmentStack, intensityStacks)
    tic();
    
    %% calculate global properties
    stackSize = segmentStack.size;
    numIntensityStacks = numel(intensityStacks);
    
    %% settings
    verbose = true;
    numIntensityPoints = 5;
    
    %% create segmenter
    segmenter = Segmenter();
    segmenter.areaRange = [3, 60] .^2 * pi;
    segmenter.removeConcave = false;
    segmenter.performThinning = true;
    segmenter.performWatershed = true;
    segmenter.performBridging = true;
    
    %% create tracker
    tracker = DropletTracker(stackSize, numIntensityStacks);
    tracker.maxBorderDistance = 5;
    tracker.maxRadiusChange = 0.2;
    tracker.minMaxRadiusChange = 2;
    
    
    output('process first image...');
    output(' ... read tracking image');
    segmentImage = segmentStack.getImage(1);
    output(' ... get ROIs');
    roi = segmenter.segment(segmentImage);
    output(' ... read intensity images');
    for stackIndex = 1:numIntensityStacks
        intensityImage = intensityStacks(stackIndex).getImage(1);
        for roiIndex = 1:numel(roi)
            roi(roiIndex).Intensity(stackIndex) = getIntensityProperties(roi(roiIndex), intensityImage);
        end
    end
    output(' ... initialise tracker');
    tracker.addFirstDroplets(roi);
    
    output([char(10) 'start stack' char(10)]);
    lastLength = 0;
    for imageIndex = 2:stackSize
        lastLength = outputStepInfo(imageIndex - 1, lastLength);
        
        segmentImage = segmentStack.getImage(imageIndex);
        roi = segmenter.segment(segmentImage);
        
        for stackIndex = 1:numIntensityStacks
            intensityImage = intensityStacks(stackIndex).getImage(imageIndex);
            for roiIndex = 1:numel(roi)
                roi(roiIndex).Intensity(stackIndex) = getIntensityProperties(roi(roiIndex), intensityImage);
            end
        end

        tracker.addDroplets(roi);
    end
    
    outputStepInfo(imageIndex, lastLength);
    output([char(10), 'tracking finished']);
    
    droplets = tracker.droplets;
    
    function lastLength = outputStepInfo(imageIndex, lastLength)
        ellapsedTime = toc();
        ellapsedMin = floor(ellapsedTime / 60);
        ellapsedSec = floor(ellapsedTime - ellapsedMin * 60);
        
        remaining = (stackSize - imageIndex) * ellapsedTime / imageIndex;
        remainingMin = floor(remaining / 60);
        remainingSec = floor(remaining - remainingMin * 60);
        str = sprintf( ...
            [repmat(8, 1, lastLength), ...
            '%02.2f%% complete (%i of %i)\n' ...
            'droplets: %i (%i active)\n'...
            'Time: % 2i:%02i min, Remaining: % 2i:%02i min (estimated)'], ...
            imageIndex/stackSize*100, ...
            imageIndex, stackSize, ...
            numel(tracker.droplets), ...
            numel(tracker.currentDropletIndices), ...
            ellapsedMin, ...
            ellapsedSec, ...
            remainingMin, ...
            remainingSec ...
        );
        disp(str);
        lastLength = numel(str) + 1 - lastLength;
    end
    
    function properties = getIntensityProperties(roi, image)
        intensityValues = double(image(roi.PixelIdxList));
        brightValues = im2bw(intensityValues, graythresh(intensityValues));
%         properties = struct( ...
%             'sum', sum(intensityValues), ...
%             'min', sum(mink(intensityValues, numIntensityPoints) / numIntensityPoints), ...
%             'max', sum(maxk(intensityValues, numIntensityPoints) / numIntensityPoints)...
%         );
        properties.sum = sum(intensityValues);
        properties.min = sum(mink(intensityValues, numIntensityPoints) / numIntensityPoints);
        properties.max = sum(maxk(intensityValues, numIntensityPoints) / numIntensityPoints);
        
        properties.brightArea = sum(brightValues);
        properties.brightSum = sum(intensityValues(brightValues));
    end

    function output(str)
        if (verbose)
            disp(str);
        end
    end
end
