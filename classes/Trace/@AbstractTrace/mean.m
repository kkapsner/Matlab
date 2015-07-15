function meanValue = mean(this)
    meanValue = nan(1, numel(this));
    for i = 1:numel(this)
        o = this(i);
        if o.dataSize > 2
            dValue = diff(o.value);
            dTime = diff(o.time);

            posts = o.value((1:(end - 1))') .* dTime + dValue .* dTime /2;
            meanValue(i) = sum(posts) / (o.time(end) - o.time(1));
        elseif o.dataSize == 1
            meanValue(i) = o.value(1);
        end
    end
end