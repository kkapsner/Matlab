classdef verticalMarker < handle
    %VERTICALMARKER creates a vertical marker in an axes. Additional a
    %slider is generated
    %   OBJ = VERTICALMARKER(AXES, 'parameter', value, ...) creates a
    %   vertical marker in the AXES object
    %   Possible parameters:
    %       Parent: the parent of the slider and the inputs (default: figure
    %       ancestor of AXES
    %       Min: the minimal value (default: minimum of the x-axis of AXES
    %       MinInput: on|off
    %       Max: analoge to Min
    %       MaxInput: analoge to MinInput
    %       Value: the current value of the marker (default: Min)
    %       ValueInput: analoge to MinINput
    %       SliderInput: if visible slider
    %       Color: color of the slider tray and the graphical marker
    
    events
        minChange
        valueChange
        maxChange
        
        callback
    end
    properties (Access=protected)
        controls
    end
    properties
        axes
        parent
        min = -Inf
        minInput
        max = Inf
        maxInput
        value = 0
        valueInput
        sliderInput
        color
        position
        units
        userData
    end
    
    methods
        function obj = verticalMarker(varargin)
            if (nargin)
                obj.parseParameter(varargin{:});
                obj.createControls();
                obj.setEventListener();
            end
        end
        
        repaint(obj)
    end
    
    %setter
    methods
        function set.min(obj, min)
            assert(isnumeric(min) && isfinite(min), ...
                'Gui:verticalMarker:minNonNumericOrInfinite', ...
                'minimal value must be numeric an finite');
            if (min ~= obj.min)
                obj.min = min;
                if (obj.min > obj.value)
                    obj.value = min;
                end
                if (obj.min > obj.max)
                    obj.max = min;
                end
                obj.setControlProperty('minValue', 'value', min);
                obj.setControlProperty('slider', 'min', min);
                notify(obj, 'minChange');
            end
        end
        
        function set.minInput(obj, minInput)
            obj.minInput = toLogical(minInput);
            obj.setControlProperty('minInput', 'Visibile', logicalToString(obj.minInput));
            obj.repaint();
        end
        
        function set.value(obj, value)
            assert(isnumeric(value) && isfinite(value), ...
                'Gui:verticalMarker:valueNonNumericOrInfinite', ...
                'value must be numeric an finite');
            assert(value >= obj.min, ...
                'Gui:verticalMarker:valueSmallerThanMin', ...
                'value must be bigger than min');
            assert(value <= obj.max, ...
                'Gui:verticalMarker:valueBiggerThanMax', ...
                'value must be smaller than max');
            if (value ~= obj.value)
                obj.value = value;
                obj.setControlProperty('valueInput', 'value', value);
                obj.setControlProperty('slider', 'value', value);
                if (isfield(obj.controls, 'imline') && ishandle(obj.controls.imline))
                    obj.controls.imline.position = value;
                end
                notify(obj, 'valueChange');
            end
        end
        
        function set.valueInput(obj, valueInput)
            obj.valueInput = toLogical(valueInput);
            obj.setControlProperty('valueInput', 'Visibile', logicalToString(obj.valueInput));
            obj.repaint();
        end
        
        
        function set.max(obj, max)
            assert(isnumeric(max) && isfinite(max), ...
                'Gui:verticalMarker:maxNonNumericOrInfinite', ...
                'maximal value must be numeric an finite');
            if (max ~= obj.max)
                obj.max = max;
                if (obj.max < obj.value)
                    obj.value = max;
                end
                if (obj.min > obj.max)
                    obj.min = max;
                end
                obj.setControlProperty('maxValue', 'value', max);
                obj.setControlProperty('slider', 'max', max);
                notify(obj, 'maxChange');
            end
        end
        
        function set.maxInput(obj, maxInput)
            obj.maxInput = toLogical(maxInput);
            obj.setControlProperty('maxInput', 'Visibile', logicalToString(obj.maxInput));
            obj.repaint();
        end
        
        function set.color(obj, color)
            if (~isequal(obj.color, color))
                obj.color = color;
                obj.setControlProperty('slider', 'BackgroundColor', color);
                if (isfield(obj.controls, 'imline') && ishandle(obj.controls.imline))
                    obj.controls.imline.color = color;
                end
            end
        end
        
        function set.position(obj, position)
            obj.position = position;
            obj.setControlProperty('panel', 'Position', position);
        end
    end
    
    methods (Access=private)
        parseParameter(obj, varargin)
        createControls(obj)
        setEventListener(obj)
        setControlProperty(obj, control, varargin)
        [varargout] = getControlProperty(obj, control, varargin)
    end
    
end