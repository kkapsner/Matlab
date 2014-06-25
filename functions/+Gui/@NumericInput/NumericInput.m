classdef NumericInput < handle
    %NUMERICINPUT creates a uicontrol type edit which only accepts numeric
    %input
    %   If a non numeric input is 
    
    events
        valueChange
    end
    
    properties
        handle
        value = nan
        format = '%.2g'
    end
    
    methods
        function obj = NumericInput(varargin)
            obj.handle = uicontrol( ...
                varargin{:}, ...
                'Style', 'edit', ...
                'Callback', @obj.handleCallback ...
            );
            addlistener(obj.handle, 'Value', 'PostSet', ...
                @obj.handleValueCallback);
            
            obj.value = get(obj.handle, 'Value');
        end
        
        function set.value(obj, value)
            assert(isnumeric(value), ... && isfinite(value), ...
                'Gui:NumericInput:nonNumericOrInfinteValue', ...
                'Value muss be numeric an finite.');
            if (value ~= obj.value)
                obj.value = value;
                set(obj.handle, 'Value', value);
                set(obj.handle, 'String', sprintf(obj.format, value));
                notify(obj, 'valueChange');
            end
        end
        
        function set(obj, varargin)
            set(obj.handle, varargin{:});
        end
        function varargout = get(obj, varargin)
            [varargout{1:nargout}] = get(obj.handle, varargin{:});
        end
        function ish = ishandle(obj)
            ish = ishandle(obj.handle);
        end
        
        function handleCallback(obj, varargin)
            newValue = str2double(get(obj.handle, 'String'));
            if (isnan(newValue))
                set(obj.handle, 'String', sprintf(obj.format, obj.value));
            else
                obj.value = newValue;
            end
        end
        function handleValueCallback(obj, varargin)
            obj.value = get(obj.handle, 'Value');
        end
    end
    
end

