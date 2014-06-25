function d = Droplet(this, dataSize, currentIndex)
    if (nargin < 3)
        currentIndex = 1;
    end
    
    numDroplets = numel(this);
    if (numDroplets)
        d = Droplet(dataSize, numDroplets, numel(this(1).Intensity));
        
        for i = 1:numDroplets
            roi = this(i);
            d(i).setFromROI(roi, currentIndex);
            d(i).stacks = {roi.segmentationStack, roi.intensityStacks{:}};
        end
    else
        d = Droplet.empty();
    end
end