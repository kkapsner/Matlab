classdef RawDataTrace < AbstractTrace & handle
    
    properties (Dependent)
        meta
    end
    
    properties (SetObservable)
        timeUnit = 's'
        timeName = 'Time'
        
        valueUnit = 'a.u.'
        valueName = 'Value'
        
        name = ''
    end
    properties (Access=private)
        rawValue
        rawTime
        
        rawMeta
    end
    
    methods
        function this = RawDataTrace(time, value, name)
            if (nargin > 0)
                if (isrow(time))
                    time = time';
                end
                if (isrow(value))
                    value = value';
                end
                
                sTime = size(time);
                sValue = size(value);
                if (numel(sTime) ~= 2 || numel(sValue) ~= 2)
                    error('RawDataTrace:invalidDimension', ...
                        'Time and value must have a dimension of two.');
                end
                if (any(sTime == 1))
                    if (numel(time) ~= sValue(1))
                        error('RawDataTrace:sizeMissmatch', ...
                            'Time and value must have same lengths.');
                    end
                    time = reshape(time, [], 1) * ones(1, sValue(2));
                    sTime = sValue;
                else
                    if (any(sTime ~= sValue))
                        error('RawDataTrace:sizeMissmatch', ...
                            'Time and value must have the same size.');
                    end
                end
                this(sTime(2)) = RawDataTrace();
                for i = 1:sTime(2)
                    this(i).rawTime = time(:, i);
                    this(i).rawValue = value(:, i);
                    
                    if (nargin >= 3)
                        if (iscell(name))
                            this(i).name = name{i};
                        else
                            this(i).name = name;
                        end
                    end
                    
                end
                
                this.registerListeners();
            end
        end
        
        function registerListeners(this)
            for i = 1:numel(this)
                addlistener(this(i), 'timeUnit', 'PostSet', @(~,~)this(i).notify('change'));
                addlistener(this(i), 'timeName', 'PostSet', @(~,~)this(i).notify('change'));
                addlistener(this(i), 'valueUnit', 'PostSet', @(~,~)this(i).notify('change'));
                addlistener(this(i), 'valueName', 'PostSet', @(~,~)this(i).notify('change'));
                addlistener(this(i), 'name', 'PostSet', @(~,~)this(i).notify('change'));
            end
        end
        
        function meta = get.meta(this)
            meta = this.getMeta();
        end
        function meta = getMeta(this)
            meta = this.rawMeta;
        end
        function set.meta(this, meta)
            this.setMeta(meta);
        end
        function setMeta(this, meta)
            this.rawMeta = meta;
        end
        
        function value = getValue(this)
            value = this.rawValue;
        end
        function time = getTime(this)
            time = this.rawTime;
        end
        
        function timeUnit = getTimeUnit(this)
            timeUnit = this.timeUnit;
        end
        function timeName = getTimeName(this)
            timeName = this.timeName;
        end
        function valueUnit = getValueUnit(this)
            valueUnit = this.valueUnit;
        end
        function valueName = getValueName(this)
            valueName = this.valueName;
        end
        function name = getName(this)
            name = this.name;
        end
    end
end