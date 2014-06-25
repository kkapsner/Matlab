function assignment = track(tracker, p1, r1, p2, r2)
%     disp('start tracking...');
%     trackingTickId = tic();
    
    % reshape input to proper dimensions
    dim1 = numel(r1);
    dim2 = numel(r2);
    
    if (dim1 == 0 || dim2 == 0)
        assignment = zeros(0, 2);
        return
    end
    
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
    dists2 = dists2(distFilter) + (2*dr(distFilter)).^2;
    indexTranslator = find(distFilter);
    
%     if (isempty(dists2))
%         assignment = zeros(0, 2);
%         return
%     end
    
    if (isempty(dists2))
        assignment = zeros(0, 2);
        return;
    end

    % reshape matrix for sorting
    dists2 = reshape(dists2, [], 1);
    % sort distances
    [~, sortedIdx] = sort(dists2);
    % get sorted index pairs
    [sortedIdx1, sortedIdx2] = ind2sub2D([dim1, dim2], indexTranslator(sortedIdx));
    
%     % remove double indexes
%     [uniqueSortedIdx1, ia] = unique(sortedIdx1, 'stable');
%     uniqueSortedIdx2 = sortedIdx2(ia);
%     [uniqueSortedIdx2, ia] = unique(uniqueSortedIdx2, 'stable');
%     uniqueSortedIdx1 = uniqueSortedIdx1(ia);
%     
%     % create output
%     assignment = [uniqueSortedIdx1, uniqueSortedIdx2];

    % find double indices
    doubleIdx = orUnique([sortedIdx1, sortedIdx2]);
    uniqueIdx = doubleIdx == 0;
    assignment = [sortedIdx1(uniqueIdx), sortedIdx2(uniqueIdx)];

%     toc(trackingTickId);
end