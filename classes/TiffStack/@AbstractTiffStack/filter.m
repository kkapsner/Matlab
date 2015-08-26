function filteredStack = filter(obj, cutoffs)
%ABSTRACTTIFFSTACK.NORMALISE returns a filtered tiff stack.
%
%   FILTEREDSTACK = STACK.NORMALISE(CUTOFFS)
%
% SEE ALSO: FILTEREDTIFFSTACK
    filteredStack = FilteredTiffStack(obj, cutoffs);
end