classdef (Abstract) AbstractTrace < handle & Selectable & Binable & matlab.mixin.Heterogeneous
    %ABSTRACTTRACE is the inheritance root for the Trace-framework
    %
    
    events
        change
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
        end
        
        function dataSize = get.dataSize(this)
            dataSize = numel(this.time);
        end
        
        dm = dialog(this)
        h = plot(this, varargin)
        
        tr = filter(this, filterValue, filterType)
        tr = slice(this, startTime, endTime)
        tr = diff(this)
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
    
    methods (Static)
        function a = loadobj(a)
            a.registerListeners();
        end
    end
end

