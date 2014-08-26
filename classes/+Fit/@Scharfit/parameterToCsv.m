function parameterToCsv(this, varargin)
    
    data = struct('name', {}, 'type', {}, 'value', {}, 'lowerBound', {}, 'upperBound', {});
    fields = {'name', 'type', 'value', 'lowerBound', 'upperBound'};
    
    for p = this.allParameter
        data(end + 1).name = '';
        for f = fields
            data(end).(f{1}) = p.(f{1});
        end
        if (strcmp(p.type(1:5), 'schar'))
            data(end).value = [];
            
            for i = 1:this.scharSize
                data(end + 1).value = p.value(i);
            end
        end
    end
    
    objectToCsv(data, fields, varargin{:});
end