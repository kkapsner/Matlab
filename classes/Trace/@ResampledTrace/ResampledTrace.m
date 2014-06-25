classdef ResampledTrace < TraceDecorator & handle
    
    properties (SetAccess=private,SetObservable)
        resampledTime
    end
    
    properties (Access=private,Transient)
        resampledValue
    end
    
    methods
        function this = ResampledTrace(trace)
            if (nargin == 0)
                trace = [];
            end
            
            this = this@TraceDecorator(trace);
            this.registerListeners(this);
        end
        
        function registerListeners(this)
            for i = 1:numel(this)
                rTrace = this(i);
                l = addlistener(trace(i), 'change', @rTrace.resetResampled);
                addlistener(rTrace, 'ObjectBeingDestroyed', @(~,~)delete(l));
                addlistener(rTrace, 'resampledTime', 'PostSet', @rTrace.resetResampled);
            end
        end
        
        function value = getValue(this)
            if (isempty(this.resampledValue))
                this.resample();
            end
            value = this.resampledValue;
        end
        
        function time = getTime(this)
            time = this.resampledTime;
        end
        
        function setResampledTime(this, time)
            if (~isvector(time))
                error('ResampledTrace:invalidTime', ...
                    'Time has to be a vector.');
            end
            for o = this
                o.resampledTime = time;
            end
        end
    end
    
    methods (Access=private)
        function resetResampled(this, ~, ~)
            for o = this
                o.resampledValue = [];
                o.notify('change');
            end
        end
        function resample(this)
            for o = this
                o.resampledValue = ...
                    interp1(o.trace.time, o.trace.value, o.resampledTime);
            end
        end
    end
end