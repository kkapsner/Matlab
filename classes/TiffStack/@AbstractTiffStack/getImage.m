function image = getImage(this, index)
%getImage extracts an image out of a tiff stack
%   DO NOT OVERWRITE THIS FUNCTION IN SUBCLASSES OF TiffStack!
    if (this.caching && ~isempty(this.cachedIndex) && (index == this.cachedIndex))
       image = this.cachedImage;    
    else
        image = this.getUncachedImage(index);
        
        if (this.caching)
            this.cachedIndex = index;
            this.cachedImage = image;
        end
    end
end

