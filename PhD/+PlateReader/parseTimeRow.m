function [times, meta] = parseTimeRow(row)
    row = row(4:end);
    while (~isempty(row) && (isempty(row{end}) || any(isnan(row{end}))))
        row = row(1:end - 1);
    end
    dataLength = numel(row);
    time = zeros(dataLength, 1);
    lastTime = -Inf;
    junkSizes = zeros(dataLength, 1);
    numJunks = 1;
    lastJunkStart = 1;
    for cellIndex = 1:dataLength
        cellContent = row{cellIndex};
        timePart = regexprep(cellContent, '^.*-\s*', '');
        parts = sscanf(timePart, '%d h %d min');
        if (isempty(parts))
            parts = sscanf(timePart, '%d h');
            parts(2) = 0;
        elseif (numel(parts) == 1)
            parts(2) = 0;
        end
        time(cellIndex) = parts(1) * 3600 + parts(2) * 60;
        if (time(cellIndex) < lastTime)
            junkSizes(numJunks) = cellIndex - lastJunkStart;
            numJunks = numJunks + 1;
            lastJunkStart = cellIndex;
        end
        lastTime = time(cellIndex);
    end
    junkSizes(numJunks) = dataLength + 1 - lastJunkStart;
    junkSizes = junkSizes(1:numJunks);
    junkEnds = cumsum(junkSizes);
    
    times = mat2cell(time, junkSizes);
    
    meta = struct('type', [], 'exitation', [], 'emission', []);
    for junkIndex = 1:numJunks
        cellContent = row{junkEnds(junkIndex)};
        junkMeta = regexp(cellContent, '^(?<type>.*)\s+\(\s*(?<exitation>\d+)\s*,\s*(?<emission>\d+)(?:\s+\d+)?\s*\)\s*\d+\s*-', 'names');
        junkMeta.exitation = str2double(junkMeta.exitation);
        junkMeta.emission = str2double(junkMeta.emission);
        meta(junkIndex) = junkMeta;
    end
    junkSizes = mat2cell(junkSizes, ones(numJunks, 1));
    [meta.length] = deal(junkSizes{:});
end