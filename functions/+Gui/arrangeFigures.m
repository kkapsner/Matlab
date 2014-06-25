function arrangeFigures(figures, rowCounts)
%ARRANGEFIGURES 
    windowSize = get(0, 'ScreenSize');
    pos = get(figures, 'OuterPosition');
    if (numel(figures) == 1)
        pos = {pos};
    end
    
    margin = 5;
    
    if (sum(rowCounts) ~= numel(figures))
        error('Gui:arrangeFigure:countMissmatch', 'Number of rows do not match figure count.');
    else
        columns = cell(numel(rowCounts), 1);
        maxColumnWidth = zeros(size(columns));
        columnHeight = zeros(size(columns)) - margin;
        
        figureIndex = 0;
        for i = 1:numel(rowCounts)
            columns{i} = zeros(rowCounts(i), 1);
            for c = 1:rowCounts(i)
                figureIndex = figureIndex + 1;
                columns{i}(c) = figures(figureIndex);
                maxColumnWidth(i) = max(maxColumnWidth(i), pos{figureIndex}(3));
                columnHeight(i) = columnHeight(i) + margin + pos{figureIndex}(4);
            end
        end
        
        x = ( ...
                windowSize(3) - ...
                sum(maxColumnWidth) - (numel(rowCounts) - 1) * margin ...
            ) / 2;
        
        figureIndex = 0;
        for i = 1:numel(rowCounts)
            y = (windowSize(4) + columnHeight(i)) / 2 + margin;
            
            for c = 1:rowCounts(i)
                figureIndex = figureIndex + 1;
                y = y - margin - pos{figureIndex}(4);
                x_ = x + (maxColumnWidth(i) - pos{figureIndex}(3)) / 2;
                set(figures(figureIndex), 'OuterPosition', ...
                    [x_, y, pos{figureIndex}(3), pos{figureIndex}(4)] ...
                );
            end
            
            x = x + margin + maxColumnWidth(i);
        end
    end
    
end

