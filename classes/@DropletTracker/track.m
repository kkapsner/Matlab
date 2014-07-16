function assignment = track(tracker, p1, r1, p2, r2)
%TRACKER.TRACK tracks droplets between frames
%
%   ASSIGMENT = TRACKER.TRACK(P1, R1, P2, R2)
%       Droplets with positions P1 (DIM1x2) and radii R1
%       (DIM1x1) will be tracked on droplets with positions
%       P2 (DIM2x2) and radii R2 (DIM2x2). The assigment
%       matrix ASSIGMENTS (Nx2) contains all N assigments
%       where the first column contains the indices of the
%       first droplet set and the second column the indices
%       of the second set. The relation N <= min(DIM1, DIM2)
%       always hold true.
    
    dim1 = numel(r1);
    dim2 = numel(r2);
    
    if (dim1 == 0 || dim2 == 0)
        % one droplet set contains no droplets
        assignment = zeros(0, 2);
        return
    end
    
    % reshape input to proper dimensions
    x1 = reshape(p1(:, 1), dim1, 1);
    y1 = reshape(p1(:, 2), dim1, 1);
    r1 = reshape(r1, dim1, 1);
    x2 = reshape(p2(:, 1), 1, dim2);
    y2 = reshape(p2(:, 2), 1, dim2);
    r2 = reshape(r2, 1, dim2);
    
    % vectors for matrix generation
    ones1 = ones(dim1, 1);
    ones2 = ones(1, dim2);
    
    % create radii matrices
    r1 = r1 * ones2;
    r2 = ones1 * r2;
    
    % calculate distances
    dists2 = ...
        (x1 * ones2 - ones1 * x2).^2 + ...
        (y1 * ones2 - ones1 * y2).^2;
    
    % calculate radii distances and sums
    dr = abs(r1 - r2);
    sr = r1 + r2 + tracker.maxBorderDistance;
    
    % filter too big distances and too big radii changes
    distFilter = ...
        dists2 <= sr.^2 & ...
        dr < max( ...
            tracker.minMaxRadiusChange, ...
            tracker.maxRadiusChange * r1 ...
        );
    
    % create metric
    dists2 = dists2(distFilter) + (2*dr(distFilter)).^2;
    indexTranslator = find(distFilter);
    
    if (isempty(dists2))
        % no droplet pair holds the threshold constrains
        assignment = zeros(0, 2);
        return;
    end

    % reshape matrix for sorting
    dists2 = reshape(dists2, [], 1);
    % sort distances
    [~, sortedIdx] = sort(dists2);
    % get sorted index pairs
    [sortedIdx1, sortedIdx2] = ind2sub2D( ...
        [dim1, dim2], ...
        indexTranslator(sortedIdx) ...
    );

    % find double indices
    doubleIdx = orUnique([sortedIdx1, sortedIdx2]);
    uniqueIdx = doubleIdx == 0;
    % return only the unique
    assignment = ...
        [sortedIdx1(uniqueIdx), sortedIdx2(uniqueIdx)];

end