classdef Scharfit < handle & matlab.mixin.Copyable
    %SCHARFIT provides functionality to fit families of parameter functions
    
    properties (SetObservable)
        scharSize = 1
        weighting = 1
        fitAlsoDerivative = false
        derivativeScaling = 1
    end
    
    properties (SetAccess=private)
        allParameter
        modelFunction
    end
    
    properties (Dependent)
        independent
        parameter
        problem
        scharParameter
        scharProblem
    end
    
    properties (Transient, Access=private)
        listeners = []
    end
    
    events
        change
    end
    
    methods
        function this = Scharfit(func, param)
            if (nargin > 0)
                this.modelFunction = func;

                if (nargin < 2)
                    param = getFunctionArguments(func);
                end
                if (iscell(param))
                    this.allParameter = Fit.Parameter;
                    for i = 1:numel(param)
                        this.allParameter(i) = Fit.Parameter(this, param{i});
                    end
                elseif (isa(param, 'Fit.Parameter'))
                    this.allParameter = param;
                else
                    error('Scharfit:invalidParameter', 'Invalid parameter input.');
                end
                this.allParameter(end).type = 'independent';

                this.setListeners();
            end
        end
        
        function setModelFunction(this, func)
            param = getFunctionArguments(func);
            oldParams = this.allParameter;
            
            this.allParameter = Fit.Parameter;
            for i = 1:numel(param)
                p = oldParams.select(@(p)strcmp(p.name, param{i}));
                if (isempty(p))
                    p = Fit.Parameter(this, param{i});
                end
                this.allParameter(i) = p;
            end
            
            this.modelFunction = func;
            this.renewListeners();
        end
        
        function setListeners(this)
            if (isempty(this.listeners))
                for p = this.allParameter
                    l = addlistener(p, 'value', 'PostSet', @(~,~)this.notify('change'));
                    if (isempty(this.listeners))
                        this.listeners = l;
                    else
                        this.listeners(end + 1) = l;
                    end
                end
                this.listeners(end + 1) = addlistener(this, 'scharSize', 'PostSet', @this.newScharSize);
            end
        end
        
        function removeListeners(this)
            delete(this.listeners);
            this.listeners = [];
        end
        
        function renewListeners(this)
            this.removeListeners();
            this.setListeners();
        end
        
        function p = get.independent(this)
            p = this.allParameter.select(@(p)strcmpi('independent', p.type));
        end
        function p = get.parameter(this)
            p = this.allParameter.select(@(p)strcmpi('parameter', p.type));
        end
        function p = get.problem(this)
            p = this.allParameter.select(@(p)strcmpi('problem', p.type));
        end
        function p = get.scharParameter(this)
            p = this.allParameter.select(@(p)strcmpi('scharParameter', p.type));
        end
        function p = get.scharProblem(this)
            p = this.allParameter.select(@(p)strcmpi('scharProblem', p.type));
        end
        
        function setParameterType(this, name, type)
            params = this.allParameter.select(@(p)strcmp(name, p.name));
            for p = params
                p.type = type;
            end
        end
        
        function arg = arg(this, name)
            %THIS.arg(NAME) alias to THIS.getArgumentByName(NAME)
            
            arg = this.getArgumentByName(name);
        end
        function arg = getArgumentByName(this, name)
            arg = this.allParameter.select(@(p)strcmp(name, p.name));
        end
        function setArgumentValue(this, name, value)
            if isa(name, 'cell')
                if length(value) == 1
                    value = ones(size(name)) * value;
                end
                for i = 1:numel(name)
                    this.setArgumentValue(name{i}, value(:,i));
                end
            else
                arg = this.arg(name);
                arg.value = value;
            end
        end
        
        function setArgumentProperties(this, name, varargin)
            arg = this.arg(name);
            for i = 1:2:(numel(varargin) - 1)
                arg.(varargin{i}) = varargin{i + 1};
            end
        end
        
        fitP = fit(this, schar, weights)
        y = feval(this, y)
        h = plot(this, y, varargin)
        parameterToCsv(this, varargin)
        
    end
    
    methods (Access=protected)
        function copy = copyElement(this)
            copy = copyElement@matlab.mixin.Copyable(this);
            copy.allParameter = this.allParameter.copy();
            copy.setListeners();
        end
    end
    methods (Access=private)
        function adjustParameterDimensions(this, scharSize)
            if (nargin < 2 || isempty(scharSize))
                scharSize = this.scharSize;
            end
            for p = this.allParameter
                lowerSize = numel(p.lowerBound);
                if (lowerSize == 0)
                    p.lowerBound = -Inf;
                elseif (lowerSize > 1)
                    p.lowerBound = p.lowerBound(1);
                end
                
                upperSize = numel(p.upperBound);
                if (upperSize == 0)
                    p.upperBound = Inf;
                elseif (upperSize > 1)
                    p.upperBound = p.upperBound(1);
                end
                
                currentSize = numel(p.value);
                switch (p.type)
                    case {'scharParameter', 'scharProblem'}
                        if (currentSize > scharSize)
                            p.value = p.value(1:scharSize);
                        elseif (currentSize == 0)
                            p.value = zeros(scharSize, 1);
                        elseif (currentSize < scharSize)
                            p.value = p.value([1:currentSize, ones(1, scharSize - currentSize)]);
                        end
                        
                    case {'parameter', 'problem', 'independent'}
                        if (currentSize > 1)
                            p.value = p.value(1);
                        elseif (currentSize == 0)
                            p.value = 0;
                        end
                            
                    otherwise
                        p.value = p.value(1);
                end
                
                p.value = reshape(p.value, [], 1);
            end
            
            % adjust weighting factor
            currentSize = numel(this.weighting);
            if (currentSize > scharSize)
                this.weighting = this.weighting(1:scharSize);
            elseif (currentSize == 0)
                this.weighting = ones(scharSize, 1);
            elseif (currentSize < scharSize)
                this.weighting = this.weighting([1:currentSize, ones(1, scharSize - currentSize)]);
            end
            this.weighting = reshape(this.weighting, [], 1);
        end
        
        function [func, startValues, lowerBounds, upperBounds] = ...
                createMinimizeProperties(this, schar, weights)
            
            dataSizes = arrayfun(@(t)numel(t.time), schar(:));
            if (this.fitAlsoDerivative)
                dataSizes = dataSizes * 2;
            end
            maxSize = max(dataSizes);
            allDataSize = sum(dataSizes);
            dataEndIndex = cumsum(dataSizes);
            dataIndices = cell(size(dataEndIndex));
            for scharI = 1:numel(dataEndIndex)
                dataIndices{scharI} = dataEndIndex(scharI) + 1 - (dataSizes(scharI):-1:1);
            end

            if (nargin < 3 || isempty(weights))
                weights = maxSize ./ dataSizes .* this.weighting;
            end
            
            parameterCount = numel(this.allParameter);
            
            this.adjustParameterDimensions(numel(schar));
            
            % get values and indices of parameter and problems
            [problem, ~, problemFilter] = ...
                this.allParameter.select(@(p)strcmpi('problem', p.type));
            problemIndices = find(problemFilter);
            problemValues = {problem.value};
            
            [scharProblem, ~, scharProblemFilter] = ...
                this.allParameter.select(@(p)strcmpi('scharProblem', p.type));
            scharProblemIndices = find(scharProblemFilter);
            scharProblemValues = num2cell([scharProblem.value]);
            
            [parameter, ~, parameterFilter] = ...
                this.allParameter.select(@(p)strcmpi('parameter', p.type));
            parameterIndices = find(parameterFilter);
            parameterValues = vertcat(parameter.value);
            parameterLowerBounds = vertcat(parameter.lowerBound);
            parameterUpperBounds = vertcat(parameter.upperBound);
            
            [scharParameter, ~, scharParameterFilter] = ...
                this.allParameter.select(@(p)strcmpi('scharParameter', p.type));
            scharParameterIndices = find(scharParameterFilter);
            scharParameterValues = vertcat(scharParameter.value);
            
            if (any(scharParameterFilter))
                expander = ones(numel(schar), 1);
            else
                expander = [];
            end
            scharParameterLowerBounds = ...
                reshape(expander * [scharParameter.lowerBound], [], 1);
            scharParameterUpperBounds = ...
                reshape(expander * [scharParameter.upperBound], [], 1);
            
            [~, ~, independentFilter] = ...
                this.allParameter.select(@(p)strcmpi('independent', p.type));
            independentIndex = find(independentFilter);
            if (numel(independentIndex) ~= 1)
                error('Scharfit:invalidIndependentCount', 'There must be exactly one independent parameter.');
            end
            
            func = @evaluate;
            startValues = vertcat(parameterValues, scharParameterValues);
            lowerBounds = vertcat(parameterLowerBounds, scharParameterLowerBounds);
            upperBounds = vertcat(parameterUpperBounds, scharParameterUpperBounds);
            
            parameterInputIndices = 1:numel(parameterValues);
            scharParameterInputOffset = numel(parameterValues) + 1;
            scharParameterInputIndices = 1:numel(scharParameterIndices);
            
            function difference = evaluate(param)
                difference = zeros(allDataSize, 1);
                for i = 1:numel(schar)
                    if (weights(i) ~= 0)
                        t = schar(i).time;
                        args = cell(parameterCount, 1);
                        args(problemIndices) = problemValues;
                        if (~isempty(scharProblemIndices))
                            args(scharProblemIndices) = scharProblemValues(i, :);
                        end

                        args(parameterIndices) = num2cell(param(parameterInputIndices));
                        if (~isempty(scharParameterIndices))
                            args(scharParameterIndices) = num2cell( ...
                                param(scharParameterInputIndices * (i - 1) + scharParameterInputOffset) ...
                            );
                        end

                        args{independentIndex} = t;

                        yFit = this.modelFunction(args{:});
                        % difference(i) = sqrt(sum((yFit - schar(i).value).^2));
                        if (this.fitAlsoDerivative)
                            
                            dValue = diff(yFit);
                            dTime = diff(t);

                            dyFit = ...
                                ( ...
                                    dValue([1; (1:end)']) + dValue([(1:end)'; 1]) ...
                                ) ./ ( ...
                                    dTime([1; (1:end)']) + dTime([(1:end)'; 1]) ...
                                );
                            if (isa(schar(i), 'DifferentiatedTrace'))
                                difference(dataIndices{i}) = ( ...
                                    [ ...
                                        yFit - schar(i).trace.value, ...
                                        (dyFit - schar(i).value) * this.derivativeScaling ...
                                    ] ...
                                ) * weights(i);
                            else
                                dValue = diff(schar(i).value);
                                dValue = ...
                                    ( ...
                                        dValue([1; (1:end)']) + dValue([(1:end)'; 1]) ...
                                    ) ./ ( ...
                                        dTime([1; (1:end)']) + dTime([(1:end)'; 1]) ...
                                    );
                                difference(dataIndices{i}) = ( ...
                                    [ ...
                                        yFit - schar(i).value, ...
                                        (dyFit - dValue) * this.derivativeScaling ...
                                    ] ...
                                ) * weights(i);
                            end
                        else
                            difference(dataIndices{i}) = (yFit - schar(i).value) * weights(i);
                        end
                    end
                end
            end
        end
        
        function feedBackParameter(this, values)
            this.removeListeners();
            
            parameter = ...
                this.allParameter.select(@(p)strcmpi('parameter', p.type));
            parameterCount = numel(parameter);
            for i = 1:parameterCount
                parameter(i).value = values(i);
            end
            values = values((parameterCount + 1):end);
            
            scharParameter = ...
                this.allParameter.select(@(p)strcmpi('scharParameter', p.type));
            scharParameterCount = numel(scharParameter);
            scharSize = numel(values) / scharParameterCount;
            for i = 1:scharParameterCount
                scharParameter(i).value = values((i - 1) * scharSize + (1:scharSize).');
            end
            this.notify('change');
            this.setListeners();
        end
    end
    
    methods (Static)
        function this = loadobj(this)
            for o = this
                o.setListeners();
                for arg = o.allParameter
                    arg.fit = o;
                end
            end
        end
    end
end

