classdef (Abstract) AbstractTiffStack  < handle & matlab.mixin.Heterogeneous
    %TiffStack manages a file containing a tiff image stack
    
    properties
        caching = true
    end
    properties(Access=private, Transient)
        cachedIndex = []
        cachedImage = []
    end
    
    properties(Dependent)
        size
        height
        width
        imageSize
    end
    
    methods (Abstract)
        size = getSize(this);
        height = getHeight(this);
        width = getWidth(this);
        
        image = getUncachedImage(this, index);
        
        str = char(this);
    end
    
    methods
        
        function size = get.size(this)
            size = this.getSize();
        end
        
        function height = get.height(this)
            height = this.getHeight();
        end
        
        function width = get.width(this)
            width = this.getWidth();
        end
        
        function imageSize = get.imageSize(this)
            imageSize = this.getImageSize();
        end
        
        function imageSize = getImageSize(this)
            imageSize = [this.getHeight(), this.getWidth()];
        end
    end
    
    methods
        function clearCache(this)
            %STACK.CLEARCACHE() deletes the cache of the Tiff stack.
            
            this.cachedIndex = [];
            this.cachedImage = [];
        end
        
        [panel] = getDialogPanel(this, dm, changeCallback)
        dm = dialog(this, waitForClose, segmenter)
    end
end

