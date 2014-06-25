function [panelHandle, mainAxesHandle, topAxesHandle, rightAxesHandle] = ...
    slicePlot(x, y, data, varargin)
    
    splitRatio = 0.7;
    [minX, minXIdx] = min(x);
    [minY, minYIdx] = min(y);
    
    panelHandle = handle(uipanel());
    mainAxesHandle = handle(axes( ...
        'parent', panelHandle, ...
        'units', 'normalize', ...
        'outerPosition', [0, 0, splitRatio, splitRatio] ...
    ));
    image( ...
        'Parent', mainAxesHandle, ...
        'XData', x, 'YData', y, 'CData', data, ...
        'CDataMapping', 'scaled' ...
    );
    mainAxesHandle.xlim = [minX, max(x)];
    mainAxesHandle.ylim = [minY, max(y)];
    mainAxesHandle.clim = [min(data(:)), max(data(:))];

    topAxesHandle = handle(axes( ...
        'parent', panelHandle, ...
        'units', 'normalize', ...
        'outerPosition', [0, splitRatio, splitRatio, 1 - splitRatio] ...
    ));
    topPlot = handle(plot(topAxesHandle, x, data(minYIdx, :)));
    title(topAxesHandle, sprintf('%f', minY));
    topAxesHandle.xlim = mainAxesHandle.xlim;
    
    rightAxesHandle = handle(axes( ...
        'parent', panelHandle, ...
        'units', 'normalize', ...
        'outerPosition', [splitRatio, 0, 1 - splitRatio, splitRatio] ...
    ));
    rightPlot = handle(plot(rightAxesHandle, data(:, minXIdx), y));
    title(rightAxesHandle, sprintf('%f', minX));
    rightAxesHandle.ylim = mainAxesHandle.ylim;

    
    
    mainImh = Gui.imhline(mainAxesHandle, minY);
    mainImh.positionConstraintFcn = @getMatchY;
    addlistener(mainImh, 'newPosition', @updateY);
    
    rightImh = Gui.imhline(rightAxesHandle, minY);
    rightImh.positionConstraintFcn = @getMatchY;
    addlistener(rightImh, 'newPosition', @updateY);
    
    mainImv = Gui.imvline(mainAxesHandle, minX);
    mainImv.positionConstraintFcn = @getMatchX;
    addlistener(mainImv, 'newPosition', @updateX);
    
    topImv = Gui.imvline(topAxesHandle, minX);
    topImv.positionConstraintFcn = @getMatchX;
    addlistener(topImv, 'newPosition', @updateX);
    
    function [xmatched, idx] = getMatchX(xRequested)
        [~, idx] = min(abs(x - xRequested));
        xmatched = x(idx);
    end
    function [yMatched, idx] = getMatchY(yRequested)
        [~, idx] = min(abs(y - yRequested));
        yMatched = y(idx);
    end

    function updateX(line, ~)
        [currentX, idx] = getMatchX(line.position);
        mainImv.position = currentX;
        topImv.position = currentX;
        rightPlot.XData = data(:, idx);
        title(rightAxesHandle, sprintf('%f', currentX));
    end
    function updateY(line, ~)
        [currentY, idx] = getMatchY(line.position);
        mainImh.position = currentY;
        rightImh.position = currentY;
        topPlot.YData = data(idx, :);
        title(topAxesHandle, sprintf('%f', currentY));
    end
end