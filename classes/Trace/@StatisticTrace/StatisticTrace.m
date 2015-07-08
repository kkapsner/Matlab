classdef StatisticTrace < AbstractTraceDecorator
    %StatisticTrace
    
    properties(SetAccess=private)
        traces
    end
    
    properties(SetObservable)
        operation
    end
    
    properties(Access=private,Transient)
        calculatedValue
    end
    
    methods
        function this = StatisticTrace(traces, operation)
            if (nargin > 0)
                if (nargin < 2)
                    operation = 'mean';
                end
                
                this.operation = operation;
                if (isempty(traces))
                    error('StatisticTrace:noTracesProvided', 'At least one trace has to be provided.');
                end
                
                time = traces(1).time;
                
                for i = 2:numel(traces)
                    if ( ...
                        numel(time) ~= numel(traces(i).time) || ...
                        any(time ~= traces(i).time) ...
                    )
                        traces(i) = ResampledTrace(traces(i));
                        traces(i).setResampledTime(time);
                    end
                end
                
                this.traces = traces;
                this.registerListeners();
            end
        end
        
        function registerListeners(this)
            for i = 1:numel(this)
                trace = this(i);
                
                l = addlistener(trace, 'operation', 'PostSet', @this.resetCalculated);
                
                for traceIndex = 1:numel(trace.traces)
                    l(traceIndex) = addlistener(trace.traces(traceIndex), 'change', @this.resetCalculated);
                end

                addlistener(trace, 'ObjectBeingDestroyed', @(~,~)delete(l));
            end
        end
        
        function time = getTime(this)
            time = this.traces(1).time;
        end
        
        function value = getValue(this)
            if (isempty(this.calculatedValue))
                this.calculate();
            end
            value = this.calculatedValue;
        end
        
        function timeUnit = getTimeUnit(this)
            timeUnit = this.traces(1).getTimeUnit();
        end
        function timeName = getTimeName(this)
            timeName = this.traces(1).getTimeName();
        end
        function valueUnit = getValueUnit(this)
            valueUnit = this.traces(1).getValueUnit();
        end
        function valueName = getValueName(this)
            valueName = this.traces(1).getValueName();
        end
        function name = getName(this)
            name = this.operation;
        end
        
        function newTrace = mean(this)
            newTrace = copy(this);
            for o = newTrace
                o.operation = 'mean';
            end
        end
        function newTrace = std(this)
            newTrace = copy(this);
            for o = newTrace
                o.operation = 'std';
            end
        end
        function newTrace = meanPlusStd(this)
            newTrace = copy(this);
            for o = newTrace
                o.operation = 'mean + std';
            end
        end
        function newTrace = meanMinusStd(this)
            newTrace = copy(this);
            for o = newTrace
                o.operation = 'mean - std';
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
        function calculate(this)
            for o = this
                values = [o.traces.value];
                switch o.operation
                    case 'mean'
                        value = mean(values, 2);
                    case 'std'
                        value = std(values, [], 2);
                    case 'mean + std'
                        value = mean(values, 2) + std(values, [], 2);
                    case 'mean - std'
                        value = mean(values, 2) - std(values, [], 2);
                end
                
                o.calculatedValue = value;
            end
        end
    end
    
    methods(Access=protected)
        function copiedThis = copyElement(this)
            copiedThis = copyElement@AbstractTrace(this);
            copiedThis.traces = copy(this.traces);
        end
    end
end

