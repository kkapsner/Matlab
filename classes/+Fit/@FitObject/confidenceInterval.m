function interval = confidenceInterval(fitObj, level, name)
    if (numel(fitObj) > 1)
        interval = cell(size(fitObj));
        for i = 1:numel(fitObj)
            interval{i} = fitObj(i).confidenceInterval(level, name);
        end
    else
        if (isempty(fitObj.lastResult))
            error('FitObject:performFitFirst', 'Perform the fit first.');
        end

        if (nargin < 2)
            level = 0.95;
        end

        interval = confint(fitObj.lastResult.fitobj, level);

        if (nargin > 2)
            names = coeffnames(fitObj.lastResult.fitobj);
            found = find(strcmp(name, names));
            if (isempty(found))
                error('FitObjext:unknownParameter', 'Unknown parameter "%s"', name);
            end
            interval = interval(:, found);
        end
    end
end