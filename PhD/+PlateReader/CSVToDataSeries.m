function [varargout] = CSVToDataSeries(file)
    % semicolon as value separator
    lines = file.readLines();
    lines = cellfun(@(line) regexp(line, ';', 'split'), lines, 'Uniform', false);
    
    timeLine = lines{6};
    dataLength = numel(timeLine);
    time = zeros(dataLength - 4, 1);
    j = -2;
    for item = timeLine
        if (j > 0) && (j <= dataLength - 4)
            % comma as decimal point
            timePart = regexprep(item{1}, '^.*-\s*', '');
            parts = sscanf(timePart, '%d h %d min');
            if (isempty(parts))
                parts = sscanf(timePart, '%d h');
                parts(2) = 0;
            elseif (numel(parts) == 1)
                parts(2) = 0;
            end
            time(j) = parts(1) * 3600 + parts(2) * 60;
        end
        j = j + 1;
    end
    
    
    dataLinesCell = lines(7:length(lines)-1);
    %dataLines = dataLinesCell;
    dataLength = length(dataLinesCell{1});
    dataLines = zeros(dataLength - 4, length(dataLinesCell));
    cells = cell(1, length(dataLinesCell));
    i = 1;
    for line = dataLinesCell
        lineA = line{1};
        cells{i} = [lineA{1} lineA{2} ' ' lineA{3}];
        j = -2;
        for item = lineA
            if (j > 0) && (j <= dataLength - 4)
                % comma as decimal point
                dataLines(j, i) = str2double(strrep(item, ',', '.'));
            end
            j = j + 1;
        end
        i = i + 1;
    end
    
    if (nargout == 1)
        varargout{1} = dataLines;
    elseif (nargout == 2)
        varargout{1} = time;
        varargout{2} = dataLines;
    else
        varargout{1} = cells;
        varargout{2} = time;
        varargout{3} = dataLines;
    end
end