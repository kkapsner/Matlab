function roi = importROI(file)
    if (nargin < 1)
        file = File.get();
    elseif (~isa(file, 'File'))
        file = File(file);
    end
    
    fid = fopen(file.fullpath);
    fseek(fid, 6, 0);
    data = fread(fid, 5, 'uint16', 0, 'b');
    fclose(fid);
    
    assert(data(1) == 256, 'Can only import rectangles');
    
    roi = struct( ...
        'top', data(1), ...
        'left', data(2), ...
        'bottom', data(3), ...
        'right', data(4) ...
    );
end