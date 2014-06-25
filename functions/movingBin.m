function [bins, centers] = movingBin(data, stepSize, binSize)
    [dataMin, dataMax] = minmax(data);
    
    if (binSize < stepSize)
        warning( ...
            'movinBin:badSizes', ...
            'Bin size should be greater than step size' ...
        );
    end
    
    centers = (dataMin:stepSize:dataMax)' + binSize / 2;
    
    bins = false(numel(centers), numel(data));
    
    for i = 1:numel(centers)
        bins(i, :) = ...
            (data >= centers(i) - binSize / 2) & ...
            (data < centers(i) + binSize / 2);
    end
end