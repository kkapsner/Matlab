function savePlot(obj, dir, rows, cols)
%SAVEPLOT 

    if (nargin < 4)
        cols = 1;
        rows = 1;
    end
    splitSize = cols * rows;
    num = numel(obj);
    for i = 1:splitSize:num
        if (i + splitSize - 1 > num)
            splitSize = num + 1 - i;
            rows = ceil(splitSize / cols);
            if (rows == 1)
                cols = splitSize;
            end
        end
        objSlice = obj(i:(i+splitSize - 1));
        name = '';
        f = figure('Visible', 'off', ...
            'PaperOrientation', 'portrait', ...
            'PaperType', 'A0' ...
        );
        for j = 1:splitSize
            sub = subplot(rows, cols, j, 'Parent', f, ...
                'FontSize', 4);
            o = objSlice(j);
            h = plot( ...
                o.time, [o.value o.baselineCorrectedValue o.filteredValue], '-', ...
                o.peakTimes, o.peakValues, 'x', ...
                'LineWidth', 1.5, ...
                'Parent', sub ...
            );
            legend(h, ...
                {'original', 'baseline corrected', 'filtered', 'peaks'}, ...
                'box', 'off' ...
            );
            set(h(end), 'Markersize', 6, 'Color', [0 0 0]);
            title(sub, o.advancedName);
            name = [name '+' o.name];
        end
        
        if (nargin < 2)
            set(f, 'Visible', 'on', 'PaperType', 'A4');
        else
            filename = [dir.path filesep 'traces'];% name(2:end)];
            if exist([filename '.png'], 'file')
                count = 1;
                while exist(sprintf('%s(%u).png', filename, count), 'file')
                    count = count + 1;
                end
                filename = sprintf('%s(%u)', filename, count);
            end
            %print(f, filename, '-depsc2');
            print(f, filename, '-dpng', '-r500');
            close(f);
        end
    end
end

