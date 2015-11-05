function filteredStack = filter(obj, cutoffs)
%ABSTRACTTIFFSTACK.FILTER returns a filtered tiff stack.
%
%   FILTEREDSTACK = STACK.FILTER(CUTOFFS)
%
% SEE ALSO: FILTEREDTIFFSTACK
    filteredStack = FilteredTiffStack(obj, cutoffs);
end