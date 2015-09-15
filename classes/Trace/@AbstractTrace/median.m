function medianValue = median(this)
    medianValue = nan(1, numel(this));
    for i = 1:numel(this)
        o = this(i);
        medianValue(i) = nanmedian(o.value);
    end
end