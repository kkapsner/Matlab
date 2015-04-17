function image = getUncachedImage(stack, index)
%getUncachedImage extracts an image out of a tiff stack without caching
%   Overwrite this method for subclasses of TiffStack!
    image = stack.matrix(:, :, index);
end

