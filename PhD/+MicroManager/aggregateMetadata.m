function aggregate = aggregateMetadata(dir, referenceTime, shiftTime)
%AGGREGATEMETADATA creates a struct out of the metadata.txt files
    aggregate = struct( ...
        'position',{}, ...
        'frames', {}, ...
        'startTime', {}, ...
        'name', {}, ...
        'fluorescenceName', {}, ...
        'ellapsedTime', {}, ...
        'time', {}, ...
        'shiftedTime', {} ...
    );

    if (nargin < 1 || isempty(dir))
        dir = Directory.get();
        if (dir == 0)
            return;
        end
    elseif (~isa(dir, 'Directory'))
        dir = Directory(dir);
    end
    
    if (nargin < 2 || isempty(referenceTime))
        referenceTime = zeros(1, 6);
    end
    if (nargin < 3 || isempty(shiftTime))
        shiftTime = 0;
    end
    
    files = File.empty();
    allPositions = dir.search('Pos*');
    positions = allPositions([allPositions.isdir]);
    posCount = numel(positions);
    
    if (posCount ~= 0)
        try 
            posIdx = arrayfun(@(p)sscanf(p.name, 'Pos%d'), positions);
        catch e
            return
        end
        [~, sortIdx] = sort(posIdx);
        positions = positions(sortIdx);

        for i = 1:posCount
            pos = dir.child(positions(i).name);
            files(i) = File(pos, 'metadata.txt');
        end
        
        return;
    else
        allPositions = dir.search('*_metadata.txt');
        positions = allPositions(~[allPositions.isdir]);
        posCount = numel(positions);
        for i = 1:posCount
            files(i) = File(dir, positions(i).name);
        end
    end
    
    if (isempty(files))
        return;
    end
    
    for fileIdx = 1:numel(files)
        fillAggregate(files(fileIdx), fileIdx);
    end
    
    if (nargout == 0)
        saveFile = File(dir, 'aggregate.mat');
        save(saveFile.char(), 'aggregate');
    end
    function fillAggregate(file, idx)
        fprintf('read %s\n', positions(idx).name);
        json = JSON.parse(file.read());
        agg = struct( ...
            'position', [], ...
            'frames', [], ...
            'startTime', [], ...
            'name', '', ...
            'fluorescenceName', '', ...
            'ellapsedTime', [], ...
            'time', [], ...
            'shiftedTime', [] ...
        );
        agg.position = [0, 0, 0];
        agg.name = positions(idx).name;
        
        summary = json('Summary');
        agg.fluorescenceName = summary('ChNames');
        agg.fluorescenceName = agg.fluorescenceName{2};
        frameOne = json('FrameKey-0-0-0');
        framesCount = summary('Frames');
        
        if (summary.isKey('StartTime'))
%             agg.startTime = datevec(summary('StartTime'), 'yyyy-mm-dd ddd HH:MM:SS');
            agg.startTime = sscanf(summary('StartTime'), '%4d-%2d-%2d %*s %2d:%2d:%2d')';
        elseif (summary.isKey('Time'))
%             agg.startTime = datevec(summary('Time'), 'yyyy-mm-dd HH:MM:SS');
            agg.startTime = sscanf(summary('Time'), '%4d-%2d-%2d %*s %2d:%2d:%2d')';
            agg.startTime(6) = agg.startTime(6) - frameOne('ElapsedTime-ms') / 1000;
        else
            agg.startTime = zeros(1, 6);
        end
        
        start = etime(agg.startTime, referenceTime);
        
        for f = 0:framesCount
            if (~json.isKey(sprintf('FrameKey-%d-1-0', f)))
                break;
            end
            frame = json(sprintf('FrameKey-%d-1-0', f));
            agg.ellapsedTime(f + 1, 1) = frame('ElapsedTime-ms') / 1000;
            agg.time(f + 1, 1) = agg.ellapsedTime(f + 1, 1) + start;
            agg.shiftedTime(f + 1, 1) = agg.time(f + 1, 1) + shiftTime;
            
            if (frame.isKey('XPositionUm'))
                agg.position(f + 1, :) = [ ...
                    frame('XPositionUm'), ...
                    frame('YPositionUm'), ...
                    frame('ZPositionUm') ...
                ];
            end
        end
        agg.frames = numel(agg.time);
        
        aggregate(idx) = agg;
    end
end

