classdef TiffStack < AbstractTiffStack
    %TiffStack manages a file containing a tiff image stack
    
    properties
        file
    end
    properties(Access=private, Transient)
        info_
%         link_
    end
    
    properties(Dependent)
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
                    if (~logical(exist(file, 'file')))
                        file = File.get([], ['Select new file location for ', file]);
                        file = file.fullpath;
                    end
                    obj.file = file;
                    obj.info_ = imfinfo(file);
%                 end
                
%                 w = warning('query', 'MATLAB:imagesci:tiffmexutils:libtiffWarning');
%                 warning('off', w.identifier);
%                 obj.link_ = Tiff(file, 'r');
%                 warning(w.state, w.identifier);
            end
        end
        
        function height = getHeight(this)
            height = this.info(1).Height;
        end
        
        function width = getWidth(this)
            width = this.info(1).Width;
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
    
    methods (Static)
        stack = guiCreateStack(selectedFile)
        [panel, getParameter] = getGUIParameterPanel(parent, file)
    end
    
    methods (Static)
        function obj = loadobj(A)
            if (strcmp(class(A), 'TiffStack')) %#ok<STISA>
                try
                    obj = TiffStack(A.file);
                catch
                    obj = A;
                end
                obj.caching = A.caching;
            else
                obj = A;
            end
        end
    end
end

