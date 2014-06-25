function pos = posInStrCellArray(cellArray, str)
    pos = 0;
    for i = 1:length(cellArray)
        if (strcmpi(cellArray{i}, str));
            pos = i;
            break;
        end
    end
end