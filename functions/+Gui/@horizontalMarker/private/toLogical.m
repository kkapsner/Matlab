function log = toLogical(log)
%TOLOGICAL converts an input to a logical
%   logicals are returned as they are. Non logical are compared with 'on'.
    if (~isa(log, 'logical'))
        log = strcmpi(log, 'on');
    end
end