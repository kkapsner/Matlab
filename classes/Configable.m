classdef Configable < handle
    %CONFIGABLE makes a class configureable with a config file for better
    %readablity of saved data
    %   
    %   Only scalar and vectoral numeric properties are written/read
    %   to/from the config file.
    %   Also no transient or dependent or constant properties are saved/loaded.
    %
    %   see also: ConfigFile
    
    methods(Access=private)
        function props = getProperties(obj)
            props_ = properties(obj);
            props = cell(size(props_));
            j = 0;
            for i = 1:numel(props_)
                prop = props_{i};
                mp = findprop(obj, prop);
                if (~mp.Transient && ~mp.Dependent && ~mp.Constant)
                    j = j + 1;
                    props{j} = prop;
                end
            end
            props = props(1:j);
        end
    end
    
    methods
        function readFromConfigFile(obj, config, section)
            %READFROMCONFIGFILE reads the configurations in a config file
            %   OBJ.READFORMCONFIGFILE(CONFIG) reads the data from CONFIG.
            %   If CONFIG is a ConfigFile instance the data is directly
            %   read without an additional CONFIG.read() call. If CONFIG is
            %   something different a new ConfigFile instance is created
            %   with CONFIG as parameter and the instance is read.
            
            if ~isa(config, 'ConfigFile')
                config = ConfigFile(config);
                config.read();
            end
            
            if (nargin < 3)
                s = config.values;
            else
                if (isfield(config.values, section))
                    s = config.values.(section);
                else
                    return;
                end
            end
            
            props = obj.getProperties();
            
            for i = 1:numel(props)
                prop = props{i};
                if isfield(s, prop)
                    value = s.(prop);
                    if ischar(value) && all(regexpi(value, '^([+-]?\d+(?:\.\d*)?(?:e[+-]?\d+)?\|)+$') == 1)
                        value = sscanf(value, '%g|')';
                    end
                    obj.(prop) = value;
                end
            end
        end
        
        function writeToConfigFile(obj, config, section)
            %WRITETOCONFIGFILE writes the configurations in a config file
            %   OBJ.WRITETOCONFIGFILE(CONFIG) writes the data to CONFIG.
            %   If CONFIG is a ConfigFile instance the data is directly
            %   written without an additional CONFIG.write() call. If
            %   CONFIG is something different a new ConfigFile instance is
            %   created with CONFIG as parameter and the instance is
            %   written afterwards.
            
            if ~isa(config, 'ConfigFile')
                config = ConfigFile(config);
                config.read();
                saveConfig = true;
            else
                saveConfig = false;
            end
            
            if (nargin < 3)
                section = '';
            end
            
            props = obj.getProperties();
            
            for i = 1:numel(props)
                prop = props{i};
                value = obj.(prop);
                if isnumeric(value) && isvector(value) && ~isscalar(value)
                    value = sprintf('%g|', value);
                end
                
                if isscalar(value) || (ischar(value) && isvector(value))
                    if isempty(section)
                       config.values.(prop) = value;
                    else
                       config.values.(section).(prop) = value;
                    end
                end
            end
            
            if saveConfig
                config.write();
            end
        end
        
        function json = toJSON(obj, replacer, space)
            %TOJSON creates a JSON formated string
            %   OBJ.TOJSON(REPLACER, SPACE) creates a JSON string
            %   containing the whole objects configuration.
            
            if (nargin < 2)
                replacer = [];
            end
            if (nargin < 3)
                space = '';
            end
            
            props = obj.getProperties();
            s = struct();
            
            for i = 1:numel(props)
                prop = props{i};
                value = obj.(prop);
                s.(prop) = value;
            end
            
            json = JSON.stringify(s, replacer, space);
        end
        
        function fromJSON(obj, json, reviver)
            if (nargin < 3)
                reviver = [];
            end
            
            s = JSON.parse(json, reviver);
            
            props = obj.getProperties();
            for i = 1:numel(props)
                prop = props{i};
                if (s.isKey(prop))
                    obj.(prop) = s(prop);
                end
            end
        end
    end
    
end

