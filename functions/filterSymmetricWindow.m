%FILTERSYMMETRICWINDOW filters via a window vector
% FILTERED = FILTERSYMMETRICWINDOW(WINDOW, DATA)

% function filtered = filterSymmetricWindow(window, data)
%     l = size(data);
%     filtered = zeros(l);
%     if (min(l) == 1)
%         l = max(l);
%         wl = max(size(window));
%         for i = 1:l
%             sum = window(1);
%             d = data(i) * window(1);
%             for j = 1:wl-1
%                 if (i - j) >= 1
%                     sum = sum + window(j + 1);
%                     d = d + data(i - j) * window(j + 1);
%                 end
%                 if (i + j) <= l
%                     sum = sum + window(j + 1);
%                     d = d + data(i + j) * window(j + 1);
%                 end
%             end
%             if sum == 0
%                 filtered(i) = 0;
%             else
%                 filtered(i) = d / sum;
%             end
%         end
%     else
%         for i = 1:l(2)
%             filtered(:,i) = filterSymmetricWindow(window, data(:,i));
%         end
%     end
% end