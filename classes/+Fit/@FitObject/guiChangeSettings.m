function guiChangeSettings(obj, varargin)
%GUICHANGESETTINGS complete GUI to change all settings for the fit object
    
    p = inputParser();
    p.addOptional('X', Inf, @isnumeric);
    p.addOptional('Y', Inf, @isnumeric);
    p.addOptional('Parent', -1, @ishandle);
    
    p.parse(varargin{:});
    
    margin = 5;
    lineHeight = 20;
    titleHeight = 4 * lineHeight;
    
    height = ...
        (obj.numArguments + 1) * (lineHeight + margin) + margin + ...
        titleHeight + margin;
    width = 350;
    
    screenSize = get(0, 'ScreenSize');
    x = p.Results.X;
    if (~isfinite(x))
        x = (screenSize(3) - width) / 2;
    end
    y = p.Results.Y;
    if (~isfinite(y))
        y = screenSize(4) - 50 - height;
    end
    
    p = p.Results.Parent;
    if (~ishandle(p))
        p = figure( ...
            'Name', 'Change fit arguments', ...
            'NumberTitle', 'off', ...
            'Position', [x y width height], ...
            'HandleVisibility', 'off', ...
            'Color', 'w', ...
            'MenuBar', 'none', ...
            'CloseRequestFcn', @figureCloseRequest ...
        );
    end
    background = get(p, 'Color');
    f = uipanel('Parent', p);

    listeners = event.proplistener.empty();
    
    textAxes = axes( ...
        'Color', background, ...
        'Units', 'pixels', ...
        'Position', [ ...
            margin, height - margin - titleHeight, ...
            width - 2 * margin, titleHeight ...
        ], ...
        'HandleVisibility', 'off', ...
        'Box', 'on', ...
        'XTick', [], ...
        'YTick', [], ...
        'Parent', f ...
    );
    t = handle(textAxes);
    functionText = text( ...
        'Parent', textAxes, ...
        'String', obj.funcTex, ...
        'BackgroundColor', background, ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', ...
        'Interpreter', 'latex', ...
        'FontSize', 20, ...
        'Units', 'normalized', ...
        'Position', [0.5 0.5] ...
    );

    x = 0;
    tableY = 0;
    x = createRow(x + margin, tableY, '', 40, @createArgumentNameText);
    x = createRow(x + margin, tableY, '', 90, @createArgumentTypeSelect);
    x = createRow(x + margin, tableY, 'value', 60, @createArgumentValueInput);
    x = createRow(x + margin, tableY, 'lower', 60, @createArgumentLowerBoundInput);
    x = createRow(x + margin, tableY, 'upper', 60, @createArgumentUpperBoundInput);
    
    
    
    
    
   % uiwait(f);
    
    function h = createArgumentNameText(argName)
        h = uicontrol( ...
            'Style', 'text', ...
            'BackgroundColor', background, ...
            'HorizontalAlignment', 'Left', ...
            'String', argName, ...
            'Parent', f ...
        );
    end

    function h = createArgumentTypeSelect(argName)
        values = {'independent', 'parameter', 'problem'};
        
        arg = obj.getArgumentByName(argName);
        index = find(ismember(values, arg.type));
        h = uicontrol( ...
            'Style', 'popupmenu', ...
            'String', values, ...
            'Value', index, ...
            'Callback', @callback, ...
            'Parent', f ...
        );
        function callback(~,~)
            switch get(h, 'Value')
                case 1
                    obj.setIndependent(argName);
                case 2
                    obj.setParameter(argName);
                case 3
                    obj.setProblem(argName);
            end
        end
        
        listeners(end + 1) = addlistener(arg, 'type', 'PostSet', @reverseCallback);
        function reverseCallback(~,~)
            set(h, 'Value', find(ismember(values, arg.type)));
        end
    end

    function h = createArgumentValueInput(argName)
        arg = obj.getArgumentByName(argName);
        h = Gui.NumericInput( ...
            'Value', arg.value, ...
            'Parent', f ...
        );
        addlistener(h, 'valueChange', @callback);
        function callback(~,~)
            arg.value = h.value;
            notify(obj, 'valueChange');
        end
        
        listeners(end + 1) = addlistener(arg, 'value', 'PostSet', @reverseCallback);
        function reverseCallback(~,~)
            h.value = arg.value;
        end
    end

    function h = createArgumentLowerBoundInput(argName)
        arg = obj.getArgumentByName(argName);
        h = Gui.NumericInput( ...
            'Value', arg.lowerBound, ...
            'Parent', f ...
        );
        addlistener(h, 'valueChange', @callback);
        function callback(~,~)
            arg.lowerBound = h.value;
        end
        
        listeners(end + 1) = addlistener(arg, 'lowerBound', 'PostSet', @reverseCallback);
        function reverseCallback(~,~)
            h.value = arg.lowerBound;
        end
    end

    function h = createArgumentUpperBoundInput(argName)
        arg = obj.getArgumentByName(argName);
        h = Gui.NumericInput( ...
            'Value', arg.upperBound, ...
            'Parent', f ...
        );
        addlistener(h, 'valueChange', @callback);
        function callback(~,~)
            arg.upperBound = h.value;
        end
        
        listeners(end + 1) = addlistener(arg, 'upperBound', 'PostSet', @reverseCallback);
        function reverseCallback(~,~)
            h.value = arg.upperBound;
        end
    end

    function x = createRow(x, y, title, minWidth, createCallback)
        title = uicontrol( ...
            'Style', 'text', ...
            'BackgroundColor', background, ...
            'String', title, ...
            'Parent', f ...
        );
        ex = get(title, 'Extent');
        ex = ex + margin;
        rowWidth = max(minWidth, ex(3));
        
        y = y + margin;
        for i=obj.numArguments:-1:1
            h = createCallback(obj.arguments(i).name);
            set(h, 'Position', [x y rowWidth lineHeight]);
            y = y + lineHeight + margin;
        end
        
        set(title, 'Position', [x y rowWidth lineHeight]);
        
        x = x + rowWidth;
    end
    
    
    function figureCloseRequest(hObject, ~)
        delete(hObject);
        delete(listeners);
    end
end

