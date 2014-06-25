classdef RescaledTrace < TraceDecorator & handle
    
    properties (SetObservable)
        timeFactor = 1
        isTimeFactorInverse = 0
        valueFactor = 1
        isValueFactorInverse = 0
        
        timeUnit = 'unspecified';
        valueUnit = 'unspecified';
    end
    
    properties (Access=private,Transient)
        rescaledTime
        rescaledValue
    end
    
    methods
        function this = RescaledTrace(trace)
            if (nargin == 0)
                trace = [];
            end
            
            this = this@TraceDecorator(trace);
            
            if (~isempty(trace))
                this.registerListeners();
            end
        end
        
        function registerListeners(this)
            for i = 1:numel(this)
                fTrace = this(i);
                l = addlistener(fTrace.trace, 'change', @fTrace.resetRescaled);
                addlistener(fTrace, 'ObjectBeingDestroyed', @(~,~)delete(l));
                addlistener(fTrace, 'timeFactor', 'PostSet', @fTrace.resetRescaled);
                addlistener(fTrace, 'isTimeFactorInverse', 'PostSet', @fTrace.resetRescaled);
                addlistener(fTrace, 'valueFactor', 'PostSet', @fTrace.resetRescaled);
                addlistener(fTrace, 'isValueFactorInverse', 'PostSet', @fTrace.resetRescaled);
            end
        end
        
        
        function timeUnit = getTimeUnit(this)
            if (this.timeFactor == 1)
                timeUnit = this.trace.getTimeUnit();
            else
                timeUnit = this.timeUnit;
            end
        end
        
        function valueUnit = getValueUnit(this)
            if (this.valueFactor == 1)
                valueUnit = this.trace.getValueUnit();
            else
                valueUnit = this.valueUnit;
            end
        end
        
        function value = getValue(this)
            if (isempty(this.rescaledValue))
                this.performRescaling();
            end
            value = this.rescaledValue;
        end
        
        function time = getTime(this)
            if (isempty(this.rescaledTime))
                this.performRescaling();
            end
            time = this.rescaledTime;
        end
        
        function setTimeFactor(this, value)
            if (numel(value) ~= 1)
                error('RescaledTrace:invalidTimeFactor', ...
                    'Time factor has to be scalar.');
            end
            for o = this
                o.timeFactor = value;
            end
        end
        
        function setIsTimeFactorInverse(this, value)
            if (numel(value) ~= 1)
                error('RescaledTrace:invalidIsTimeFactorInverse', ...
                    'Time factor inverse has to be scalar.');
            end
            for o = this
                o.isTimeFactorInverse = value;
            end
        end
        
        function setValueFactor(this, value)
            if (numel(value) ~= 1)
                error('RescaledTrace:invalidValueFactor', ...
                    'Value factor has to be scalar.');
            end
            for o = this
                o.valueFactor = value;
            end
        end
        
        function setIsValueFactorInverse(this, value)
            if (numel(value) ~= 1)
                error('RescaledTrace:invalidIsValueFactorInverse', ...
                    'Value factor inverse has to be scalar.');
            end
            for o = this
                o.isValueFactorInverse = value;
            end
        end
    end
    
    methods (Access=private)
        function resetRescaled(this, ~, ~)
            for o = this
                o.rescaledTime = [];
                o.rescaledValue = [];
                o.notify('change');
            end
        end
        function performRescaling(this)
            for o = this
                vFactor = o.valueFactor;
                if (o.isValueFactorInverse)
                    vFactor = 1 / vFactor;
                end
                tFactor = o.timeFactor;
                if (o.isTimeFactorInverse)
                    tFactor = 1 / tFactor;
                end

                o.rescaledTime = o.trace.time * tFactor;
                o.rescaledValue = o.trace.value * vFactor;
            end
        end
    end
end