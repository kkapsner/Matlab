function api = verticalMarker_old(varargin)
%VERTICALMARKER_OLD
%   
    isBooleanString = @(x) any(validatestring(x, {'off', 'on'}));
    p = inputParser;
    p.addRequired('Axes', @ishandle);
    p.addOptional('Parent', -1, @ishandle);
    p.addOptional('Min', Inf, @isnumeric);
    p.addOptional('MinInput', 'off', isBooleanString);
    p.addOptional('Max', Inf, @isnumeric);
    p.addOptional('MaxInput', 'off', isBooleanString);
    p.addOptional('Value', Inf, @isnumeric);
    p.addOptional('ValueInput', 'off', isBooleanString);
    p.addOptional('SliderInput', 'on', isBooleanString);
    p.addOptional('Color', [0 0 0]);
    p.addOptional('Callback', (@(x,~) x));
    p.addOptional('ValueCallback', (@(x,~) x));
    p.addOptional('Position', [1 1 300 40]);
    p.addOptional('Units', 'Pixel');
    p.addOptional('UserData', []);
    
    p.parse(varargin{:});
    
    
    
    if (p.Results.Parent == -1)
        parent = ancestor(p.Results.Axes, 'figure');
    else
        parent = p.Results.Parent;
    end
    
    dim = axis(p.Results.Axes);
    if (p.Results.Min == Inf)
        min = dim(1);
    else
        min = p.Results.Min;
    end
    
    if (p.Results.Max == Inf)
        max = dim(2);
    else
        max = p.Results.Max;
    end
    
    if (p.Results.Value == Inf)
        value = min;
    else
        value = p.Results.Value;
    end
    
    
    createControls();
    
    api.setColor = @localeSetColor;
    api.getMin = @localeGetMin;
    api.setMin = @localeSetMin;
    api.getMax = @localeGetMax;
    api.setMax = @localeSetMax;
    api.setValue = @localeSetValue;
    api.getValue = @localeGetValue;
    
    api.getPosition = @(p)get(api.handles.panel, 'Position');
    api.setPosition = @(p)set(api.handles.panel, 'Position', p);
    
    api.UserData = p.Results.UserData;
    

    function localeSetColor(color)
        set(api.handles.slider, 'BackgroundColor', color);
        api.imline.color = color;
    end

    function min = localeGetMin()
        min = get(api.handles.slider, 'Min');
    end
    function localeSetMin(newMin)
        assert(isnumeric(newMin), ...
            'verticalMarker:nonNumericMin', ...
            'Minimal value must be numeric.');
        assert(isfinite(newMin), ...
            'verticalMarker:infinteMin', ...
            'Minimal value must be finite');
        
        if (api.getValue() < newMin)
            api.setValue(newMin);
        end
        
        min = newMin;
        set(api.handles.slider, 'Min', min);
        set(api.handles.minInput, 'String', sprintf('%.2f', min));
    end
    function minInputCallback(hObject, ~)
        numValue = str2double(get(hObject, 'String'));
        if (isnan(numValue))
            numValue = api.getMin();
        end
        api.setMin(numValue);
    end

    function max = localeGetMax()
        max = get(api.handles.slider, 'Max');
    end
    function localeSetMax(newMax)
        assert(isnumeric(newMax), ...
            'verticalMarker:nonNumericMax', ...
            'Maximal value must be numeric.');
        assert(isfinite(newMax), ...
            'verticalMarker:infinteMax', ...
            'Maximal value must be finite');

        if (api.getValue() > newMax)
            api.setValue(newMax);
        end
        
        max = newMax;
        set(api.handles.slider, 'Max', max);
        set(api.handles.maxInput, 'String', sprintf('%.2f', max));
    end
    function maxInputCallback(hObject, ~)
        numValue = str2double(get(hObject, 'String'));
        if (isnan(numValue))
            numValue = api.getMax();
        end
        api.setMax(numValue);
    end

    function value = localeGetValue()
        value = get(api.handles.slider, 'Value');
    end
    function localeSetValue(value)
        if (nargin < 1)
            value = api.getValue();
        end
        assert(isnumeric(value), ...
            'verticalMarker:nonNumericValue', ...
            'Value must be numeric.');
        assert(value >= min, ...
            'verticalMarker:valueTooSmall', ...
            'Value is too small.');
        assert(value <= max, ...
            'verticalMarker:valueTooBig', ...
            'Value is too big.');
        
        set(api.handles.slider, 'Value', value);
        set(api.handles.valueInput, 'String', sprintf('%.2f', value));
        api.imline.position = value;
        p.Results.ValueCallback(api, []);
    end
    function valueInputCallback(hObject, ~)
        numValue = str2double(get(hObject, 'String'));
        if (isnan(numValue))
            numValue = api.getValue();
        end
        if (numValue < min)
            numValue = min;
        elseif (numValue > max)
            numValue = max;
        end
        api.setValue(numValue);
    end

    function sliderCallback(hObject,~)
        api.setValue(get(hObject, 'Value'));
        p.Results.Callback(api, []);
    end

    function markerCallback(o, ~)
        pos = o.position;
        if(pos ~= api.getValue())
            api.setValue(pos);
            p.Results.Callback(api, []);
        end
    end
    function pos = markerConstraint(pos)
        if (pos < min)
            pos = min;
        elseif (pos > max)
            pos = max;
        end
    end

    function createControls()
        % panel
        api.handles.panel = uipanel( ...
            'Units', p.Results.Units, ...
            'BorderWidth', 0, ...
            'Parent', parent ...
        );
        set(api.handles.panel, 'Position',  p.Results.Position);
        set(api.handles.panel, 'ResizeFcn',  @manageLayout);
        
        
        % valueInput
        api.handles.valueInput = uicontrol( ...
            'Style', 'edit', ...
            'String', sprintf('%.2f', value), ...
            'Callback', @valueInputCallback, ...
            'HandleVisibility', 'off', ...
            'Visible', p.Results.ValueInput, ...
            'Parent', api.handles.panel ...
        );
        % minInput
        api.handles.minInput = uicontrol( ...
            'Style', 'edit', ...
            'String', sprintf('%.2f', min), ...
            'Callback', @minInputCallback, ...
            'HandleVisibility', 'off', ...
            'Visible', p.Results.MinInput, ...
            'Parent', api.handles.panel ...
        );
        % slider
        api.handles.slider = uicontrol( ...
            'Style', 'slider', ...
            'Value', value, ...
            'Min', min, ...
            'Max', max, ...
            'Callback', @sliderCallback, ...
            'SliderStep', [0.01, 0.1], ...
            'HandleVisibility', 'off', ...
            'Visible', p.Results.SliderInput, ...
            'BackgroundColor', p.Results.Color, ...
            'Parent', api.handles.panel ...
        );
        addlistener(api.handles.slider, 'Value', 'PostSet', @(h,~)localeSetValue());
        
        % minInput
        api.handles.maxInput = uicontrol( ...
            'Style', 'edit', ...
            'String', sprintf('%.2f', max), ...
            'Callback', @maxInputCallback, ...
            'HandleVisibility', 'off', ...
            'Visible', p.Results.MaxInput, ...
            'Parent', api.handles.panel ...
        );
    
        api.imline = Gui.imvline( ...
            p.Results.Axes,  ...
            value ...
        );
        api.imline.positionConstraintFcn = @markerConstraint;
        addlistener(api.imline, 'newPosition', @markerCallback);
        api.imline.color = p.Results.Color;
        
        manageLayout();
    end

    function manageLayout(~, ~)
        pDim = get(api.handles.panel, 'Position');
        width = pDim(3);
        height = pDim(4);
        
        fLine = lineVisible(1);
        sLine = lineVisible(2);
        
        lineHeight = height / (fLine + sLine);
        
        if (fLine)
            iDim = get(api.handles.valueInput, 'Position');
            iDim(1) = 1 + (width - iDim(3)) / 2;
            iDim(2) = 1 + lineHeight * sLine + (lineHeight - iDim(4)) / 2;
            set(api.handles.valueInput, 'Position', iDim);
        end
        
        if (sLine)
            margin = 5;
            x = [1 0];
            if (Gui.isVisible(api.handles.minInput))
                iDim = get(api.handles.minInput, 'Position');
                iDim(1) = x(1);
                iDim(2) = 1 + (lineHeight - iDim(4)) / 2;
                set(api.handles.minInput, 'Position', iDim);
                x(1) = margin + iDim(1) + iDim(3);
            end
            if (Gui.isVisible(api.handles.maxInput))
                iDim = get(api.handles.maxInput, 'Position');
                iDim(1) = 1 + width - iDim(3);
                iDim(2) = 1 + (lineHeight - iDim(4)) / 2;
                set(api.handles.maxInput, 'Position', iDim);
                x(2) = margin + iDim(3);
            end
            if (Gui.isVisible(api.handles.slider))
                iDim = get(api.handles.slider, 'Position');
                iDim(1) = x(1);
                iDim(2) = 1 + (lineHeight - iDim(4)) / 2;
                iDim(3) = width - x(1) - x(2);
                set(api.handles.slider, 'Position', iDim);
            end
        end
    end

    function isV = lineVisible(index)
        switch index
            case 1
                isV = Gui.isVisible(api.handles.valueInput);
            case 2
                isV = ...
                    Gui.isVisible(api.handles.minInput) | ...
                    Gui.isVisible(api.handles.slider) | ...
                    Gui.isVisible(api.handles.maxInput);
        end
    end

    
end

