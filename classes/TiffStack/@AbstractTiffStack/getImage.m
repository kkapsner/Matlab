function image = getImage(stack, index)
%getImage extracts an image out of a tiff stack
%   DO NOT OVERWRITE THIS FUNCTION IN SUBCLASSES OF TiffStack!
    if (stack.caching && ~isempty(stack.cachedIndex) && (index == stack.cachedIndex))
       image = stack.cachedImage;    
    else
        image = stack.getUncachedImage(index);
        
        if (stack.caching)
            stack.cachedIndex = index;
            stack.cachedImage = image;
        end
    end
end

