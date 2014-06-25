function image = getUncachedImage(stack, index)
%getUncachedImage extracts an image out of a tiff stack without caching
%   Overwrite this method for subclasses of TiffStack!
    image = imread(stack.file, 'tif', 'Info', stack.info, 'Index', index);

%     w = warning('query', 'MATLAB:imagesci:tiffmexutils:libtiffWarning');
%     warning('off', w.identifier);
% 
%     stack.link.setDirectory(index);
%     image = stack.link.read();
% 
%     warning(w.state, w.identifier);
end

