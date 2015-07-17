function trace = createFromGraphicalObject(line)
    if (nargin < 1)
        line = gco;
    end
    trace = RawDataTrace.empty();
    for i = numel(line):-1:1
        x = get(line(i), 'XData');
        y = get(line(i), 'YData');
        name = get(line(i), 'DisplayName');
        trace(i) = RawDataTrace(x, y, name);
    end
end