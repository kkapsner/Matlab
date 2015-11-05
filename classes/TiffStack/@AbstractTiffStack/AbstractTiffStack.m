classdef (Abstract) AbstractTiffStack  < handle & matlab.mixin.Heterogeneous & matlab.mixin.Copyable
    %TiffStack manages a file containing a tiff image stack
    
    properties
        caching = true
    end
    properties(Access=private, Transient)
        cachedIndex = []
        cachedImage = []
    end
    properties(SetAccess=private, GetAccess=protected, Transient)
        doDeepCopy = true
    end
    events
        cacheCleared
        nameChanged
        sizeChanged
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
        str = getNamePanelText(this);
        fillNamePanel(this, dm, panel, addText);
    end
    
    methods (Access=protected)
        function [cpStack, originalStacks, copiedStacks] = copyStructureElement(this, originalStacks, copiedStacks)
            this.doDeepCopy = false;
            cpStack = copy(this);
            this.doDeepCopy = true;
            
            originalStacks{end + 1} = this;
            copiedStacks{end + 1} = cpStack;
        end
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
            this.notify('cacheCleared');
        end
        function renewListeners(this, all)
        end
        
        [panel] = getDialogPanel(this, dm, changeCallback)
        dm = dialog(this, waitForClose, segmenter)
        panel = getNamePanel(this, dm, panel);
    end
    
    methods (Static)
        cpStructure = copyStructure(structure)
        
        function obj = loadobj(obj)
            for o = obj
                o.renewListeners();
            end
        end
    end
    
    methods (Static, Access=protected)
        function el = getDefaultScalarElement()
            el = EmptyTiffStack();
        end
        [cp, originalStacks, copiedStacks] = getCopiedStack(stack, originalStacks, copiedStacks)
    end
end

