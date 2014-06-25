function h = plot(this, varargin)
    p = inputParser();
    p.KeepUnmatched = true;
    p.addParameter('keepUpdated', false, @islogical);
    p.addParameter('keepValuesUpdated', false, @islogical);
    p.addParameter('keepNameUpdated', false, @islogical);
    p.parse(varargin{:});
    
    unmatchedFields = fieldnames(p.Unmatched)';
    if (isempty(unmatchedFields))
        unmatched = {};
    else
        unmatchedValues = struct2cell(p.Unmatched)';
        unmatched = {unmatchedFields{:}; unmatchedValues{:}};
    end
    
    dataSizes = [this.dataSize];
    
    if (numel(this) == 1 || all(diff(dataSizes) == 0))
        time = [this.time];
        value = [this.value];
    else
        time = nan(max(dataSizes), numel(this));
        value = nan(max(dataSizes), numel(this));
        
        for i = 1:numel(this)
            time(1:dataSizes(i), i) = this(i).time;
            value(1:dataSizes(i), i) = this(i).value;
        end
    end
    
    if (any(size(time) == 0))
        time = nan(2, numel(this));
        value = nan(2, numel(this));
    end
    
    if (size(time, 1) == 1)
        time = vertcat(time, nan(1, numel(this)));
        value = vertcat(value, nan(1, numel(this)));
    end
    
    
    h = plot(time, value, 'DisplayName', {this.traceName}, unmatched{:});
    
    if (p.Results.keepUpdated || p.Results.keepValuesUpdated || p.Results.keepNameUpdated)
        for i = 1:numel(this)
            ha = handle(h(i));
            l = addlistener(this(i), 'change', @(~,~)update(ha, i));
            addlistener(ha, 'ObjectBeingDestroyed', @(~,~)delete(l));
        end
    end
    
    function update(h_, i)
        if (p.Results.keepUpdated || p.Results.keepValuesUpdated)
            h_.YData = this(i).value;
            h_.XData = this(i).time;
        end
        
        if (p.Results.keepUpdated || p.Results.keepNameUpdated)
            h_.DisplayName = this(i).traceName;
        end
    end
end