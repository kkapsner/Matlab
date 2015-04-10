classdef CalculationTrace < AbstractTrace & handle
    %CalculationTrace
    
    properties(SetAccess=private)
        trace1
        operation
        trace2
    end
    
    properties(Access=private,Transient)
        calculatedValue
    end
    
    methods
        function this = CalculationTrace(trace1, operation, trace2)
            if (nargin > 0)
                num1 = numel(trace1);
                num2 = numel(trace2);
                if (num1 == 1 && num2 == 1)
                    this.trace1 = trace1;
                    this.operation = operation;
                    if ( ...
                        numel(trace1.time) ~= numel(trace2.time) || ...
                        any(trace1.time ~= trace2.time) ...
                    )
                        trace2 = ResampledTrace(trace2);
                        trace2.setResampledTime(trace1.time);
                    end
                    this.trace2 = trace2;

                    this.registerListeners();
                elseif (num1 == 1 && num2 ~= 1)
                    this(num2) = CalculationTrace();
                    for i = 1:num2
                        this(i) = CalculationTrace(trace1, operation, trace2(i));
                    end
                elseif (num1 ~= 1 && num2 == 1)
                    this(num1) = CalculationTrace();
                    for i = 1:num1
                        this(i) = CalculationTrace(trace1(i), operation, trace2);
                    end
                elseif (num1 ~= 1 && num2 ~= 1 && num1 == num2)
                    this(num1) = CalculationTrace();
                    for i = 1:num1
                        this(i) = CalculationTrace(trace1(i), operation, trace2(i));
                    end
                else
                    error('CalculationTrace:dimensionMissmatch', 'Number of traces have to match.');
                end
            end
        end
        
        function registerListeners(this)
            for i = 1:numel(this)
                trace = this(i);
            
                l = [ ...
                    addlistener(trace.trace1, 'change', @this.resetCalculated), ...
                    addlistener(trace.trace2, 'change', @this.resetCalculated) ...
                ];

                addlistener(trace, 'ObjectBeingDestroyed', @(~,~)delete(l));
            end
        end
        
        function time = getTime(this)
            time = this.trace1.time;
        end
        
        function value = getValue(this)
            if (isempty(this.calculatedValue))
                this.calculate();
            end
            value = this.calculatedValue;
        end
        
        function timeUnit = getTimeUnit(this)
            timeUnit = this.trace1.getTimeUnit();
        end
        function timeName = getTimeName(this)
            timeName = this.trace1.getTimeName();
        end
        function valueUnit = getValueUnit(this)
            valueUnit = this.trace1.getValueUnit();
        end
        function valueName = getValueName(this)
            valueName = this.trace1.getValueName();
        end
        function name = getName(this)
            name = this.trace1.getName();
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
                value1 = o.trace1.value;
                value2 = o.trace2.value;
                switch o.operation
                    case '+'
                        value = value1 + value2;
                    case '-'
                        value = value1 - value2;
                    case '*'
                        value = value1 .* value2;
                    case '/'
                        value = value1 ./ value2;
                    case '^'
                        value = value1 .^ value2;
                end
                
                o.calculatedValue = value;
            end
        end
    end
    
    methods(Access=protected)
        function copiedThis = copyElement(this)
            copiedThis = copyElement@AbstractTrace(this);
            copiedThis.trace1 = copy(this.trace1);
            copiedThis.trace2 = copy(this.trace2);
        end
    end
end

