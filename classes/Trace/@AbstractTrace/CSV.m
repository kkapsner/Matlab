function csv = CSV(this, csv, nameFormat)
    dataSizesDiff = diff([this.dataSize]) == 0;
    assert(all(dataSizesDiff), 'Trace:unableToConvertToCSV', 'Unable to convert traces with different data sizes to CSV.');
    
    createdCSV = false;
    if (nargin < 2)
        csv = CSV();
        createdCSV = true;
    end
    if (nargin < 3)
        if (~isa(csv, 'CSV'))
            nameFormat = csv;
            csv = CSV();
            createdCSV = true;
        else
            nameFormat = '%s';
        end
    end
    t = this(1).time;
    oneTime = true;
    for i = 2:numel(this)
        if (any(this(i).time ~= t))
            oneTime = false;
            break;
        end
    end
    
    if (createdCSV && oneTime)
        csv.addColumn('time', t);
    end
    
    for tr = this
        name = sprintf(nameFormat, tr.traceName);
        if (~oneTime)
            csv.addColumn(sprintf('time %s', name), tr.time);
        end
        csv.addColumn(name, tr.value);
    end
end