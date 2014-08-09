function roi = segmentEnhancedBW(seg, image, stack)
    % SEGMENTENHANCEDBW performs the segmentation on the enhanced BW image
    %   ROI = SEGMENTER.SEGMENT(IMAGE, STACK)
    
    if (nargin < 3)
        stack = [];
    end

    imageSize = size(image);
    
    % get regions
    roiOrig = bwconncomp(image, 4);


    roi = ROI(roiOrig.PixelIdxList, imageSize, stack);
    roi = roi.select('Area', seg.areaRange(1), true, seg.areaRange(2), true);
    roi.initialiseProperties();
    if (isempty(roi))
        return;
    end

    if (seg.performWatershed)
        roiFilter = true(size(roi));
        % create index matrix
        idxImage = reshape(1:numel(image), imageSize);
        
        newRoi = [];
        for i = 1:numel(roi)
            r = roi(i);
            if (r.Eccentricity > seg.watershedEccentricityThreshold)
                subIdxImage = idxImage(r.minY:r.maxY, r.minX:r.maxX);

                rImage = r.Image;

%                         firstCol = 1:h;
%                         lastRow = ((2:(w-1))*h);
%                         rImage = rImage ~= imfill(rImage, [firstCol, lastRow, lastRow - h + 1, firstCol + (w-1)*h]', 8);
                rImage = rImage ~= Image.borderFill(rImage);
%                     rImage = ~imfill(rImage, 8, 'holes');

                dist = Filter.gauss2D(-bwdist(rImage), [1, 1] * seg.watershedFilter, 1);
                dist(rImage) = Inf;
                imageSeg = watershed(dist, 4);
                imageSeg(rImage) = 0;
                maxId = max(imageSeg(:));
                if (maxId > 1)
                    idxCell = cell(maxId, 1);
                    waterFilter = true(maxId, 1);
                    for j = 1:maxId
                        subRImage = imageSeg == j;
                        idxCell{j} = subIdxImage(subRImage);
                        area = sum(subRImage(:));
                        waterFilter(j) = area >= seg.areaRange(1) & area <= seg.areaRange(2);
                    end
                    if (sum(waterFilter(:)))
                        nRoi = ROI(idxCell(waterFilter), imageSize, stack);
                        nRoi.initialiseProperties();

                        if (numel(newRoi))
                            newRoi = [newRoi, nRoi];
                        else 
                            newRoi = nRoi;
                        end
                    end
                    roiFilter(i) = 0;
                end
            end
        end
        if (numel(newRoi))
            roi = [roi(roiFilter), newRoi];
        else 
            roi = roi(roiFilter);
        end
    end
    
    for filter = seg.filters
        roi = filter.filter(roi);
    end
end