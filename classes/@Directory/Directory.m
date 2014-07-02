classdef Directory < handle
    properties (Dependent)
        path
    end
    
    properties (Access=private)
        parentPath
        folderName
    end
    
    methods
        function obj = Directory(path)
            if (nargin < 1)
                path = pwd;
            end
            obj.path = path;
        end
        
        function set.path(obj, path)
            if (isa(path, 'char'))
                [path, tailing, extension] = fileparts(path);
                if (isempty(tailing) && isempty(extension))
                    [path, tailing, extension] = fileparts(path);
                end
                
                obj.parentPath = path;
                obj.folderName = [tailing extension];
            elseif (isa(path, 'Directory'))
                obj.parentPath = path.parentPath;
                obj.folderName = path.parentPath;
            else
                obj.parentPath = '';
                obj.folderName = '';
            end
        end
        
        function value = get.path(obj)
            value = [obj.parentPath filesep obj.folderName];
        end
        
        function ex = exist(obj)
            ex = exist(obj.path, 'dir');
        end
        
        function create(obj)
            if (~obj.exist())
                mkdir(obj.parentPath, obj.folderName);
            end
        end
        
        function status = rename(obj, newname)
            status = movefile(obj.path, [obj.parentPath filesep newname]);
            if status
                obj.folderName = newname;
            end
        end
        
        function status = move(obj, newParentPath)
            if isa(newParentPath, 'Directory')
                newParentPath = newParentPath.path;
            end
            status = movefile(obj.path, [newParentPath filesep obj.newname]);
            if status
                obj.parentPath = newParentPath;
            end
        end
        
        function c = createChild(obj, foldername)
            c = obj.child(foldername);
            if (~c.exist)
                mkdir(obj.path, foldername);
            end
        end
        
        function c = child(obj, child)
            c = Directory(0);
            c.parentPath = obj.path;
            c.folderName = child;
        end
        
        function p = parent(obj)
            p = Directory(obj.parentPath);
        end
        
        function isEq = eq(obj, eqDir)
            isEq = isa(eqDir, 'Directory') && strcmp(obj.path, eqDir.path);
        end
    end
    
    %converter
    methods
        c = char(obj)
    end
    
    methods(Static)
        obj = get(startpath, title)
    end
end
    