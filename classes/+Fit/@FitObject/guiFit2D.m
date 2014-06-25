function result = guiFit2D(this, zData, varargin)

    defaultButtons(1) = struct('String', 'OK', 'Id', 1);
    defaultButtons(2) = struct('String', 'cancel', 'Id', 2);
    
    isNumericVector = (@(d)isnumeric(d) && min(size(d)) == 1);
    p = inputParser;
    p.addRequired('ZData', @isnumeric);%, isNumericVector);
    p.addOptional('XData', Inf, @isnumeric);%, isNumericVector);
    p.addOptional('YData', Inf, @isnumeric);%, isNumericVector);
    p.addOptional('Points', [], @isnumeric);%
    p.addOptional('Buttons', defaultButtons);
    p.addOptional('Name', 'Fitting');
    p.addOptional('Wait', false, @islogical);
    
    p.parse(zData, varargin{:});
    
    zData = p.Results.ZData;
    
    if (~isvector(zData))
        if (p.Results.XData == Inf)
            xData = transpose(1:size(zData, 2));
        else
            xData = p.Results.XData;
            assert(numel(xData) == size(zData, 2), 'x and z data must match in dimensions.');
        end
        xData = ones(size(zData, 1), 1) * reshape(xData, 1, []);
        
        if (p.Results.YData == Inf)
            yData = transpose(1:size(zData, 1));
        else
            yData = p.Results.XData;
            assert(numel(yData) == size(zData, 1), 'y and z data must match in dimensions.');
        end
        yData = reshape(yData, [], 1) * ones(1, size(zData, 2));
        
        xData = reshape(xData, [], 1);
        yData = reshape(yData, [], 1);
        zData = reshape(zData, [], 1);
    else
        xData = p.Results.XData;
        yData = p.Results.YData;
        assert(all(xData ~= Inf), 'No x data provided.');
        assert(all(yData ~= Inf), 'No y data provided.');
        assert(iscolumn(xData), 'x data must be a column vector.');
        assert(all(size(xData) == size(zData)), 'x and z data have same dimensions.');
        assert(all(size(xData) == size(yData)), 'x and y data have same dimensions.');
    end
    
    minX = min(xData);
    maxX = max(xData);
    minY = min(yData);
    maxY = max(yData);
    
    fitCount = numel(this);
    markerCount = 4 * fitCount;
    
    result = struct( ...
        'button', 0 ...
    );
    result.marker = zeros(4, fitCount);
    for i = fitCount:-1:1
        result.fit(i) = struct( ...
            'results', [] ...
        );
        
        if (this(i).startX == -Inf)
            result.marker(1, i) = minX;
        elseif (this(i).startX == Inf)
            result.marker(1, i) = maxX;
        else
            result.marker(1, i) = this(i).startX;
        end
        
        if (this(i).endX == -Inf)
            result.marker(2, i) = minX;
        elseif (this(i).endX == Inf)
            result.marker(2, i) = maxX;
        else
            result.marker(2, i) = this(i).endX;
        end
        
        if (this(i).startY == -Inf)
            result.marker(3, i) = minY;
        elseif (this(i).startY == Inf)
            result.marker(3, i) = maxY;
        else
            result.marker(3, i) = this(i).startY;
        end
        
        if (this(i).endY == -Inf)
            result.marker(4, i) = minY;
        elseif (this(i).endY == Inf)
            result.marker(4, i) = maxY;
        else
            result.marker(4, i) = this(i).endY;
        end
    end
    markerColorOrder = hsv(markerCount);
    
    %  Create and hide the GUI as it is being constructed.
    f = figure( ...
        'Name', p.Results.Name, ...
        'NumberTitle', 'off', ...
        'Visible', 'on', ...
        'Position', [50 50 500 500], ...
        'ResizeFcn', @manageLayout, ...
        'HandleVisibility', 'off', ...
        'MenuBar', 'none', ...
        'Toolbar', 'figure' ...
    );

    % remove toolbar buttons excep 'rotate'
    htb = findall(findall(f, 'type', 'uitoolbar'));
    i = true(ones(size(htb')));
    i([1 9]) = 0;
    delete(htb(i));
    
    hPlot = axes('Units', 'Pixels', ...
        'HandleVisibility', 'callback', ...
        'Parent', f ...
    );
    
    hold(hPlot, 'all');
    plot3(xData, yData, zData, '.', 'Parent', hPlot);
    
    for i=1:3:numel(p.Results.Points) - 1
        plot3( ...
            p.Results.Points(i), p.Results.Points(i + 1), p.Results.Points(i + 2), ...
            '+', 'MarkerSize', 20, 'Parent', hPlot ...
        );
    end
    set( ...
        hPlot, ...
        'XLim', get(hPlot, 'XLim'), 'XLimMode', 'manual', ...
        'YLim', get(hPlot, 'YLim'), 'YLimMode', 'manual', ...
        'ZLim', get(hPlot, 'ZLim'), 'ZLimMode', 'manual' ...
    );
    
    hMarkerText = zeros(1, markerCount);
    marker = cell(4, fitCount);
    for j = 1:4:markerCount
        for i = j + (0:1)
            hMarkerText(i) = uicontrol( ...
                'Style', 'text', ...
                'String', sprintf('X Marker %u', i), ...
                'Parent', f, ...
                'Position', [0 0 50 20] ...
            );
            marker{i} = Gui.verticalMarker( ...
                hPlot, ...
                'Parent', f, ...
                'Value', result.marker(i), ...
                'ValueInput', 'off', ...
                'Min', minX, ...
                'MinInput', 'off', ...
                'Max', maxX, ...
                'MaxInput', 'off', ...
                'Position', [0 0 1690 20], ...
                'Color', markerColorOrder(i, :), ...
                'UserData', struct('index', i) ...
            );
            addlistener(marker{i}, 'valueChange',  @markerCallback);
        end
        
        for i = j + (2:3)
            hMarkerText(i) = uicontrol( ...
                'Style', 'text', ...
                'String', sprintf('Y Marker %u', i), ...
                'Parent', f, ...
                'Position', [0 0 50 20] ...
            );
            marker{i} = Gui.horizontalMarker( ...
                hPlot, ...
                'Parent', f, ...
                'Value', result.marker(i), ...
                'ValueInput', 'off', ...
                'Min', minX, ...
                'MinInput', 'off', ...
                'Max', maxX, ...
                'MaxInput', 'off', ...
                'Position', [0 0 1690 20], ...
                'Color', markerColorOrder(i, :), ...
                'UserData', struct('index', i) ...
            );
            addlistener(marker{i}, 'valueChange',  @markerCallback);
        end
    end
    
    for i = numel(p.Results.Buttons):-1:1
        hButton(i) = createClosingButton( ...
            p.Results.Buttons(i).String, ...
            p.Results.Buttons(i).Id ...
        );
    end
    hButton(numel(p.Results.Buttons) + 1) = createClosingButton( ...
        'fit', -1, ...
        'Callback', @hFitCallback ...
    );
    
    for i = fitCount:-1:1
        hFitResult(i) = uicontrol( ...
            'Style', 'text', ...
            'Parent', f, ...
            'Position', [0 0 200 20] ...
        );
        hFitSettings(i) = uicontrol( ...
            'Style', 'pushbutton', ...
            'String', 'Settings', ...
            'Parent', f, ...
            'Position', [0 0 50 20], ...
            'Callback', @(~,~)this(i).guiChangeSettings() ...
        );
    end
    hFitPlots = [];
    
    set(f, 'Visible', 'on');
    drawnow;
    Gui.maximizeFigure(f);
    if (p.Results.Wait)
        uiwait(f);
    end
    
    function markerCallback(marker, ~)
        result.marker(marker.userData.index) = marker.value;
    end
    
    function hButton = createClosingButton(string, buttonId, varargin)
        hButton = uicontrol( ...
            'Style', 'pushbutton', ...
            'String', string, ...
            'UserData', buttonId, ...
            'FontSize', 20, ...
            'Callback', @hClosingButtonCallback, ...
            'Parent', f, ...
            varargin{:} ...
        );
        extent = get(hButton, 'Extent');
        set(hButton, 'Position', [1 1 extent(3) + 10 extent(4) + 10]);
    end

    function hClosingButtonCallback(hObject, eventdata)
        %UserData in hObject stores button id.
        
        result.button = get(hObject, 'UserData');
        figureCloseRequest(f, eventdata);
    end
    
    function hFitCallback(~, ~)
        %remove old fitplots
        for h = hFitPlots
            delete(h);
        end
        hFitPlots = [];
        
        for index = 1:fitCount
            fitObject = this(index);
            fitObject.startX = result.marker(1, index);
            fitObject.endX = result.marker(2, index);
            fitObject.startY = result.marker(3, index);
            fitObject.endY = result.marker(4, index);
            
            x0 = fitObject.startX;
            x1 = fitObject.endX;
            y0 = fitObject.startY;
            y1 = fitObject.endY;
            
            filter = (xData >= x0 & xData <= x1 & yData >= y0 & yData <= y1);
            if (~any(filter))
                result.fit(index).results = [];
                set(hFitResult(index), 'String', '');
                continue;
            end
            
            x = xData(filter);
            y = yData(filter);
            z = zData(filter);
            
            if (fitObject.hasArgument('x0'))
                fitObject.setArgumentValue('x0', x(1));
            end
            if (fitObject.hasArgument('y0'))
                fitObject.setArgumentValue('y0', y(1));
            end
            if (fitObject.hasArgument('z0'))
                fitObject.setArgumentValue('z0', z(1));
            end
            
            r = fitObject.fit2D(x, y, z);
            
            result.fit(index).results = r;
            
            [plotX, plotY] = meshgrid(linspace(x0, x1, 100), linspace(y0, y1, 100));
            hFitPlots(index) = mesh( ...
                plotX, ...
                plotY, ...
                feval(r, plotX, plotY), ...
                'Parent', hPlot, ...
                'HitTest', 'off' ...
            );
            
            set(hFitResult(index), ...
                'String', [sprintf( ...
                    'Fit %u: ' , ...
                    index ...
                ) fitObject.char()] ...
            );
        end
    end

    function manageLayout(~, ~)
        pos = get(f, 'Position');
        
        %window too small
        if (pos(3) < 750)
            pos(3) = 750;
            set(f, 'Position', pos);
        end
        if (pos(4) < 400)
            outerPos = get(f, 'OuterPosition');
            outerPos(2) = outerPos(2) - 400 + pos(4);
            outerPos(4) = outerPos(4) + 400 - pos(4);
            pos(4) = 400;
            set(f, 'OuterPosition', outerPos);
        end
        
        windowWidth = pos(3);
        windowHeight = pos(4);
        
        %width - 2 * margin - sliderTextEndPosition
        sliderWidth = windowWidth - 2 * 5 - 55;
        
        y = windowHeight;
        for index = 1:markerCount
            y = y - 20;
            set(hMarkerText(index), ...
                'Position', [5 y 50 15] ...
            );
            marker{index}.position = [60 y sliderWidth 15];
            
            if (mod(index, 4) == 0)
                y = y - 20;
                tIndex = index / 4;
                
                set(hFitSettings(tIndex), ...
                    'Position', [5 y 50 15] ...
                );
                set(hFitResult(tIndex), ...
                    'Position', [60 y sliderWidth, 15] ...
                );
            end
        end
        y = y - 10;
        
        buttonDim = zeros(numel(hButton), 4);
        buttonWidthSum = 0;
        buttonMargin = 20;
        
        yButton = y;
        for index = 1:numel(hButton)
            buttonDim(index,:) = get(hButton(index), 'Position');
            buttonWidthSum = buttonWidthSum + buttonDim(index, 3);
            buttonDim(index, 2) = y - buttonDim(index, 4);
            yButton = min(yButton, buttonDim(index, 2));
        end
        x = floor((windowWidth - buttonWidthSum - buttonMargin * numel(hButton) - 200) / 2);
        for index = 1:numel(hButton)
            buttonDim(index, 1) = x;
            x = x + buttonDim(index, 3) + buttonMargin;
            set(hButton(index), 'Position', buttonDim(index, :));
        end
        y = yButton;
        
        plotDim = zeros(1, 4);
        %sliderWidth - 2 * arrowWidth - sizeOfTray
        plotDim(3) = (sliderWidth - 2 * 20) / 1.1;
        %centered below slider
        plotDim(1) = 55 + ((windowWidth - 55 - plotDim(3)) / 2);
        
        plotDim(2) = 30;
        %take the remaining space
        plotDim(4) = y - 10 - plotDim(2);
        set(hPlot, 'Position', plotDim);
    end
    
    function figureCloseRequest(hObject, ~)
        delete(hObject);
    end
end