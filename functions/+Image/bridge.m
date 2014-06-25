% BRIDGE performes a two pixel gap bridging
%
%   

% function imageOut = bridge(image)
%     [h, w] = size(image);
%     imageOut = image;
%     for x = 3:w-2
%         l = (x-1)*h;
%         for y = 3:h-2
%             idx = l + y;
%             if (~image(idx)) %(~image(y, x))
%                 h_ = image(idx - 1 - h);%image(y-1, x-1);
%                 a = image(idx - 1) || image(idx - 2);%image(y-1, x)||image(y-2, x);
%                 b = image(idx - 1 + h);%image(y-1, x+1);
%                 g = image(idx - 2*h) || image(idx - h);%image(y, x-2)|| image(y, x-1);
%                 c = image(idx + h) || image(idx + 2*h);%image(y, x+1)|| image(y, x+2);
%                 f = image(idx + 1 - h);%image(y+1, x-1);
%                 e = image(idx + 1) || image(idx + 2);%image(y+1, x) || image(y+2, x);
%                 d = image(idx + 1 + h);%image(y+1, x+1);
%                 imageOut(idx) = (...imageOut(y, x) = (...
%                     (xor(a, c) || (b && ~a)) + ... getChangeNumber(a, b, c) + ...
%                     (xor(c, e) || (d && ~c)) + ... getChangeNumber(c, d, e) + ...
%                     (xor(e, g) || (f && ~e)) + ... getChangeNumber(e, f, g) + ...
%                     (xor(g, a) || (h_ && ~g)) ... getChangeNumber(g, h, a) ...
%                 ) > 2;
%             end
%         end
%     end
%     function n = getChangeNumber(l, m, r)
%         n = xor(l, r) || (m && ~l);
% %         if (l == r)
% %             if (l == 1)
% %                 n = 0;
% %             else
% %                 if (m == 1)
% %                     n = 1;
% %                 else
% %                     n = 0;
% %                 end
% %             end
% %         else
% %             n = 1;
% %         end
%     end
% end