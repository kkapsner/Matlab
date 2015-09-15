function minValue = min(this)
    minValue = nan(1, numel(this));
    for i = 1:numel(this)
        o = this(i);
        minValue(i) = nanmin(o.value);
    end
end