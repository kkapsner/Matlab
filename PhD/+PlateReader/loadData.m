function traces = loadData(file)
    if (nargin < 1)
        file = File.get;
    end
    
    disp('read file');
    lines = file.readLines();
    
    disp('extract data');
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
    cellLocations = struct();
    for line = dataLinesCell
        lineA = line{1};
        if ~isfield(cellLocations, lineA{1})
            cellLocations.(lineA{1}) = [];
        end
        cellLocations.(lineA{1})(end + 1) = str2double(lineA{2});
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
    
    timeReverses = diff(time) < 0;
    if (any(timeReverses))
        numJunks = sum(timeReverses) + 1;
        dataLines = reshape(dataLines, numel(time) / numJunks, []);
        time = reshape(time * ones(1, numel(cells)), size(dataLines));
        
        newCells = cell(1, numel(cells) * numJunks);
        for i = 1:numel(cells)
            for j = 1:numJunks
                newCells{(i - 1) * numJunks + j} = sprintf('%s - junk %d', cells{i}, j);
            end
        end
        cells = newCells;
    else
        numJunks = 1;
    end
    
    disp('create traces');
    traces = RawDataTrace(time, dataLines, cells);
    
    numRows = numel(fieldnames(cellLocations));
    numCols = [];
    for field = fieldnames(cellLocations)
        currentNumCols = numel(cellLocations.(field{1}));
        if (~isempty(numCols))
            if (numCols ~= currentNumCols)
                numCols = 0;
            end
        else
            numCols = currentNumCols;
        end
    end
    if (numCols ~= 0)
        if (numJunks ~= 1)
            traces = reshape(traces, numJunks, numRows, numCols);
        else
            traces = reshape(traces,numRows, numCols);
        end
    end
end