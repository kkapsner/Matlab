function objectToCsv(object, fields, file, varargin)
    if (nargin < 3 || isempty(file))
        file = File.get({'*.csv', 'CSV-file'},'select struct output file', 'put');
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
    size = numel({object.(fields{1})});
    numFields = numel(fields);
    data = cell(size, numFields);
    for i = 1:numel(fields)
        dataColumn = reshape({object.(fields{i})}, [], 1);
        if (numel(dataColumn) == 1)
            dataColumn = mat2cell(dataColumn{1}, ones(size, 1));
        end
        if (size ~= numel(dataColumn))
            error('Missmatching dimensions');
        end
        
        data(:, i) = dataColumn;
    end
    
    file.write([ ...
        strjoin(fields, p.Results.delimiter), ...
        newline ...
    ]);

    rows = cell(1, size);
    
    for rowIdx = 1:size
        row = valueToStr(data{rowIdx, 1});
        for colIdx = 2:numFields
            row = [row, p.Results.delimiter, valueToStr(data{rowIdx, colIdx})];
        end
        rows{rowIdx} = row;
    end
    file.write(strjoin(rows, newline));
    
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
            if (~isempty(strfind(value, p.Results.delimiter)) || ~isempty(strfind(value, newline)))
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