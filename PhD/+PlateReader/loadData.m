function traces = loadData(file)
    if (nargin < 1)
        file = File.get;
    end
    
    switch (lower(file.extension))
        case {'.csv', '.txt'}
            lines = file.readLines();
            table = cellfun(@(line) regexp(line, ';', 'split'), lines, 'Uniform', false);
            
            timeLine = table{6};
            dataRows = table(7:end);
            while (~isempty(dataRows) && numel(dataRows{end}) < 3)
                dataRows = dataRows(1:end - 1);
            end
            numRows = numel(dataRows);
        case {'.xls', '.xlsx'}
            [~, ~, table] = xlsread(file.fullpath);
            
            timeLine = table(7, :);
            numRows = size(table, 1) - 8;
            dataRows = cell(numRows, 1);
            for rowIndex = 1:numRows
                dataRows{rowIndex} = table(rowIndex + 8, :);
            end
        otherwise
            error('PlateReader:loadData:unknownFileFormat', 'Unknown file format %s', file.extension);
    end
    
    [time, meta] = PlateReader.parseTimeRow(timeLine);
    if (numel(meta) == 1)
        traces(numRows) = RawDataTrace();
        for rowIndex = 1:numRows
            traces(rowIndex) = PlateReader.parseDataRow(dataRows{rowIndex}, time, meta);
        end
    else
        traces(numRows, numel(meta)) = RawDataTrace();
        for rowIndex = 1:numRows
            traces(rowIndex, :) = PlateReader.parseDataRow(dataRows{rowIndex}, time, meta);
        end
    end
end