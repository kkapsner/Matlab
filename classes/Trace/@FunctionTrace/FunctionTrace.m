classdef FunctionTrace < TraceDecorator & handle
    
    properties (SetObservable)
        func
    end
    
    properties (Access=private,Transient)
        calculatedValue = []
    end
    
    methods
        function this = FunctionTrace(trace, func)
            if (nargin == 0)
                trace = [];
            end
            if (nargin < 2)
                func = @(a)a;
            end
            
            this = this@TraceDecorator(trace);
            if (nargin ~= 0)
                for i = 1:numel(this)
                    fTrace = this(i);
                    fTrace.func = func;
                end
                this.registerListeners();
            end
        end
        
        function registerListeners(this)
            for i = 1:numel(this)
                fTrace = this(i);
                l = addlistener(fTrace.trace, 'change', @fTrace.resetCalculated);
                addlistener(fTrace, 'ObjectBeingDestroyed', @(~,~)delete(l));
                addlistener(fTrace, 'func', 'PostSet', @fTrace.resetCalculated);
            end
        end
        
        function value = getValue(this)
            if (isempty(this.calculatedValue))
                this.performCalculation();
            end
            value = this.calculatedValue;
        end
        
        function time = getTime(this)
            time = this.trace.time;
        end
        
        function setFunc(this, func)
            for o = this
                o.func = func;
            end
        end
    end
    
    methods (Access=private)
        function resetCalculated(this, ~, ~)
            for o = this
                o.calculatedValue = [];
                o.notify('change');
            end
        end
        function performCalculation(this)
            for o = this
                o.calculatedValue = o.func(o.trace.value);
            end
        end
    end
end