function normalised = normaliseData(data)
    s = size(data);
    normalised = zeros(s(1), s(2));
    for i = 1:s(2)
        minimun = min(data(:,i));
        maximim = max(data(:,i));
        if (minimun == maximim)
            maximim = minimun + 1;
        end
        normalised(:,i) = (data(:,i) - minimun) / (maximim - minimun);
    end
end