function [traces, metaOut] = parseDataRow(row, time, metaIn)
    rowIndex = row{1};
    colIndex = row{2};
    name = row{3};
    row = row(4:end);
    while (~isempty(row) && (isempty(row{end}) || any(isnan(row{end}))))
        row = row(1:end - 1);
    end
    
    data = zeros(size(row));
    for i = 1:numel(data)
        rowValue = row{i};
        if (ischar(rowValue))
            data(i) = str2double(strrep(rowValue, ',', '.'));
        elseif (isnumeric(rowValue))
            data(i) = rowValue;
        else
            data(i) = nan;
        end
    end
    
    traces(numel(metaIn)) = RawDataTrace();
    startIndex = 0;
    for metaIndex = 1:numel(metaIn)
        meta = metaIn(metaIndex);
        meta.row = rowIndex;
        meta.col = colIndex;
        trace = RawDataTrace(time{metaIndex}, data((1:meta.length) + startIndex), name);
        startIndex = startIndex + meta.length;
        trace.meta = meta;
        traces(metaIndex) = trace;
    end
    
    metaOut = struct('col', colIndex, 'row', rowIndex, 'name', name);
end