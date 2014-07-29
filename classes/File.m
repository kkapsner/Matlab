classdef File < handle
    properties
        path
        filename
    end
    
    properties (Dependent)
        fullpath
        extension
    end
    
    methods
        function this = File(path, filename)
            %FILE constructor of the FILE-class
            %   F = FILE(PATH) creates a FILE instance to a file with the
            %   path PATH. PATH can be an absolute or relative path.
            %   F = FILE(ANOTHERFILEOBJECT) creates a copy of
            %   ANOTHERFILEOBJECT
            %   F = FILE(PATH, FILENAME) create a FILE instance to a file
            %   with the directory path PATH and the filename FILENAME.
            %   PATH can ba an absolute or relative path.
            if (nargin > 0)
                if (nargin < 2 || isempty(filename))
                    if (isa(path, 'char'))
                        [path, filename, ext] = fileparts(path);
                        this.path = path;
                        this.filename = [filename, ext];
                    elseif (isa(path, 'File'))
                        this.path = path.path;
                        this.filename = this.filename;
                    end
                else
                    this.path = path;
                    this.filename = filename;
                end
            end
        end
        
        function set.path(this, path)
            if (isa(path, 'char'))
                this.path = path;
            elseif (isa(path, 'Directory'))
                this.path = path.path;
            else
                this.path = '';
            end
        end
        
        function set.filename(this, filename)
            if (isa(filename, 'char'))
                this.filename = filename;
            else
                this.filename = '';
            end
        end
        
        function ex = exist(this)
            ex = logical(exist(this.fullpath(), 'file'));
        end
        
        function path = get.fullpath(this)
            path = fullfile(this.path, this.filename);
        end
        
        function extension = get.extension(this)
            [~, ~, extension] = fileparts(this.filename);
        end
        
        function str = read(obj)
            str = fileread(obj.fullpath());
        end
        
        function write(obj, str)
            fid = fopen(obj.fullpath, 'w');
            fprintf(fid, '%s', str);
            fclose(fid);
        end
        
        function lines = readLines(obj)
            lines = regexp(obj.read, '\r\n|\n|\r', 'split');
        end
        
        function deleteFile(obj)
            delete(obj.fullpath);
        end
        
        %% casts
        
        function str = char(obj)
            str = obj.fullpath;
        end
    end
    
    methods(Static)
        function file = get(filterspec, title, multiSelect, selectedFile)
            if (nargin < 1 || isempty(filterspec))
                filterspec = {'*.*', 'All Files'};
            end
            if (nargin < 2)
                title = '';
            end
            if (nargin < 3 || isempty(multiSelect))
                multiSelect = 'off';
            end
            
            persistent lastFile;
            if (nargin >= 4 && ~isempty(selectedFile))
                lastFile = char(selectedFile);
            end
            if (isempty(lastFile))
                lastFile = '';
            end
            
            if strcmpi(multiSelect, 'put')
                [f, p] = uiputfile(filterspec, title, lastFile);
            else
                [f, p] = uigetfile(filterspec, title, lastFile, 'MultiSelect', multiSelect);
            end
            if (iscell(f))
                for i = numel(f):-1:1
                    file(i) = File(p, f{i});
                end
                lastFile = file(1).fullpath();
            elseif (~isempty(f) && all(f ~= 0))
                file = File(p, f);
                lastFile = file.fullpath();
            else
                file = File.empty;
            end
        end
    end
end