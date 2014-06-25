function aggregate = aggregateMetadata(dir, referenceTime, shiftTime)
%AGGREGATEMETADATA creates a struct out of the metadata.txt files
    
    if (nargin < 1)
        dir = Directory.get();
    elseif (~isa(dir, 'Directory'))
        dir = Directory(dir);
    end
    
    if (nargin < 2)
        referenceTime = zeros(1, 6);
    end
    if (nargin < 3)
        shiftTime = 0;
    end
    
    positions = dir.search('Pos*');
    positions = positions([positions.isdir]);
    posCount = numel(positions);
    
    if (posCount == 0)
        return;
    end
    try 
        posIdx = arrayfun(@(p)sscanf(p.name, 'Pos%d'), positions);
    catch e
        return
    end
    [~, sortIdx] = sort(posIdx);
    positions = positions(sortIdx);
    
    aggregate = struct( ...
        'position', [], ...
        'frames', [], ...
        'startTime', [], ...
        'name', '', ...
        'fluorescenceName', '', ...
        'ellapsedTime', [], ...
        'time', [], ...
        'shiftedTime', [] ...
    );
    
    for i = 1:posCount
        fprintf('read %s\n', positions(i).name);
        pos = dir.child(positions(i).name);
        jsonFile = File(pos, 'metadata.txt');
        json = JSON.parse(jsonFile.read());
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
        agg.name = positions(i).name;
        
        summary = json('Summary');
        agg.fluorescenceName = summary('ChNames');
        agg.fluorescenceName = agg.fluorescenceName{2};
        frameOne = json('FrameKey-0-0-0');
        framesCount = summary('Frames');
        
        if (summary.isKey('StartTime'))
%             agg.startTime = datevec(summary('StartTime'), 'yyyy-mm-dd ddd HH:MM:SS');
            agg.startTime = sscanf(summary('StartTime'), '%4d-%2d-%2d %*s %2d:%2d:%2d')';
        else
            agg.startTime = datevec(summary('Time'), 'yyyy-mm-dd HH:MM:SS');
            agg.startTime(6) = agg.startTime(6) - frameOne('ElapsedTime-ms') / 1000;
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
        
        aggregate(i) = agg;
    end
    
    if (nargout == 0)
        saveFile = File(dir, 'aggregate.mat');
        save(saveFile.char(), 'aggregate');
    end
end

