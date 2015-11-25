classdef StatisticTrace < AbstractTraceDecorator
    %StatisticTrace
    
    properties(SetAccess=private)
        traces
    end
    
    properties(SetObservable)
        operation
    end
    
    properties(Access=private,Transient)
        mean
        std
        min
        max
        median
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
                
                l = addlistener(trace, 'operation', 'PostSet', @(~,~)trace.notify('change'));
                
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
            if (isempty(this.mean))
                this.calculate();
            end
            
            switch this.operation
                case 'mean'
                    value = this.mean;
                case 'min'
                    value = this.min;
                case 'max'
                    value = this.max;
                case 'median'
                    value = this.median;
                case 'std'
                    value = this.std;
                case 'mean + std'
                    value = this.mean + this.std;
                case 'mean - std'
                    value = this.mean - this.std;
                otherwise
                    error( ...
                        'StatisticTrace:unknownOperation', ...
                        'Unknown operation %s', ...
                        this.operation ...
                    );
            end
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
        
        function newTrace = meanTrace(this)
            newTrace = this.copyWithOperation('mean');
        end
        function newTrace = stdTrace(this)
            newTrace = this.copyWithOperation('std');
        end
        function newTrace = meanPlusStd(this)
            newTrace = this.copyWithOperation('mean + std');
        end
        function newTrace = meanMinusStd(this)
            newTrace = this.copyWithOperation('mean - std');
        end
        function newTrace = minTrace(this)
            newTrace = this.copyWithOperation('min');
        end
        function newTrace = maxTrace(this)
            newTrace = this.copyWithOperation('max');
        end
        function newTrace = medianTrace(this)
            newTrace = this.copyWithOperation('median');
        end
        function newTrace = copyWithOperation(this, operation)
            newTrace = copy(this);
            for o = newTace
                o.operation = operation;
            end
        end
    end
    
    methods (Access=private)
        function resetCalculated(this, ~, ~)
            for o = this
                o.mean = [];
                o.std = [];
                o.min = [];
                o.max = [];
                o.median = [];
                o.notify('change');
            end
        end
        function calculate(this)
            for o = this
                values = [o.traces.value];
                o.mean = nanmean(values, 2);
                o.std = nanstd(values, [], 2);
                o.min = nanmin(values, [], 2);
                o.max = nanmin(values, [], 2);
                o.median = nanmedian(values, 2);
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

