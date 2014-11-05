classdef DistributedTiffStack < TiffStack
    %DISTRIBUTEDTIFFSTACK loads tiff images from varying files
    
    properties
        folder
        fileSchema
        files
    end
    
    methods
        function stack = DistributedTiffStack(folder, fileSchema, files)
            if (isa(folder, 'File'))
                folder = fileparts(folder.fullpath);
            elseif (isa(folder, 'Directory'))
                folder = folder.path;
            end
            stack@TiffStack( ...
                File( ...
                    folder, ...
                    DistributedTiffStack.parseFileSchema(fileSchema, files, 1) ...
                ) ...
            );
            stack.folder = folder;
            stack.fileSchema = fileSchema;
            stack.files = files;
        end
        function size = getSize(stack)
            size = numel(stack.files);
        end
    end
    
    methods(Access=private)
        function path = parsePath(stack, index)
            file = File( ...
                stack.folder, ...
                DistributedTiffStack.parseFileSchema( ...
                    stack.fileSchema, ...
                    stack.files, ...
                    index ...
                ) ...
            );
            path = file.fullpath;
        end
    end
    methods(Static)
        function fileName = parseFileSchema(fileSchema, files, index)
            fileName = sprintf(fileSchema, files(index));
        end
        
        function obj = loadobj(A)
            obj = DistributedTiffStack(A.folder, A.fileSchema, A.files);
            obj.caching = A.caching;
        end
        
        [panel, getParameter] = getGUIParameterPanel(parent, file)
    end
end

