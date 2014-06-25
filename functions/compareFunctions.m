function compareFunctions(func1, func2, func1args, func2args, runs)
%COMPAREFUNCTIONS
    
    if (nargin < 3)
        func1args = {};
    end
    if (nargin < 4)
        func2args = func1args;
    end
    if (nargin < 5)
        runs = 5;
    end
    
    tic;
    for i = 1:runs
    end
    looptime = toc;
    
    tic;
    for i = 1:runs
        func1(func1args{:});
    end
    time1 = toc() - looptime;
    
    tic;
    for i = 1:runs
        func2(func2args{:});
    end
    time2 = toc() - looptime;
    
    fprintf('%s took %fs\n%s took %fs\n', ...
        func2str(func1), time1 / runs, func2str(func2), time2 / runs ...
    );
    if (time1 > time2)
        fprintf('%s is %f-times slower than %s\n', ...
            func2str(func1), time1 / time2, func2str(func2) ...
        );
    else
        fprintf('%s is %f-times slower than %s\n', ...
            func2str(func2), time2 / time1, func2str(func1) ...
        );
    end
end

