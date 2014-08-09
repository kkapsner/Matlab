function roi = segment(this, image, stack)
    % SEGMENT performs the segmentation
    %   ROI = SEGMENTER.SEGMENT(IMAGE)
    
    if (nargin < 3)
        stack = [];
    end
    
%     [minV, maxV] = minmax(image(:));
%     image = (image - minV) / (maxV - minV);
    
    if (this.computeThreshold)
        thres = graythresh(image);
    else
        thres = this.threshold;
    end


    % create bw image
    binImage = im2bw(image, thres);

    binImage = this.enhanceBW(binImage);
    
    roi = this.segmentEnhancedBW(binImage, stack);
end