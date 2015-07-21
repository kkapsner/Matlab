function hull = convexHull(image)
%CONVEXHULL 
    [y, x] = find(image);
    
    numPixels = numel(x);
    
    if (numPixels < 2)
        hull = double(image);
    else
        colinear = false;
        if (numPixels == 2)
            colinear = true;
        else
            try
                hullIdx = convhull(x, y);

                hullX = x(hullIdx);
                hullY = y(hullIdx);

                hull = Image.convexHull_cpp(double(image), hullX - 1, hullY - 1);
            catch
                colinear = true;
            end
        end
        
        if (colinear)
            hull = double(image);
            imageSize = size(image);
            for i = 2:numel(x)
                dx = x(i) - x(i - 1);
                dy = y(i) - y(i - 1);
                if (abs(dx) > abs(dy))
                    xPos = x(i - 1):sign(dx):x(i);
                    yPos = round(interp1(x([i, i - 1]), y([i, i - 1]), xPos, 'linear'));
                else
                    yPos = y(i - 1):sign(dy):y(i);
                    xPos = round(interp1(y([i, i - 1]), x([i, i - 1]), yPos, 'linear'));
                end
                hull(sub2ind2D(imageSize, yPos, xPos)) = 1;
            end
        end
    end
    
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

