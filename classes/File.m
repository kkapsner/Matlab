classdef File < handle
    properties
        path = ''
        filename = ''
    end
    
    properties (Dependent)
        fullpath
        name
        extension
        basename
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
                    else
                        error('File:invalidParameter', 'Invalid path parameter.');
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
            warning('File:exist:deprecated', 'File.exist() is deprecated. Use File.exists().');
            ex = this.exists();
        end
        
        function ex = exists(this)
            ex = logical(exist(this.fullpath(), 'file'));
        end
        
        function path = get.fullpath(this)
            path = fullfile(this.path, this.filename);
        end
        
        function name = get.name(this)
            [~, name, ~] = fileparts(this.filename);
        end
        
        function basename = get.basename(this)
            [~, basename] = fileparts(this.filename);
        end
        
        function extension = get.extension(this)
            [~, ~, extension] = fileparts(this.filename);
        end
        
        function str = read(obj)
            str = fileread(obj.fullpath());
        end
        
        function write(obj, str, mode)
            if (nargin < 3)
                mode = 'w';
            end
            fid = fopen(obj.fullpath, mode);
            fprintf(fid, '%s', str);
            fclose(fid);
        end
        
        function lines = readLines(obj)
            lines = regexp(obj.read, '\r\n|\n|\r', 'split');
        end
        
        function deleteFile(obj)
            delete(obj.fullpath);
        end
        
        function varargout = copyFile(obj, destination)
            varargout = cell(nargout, 1);
            [varargout{:}] = copyfile(obj.fullpath, destination.fullpath);
        end
		
        function save(obj, variables, flag)
            if (nargin < 3)
                flag = [];
            end
            variableStruct = struct();
            for var = variables
                variableStruct.(var{1}) = evalin('caller', var{1});
            end
            save(obj.fullpath, variableStruct, flag);
		end
        
        function varargout = load(obj, varargin)
            if (nargout)
                varargout = cell(nargout, 1);
                [varargout{:}] = load(obj.fullpath, varargin{:});
            else
                
            end
        end
        
        %% casts
        
        function str = char(obj)
            str = obj.fullpath;
        end
    end
    
    properties (Constant, Transient)
        fileMap = containers.Map;
        fileMapFeatures = containers.Map({'enabled', 'useSameFilename'}, [true, false]);
    end
    
    methods(Static)
        function oldEnable = enableMapFeature(featureName, enable)
            features = File.fileMapFeatures;
            oldEnable = features(featureName);
            if (nargin < 2)
                enable = true;
            end
            features(featureName) = enable;
        end
        function file = getMappedFile(oldFile)
            features = File.fileMapFeatures;
            if (features('enabled'))
                map = File.fileMap;
                if (map.isKey(oldFile.fullpath))
                    file = map(oldFile.fullpath);
                else
                    if (features('useSameFilename'))
                        file = File('', oldFile.filename);
                        if (file.exists())
                            return;
                        end
                    end
                    file = File.get([], ['Select new location of ', oldFile.filename]);
                    map(oldFile.fullpath) = file;
                end
            else
                file = File.empty();
            end
        end
        function file = loadobj(file)
            if (~file.exists())
                file = File.getMappedFile(file);
            end
        end
        
        function file = put(filterspec, title, selectedFile)
            if (nargin < 1)
                filterspec = [];
            end
            if (nargin < 2)
                title = [];
            end
            if (nargin < 3)
                selectedFile = [];
            end
            file = File.get(filterspec, title, 'put', selectedFile);
        end
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