classdef SlicedTrace < TraceDecorator & handle
    
    properties (SetObservable)
        startTime = 0
        endTime = 0
    end
    
    properties (Access=private,Transient)
        slicedTime
        slicedValue
    end
    
    methods
        function this = SlicedTrace(trace)
            if (nargin == 0)
                trace = [];
            end
            
            this = this@TraceDecorator(trace);
            if (nargin ~= 0)
                for i = 1:numel(this)
                    fTrace = this(i);
                    
                    
                    startIndex = find(~isnan(fTrace.trace.time), 1, 'first');
                    if (isempty(startIndex))
                        fTrace.startTime = fTrace.trace.time(1);
                        fTrace.endTime = fTrace.trace.time(end);
                    else
                        endIndex = find(~isnan(fTrace.trace.time), 1, 'last');
                        fTrace.startTime = fTrace.trace.time(startIndex);
                        fTrace.endTime = fTrace.trace.time(endIndex);
                    end
                end
                this.registerListeners();
            end
        end
        
        function registerListeners(this)
            for i = 1:numel(this)
                fTrace = this(i);
                l = addlistener(fTrace.trace, 'change', @fTrace.resetSliced);
                addlistener(fTrace, 'ObjectBeingDestroyed', @(~,~)delete(l));
                addlistener(fTrace, 'startTime', 'PostSet', @fTrace.resetSliced);
                addlistener(fTrace, 'endTime', 'PostSet', @fTrace.resetSliced);
            end
        end
        
        function value = getValue(this)
            if (isempty(this.slicedValue))
                this.performSlicing();
            end
            value = this.slicedValue;
        end
        
        function time = getTime(this)
            if (isempty(this.slicedTime))
                this.performSlicing();
            end
            time = this.slicedTime;
        end
        
        function setStartTime(this, value)
            if (numel(value) ~= 1)
                error('SlicedTrace:invalidStartTime', ...
                    'Start time has to be scalar.');
            end
            for o = this
                o.startTime = value;
            end
        end
        
        function setEndTime(this, value)
            if (numel(value) ~= 1)
                error('SlicedTrace:invalidEndTime', ...
                    'End time has to be scalar.');
            end
            for o = this
                o.endTime = value;
            end
        end
    end
    
    methods (Access=private)
        function resetSliced(this, ~, ~)
            for o = this
                o.slicedTime = [];
                o.slicedValue = [];
                o.notify('change');
            end
        end
        function performSlicing(this)
            for o = this
                value = o.trace.value;
                time = o.trace.time;
                
                filter = (time >= o.startTime) & (time <= o.endTime);

                o.slicedTime = time(filter);
                o.slicedValue = value(filter);
            end
        end
    end
end