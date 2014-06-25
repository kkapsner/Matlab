function [fitobj, goodness, output, warnstr, errstr, convmsg] = ...
        fit(obj, xData, yData)
    if (nargin < 3)
        yData = xData;
        xData = transpose(1:numel(xData));
    end
    
    
    xDataSize = size(xData);
    assert( ...
        all(xDataSize == size(yData)), ...
        'FitObject:fit:wrongDimensions', ...
        'x and y data must have same size' ...
    );
    assert( ...
        min(xDataSize) == 1, ...
        'FitObject:fit:noVector', ...
        'Data must be a vector.' ...
    );
    if (xDataSize(1) == 1)
        xData = transpose(xData);
        yData = transpose(yData);
    end
    
    nanFilter = isnan(xData) | isnan(yData);
    xData = xData(~nanFilter);
    yData = yData(~nanFilter);
    
    optionNames = fieldnames(obj.options);
    optionsArgs = cell(2*numel(optionNames), 1);
    for i = 1:numel(optionNames)
        optionsArgs{(i - 1) * 2 + 1} = optionNames{i};
        optionsArgs{(i - 1) * 2 + 2} = obj.options.(optionNames{i});
    end

    [parameterNames, start, lower, upper] = ...
        obj.getListProperties('parameter');

    [problemNames, problemValues] = ...
        obj.getListProperties('problem');

    independentNames = obj.getListProperties('independent');

    foptions = fitoptions( ...
        optionsArgs{:}, ...
        'Lower', lower, ...
        'Upper', upper ...
    );
    
    if (obj.useFuncBody)
        func = obj.funcBody;
    else
        func = obj.func;
    end
    
    type = fittype(...
        func, ...
        'coefficient', parameterNames, ...
        'independent', independentNames, ...
        'problem', problemNames, ...
        'options', foptions ...
    );

    filter = (xData >= obj.startX & xData <= obj.endX);
    x = xData(filter);
    y = yData(filter);

    [fitobj, goodness, output, warnstr, errstr, convmsg] = fit( ...
        x, y, ...
        type, ...
        'StartPoint', start, ...
        'problem', ...
        num2cell(problemValues) ...
    );
    
    if (~isempty(fitobj))
        for i = 1:obj.numArguments
            if ~strcmp(obj.argumentType{i}, 'independent')
                obj.arguments(i).value = fitobj.(obj.arguments(i).name);
            end
        end
    end

    obj.lastResult.fitobj = fitobj;
    obj.lastResult.goodness = goodness;
    obj.lastResult.output = output;
    obj.lastResult.warnstr = warnstr;
    obj.lastResult.errstr = errstr;
    obj.lastResult.convmsg = convmsg;
end