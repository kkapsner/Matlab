function [xs, ys] = roiToPolyline(roi)
%POLYLINE.ROITOPOLYLINE Creates a polyline that approximates a ROI.
%   [XS, YS] = roiToPolyline(ROI)
%
% Idea is based on:
% @article{furferi2011unordered,
%   title={From unordered point cloud to weighted B-spline-A novel PCA-based method},
%   author={Furferi, Rocco and Governi, Lapo and Palai, Matteo and Volpe, Yary},
%   journal={Proceedings of the 2011 American conference on applied mathematics and the 5th WSEAS international conference on Computer engineering and applications},
%   pages={146--151},
%   year={2011},
%   publisher={World Scientific and Engineering Academy and Society (WSEAS)}
% }
% https://www.researchgate.net/publication/228913048_From_unordered_point_cloud_to_weighted_B-spline_a_novel_PCA-based_method
% 
% SEE ALSO: ROI, POLYLINE
    
%     rImage = Image.localConvexHull(roi.Image, 2);
    rImage = roi.Image;
    skel = bwmorph(rImage, 'thin', Inf);
    skel = Image.elongateEndPoints(skel, rImage, 4);
    [~, idx1, idx2] = Image.getMaxContour(skel);
    [skel, skelIdx] = Image.getShortestPath(skel, idx1, idx2);
    [skelY, skelX] = ind2sub2D(size(rImage), skelIdx);
    PixelIdxList = find(rImage);
    skelIdx = arrayfun(@(idx)find(idx == PixelIdxList, 1, 'first'), skelIdx);
    distMap = bwdist(skel, 'euclidean');
    distMap = distMap(bwperim(rImage));
    radius = max(quantile(distMap, 0.9) * 1.5, max(distMap));


    distImage = bwdistgeodesic(rImage, idx1, 'quasi-euclidean');
    distances = double(distImage(PixelIdxList));

%     ax = Paper.Axes();
%     Image.show(roi.toImage(), ax.ax);
%     ax.xlim([roi.minX - 5, roi.maxX + 5]);
%     ax.ylim([roi.minY - 5, roi.maxY + 5]);
%     ax2 = Paper.Axes();
    
    subX = roi.subX - roi.minX + 1;
    subY = roi.subY - roi.minY + 1;
    width = roi.maxX - roi.minX + 1;
    height = roi.maxY - roi.minY + 1;
    x = subX(1);
    y = subY(1);
    
%     ax.plot(x, y, '+r');
    considered = false(size(subX));
    
    % find a proper starting point
    [groupX, groupY] = getInRadius(x, y, radius);
    [centerX, centerY] = getCenter(groupX, groupY);
    while (abs(centerX - x) > 0.01 || abs(centerY - y) > 0.01)
        x = centerX;
        y = centerY;
%         ax.plot(x, y, '+g');
        considered = false(size(subX));
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
    
    xs = [leftLineX(end:-1:1), startX, rightLineX] + roi.minX - 1;
    ys = [leftLineY(end:-1:1), startY, rightLineY] + roi.minY - 1;
    
%     ax.plot(xs, ys);
    
    function [lineX, lineY] = getLine(x, y, lastX, lastY)
        lineX = zeros(1, roi.Area);
        lineY = zeros(1, roi.Area);
        lineIdx = 0;
        filter = getInRadiusFilter(x, y, radius);
        while (true)
            [groupX, groupY] = getInRadius(filter);
            if (~isempty(groupX))
                [centerX, centerY, alpha] = get2DDatasetRegression(groupX, groupY);
                lineIdx = lineIdx + 1;
                lineX(lineIdx) = centerX;
                lineY(lineIdx) = centerY;
                [nextX1, nextY1, nextX2, nextY2] = getIntersection(x, y, centerX, centerY, alpha, radius);
                filter1 = getInRadiusFilter(nextX1, nextY1, radius);
                filter2 = getInRadiusFilter(nextX2, nextY2, radius);
                unconsidered1 = sum(~considered(filter1));
                unconsidered2 = sum(~considered(filter2));
%                 debug(x, y, centerX, centerY, nextX1, nextY1, nextX2, nextY2, alpha)
                
                if (unconsidered1 + unconsidered2 == 0)
                    % reached end
                    in = 0;
                    out = 1;
                    dX = x - lastX;
                    dY = y - lastY;
                    length = sqrt(dX * dX + dY * dY);
                    threshold = 0.1 / length;
                    % restriction to image borders
                    if (dY < 0)
                        maxOut = (1 - centerY) / dY;
                    else
                        maxOut = (height - centerY) / dY;
                    end
                    if (dX < 0)
                        maxOut = min(maxOut, (1 - centerX) / dX);
                    else
                        maxOut = min(maxOut, (width - centerX) / dX);
                    end
                    
                    restricted = false;
                    if (out > maxOut)
                        out = maxOut;
                        restricted = true;
                    end
                    
                    
                    while (rImage(round(centerY + out * dY), round(centerX + out * dX)))
                        in = out;
                        if (restricted)
                            break
                        else
                            out = out + 1;
                        end
                        if (out > maxOut)
                            out = maxOut;
                            restricted = true;
                        end
                    end
                    while out - in > threshold
                        if (rImage(round(centerY + (in + out) / 2 * dY), round(centerX + (in + out) / 2 * dX)))
                            in = (in + out) / 2;
                        else
                            out = (in + out) / 2;
                        end
                    end
                    
                    
                    lineIdx = lineIdx + 1;
                    lineX(lineIdx) = centerX + in * dX;
                    lineY(lineIdx) = centerY + in * dY;
                    break;
                else
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
                        filter = filter1;
                    else
                        lastX = x;
                        lastY = y;
                        x = nextX2;
                        y = nextY2;
                        filter = filter2;
                    end
                end
            else
                break;
            end
        end
        
        lineX = lineX(1:lineIdx);
        lineY = lineY(1:lineIdx);
    end
    function filter = getInRadiusFilter(x, y, radius)
        filter = (subX - x) .^ 2 + (subY - y) .^ 2 <= radius * radius;
        dist = distances(filter);
        if (~isempty(dist))
            minDist = min(dist);
            maxDist = max(dist);
            if (maxDist - minDist > 2 * radius + 1)
                threshold = otsu(dist);
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
    function [xs, ys] = getInRadius(x, y, radius)
        if (nargin == 1)
            filter = x;
        else
            filter = getInRadiusFilter(x, y, radius);
        end
        considered(filter) = true;
        xs = subX(filter);
        ys = subY(filter);
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
        waitforbuttonpress();
        delete(deleteAble);
    end
end