function data = loadCDData(filename)
    if (~isa(filename, 'File'))
        filename = File(filename);
    end
    lines = filename.readLines();
    numLines = numel(lines);
    
    data = struct('header', containers.Map, 'channel', '');
    for i = 1:numLines
        line = lines{i};
        if (numel(line) >= 7 && strcmp(line(1:7), 'Channel'))
            break;
        end
        parts = regexp(line, ',', 'split');
        if (numel(parts) == 2)
            data.header(parts{1}) = parts{2};
        else
            data.header(parts{1}) = parts(2:end);
        end
        if (i == numLines)
            return;
        end
    end
    channelCount = 0;
    while i <= numLines
        channelCount = channelCount + 1;
        i = i + 1;
        channel = struct('x', [], 'y', [], 'data', []);
        headLine = lines{i};
        xDataPoints = regexp(headLine, ',', 'split');
        channel.x = str2double(xDataPoints(2:end));
        for i = (i + 1):numLines
            line = lines{i};
            if (numel(line) >= 7 && strcmp(line(1:7), 'Channel'))
                break;
            end
            if (numel(line))
                dataLine = cell2mat(textscan(line, '%n', length(xDataPoints), 'delimiter', ','));
                channel.y(end + 1) = dataLine(1);
                channel.data(end + 1, :) = dataLine(2:end);
            end
        end
        if (channelCount == 1)
            data.channel = channel;
        else
            data.channel(channelCount) = channel;
        end
        
        if (i == numLines)
            return;
        end
    end
    
    return;
    
    [channelStarts, channelHeaderEnds] = regexp( ...
        content, ...
        '([\n\r])?Channel\s+(\d+)([\n\r])?', ...
        'start', 'end' ...
    );
    
    data.header = content(1:channelStarts(1));
    data.channels = cell(numel(channelStarts), 1);
    
    for i = 1:(numel(channelStarts) - 1)
        data.channels{i} = parseMatrix( ...
            content(channelHeaderEnds(i):channelStarts(i + 1)) ...
        );
    end
    data.channels{end} = parseMatrix(content(channelHeaderEnds(end):end));

    function cData = parseMatrix(str)
        disp(str);
        cData = dlmread( ...
            str ...
        );
    end
end