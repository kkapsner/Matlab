function obj = parse(str, reviver)
    if (~ischar(str))
        error( ...
            'JSON:parse:noString', ...
            'JSON.parse() expects a string as first parameter.' ...
        );
    end
    
    strSize = numel(str);
    whiteSpace = [' ', 0, 9, 10, 12, 13];
    
    
    [obj, endOfObj] = readValue(1);
    endOfObj = findNextNon(endOfObj, whiteSpace);
    if (endOfObj <= strSize)
        error('JSON:parse:invalid', 'Invalid JSON structure.');
    end
    
    if (nargin > 1)
    end
    
    function [value, endOfValue] = readValue(startPos)
        startPos = findNextNon(startPos, whiteSpace);
        switch (str(startPos))
            case {'"', ''''}
                [value, endOfValue] = readString(startPos);
            case {'n', 't', 'f'}
                [value, endOfValue] = readConstant(startPos);
            case {'+', '-', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}
                [value, endOfValue] = readNumber(startPos);
            case '{'
                [value, endOfValue] = readObject(startPos);
            case '['
                [value, endOfValue] = readArray(startPos);
            otherwise
                error('JSON:parse:invalid', 'Unexpected character');
        end
    end
    
    function [string, endOfString] = readString(startPos)
        endChar = str(startPos);
        if (~any(endChar == '''"'))
            error( ...
                'JSON:parse:StringExpected', ...
                'Invalid JSON structure. String expected.' ...
            );
        end
        endOfString = startPos;
        startPos = startPos + 1;
        i = startPos;
        while (i <= strSize)
            c = str(i);
            if (c == '\')
                i = i + 1;
                switch (str(i))
                    case 'b'
                        c = 8;
                    case 't'
                        c = 9;
                    case 'n'
                        c = 10;
                    case 'f'
                        c = 12;
                    case 'r'
                        c = 13;
                    case 'x'
                        c = sscanf(str((i + 1):(i + 2)), '%02X');
                        i = i + 2;
                    case 'u'
                        c = sscanf(str((i + 1):(i + 4)), '%04X');
                        i = i + 4;
                    otherwise
                        c = str(i);
                end
            elseif (c == endChar)
                break;
            end
            str(endOfString + 1) = c;
            endOfString = endOfString + 1;
            i = i + 1;
        end
        
        if (i > strSize)
            error('JSON:parse:invalid', 'Invalid JSON structure');
        end
        
        string = str(startPos:endOfString);
        endOfString = i + 1;
    end

    function [con, endOfCon] = readConstant(startPos)
        if (strcmp(str(startPos + (0:3)), 'null'))
            con = 0;
            endOfCon = startPos + 4;
        elseif (strcmp(str(startPos + (0:3)), 'true'))
            con = true;
            endOfCon = startPos + 4;
        elseif (strcmp(str(startPos + (0:4)), 'false'))
            con = false;
            endOfCon = startPos + 5;
        else
            error('JSON:parse:invalid', 'Invalid JSON structure.');
        end
    end

    function [num, endOfNum] = readNumber(startPos)
        switch (str(startPos))
            case '+'
                sign = +1;
                startPos = startPos + 1;
            case '-'
                sign = -1;
                startPos = startPos + 1;
            otherwise
                sign = +1;
        end
        endInt = findNextNon(startPos, '0123456789');
        num = str2double(str(startPos:(endInt-1)));
        startPos = endInt;
        if (startPos <= strSize && str(startPos) == '.')
            startPos = startPos + 1;
            endFloat = findNextNon(startPos, '0123456789');
            floatString = str(startPos:(endFloat-1));
            num = num + (str2double(floatString) / (10^numel(floatString)));
            
            startPos = endFloat;
        end
        
        if (startPos <= strSize && any(str(startPos) == 'eE'))
            startPos = startPos + 1;
            switch (str(startPos))
                case '+'
                    expSign = +1;
                    startPos = startPos + 1;
                case '-'
                    expSign = -1;
                    startPos = startPos + 1;
                otherwise
                    expSign = +1;
            end
            endExp = findNextNon(startPos, '0123456789');
            exponent = str2num(str(startPos:(endExp-1))) * expSign;
            
            startPos = endExp;
        else
            exponent = 0;
        end
        
        endOfNum = startPos;
        num = sign * num * 10^exponent;
%         [num, ~, ~, count] = sscanf(str(startPos:end), '%g', 1);
%         endOfNum = startPos + count - 1;
    end

    function [obj, endOfObj] = readObject(startPos)
        keys = cell(0, 1);
        values = cell(0, 1);
        
        idx = 0;
        startPos = findNextNon(startPos + 1, whiteSpace);
        while (str(startPos) ~= '}')
            idx = idx + 1;
            
            [keys{idx}, startPos] = readString(startPos);
            startPos = findNextNon(startPos, whiteSpace);
            if (str(startPos) ~= ':')
                error('JSON:parse:invalid', 'Invalid JSON structure');
            end
            startPos = findNextNon(startPos + 1, whiteSpace);
            [values{idx}, startPos] = readValue(startPos);
            startPos = findNextNon(startPos, whiteSpace);
            if (startPos > strSize)
                warning('JSON:parse:openObject', 'Open Object found.');
                break;
                error('JSON:parse:invalid', 'Invalid JSON structure');
            end
            switch (str(startPos))
                case ','
                    startPos = findNextNon(startPos + 1, whiteSpace);
                case '}'
                otherwise
                    warning('JSON:parse:openObject', 'Open Object found.');
                    break;
                    error('JSON:parse:invalid', 'Invalid JSON structure');
            end
        end
        if (idx == 0)
            obj = JSON.JSONObject.empty();
        else
            obj = JSON.JSONObject(keys(1:idx), values(1:idx));
        end
        
        if (obj.isKey('MATLAB::constructor'))
            constructor = obj('MATLAB::constructor');
            if (obj.isKey('MATLAB::constructor::parameter'))
                param = obj('MATLAB::constructor::parameter');
                if (~iscell(param))
                    param = num2cell(param);
                end
            else
                param = {};
            end
            try
                obj = feval(constructor, param{:});
            end
        end
        endOfObj = startPos + 1;
    end

    function [arr, endOfArr] = readArray(startPos)
        arr = {};
        startPos = findNextNon(startPos + 1, whiteSpace);
        while (str(startPos) ~= ']')
            [arr{end + 1}, startPos] = readValue(startPos);
            startPos = findNextNon(startPos, whiteSpace);
            if (startPos > strSize)
                error('JSON:parse:invalid', 'Invalid JSON structure');
            end
            switch (str(startPos))
                case ','
                    startPos = findNextNon(startPos + 1, whiteSpace);
                case ']'
                otherwise
                    error('JSON:parse:invalid', 'Invalid JSON structure');
            end
        end
        endOfArr = startPos + 1;
        
        if (isempty(arr))
            arr = [];
        elseif (~ischar(arr{1}))
            type = class(arr{1});
            sameType = true;
            for i = 2:numel(arr)
                if (~strcmp(type, class(arr{i})))
                    sameType = false;
                    break;
                end
            end
            
            if (sameType)
                arr = [arr{:}];
            end
        end
    end

    function pos = findNextUnmasked(pos, c)
        while pos <= strSize
            if (str(pos) == '\')
                pos = pos + 1;
            elseif (str(pos) == c)
                return;
            end
            pos = pos + 1;
        end
        
        error( ...
            'JSON:parse:invalid', ...
            'Invalid JSON structure' ...
        );
    end

    function pos = findNextNon(pos, cs)
        while ( ...
                pos <= strSize && ...
                any(str(pos) == cs) ...
            )
            pos = pos + 1;
        end
    end
end