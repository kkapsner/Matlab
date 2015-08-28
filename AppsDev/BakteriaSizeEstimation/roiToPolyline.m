function [xs, ys] = roiToPolyline(roi)
%ROITOPOLYLINE Creates a polyline that approximates a ROI.
%   [XS, YS] = roiToPolyline(ROI)
%
% SEE ALSO: ROI
    
%     rImage = Image.localConvexHull(roi.Image, 2);
    rImage = roi.toImage();
    skel = bwmorph(rImage, 'thin', Inf);
    skel = Image.elongateEndPoints(skel, rImage, 4);
    [~, idx1, idx2] = Image.getMaxContour(skel);
    [skel, skelIdx] = Image.getShortestPath(skel, idx1, idx2);
    [skelY, skelX] = ind2sub2D(size(rImage), skelIdx);
    skelIdx = arrayfun(@(idx)find(idx == roi.PixelIdxList), skelIdx);
    distMap = rImage .* bwdist(skel, 'euclidean');
    radius = max(distMap(:));


    distImage = bwdistgeodesic(rImage, idx1, 'quasi-euclidean');
    distances = double(distImage(roi.PixelIdxList));

%     ax = Paper.Axes();
%     ax2 = Paper.Axes();
%     Image.show(roi.toImage(), ax.ax);
%     ax.xlim([roi.minX - 5, roi.maxX + 5]);
%     ax.ylim([roi.minY - 5, roi.maxY + 5]);
    
    x = roi.subX(1);
    y = roi.subY(1);
    
%     ax.plot(x, y, '+r');
    considered = false(size(roi.subX));
    
    % find a proper starting point
    [groupX, groupY] = getInRadius(x, y, radius);
    [centerX, centerY] = getCenter(groupX, groupY);
    while (abs(centerX - x) > 0.1 || abs(centerY - y) > 0.1)
        x = centerX;
        y = centerY;
%         ax.plot(x, y, '+g');
        considered = false(size(roi.subX));
        [groupX, groupY] = getInRadius(x, y, radius);
        [centerX, centerY] = getCenter(groupX, groupY);
    end
    
    startX = centerX;
    startY = centerY;
    
%     ax.plot(centerX, centerY, '+b');
    
    % get starting points of the two lines
    [centerX, centerY, alpha] = get2DDatasetRegression(groupX, groupY);
    [leftX, leftY, rightX, rightY] = getIntersection(x, y, centerX, centerY, alpha, radius);
%     debug(x, y, centerX, centerY, leftX, leftY, rightX, rightY, alpha)
    
    [leftLineX, leftLineY] = getLine(leftX, leftY, startX, startY);
    [rightLineX, rightLineY] = getLine(rightX, rightY, startX, startY);
    
    xs = [leftLineX(end:-1:1), startX, rightLineX];
    ys = [leftLineY(end:-1:1), startY, rightLineY];
    
%     ax.plot(xs, ys);
    
    function [lineX, lineY] = getLine(x, y, lastX, lastY)
        lineX = [];
        lineY = [];
        unconsidered = true;
        while (unconsidered)
            [groupX, groupY, unconsidered] = getInRadius(x, y, radius);
            if (~isempty(groupX))
                [centerX, centerY, alpha] = get2DDatasetRegression(groupX, groupY);
                lineX(end + 1) = centerX;
                lineY(end + 1) = centerY;
                [nextX1, nextY1, nextX2, nextY2] = getIntersection(x, y, centerX, centerY, alpha, radius);
                filter1 = getInRadiusFilter(nextX1, nextY1, radius);
                filter2 = getInRadiusFilter(nextX2, nextY2, radius);
                unconsidered1 = sum(~considered(filter1));
                unconsidered2 = sum(~considered(filter2));
%                 debug(x, y, centerX, centerY, nextX1, nextY1, nextX2, nextY2, alpha)

                if ( ...
                    unconsidered1 > unconsidered2 || ...
                    ( ...
                        unconsidered1 == unconsidered2 && ...
                        (nextX1 - lastX)^2 + (nextY1 - lastY)^2 > (nextX2 - lastX)^2 + (nextY2 - lastY)^2 ...
                    ) ...
                )
                    lastX = x;
                    lastY = y;
                    x = nextX1;
                    y = nextY1;
                else
                    lastX = x;
                    lastY = y;
                    x = nextX2;
                    y = nextY2;
                end
            end
        end
    end
    function filter = getInRadiusFilter(x, y, radius, pdfOutput)
        filter = (roi.subX - x) .^ 2 + (roi.subY - y) .^ 2 <= radius * radius;
        dist = distances(filter);
        if (~isempty(dist))
            [minDist, maxDist] = minmax(dist);
            if (maxDist - minDist > 2 * radius + 1)
                threshold = minDist + maxDist * graythresh((dist - minDist) / (maxDist - minDist));
