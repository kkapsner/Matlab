function createAllAggregates(dir, referenceTime, shiftTime)
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
    
    fprintf('Check folder %s\n', dir.path);
    
    csv = dir.search('*.csv');
    if (numel(csv))
        newReferenceTime = Cary.getStartTime(File(dir, csv(1).name));
        if any(newReferenceTime ~= 0)
            referenceTime = newReferenceTime;
        end
        caryBulkFile = File(dir, 'caryBulk.mat');
        if (caryBulkFile.exist())
            load(caryBulkFile.fullpath, 'caryBulk');
            shiftTime = caryBulk.trace.timeShift;
        end
    end
    
    MicroManager.aggregateMetadata(dir, referenceTime, shiftTime);
    
    children = dir.search('*');
    for c = 1:numel(children)
        child = children(c);
        if (child.isdir && any(child.name ~= '.'))
            child = dir.child(child.name);
%             if (~File(child, 'aggregate.mat').exist())
                MicroManager.createAllAggregates(child, referenceTime, shiftTime);
%             end
        end
    end
end