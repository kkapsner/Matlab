classdef IntegratedTrace < TraceDecorator & handle
    properties (SetObservable)
        integrationConstant = 0;
    end
    
    properties (Access=private,Transient)
        integratedValue
        
    end
    
    methods
        function this = IntegratedTrace(trace)
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
                l = addlistener(rTrace.trace, 'change', @rTrace.resetIntegrated);
                addlistener(rTrace, 'ObjectBeingDestroyed', @(~,~)delete(l));
                l = addlistener(rTrace, 'integrationConstant', 'PostSet', @rTrace.resetIntegrated);
                addlistener(rTrace, 'ObjectBeingDestroyed', @(~,~)delete(l));
            end
        end
        
        function value = getValue(this)
            if (isempty(this.integratedValue))
                this.integrate();
            end
            value = this.integratedValue;
        end
        
        function time = getTime(this)
            time = this.trace.time;
        end
        
        function valueName = getValueName(this)
            valueName = sprintf('d%s * dt', this.trace.getValueName());
        end
        
        function valueUnit = getValueUnit(this)
            valueUnit = sprintf('%s %s', this.trace.getValueUnit(), this.trace.getTimeUnit());
        end
    end
    
    methods (Access=private)
        function resetIntegrated(this, ~, ~)
            for o = this
                o.integratedValue = [];
                o.notify('change');
            end
        end
        function integrate(this)
            for o = this
                dValue = diff(o.trace.value);
                dTime = diff(o.trace.time);
                
                posts = [
                    o.integrationConstant;
                    o.trace.value((1:(end - 1))') .* dTime + dValue .* dTime /2
                ];
                
                o.integratedValue = cumsum(posts);
            end
        end
    end
end