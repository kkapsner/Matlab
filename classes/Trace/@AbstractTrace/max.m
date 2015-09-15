function maxValue = max(this)
    maxValue = nan(1, numel(this));
    for i = 1:numel(this)
        o = this(i);
        maxValue(i) = nanmax(o.value);
    end
end