%                 if (nargin > 3)
%                     ax2.clear();
%                     ax2.plot(1:numel(dist), sort(dist));
%                     ax2.plot([1, numel(dist)], [1, 1] * threshold);
%                     waitforbuttonpress();
%                 end
                [~, nextSkelIdx] = Polyline.getDistance(skelX, skelY, x, y);
                skelDist = distances(skelIdx(round(nextSkelIdx)));
                filterIdx = find(filter);
                if (abs(maxDist - skelDist) > abs(minDist - skelDist))
                    % use lower population
                    filter(filterIdx(dist > threshold)) = false;
                else
                    % use upper population
                    filter(filterIdx(dist < threshold)) = false;
                end
            end
        end
    end
    function [xs, ys, unconsidered] = getInRadius(x, y, radius)
        filter = getInRadiusFilter(x, y, radius, true);
        unconsidered = any(filter) && ~all(considered(filter));
        considered(filter) = true;
        xs = roi.subX(filter);
        ys = roi.subY(filter);
    end
    function [x, y] = getCenter(xs, ys)
        x = mean(xs);
        y = mean(ys);
    end
    function [x1, y1, x2, y2] = getIntersection(xr, yr, xg, yg, alpha, r)
        if (abs(tan(alpha)) > 1)
            [y1, x1, y2, x2] = getIntersection2(yr, xr, yg, xg, pi / 2 - alpha, r);
        else
            [x1, y1, x2, y2] = getIntersection2(xr, yr, xg, yg, alpha, r);
        end
    end
    function [x1, y1, x2, y2] = getIntersection2(xr, yr, xg, yg, alpha, r)
        % slope: y = a*x + b
        a = tan(alpha);
        b = yg - a*xg;
        %circle:
        %   (x - xr)^2 + (y - yr)^2 - r = 0
        %   (x - xr)^2 + (a*x + b - yr)^2 - r^2 = 0
        %   x^2 - 2*x*xr + xr^2 + a^2*x^2 + b^2 + yr^2 + 2*a*b*x - 2*a*x*yr - 2*b*yr - r^2 = 0
        %   (1 + a^2) * x^2 + (- 2*xr + 2*a*b - 2*a*yr)*x + xr^2 + b^2 + yr^2 - 2*b*yr - r^2 = 0
        A = 1 + a*a;
        B = - 2*xr + 2*a*b - 2*a*yr;
        C = xr^2 + b^2 + yr^2 - 2*b*yr - r^2;
        
%         c = cos(alpha);
%         if (c == 0)
%             x1 = xg;
%             x2 = xg;
%             y1 = sqrt(r*r - (xg - xr)^2);
%             y2 = yr - y1;
%             y1 = yr + y1;
%         else
%             t = tan(alpha);
%             beta = yg - t*xg - yr;
%             
%             A = 1 + t*t;
%             B = 2*beta*t - 2*xr;
%             C = xr*xr + beta*beta - r*r;
            wurzel = sqrt(B*B - 4*A*C);
            x1 = (-B + wurzel ) / (2 * A);
            x2 = (-B - wurzel ) / (2 * A);
%             y1 = t * x1 + beta + yr;
%             y2 = t * x2 + beta + yr;
            y1 = a * x1 + b;
            y2 = a * x2 + b;
%         end
    end

    function debug(x, y, centerX, centerY, nextX1, nextY1, nextX2, nextY2, alpha)
        phi = 0:0.1:(2.1*pi);
        ax.plot(centerX, centerY, '+');
        deleteAble = [
            ax.plot(x + radius * cos(phi), y + radius * sin(phi), '-g'),
            ax.plot(centerX + (-50:0.1:50), centerY + (-50:0.1:50) * tan(alpha), '--'),
            ax.plot([nextX1, nextX2], [nextY1, nextY2], 'o')
        ];
%         waitforbuttonpress();
        delete(deleteAble);
    end
end