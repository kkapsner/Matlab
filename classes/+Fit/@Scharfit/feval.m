function y = feval(this, x)
%FEVAL evaluates the fitmodel
    this.adjustParameterDimensions();

    x = reshape(x, [], 1);
    y = zeros(numel(x), this.scharSize);
    args = cell(numel(this.allParameter), 1);

    % fill problem parameter
    [problem, ~, problemFilter] = ...
        this.allParameter.select(@(p)strcmpi('problem', p.type));
    problemValues = {problem.value};
    
    args(problemFilter) = problemValues;

    
    [scharProblem, ~, scharProblemFilter] = ...
        this.allParameter.select(@(p)strcmpi('scharProblem', p.type));
    scharProblemValues = num2cell([scharProblem.value]);

    % fill parameter
    [parameter, ~, parameterFilter] = ...
        this.allParameter.select(@(p)strcmpi('parameter', p.type));
    parameterValues = vertcat(parameter.value);
    
    args(parameterFilter) = num2cell(parameterValues);
    
    
    [scharParameter, ~, scharParameterFilter] = ...
        this.allParameter.select(@(p)strcmpi('scharParameter', p.type));
    scharParameterValues = num2cell([scharParameter.value]);
    

    [~, ~, independentFilter] = ...
        this.allParameter.select(@(p)strcmpi('independent', p.type));
    if (sum(independentFilter(:)) ~= 1)
        error('Scharfit:invalidIndependentCount', 'There must be exactly one independent parameter.');
    end
    
    args{independentFilter} = x;
    
    for i = 1:this.scharSize
        if (any(scharProblemFilter))
            args(scharProblemFilter) = scharProblemValues(i, :);
        end

        if (any(scharParameterFilter))
            args(scharParameterFilter) = scharParameterValues(i, :);
        end
                    
        y(:, i) = this.modelFunction(args{:});
    end
end

