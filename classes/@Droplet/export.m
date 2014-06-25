function export(this, dir, fields, timeStep)
%EXPORT writes the data in CSV files
%
%   DROP.EXPORT(DIR, FIELDS) saves the fields specified in the cell FIELDS
%       in files in the directory DIR. Every field gets a seperate file
%       named "{FIELDNAME}.csv". The first row in the file is the droplet
%       number and the first column is the time.
%   DROP.EXPORT([], FIELDS) asks for a directory where the files should be
%       created
%   DROP.EXPORT(..., TIMESTEP) specifies the time step between two images

    if (nargin < 4)
        timeStep = 1;
    end

    % don't process an empty array of droplets
    if (isempty(this))
        return;
    end

    % if no directory is provided ask for it
    if (isempty(dir) || dir == 0)
        dir = Directory.get();
    end
    
    header = 1:numel(this);
    time = (0:(numel(this(1).radius) - 1))' * timeStep;
    
    for fieldIndex = 1:numel(fields)
        field = fields{fieldIndex};
        fieldFile = File(dir, sprintf('%s.csv', field));
        
        fileID = fopen(fieldFile.fullpath, 'w');
        
        dataSize = size(this(1).(field));
        
        fwrite(fileID, 'Time');
        
        headerTemplate = [',%u' repmat(',', dataSize(2) - 1)];
        
        for dropletIndex = header
            fwrite(fileID, sprintf(headerTemplate, dropletIndex));
        end
        fwrite(fileID, 13);
        fclose(fileID);
        
        data = [this.(field)];
        dlmwrite(fieldFile.fullpath, [time, data], '-append');
    end
end

