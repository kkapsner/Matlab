% GETPERIMETER(IMAGE) computes the over all perimeter of an image
% 
%   GETPERIMETER estimates the mid-crack perimeter of all black/white
%   borders in the IMAGE. The outside of the image is asumed to be black.
%   The pure mid-crack perimeter is corrected by the Kulpa correction
%   factor (Comput. Graph. Image Process, 6:434-451, 1977).
%   This function best approximates the perimeter of circular shapes.
%   For best performance IMAGE should be a logical. Otherwise the IMAGE is
%   converted to a logical which takes quite a time.
%   
%   P = GETPERIMETER(IMAGE)
%   
%   See also: regionprops, bwperim, bwboundaries

% Equivalent MATLAB code:
% 
% function p = getPerimeter(image)
%     [h, w] = size(image);
%     
%     d = 1/sqrt(2);
%     p = 0;
%     for x = 1:w
%         for y = 1:h
%             if (image(y, x))
%                 if (~getPixel(y - 1, x))
%                     if (getPixel(y - 1, x - 1))
%                         p = p + d;
%                     elseif (getPixel(y, x - 1))
%                         p = p + 1;
%                     else
%                         p = p + d;
%                     end
%                     
%                     if (getPixel(y - 1, x + 1))
%                         p = p + d;
%                     elseif (getPixel(y, x + 1))
%                         p = p + 1;
%                     else
%                         p = p + d;
%                     end
%                 end
%                 
%                 if (~getPixel(y + 1, x))
%                     if (getPixel(y + 1, x - 1))
%                         p = p + d;
%                     elseif (getPixel(y, x - 1))
%                         p = p + 1;
%                     else
%                         p = p + d;
%                     end
%                     
%                     if (getPixel(y + 1, x + 1))
%                         p = p + d;
%                     elseif (getPixel(y, x + 1))
%                         p = p + 1;
%                     else
%                         p = p + d;
%                     end
%                 end
%                 
%                 if (~getPixel(y, x - 1))
%                     if (getPixel(y - 1, x - 1))
%                         p = p + d;
%                     elseif (getPixel(y - 1, x))
%                         p = p + 1;
%                     else
%                         p = p + d;
%                     end
%                     
%                     if (getPixel(y + 1, x - 1))
%                         p = p + d;
%                     elseif (getPixel(y + 1, x))
%                         p = p + 1;
%                     else
%                         p = p + d;
%                     end
%                 end
%                 
%                 if (~getPixel(y, x + 1))
%                     if (getPixel(y - 1, x + 1))
%                         p = p + d;
%                     elseif (getPixel(y - 1, x))
%                         p = p + 1;
%                     else
%                         p = p + d;
%                     end
%                     
%                     if (getPixel(y + 1, x + 1))
%                         p = p + d;
%                     elseif (getPixel(y + 1, x))
%                         p = p + 1;
%                     else
%                         p = p + d;
%                     end
%                 end
%             end
%         end
%     end
%     
%     
%     
%     function p = getPixel(x, y)
%         if (x >= 0 && x <= w && y >= 0 && y <= h)
%             p = image(y, x);
%         else
%             p = 0;
%         end
%     end
%     p = p/2 * pi/8*(1+sqrt(2));
% end