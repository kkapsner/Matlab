classdef ConfigFile < File
    properties
        values = struct;
    end
    
    methods
        function obj = ConfigFile(path, filename)
            if (nargin < 2)
                filename = '';
            end
            obj@File(path, filename);
        end
        
        function config = read(obj)
            name = [];
            currentS = struct;
            for line = regexp(obj.read@File, '\r\n|\n|\r', 'split')
                trimedLine = strtrim(line{1});
                if isempty(trimedLine) || trimedLine(1) == ';' || trimedLine(1) == '#'
                    continue;
                end
                
                if (trimedLine(1) == '[')
                    
                    parts = regexp( ...
                        trimedLine, ...
                        '^\[(?<name>[^\]]+)\]$', ...
                        'names' ...
                    );
                    if ~isempty(parts)
                        if isempty(name)
                            obj.values = currentS;
                        else
                            obj.values.(name) = currentS;
                        end
                        currentS = struct();
                        name = parts.name;
                    end
                else
                    parts = regexp( ...
                        trimedLine, ...
                        '^(?<key>[^=\s]+)\s*=?\s*(?<value>.*)', ...
                        'names' ...
                    );
                    if ~isempty(parts)
                        key = parts.key;
                        if (strcmp(key(1), '#') || strcmp(key(1), '%' || strcmp(key(1), ';')))
                            continue;
                        end
                        value = strtrim(parts.value);
                        dblValue = str2double(value);
                        if ~isnan(dblValue)
                            value = dblValue;
                        elseif strcmpi(value, 'Yes') || strcmpi(value, 'true')
                            value = true;
                        elseif strcmpi(value, 'No') || strcmpi(value, 'false')
                            value = false;
                        end
                        try
                            currentS.(key) = value;
                        catch e
                            disp(['Not able to set key "' key '". (' e.message ')']);
                        end
                    end
                end
            end
            
            if isempty(name)
                obj.values = currentS;
            else
                obj.values.(name) = currentS;
            end
            config = obj.values;
        end
        
        function write(obj)
            fid = fopen(obj.fullpath, 'w');
            
            structNames = writeStruct(obj.values);
            
            for i = 1:numel(structNames)
                fprintf(fid, '\n[%s]\n', structNames{i});
                writeStruct(obj.values.(structNames{i}));
            end
            
            fclose(fid);
            
            function structNames = writeStruct(s)
                names = fieldnames(s);
                namesLength = max(cellfun(@numel, names));
                structNames = {};

                for nameI = 1:numel(names)
                    name = names{nameI};
                    if isa(s.(name), 'struct')
                        structNames{end + 1} = name;
                        continue;
                    end
                    fprintf(fid, '%*s =', -namesLength, name);
                    if isnumeric(s.(name))
                        fprintf(fid, ' %d\n', s.(name));
                    elseif isa(s.(name), 'logical')
                        if (s.(name))
                            value = 'Yes';
                        else
                            value = 'No';
                        end
                        fprintf(fid, ' %s\n', value);
                    else
                        fprintf(fid, ' %s\n', s.(name));
                    end
                end
            end
        end
        
        function gotAnswers = askForMissing(obj, defaultParam, title)
            if (nargin < 3)
                title = 'Input configuration parameters.';
            end
            gotAnswers = true;
            prompt = {};
            def = {};
            names = fieldnames(defaultParam);
            for i = 1:numel(names)
                name = names{i};
                defaultParam.(name).isnum = isnumeric(defaultParam.(name).value);
                if ~isfield(obj.values, name) || ...
                        defaultParam.(name).isnum ~= isnumeric(obj.values.(name))
                    prompt(end + 1) = {defaultParam.(name).text};
                    if defaultParam.(name).isnum
                        def(end + 1) = {num2str(defaultParam.(name).value)};
                    else
                        def(end + 1) = defaultParam.(name).value;
                    end
                    defaultParam.(name).asked = length(def);
                end
            end
            if isempty(def)
                return;
            end
            
            num_lines = 1;
            answers = inputdlg(prompt,title,num_lines,def);
            
            if isempty(answers)
                gotAnswers = false;
                return;
            end
            
            for i = 1:numel(names)
                name = names{i};
                if isfield(defaultParam.(name), 'asked')
                    if defaultParam.(name).isnum
                        obj.values.(name) = str2double(answers{defaultParam.(name).asked});
                        if isnan(obj.values.(name))
                            obj.values.(name) = defaultParam.(name).value;
                        end
                    else
                        obj.values.(name) = answers{defaultParam.(name).asked};
                    end
                end
            end
        end
        
        function setDefault(obj, defaultParam)
            
            names = fieldnames(defaultParam);
            for i = 1:numel(names)
                name = names{i};
                if ~isfield(obj.values, name)
                    obj.values.(name) = defaultParam.(name);
                end
            end
        end
        
        function uichange(obj, title)
            if (nargin < 2)
                title = 'Input configuration parameters.';
            end
            names = fieldnames(obj.values);
            if isempty(names)
                return;
            end
            
            num = numel(names);
            prompt = cell(1, num);
            def = cell(1, num);
            for i = 1:num
                name = names{i};
                prompt{i} = name;
                def{i} = num2str(obj.values.(name));
            end
            
            num_lines = 1;
            answers = inputdlg(prompt,title,num_lines,def);
            
            if isempty(answers)
                return;
            end
            
            for i = 1:num
                name = names{i};
                value = answers{i};
                if isnumeric(obj.values.(name))
                    dblValue = str2double(value);
                    if ~isnan(dblValue)
                        obj.values.(name) = dblValue;
                    end
                else
                    obj.values.(name) = value;
                end
            end
            
            obj.write;
        end
    end
    
    methods(Static)
        function obj = get(varargin)
            if (nargin < 1)
                filterspec = {'*.*', 'All Files'};
            else
                filterspec = varargin(1);
                filterspec = filterspec{1};
            end
            if (nargin < 2)
                title = '';
            else
                title = varargin(2);
                title = title{1};
            end
            
            [f, p] = uigetfile(filterspec, title);
            obj = ConfigFile(p, f);
        end
    end
end