function normalisedStack = normalise(obj)
%ABSTRACTTIFFSTACK.NORMALISE returns a normalised tiff stack.
%
% SEE ALSO: FUNCTIONTIFFSTACK, FUNCTIONTIFFSTACK.NORMALISED
    normalisedStack = FunctionTiffStack(obj, @FunctionTiffStack.normalised);
end