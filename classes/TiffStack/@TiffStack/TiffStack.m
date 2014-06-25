classdef TiffStack < handle & matlab.mixin.Heterogeneous
    %TiffStack manages a file containing a tiff image stack
    
    properties
        file
        caching = true
    end
    properties(Access=private, Transient)
        info_
%         link_
        cachedIndex = []
        cachedImage = []
    end
    
    properties(Dependent)
        size
        info
%         link
    end
    
    methods
        function obj = TiffStack(file)
            if (nargin >= 1)
                if (isa(file, 'File'))
                    file = file.fullpath;
                end
%                 if (isa(file, 'char'))
                    obj.file = file;
                    obj.info_ = imfinfo(file);
%                 end
                
%                 w = warning('query', 'MATLAB:imagesci:tiffmexutils:libtiffWarning');
%                 warning('off', w.identifier);
%                 obj.link_ = Tiff(file, 'r');
%                 warning(w.state, w.identifier);
            end
        end
        
        function size = get.size(stack)
            size = stack.getSize();
        end
        function size = getSize(stack)
            %TIFFSTACK.getSize returns the number of images in the stack
            %   overwrite this method in subclasses to overwrite the
            %   dependent .size property
            size = numel(stack.info);
        end
        
        function info = get.info(stack)
            info = stack.getInfo();
        end
        function info = getInfo(stack)
            %TIFFSTACK.getInfo returns the info struct of the stack
            %   overwrite this method in subclasses to overwrite the
            %   dependent .info property
            info = stack.info_;
        end
        
%         function info = get.link(stack)
%             info = stack.getLink();
%         end
%         function info = getLink(stack)
%             %TIFFSTACK.getLink returns the tifflib link of the stack
%             %   overwrite this method in subclasses to overwrite the
%             %   dependent .link property
%             info = stack.link_;
%         end
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
    
    methods (Static)
        stack = guiCreateStack(selectedFile)
        [panel, getParameter] = getGUIParameterPanel(parent, file)
        
        function obj = loadobj(A)
            if (strcmp(class(A), 'TiffStack'))
                obj = TiffStack(A.file);
                obj.caching = A.caching;
            else
                obj = A;
            end
        end
    end
end

