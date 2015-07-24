function path = getShortestPath(mask, idx1, idx2, conn)
%IMAGE.GETSHORTESTPATH draws the shortest path between two pixels
%
%   PATH = Image.getShortestPath(MASK, IDX1, IDX2) returns the image of the
%       path between the pixels with index IDX1 and IDX2 using MASK as a
%       mask for pixels that can be used. If there is no connection between
%       the two pixels an error is thrown.
%   ... = Image.getShortestPath(..., CONN) specifies if an 4 or 8
%       connectivity should be used (default 8)
%
% SEE ALSO: IMAGE.GETMAXCONTOUR
    if (nargin < 4)
        conn = 8;
    end
    maskSize = size(mask);
    path = false(maskSize);
    path(idx1) = true;
    
    backtracks = zeros(maskSize);
    
    while (~path(idx2) && any(path(:)))
        idxs = find(path);
        for idx = idxs(:)'
            [y, x] = ind2sub2D(maskSize, idx);
            path(idx) = false;
            setBacktrack(y, x - 1, idx);
            setBacktrack(y, x + 1, idx);
            setBacktrack(y - 1, x, idx);
            setBacktrack(y + 1, x, idx);
        end
        if (conn == 8)
            for idx = idxs(:)'
                [y, x] = ind2sub2D(maskSize, idx);
                setBacktrack(y - 1, x - 1, idx);
                setBacktrack(y + 1, x - 1, idx);
                setBacktrack(y - 1, x + 1, idx);
                setBacktrack(y + 1, x + 1, idx);
            end
        end
    end
    assert(path(idx2), 'Image:getShortestPath:notConnected', 'Points are not connected.');
    
    path = false(maskSize);
    idx = idx2;
    while (idx ~= idx1)
        path(idx) = true;
        idx = backtracks(idx);
    end
    path(idx) = true;
    
    function setBacktrack(y, x, idx)
        if (y > 0 && y <= maskSize(1) && x > 0 && x <= maskSize(2) && mask(y, x) && backtracks(y, x) == 0)
            backtracks(y, x) = idx;
            path(y, x) = true;
        end
    end
end