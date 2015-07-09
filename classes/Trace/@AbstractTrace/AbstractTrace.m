classdef (Abstract) AbstractTrace < handle & Selectable & Binable & matlab.mixin.Heterogeneous & matlab.mixin.Copyable
    %ABSTRACTTRACE is the inheritance root for the Trace-framework
    %
    
    events
        change
    end
    
    properties
        nameExtensionFunc = []
    end
    
    properties (Dependent)
        time
        value
        
        traceName
        
        dataSize
    end
    
    methods
        function value = get.value(this)
            value = this.getValue();
        end
        function time = get.time(this)
            time = this.getTime();
        end
        
        function name = get.traceName(this)
            name = this.getName();
    
            if (isa(this.nameExtensionFunc, 'function_handle'))
                name = [name, ' ', this.nameExtensionFunc(this)];
            end
        end
        
        function dataSize = get.dataSize(this)
            dataSize = numel(this.time);
        end
        
        csv = CSV(this, csv, nameFormat)
    end
    
    methods (Sealed)
        dm = dialog(this)
        h = plot(this, varargin)

        tr = filter(this, filterValue, filterType)
        tr = slice(this, startTime, endTime)
        tr = diff(this, windowSize)
        tr = int(this)
    end
    
    methods (Abstract)
        value = getValue(this)
        time = getTime(this)
        str = char(this)
        
        timeUnit = getTimeUnit(this)
        timeName = getTimeName(this)
        valueUnit = getValueUnit(this)
        valueName = getValueName(this)
        
        name = getName(this)
        
        registerListeners(this)
    end
    
    methods(Access=protected)
        function copiedThis = copyElement(this)
            copiedThis = copyElement@matlab.mixin.Copyable(this);
            copiedThis.registerListeners();
        end
    end
    
    methods (Static, Access=protected)
        function tr = getDefaultScalarElement()
            tr = RawDataTrace(0, 0, 'default');
        end
    end
    
    methods (Static)
        function a = loadobj(a)
            a.registerListeners();
        end
    end
end

