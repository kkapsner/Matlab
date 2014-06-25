function [filtered, filter] = filter(this, raw)
    value = [raw.(this.property)];
    filter = value >= this.lowerRangeLimit & value <= this.upperRangeLimit;
    filtered = raw(filter);
end