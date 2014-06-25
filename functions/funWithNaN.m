function out = funWithNaN(fun, A, varargin)
    out = NaN(size(A));
    for i = 1:size(A, 2)
        a = A(:, i);
        filter = ~isnan(a);
        out(filter, i) = fun(a(filter), varargin{:});
    end
end