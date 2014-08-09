function result = guiFit(this, yData, varargin)

    defaultButtons(1) = struct('String', 'OK', 'Id', 1);
    defaultButtons(2) = struct('String', 'cancel', 'Id', 2);
    
    isNumericVector = (@(d)isnumeric(d) && min(size(d)) == 1);
    p = inputParser;
    p.addRequired('YData', isNumericVector);
    p.addOptional('XData', Inf, isNumericVector);
    p.addOptional('Points', [], @isnumeric);
    p.addOptional('Buttons', defaultButtons);
    p.addOptional('Name', 'Fitting');
    p.addOptional('Wait', false, @islogical);
    
    p.parse(yData, varargin{:});
    
    yData = p.Results.YData;
    if (p.Results.XData == Inf)
        xData = transpose(1:numel(yData));
    else
        xData = p.Results.XData;
        assert(all(size(xData) == size(yData)), 'x and y data must have same dimensions.');
    end
    
    minX = min(xData);
    maxX = max(xData);
    
    fitCount = numel(this);
    markerCount = 2 * fitCount;
    
    result = struct( ...
        'button', 0 ...
    );
    result.marker = zeros(2, fitCount);
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
    end
    markerColorOrder = hsv(markerCount);
    
    %  Create and hide the GUI as it is being constructed.
    f = figure( ...
        'Name', p.Results.Name, ...
        'NumberTitle', 'off', ...
        'Visible', 'off', ...
        'Position', [50 50 500 500], ...
        'ResizeFcn', @manageLayout, ...
        'HandleVisibility', 'off', ...
        'MenuBar', 'none' ...
    );
    
    hPlot = axes('Units', 'Pixels', ...
        'HandleVisibility', 'off', ...
        'Parent', f ...
    );
    hold(hPlot, 'all');
    plot(xData, yData, '.', 'Parent', hPlot);
    
    for i=1:2:numel(p.Results.Points) - 1
        plot( ...
            p.Results.Points(i), p.Results.Points(i + 1), ...
            '+', 'MarkerSize', 20, 'Parent', hPlot ...
        );
    end
    set( ...
        hPlot, ...
        'XLim', get(hPlot, 'XLim'), 'XLimMode', 'manual', ...
        'YLim', get(hPlot, 'YLim'), 'YLimMode', 'manual' ...
    );
    
    hMarkerText = zeros(1, markerCount);
    for i = markerCount:-1:1
        hMarkerText(i) = uicontrol( ...
            'Style', 'text', ...
            'String', sprintf('Marker %u', i), ...
            'Parent', f, ...
            'Position', [0 0 50 20] ...
        );
        verticalMarker(i) = Gui.verticalMarker( ...
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
        addlistener(verticalMarker(i), 'valueChange',  @verticalMarkerCallback);
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
    
    hFitPlots = [];
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
        
        replotFit(i)
        l = addlistener(this(i), 'valueChange', @(~,~)replotFit(i));
        addlistener(f, 'ObjectBeingDestroyed', @(~,~)delete(l));
    end
    
    set(f, 'Visible', 'on');
    drawnow;
    Gui.maximizeFigure(f);
    if (p.Results.Wait)
        uiwait(f);
    end
    
    function verticalMarkerCallback(marker, ~)
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

    function replotFit(index)
        if (numel(hFitPlots) >= index && hFitPlots(index))
            delete(hFitPlots(index));
        end
        
        if (this(index).startX == -Inf)
            x0 = minX;
        elseif (this(index).startX == Inf)
            x0 = maxX;
        else
            x0 = this(index).startX;
        end
        if (this(index).endX == -Inf)
            x1 = minX;
        elseif (this(index).endX == Inf)
            x1 = maxX;
        else
            x1 = this(index).endX;
        end
        
        plotX = linspace(x0, x1, 500);
        hFitPlots(index) = plot( ...
            plotX, ...
            this(index).feval(plotX), ...
            'Color', [0 0 0], ...
            'Parent', hPlot, ...
            'HitTest', 'off' ...
        );
    end

    function hFitCallback(~, ~)
        
        for index = 1:fitCount
            fitObject = this(index);
            fitObject.startX = result.marker(1, index);
            fitObject.endX = result.marker(2, index);
            
            x0 = fitObject.startX;
            x1 = fitObject.endX;
            
            filter = (xData >= x0 & xData <= x1);
            if (~any(filter))
                result.fit(index).results = [];
                set(hFitResult(index), 'String', '');
                continue;
            end
            
            x = xData(filter);
            y = yData(filter);
            
            if (fitObject.hasArgument('x0'))
                fitObject.setArgumentValue('x0', x(1));
            end
            if (fitObject.hasArgument('y0'))
                fitObject.setArgumentValue('y0', y(1));
            end
            
            r = fitObject.fit(x, y);
            
            if (~isempty(fitObject.lastResult.errstr))
                msgbox(fitObject.lastResult.errstr, 'Fiterror', 'error');
            else
                notify(fitObject, 'valueChange');
            end
            
            result.fit(index).results = r;
            
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
            verticalMarker(index).position = [60 y sliderWidth 15];
            
            if (mod(index, 2) == 0)
                y = y - 20;
                tIndex = index / 2;
                
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