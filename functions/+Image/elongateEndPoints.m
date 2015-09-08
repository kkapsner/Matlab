function elongated = elongateEndPoints(skel, mask, hops)
%IMAGE.ELONGATEENDPOINTS enlongates the end points of a skeleton
% For this enlongation the end points of the skeleton are selected and half
% lines starting at these points are added. The slope and direction of
% theses half lines are specified by hopping to the nth next neighbour of
% the end point. If the hopping algorithm encounters a branch point the
% hopping stops and the branch point is used as the reference point.
%
%   ELONGATED = Image.elongateEndPoints(SKEL, MASK) creates an elongated
%       version of skeleton SKEL using MASK to specifiy the regions where
%       the half lines can be placed.
%   ... = Image.elongateEndPoints(..., HOPS) Specifies the number of hops
%       to perform from the end point to get the slope (default 4).
%
% SEE ALSO: Image.getHalfLineCoordinates, bwmorph
    if (nargin < 3)
        hops = 4;
    end
    
    imSize = size(skel);
    elongated = skel;
    endpoints = bwmorph(skel, 'endpoints') & skel; %bug in endpoints...
    branchpoints = bwmorph(skel, 'branchpoints');
    
    [endY, endX] = find(endpoints);
    
    for i = 1:numel(endX)
        x = endX(i);
        y = endY(i);
        
        [dx, dy] = getSlope(skel, x, y, hops);
        
        if (dx ~= 0 || dy ~= 0)
            [xC, yC] = Image.getHalfLineCoordinates(x, y, -dx, -dy, imSize);
            ind = sub2ind2D(imSize, yC, xC);
            lastWhite = find(~mask(ind), 1, 'first') - 1;
            if (~isempty(lastWhite))
                ind = ind(1:lastWhite);
            end
            elongated(ind) = true;
        end
    end
    
    function [dx, dy] = getSlope(skel, x, y, hops)
        if (hops > 0)
            skel(y, x) = false;
            [dx, dy, isBranch] = getNeighbours(skel, x, y);
            switch (numel(dx))
                case 0
                    dx = 0;
                    dy = 0;
                    return;
                case 1
                otherwise
                    assert(sum(isBranch) == 1, 'Image is not a skeleton.');
                    branchIdx = find(isBranch);
                    dx = dx(branchIdx);
                    dy = dy(branchIdx);
                    isBranch = true;
            end
            if (hops > 1 && ~isBranch)
                [nextDx, nextDy] = getSlope(skel, x + dx, y + dy, hops - 1);
                dx = dx + nextDx;
                dy = dy + nextDy;
            end
        else
            dx = 0;
            dy = 0;
        end
    end
    function [dx, dy, isBranch] = getNeighbours(skel, x, y)
        neighbourhood = false(3);
        branches = false(3);
        found = false;
        if (x > 1 && skel(y, x - 1))
            neighbourhood(2, 2 - 1) = true;
            branches(2, 2 - 1) = branchpoints(y, x - 1);
            found = true;
        end
        if (y > 1 && skel(y - 1, x))
            neighbourhood(2 - 1, 2) = true;
            branches(2 - 1, 2) = branchpoints(y - 1, x);
            found = true;
        end
        if (x < imSize(2) && skel(y, x + 1))
            neighbourhood(2, 2 + 1) = true;
            branches(2, 2 + 1) = branchpoints(y, x + 1);
            found = true;
        end
        if (y < imSize(1) && skel(y + 1, x))
            neighbourhood(2 + 1, 2) = true;
            branches(2 + 1, 2) = branchpoints(y + 1, x);
            found = true;
        end
        
        if (~found)
            if (x > 1 && y > 1 && skel(y - 1, x - 1))
                neighbourhood(2 - 1, 2 - 1) = true;
                branches(2 - 1, 2 - 1) = branchpoints(y - 1, x - 1);
            end
            if (x < imSize(2) && y > 1 && skel(y - 1, x + 1))
                neighbourhood(2 - 1, 2 + 1) = true;
                branches(2 - 1, 2 + 1) = branchpoints(y - 1, x + 1);
            end
            if (x > 1 && y < imSize(1) && skel(y + 1, x - 1))
                neighbourhood(2 + 1, 2 - 1) = true;
                branches(2 + 1, 2 - 1) = branchpoints(y + 1, x - 1);
            end
            if (x < imSize(2) && y < imSize(1) && skel(y + 1, x + 1))
                neighbourhood(2 + 1, 2 + 1) = true;
                branches(2 + 1, 2 + 1) = branchpoints(y + 1, x + 1);
            end
        end
        [dy, dx] = find(neighbourhood);
        isBranch = branches(sub2ind2D([3, 3], dy, dx));
        dx = dx - 2;
        dy = dy - 2;
    end
end