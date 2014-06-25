function hull = convexHull(image)
%CONVEXHULL 
    [y, x] = find(image);
    
    hullIdx = convhull(x, y);
    
    hullX = x(hullIdx);
    hullY = y(hullIdx);
    
    hull = Image.convexHull_cpp(double(image), hullX - 1, hullY - 1);
    
%     minX = min(hullX);
%     maxX = max(hullX);
%     
%     minY = min(hullY);
%     maxY = max(hullY);
%     
%     hullSegments = numel(hullIdx);
    
%     hull = zeros(size(image));
%     
%     for x = minX:maxX
%         for y = minY:maxY
%             hull(y, x) = 1;
%             if (~image(y, x))
%                 for i = 1:hullSegments
%                     if ...
%                             (x - hullX(i)) * (hullY(i) - hullY(i + 1)) + ...
%                             (y - hullY(i)) * (hullX(i + 1) - hullX(i)) < 0
%                         hull(y, x) = 0;
%                         break;
%                     end
%                 end
%             end
%         end
%     end

end

