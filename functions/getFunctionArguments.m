function args = getFunctionArguments(func)
%GETFUNCTIONARGUMENTS extracts the arguments names of a function
%   Until now only anonymous functions are supported
    
    assert(isa(func, 'function_handle'), ...
        'getFunctionArguments:noFunctionHandle', ...
        'Arguments must be a function handle.');
    
    info = functions(func);
    
    str = func2str(func);
    narg = nargin(func);
    
    switch info.type
        case 'anonymous'
            str = info.function;
            argHead = str(3:strfind(str, ')')-1);
            args = regexp(argHead, '\s*,\s*', 'split');

            
        case 'simple'
            if (isempty(info.file))
                info.file = which(info.function);
            end
            if (isempty(info.file))
                error('getFunctionArguments:functionFileNotFound', ...
                    'Unable to find file location');
            end
            str = fileread(info.file);
            argHead = str(strfind(str, '(') + 1:strfind(str, ')') - 1);
            argHead = regexprep(argHead, '\s*\.{3}.*?(?:\r\n?|\n)\s*', '');
            args = regexp(argHead, '\s*,\s*', 'split');
            
        otherwise
            error('getFunctionArguments:notSupportedFunctionType', ...
                'Not supported functions type.');
    end
    
    assert(numel(args) == abs(narg), ...
        'getFunctionArguments:unknownError', ...
        'An unknown error occured.');
end

