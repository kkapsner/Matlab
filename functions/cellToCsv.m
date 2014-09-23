function cellToCsv(data, fields, file, varargin)
    if (nargin < 3 || isempty(file))
        file = File.get({'*.csv', 'CSV-file'}, 'select output file', 'put');
    end
    
    if (~isa(file, 'File'))
        file = File(file);
    end
    
    p = inputParser();
    p.addParameter('delimiter', ',', @ischar);
    p.addParameter('newline', 'pc', @ischar);
    p.addParameter('precision', 5);
    
    p.parse(varargin{:});
    
    newline = setNewline(p.Results.newline);
    precisionIsNumeric = isnumeric(p.Results.precision);
    numRows = size(data, 1);
    fields = reshape(fields, 1, []);
    numFields = numel(fields);
    
    file.write([ ...
        strjoin(fields, p.Results.delimiter), ...
        newline ...
    ]);

    rows = cell(1, numRows);
    
    for rowIdx = 1:numRows
        row = valueToStr(data{rowIdx, 1});
        for colIdx = 2:numFields
            row = [row, p.Results.delimiter, valueToStr(data{rowIdx, colIdx})];
        end
        rows{rowIdx} = row;
    end
    file.write(strjoin(rows, newline), 'a');
    
%     dlmwrite( ...
%         file.fullpath, ....
%         data, ...
%         '-append', ...
%         'delimiter', p.Results.delimiter, ...
%         'newline', p.Results.newline, ...
%         'precision', p.Results.precision ...
%     );
    
    function str = valueToStr(value)
        if isempty(value)
            str = '';
        elseif ischar(value)
            if ( ...
                ~isempty(strfind(value, p.Results.delimiter)) || ...
                ~isempty(strfind(value, newline)) || ...
                ~isempty(strfind(value, '"')) ...
            )
                str = ['"', strrep(value, '"', '""'), '"'];
            else
                str = value;
            end
        elseif isnumeric(value)
            if precisionIsNumeric
                str = sprintf('%.*g', p.Results.precision, value);
            else
                str = sprintf(p.Results.precision, value);
            end
        else
            str = '';
        end
    end
end

function out = setNewline(in)
    if ischar(in)
        if strcmpi(in,'pc')
            out = sprintf('\r\n');
        elseif strcmpi(in,'unix')
            out = sprintf('\n');
        else
            error(message('MATLAB:dlmwrite:newline'));
        end
    else
        error(message('MATLAB:dlmwrite:newline'));
    end
end