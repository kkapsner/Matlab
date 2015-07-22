function [dist, idx, newIdx] = getMaxContour(image, method)
%IMAGE.GETMAXCONTOUR specifies the longest connection in a bw image
%
% The image has to contain only one connected white region. Otherwise the
% result is not reliable.
%
%   DIST = Image.getMaxContour(IMAGE)
%   DIST = Image.getMaxContour(..., METHOD) specifies the method by which
%       the distances should be computed. Possible values are 'cityblock',
%       'chessboard' and 'quasi-euclidean' (default).
%   [DIST, IDX1, IDX2] = Image.getMaxContour(...) also returns the indices
%       of the endpoints.
%
% SEE ALSO: IMAGE.GETSHORTESTPATH, bwdistgeodesic
    if (nargin < 2)
        method = 'quasi-euclidean';
    end
    dist = -1;
    newDist = 0;
    newIdx = find(image, 1, 'first');
    if (~isempty(newIdx))
        while (newDist > dist)
            idx = newIdx;
            dist = newDist;
            distImage = bwdistgeodesic(image, idx, method);
            [newDist, newIdx] = max(distImage(:));
        end
    end
end