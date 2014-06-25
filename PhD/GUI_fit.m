function result = GUI_fit(data, varargin)
    expFun = @(deltaI, tau, x0, y0, x)y0+deltaI*(exp(-(x-x0)/tau) - 1);
    fit = [FitObject(expFun) FitObject(expFun)];
    for i = 1:2
        fit(i).setProblem({'x0', 'y0'});
        fit(i).getArgumentByName('deltaI').set( ...
            'value', 1, ...
            'lowerBound', -100, ...
            'upperBound', 100 ...
        );
        fit(i).getArgumentByName('tau').set( ...
            'value', 1, ...
            'lowerBound', 5, ...
            'upperBound', 30 ...
        );
    end
    points = cell2mat(varargin);
    for i = 1:2:numel(varargin)-1
        f = floor((i - 1) / 4) + 1; 
        if (f > 2)
            break;
        end
        if (i == 1 | i == 5)
            fit(f).StartMarker = varargin{i};
        else
            fit(f).EndMarker = varargin{i};
        end
    end

    buttons(1) = struct('String', 'OK', 'Id', 1);
    buttons(2) = struct('String', 'false', 'Id', 2);
    buttons(3) = struct('String', 'hawadere', 'Id', 3);
    
    r = guiFit(data, ...
        'Fit', fit, ...
        'Buttons', buttons, ...
        'Points', points, ...
        'Name', 'Peak fitting' ...
    );
    
    result.button = r.button;
    if result.button == 0
        result.button = 3;
    end
    
    result.marker = round(r.marker(1:4));
    
    for i = 2:-1:1
        if (isa(r.fit(i).results, 'cfit'))
            result.fit(i) = struct( ...
                'deltaI', r.fit(i).results.deltaI, ...
                'tau', r.fit(i).results.tau ...
            );
        end
    end
end