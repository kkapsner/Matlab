classdef DifferentiatedTrace < TraceDecorator & handle
    
    properties (Access=private,Transient)
        differentiatedValue
    end
    
    methods
        function this = DifferentiatedTrace(trace)
            if (nargin == 0)
                trace = [];
            end
            
            this = this@TraceDecorator(trace);
            if (nargin ~= 0)
                this.registerListeners();
            end
        end
        
        function registerListeners(this)
            for i = 1:numel(this)
                rTrace = this(i);
                l = addlistener(rTrace.trace, 'change', @rTrace.resetDifferentiated);
                addlistener(rTrace, 'ObjectBeingDestroyed', @(~,~)delete(l));
            end
        end
        
        function value = getValue(this)
            if (isempty(this.differentiatedValue))
                this.differentiate();
            end
            value = this.differentiatedValue;
        end
        
        function time = getTime(this)
            time = this.trace.time;
        end
        
        function valueName = getValueName(this)
            valueName = sprintf('d%s / dt', this.trace.getValueName());
        end
        
        function valueUnit = getValueUnit(this)
            valueUnit = sprintf('%s / %s', this.trace.getValueUnit(), this.trace.getTimeUnit());
        end
    end
    
    methods (Access=private)
        function resetDifferentiated(this, ~, ~)
            for o = this
                o.differentiatedValue = [];
                o.notify('change');
            end
        end
        function differentiate(this)
            for o = this
                dValue = diff(o.trace.value);
                dTime = diff(o.trace.time);
                
                o.differentiatedValue = ...
                    ( ...
                        dValue([1; (1:end)']) + dValue([(1:end)'; 1]) ...
                    ) ./ ( ...
                        dTime([1; (1:end)']) + dTime([(1:end)'; 1]) ...
                    );
            end
        end
    end
end