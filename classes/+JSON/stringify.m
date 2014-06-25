function json = stringify(obj, replacer, space)
    if (nargin < 3)
        space = [];
    end
    if (nargin < 2)
        replacer = [];
    end
    
    gap = '';
    indent = '';
    if (~isempty(space))
        gap = space;
    end
    
    json = str(obj);
    
    function json = str(obj)
    if (isscalar(obj))
        if (islogical(obj))
            json = stringifyLogical(obj);
        elseif (ischar(obj))
            json = stringifyChar(obj);
        elseif (isnumeric(obj))
            json = stringifyNumber(obj);
        elseif (isstruct(obj))
            json = stringifyStruct(obj);
        else
            try
                json = obj.toJSON();
            catch e
                json = 'null';
            end
        end
    elseif (ischar(obj))
        json = stringifyChar(obj);
    elseif (isa(obj, 'containers.Map'))
        json = stringifyObject(obj.keys(), obj.values());
    else
        if (iscell(obj))
            json = stringifyArray(obj);
        else
            json = stringifyArray(num2cell(obj));
        end
    end
    end

    function json = stringifyLogical(obj)
        if (obj)
            json = 'true';
        else
            json = 'false';
        end
    end

    function json = stringifyChar(obj)
        strC = cell(1, numel(obj));
        for i = 1:numel(obj)
            c = obj(i);
            switch (c)
                case '\'
                    strC{i} = '\\';
                case '"'
                    strC{i} = '\"';
                case 8
                    strC{i} = '\b';
                case 9
                    strC{i} = '\t';
                case 10
                    strC{i} = '\n';
                case 12
                    strC{i} = '\f';
                case 13
                    strC{i} = '\r';
                otherwise
                    if (c < ' ')
                        strC{i} = sprintf('\\u%04X', c);
                    else
                        strC{i} = c;
                    end
            end
        end
        json = ['"', strjoin(strC, ''), '"'];
    end

    function json = stringifyNumber(obj)
        if (isfinite(obj))
            json = sprintf('%g', obj);
        else
            json = 'null';
        end
    end

    function json = stringifyStruct(obj)
        keys = fieldnames(obj);
        values = cellfun(@(key)obj.(key), keys, 'Uniform', false);
        json = stringifyObject(keys, values);
    end

    function json = stringifyObject(keys, values)
        stepback = indent;
        indent = [indent, gap];
        strC = cell(1, numel(keys));
        
        if (isempty(gap))
            colon = ':';
        else
            colon = ': ';
        end
        
        for i = 1:numel(keys)
            strC{i} = [ ...
                stringifyChar(keys{i}), ...
                colon, ...
                str(values{i}) ...
            ];
        end
        
        if (isempty(gap))
            json = ['{', strjoin(strC, ','), '}'];
        else
            json = sprintf( ...
                '{\n%s%s\n%s}', ...
                indent, ...
                strjoin(strC, sprintf(',\n%s', indent)), ...
                stepback ...
           );
        end
        indent = stepback;
    end

    function json = stringifyArray(values)
        stepback = indent;
        indent = [indent, gap];
        strC = cell(1, numel(values));
        for i = 1:numel(values)
            strC{i} = str(values{i});
        end
        
        if (isempty(gap))
            json = ['[', strjoin(strC, ','), ']'];
        else
            json = sprintf( ...
                '[\n%s%s\n%s]', ...
                indent, ...
                strjoin(strC, sprintf(',\n%s', indent)), ...
                stepback ...
           );
        end
        indent = stepback;
    end
end

