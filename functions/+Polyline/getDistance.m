function [dist, idx] = getDistance(polyXO, polyYO, xs, ys)
%POLYLINE.GETDISTANCE computes the distance between a polyline and a point
%
%   DIST = Polyline.getDistance(POLYX, POLYY, X, Y) calculates the minimal
%       distance between the point (X, Y) and the polyline defined by POLYX
%       and POLYY. If X and Y are not scalar the distance for every point
%       defined by the entries of X and Y.
%   [DIST, IDX] = Polyline.getDistance(...) also returns the index of the
%       nearest point on the polyline. Usually IDX is NOT an integral
%       number as the point lies on one of the lines. That means if the
%       nearest point lies half the way between the second and the third
%       knot of the polyline IDX will be 2.5.
%
% SEE ALSO: getline

    dataPoints = numel(xs);
    
    dist = zeros(size(xs));
    idx = zeros(size(xs));
    
    % discribe segments
    diffX = diff(polyXO);
    diffY = diff(polyYO);

    length = sqrt(diffX .^ 2 + diffY .^ 2);

    % direction vector
    dirX = diffX ./ length;
    dirY = diffY ./ length;
    % normal vector on line is (-dirY, dirX)
    
    for i = 1:dataPoints
        x = xs(i);
        y = ys(i);
    
        % shift origin to the point of interest
        polyX = polyXO - x;
        polyY = polyYO - y;
        
        % new offsets
        offsetX = polyX(1:(end-1));
        offsetY = polyY(1:(end-1));

        % minimal distance to the segment ends
        [pointDist, pointIdx] = min(polyX .^ 2 + polyY .^ 2);


        % calculate distances via normal vector
        distances = abs(offsetY .* dirX - offsetX .* dirY);

        % get parameter on line
        t = -(dirX .* offsetX + dirY .* offsetY) ./ length;

        filter = t >= 0 & t <= 1;

        distances(~filter) = Inf;

        [distSeg, distIdx] = min(distances);
        distIdx = distIdx + t(distIdx);

        if (isempty(distSeg) || ~isfinite(distSeg) ||distSeg > pointDist)
            dist(i) = pointDist;
            idx(i) = pointIdx;
        else
            dist(i) = distSeg;
            idx(i) = distIdx;
        end
    end
end