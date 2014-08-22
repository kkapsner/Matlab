function objectToCsv(object, fields, file, varargin)
    if (nargin < 2 || isempty(file))
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
    size = numel([object.(fields{1})]);
    data = cell(size, numel(fields));
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
    dlmwrite( ...
        file.fullpath, ....
        data, ...
        '-append', ...
        'delimiter', p.Results.delimiter, ...
        'newline', p.Results.newline, ...
        'precision', p.Results.precision ...
    );
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