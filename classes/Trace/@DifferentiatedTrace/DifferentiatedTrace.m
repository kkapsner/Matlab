classdef DifferentiatedTrace < TraceDecorator & handle
    properties (SetObservable, AbortSet)
        differentiationWindowSize = 0;
        differentiationWindowType = 'datapoints',
    end
    
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
                l = addlistener(rTrace, 'differentiationWindowSize', 'PostSet', @rTrace.resetDifferentiated);
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
                dValue = zeros(size(o.trace.value));
                switch (this.differentiationWindowType)
                    case 'datapoints'
                        windowSize = abs(round(o.differentiationWindowSize));
                    case 'time'
                        windowSize = o.differentiationWindowSize;
                end
                if (windowSize == 0)
                    dValue = diff(o.trace.value);
                    dTime = diff(o.trace.time);

                    dValue = ...
                        ( ...
                            dValue([1; (1:end)']) + dValue([(1:end)'; 1]) ...
                        ) ./ ( ...
                            dTime([1; (1:end)']) + dTime([(1:end)'; 1]) ...
                        );
                else
                    for i = 1:o.dataSize
                        switch (this.differentiationWindowType)
                            case 'datapoints'
                                startIdx = max(1, i - windowSize);
                                endIdx = min(o.dataSize, i + windowSize);
                                x = o.trace.time(startIdx:endIdx);
                                y = o.trace.value(startIdx:endIdx);
                            case 'time'
                                filter =  ...
                                    o.trace.time > o.trace.time(i) - windowSize & ...
                                    o.trace.time < o.trace.time(i) + windowSize;
                                if (sum(filter) < 2)
                                    if (i > 1)
                                        filter(i - 1) = true;
                                    end
                                    if (i < o.dataSize)
                                        filter(i + 1) = true;
                                    end
                                end
                                x = o.trace.time(filter);
                                y = o.trace.value(filter);
                        end
                        A = [x, ones(size(x))];
                        beta = pinv(A)*y;
                        dValue(i) = beta(1);
                    end
                end
                o.differentiatedValue = dValue;
            end
        end
    end
end