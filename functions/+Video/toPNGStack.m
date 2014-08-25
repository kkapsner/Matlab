function toPNGStack(video, file)
    if (nargin < 2 || isempty(file))
        file = File.get({'*.png', 'PNG-image'}, 'select png output file', 'put');
    end
    
    if (~isa(file, 'File'))
        file = File(file);
    end
    if (ndims(video) == 3)
        for i = 1:size(video, 3)
            currentFile = File(file.path, sprintf('%s-%i%s', file.name, i, file.extension));
            imwrite(video(:, :, i), currentFile.fullpath);
        end
    elseif (ndims(video) == 4)
        for i = 1:size(video, 4)
            currentFile = File(file.path, sprintf('%s-%i%s', file.name, i, file.extension));
            imwrite(video(:, :, :, i), currentFile.fullpath);
        end
    end
end