function writeColumnsToXls(filename, varargin)
%WIRTECOLUMNSTOXLS writes column data to xls file
%   writeColumnsToXls(filename, columnHeader1, columnBody1, ...,
%   columnHeaderN, columnBodyN)
%   columnBodyX has to be a cell.
    colCount = numel(varargin);
    assert(mod(colCount, 2) == 0, ...
        'writeColumnsToXls:wrongInputCount', ...
        'To every columns header must be a body provided.' ...
    );
    rowCounts = cellfun(@numel, varargin(2:2:colCount));
    rowCount = max(rowCounts);
    data = cell(rowCount + 1, colCount / 2);
    for i = 2:2:colCount
        data{1, i/2} = varargin{i - 1};
        if (rowCounts(i/2) ~= 0)
            value = varargin{i};
            if (~iscell(value))
                value = num2cell(value);
            end
            data(2:(rowCounts(i/2)+1), i/2) = value;
        end
    end
    
    xlswrite(filename, data);
end