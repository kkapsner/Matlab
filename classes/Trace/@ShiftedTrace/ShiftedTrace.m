classdef ShiftedTrace < TraceDecorator & handle
    
    properties (SetObservable)
        timeShift = 0
        valueShift = 0
    end
    
    properties (Access=private,Transient)
        shiftedTime
        shiftedValue
    end
    
    methods
        function this = ShiftedTrace(trace, valueShift, timeShift)
            if (nargin == 0)
                trace = [];
            end
            
            this = this@TraceDecorator(trace);
            if (nargin ~= 0)
                for i = 1:numel(this)
                    fTrace = this(i);
                    if (nargin < 3)
                        fTrace.timeShift = - min(fTrace.trace.time);
                    else
                        fTrace.timeShift = timeShift;
                    end
                    if (nargin > 1)
                        fTrace.valueShift = valueShift;
                    end
                end
                this.registerListeners();
            end
        end
        
        function registerListeners(this)
            for i = 1:numel(this)
                fTrace = this(i);
                l = addlistener(fTrace.trace, 'change', @fTrace.resetShifted);
                addlistener(fTrace, 'ObjectBeingDestroyed', @(~,~)delete(l));
                addlistener(fTrace, 'timeShift', 'PostSet', @fTrace.resetShifted);
                addlistener(fTrace, 'valueShift', 'PostSet', @fTrace.resetShifted);
            end
        end
        
        function value = getValue(this)
            if (isempty(this.shiftedValue))
                this.performShifting();
            end
            value = this.shiftedValue;
        end
        
        function time = getTime(this)
            if (isempty(this.shiftedTime))
                this.performShifting();
            end
            time = this.shiftedTime;
        end
        
        function setTimeShift(this, value)
            if (ischar(value))
                switch value
                    case 'first'
                        for o = this
                            o.timeShift = -o.trace.time(1);
                        end
                    case 'last'
                        for o = this
                            o.timeShift = -o.trace.time(end);
                        end
                    case 'min'
                        for o = this
                            o.timeShift = -min(o.trace.time);
                        end
                    case 'mean'
                        for o = this
                            o.timeShift = -mean(o.trace.time);
                        end
                    case 'median'
                        for o = this
                            o.timeShift = -median(o.trace.time);
                        end
                    case 'max'
                        for o = this
                            o.timeShift = -max(o.trace.time);
                        end
                    otherwise
                        error('ShiftedTrace:unknownTimeShiftType', ...
                            'Unknown time shift type.');
                end
            else
                if (numel(value) ~= 1)
                    error('ShiftedTrace:invalidTimeShift', ...
                        'Time shift has to be scalar.');
                end
                for o = this
                    o.timeShift = value;
                end
            end
        end
        
        function setValueShift(this, value)
            if (ischar(value))
                switch value
                    case 'first'
                        for o = this
                            o.valueShift = -o.trace.value(1);
                        end
                    case 'last'
                        for o = this
                            o.valueShift = -o.trace.value(end);
                        end
                    case 'min'
                        for o = this
                            o.valueShift = -min(o.trace.value);
                        end
                    case 'mean'
                        for o = this
                            o.valueShift = -mean(o.trace.value);
                        end
                    case 'median'
                        for o = this
                            o.valueShift = -median(o.trace.value);
                        end
                    case 'max'
                        for o = this
                            o.valueShift = -max(o.trace.value);
                        end
                    otherwise
                        error('ShiftedTrace:unknownValueShiftType', ...
                            'Unknown value shift type.');
                end
            else
                if (numel(value) ~= 1)
                    error('ShiftedTrace:invalidValueShift', ...
                        'Value shift has to be scalar.');
                end
                for o = this
                    o.valueShift = value;
                end
            end
        end
    end
    
    methods (Access=private)
        function resetShifted(this, ~, ~)
            for o = this
                o.shiftedTime = [];
                o.shiftedValue = [];
                o.notify('change');
            end
        end
        function performShifting(this)
            for o = this
                o.shiftedTime = o.trace.time + o.timeShift;
                o.shiftedValue = o.trace.value + o.valueShift;
            end
        end
    end
end