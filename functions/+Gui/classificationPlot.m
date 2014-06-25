function varargout = classificationPlot(dataObjects, properties)
    f = figure();
    numProperties = numel(properties);
    
    data = cell(numProperties, 1);
    borders = zeros(numProperties, 2);
    
    binnings = zeros(numProperties, numProperties, 100, 100);
    binningBorders = cell(numProperties, 1);
    
    for i = 1:numProperties
        data{i} = [dataObjects.(properties{i})];
        borders(i, :) = [min(data{i}), max(data{i})];
        binningBorders{i} = linspace(borders(i, 1), borders(i, 2), 101);
    end
    
    for i = 1:numel(dataObjects)
        for p1 = 1:numProperties
            p1Idx = ...
                min(100, max(1, ceil( ...
                    100 * ...
                    (data{p1}(i) - borders(p1, 1)) / ...
                    (borders(p1, 2) - borders(p1, 1)) ...
                )));
            for p2 = 1:numProperties
                p2Idx = ...
                    min(100, max(1, ceil( ...
                        100 * ...
                        (data{p2}(i) - borders(p2, 1)) / ...
                        (borders(p2, 2) - borders(p2, 1)) ...
                    )));
                binnings(p1, p2, p1Idx, p2Idx) = binnings(p1, p2, p1Idx, p2Idx) + 1;
            end
        end
    end
    
    axes = zeros(numProperties, numProperties);
    for y = 1:numProperties
        for x = 1:numProperties
            a = subplot(numProperties, numProperties, x + (numProperties-y) * numProperties);
            set(pcolor( ...
                a, ...
                binningBorders{x}(1:end-1) + diff(binningBorders{x})/2, ...
                binningBorders{y}(1:end-1) + diff(binningBorders{y})/2, ...
                log(reshape(binnings(y, x, :, :), 100, 100) + 1)), ...
                'EdgeColor', 'none' ...
            );
            xlim(borders(x, :));
            ylim(borders(y, :));
            if (y == 1)
                xlabel(a, properties{x});
            end
            if (x == 1)
                ylabel(a, properties{y});
            end
            
            axes(x, y) = a;
        end
    end
    
    if (nargout == 1)
        varargout = {axes};
    end
end