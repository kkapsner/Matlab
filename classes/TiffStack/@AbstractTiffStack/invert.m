function invertedStack = invert(obj)
%ABSTRACTTIFFSTACK.INVERT returns an inverted tiff stack.
%
% SEE ALSO: FUNCTIONTIFFSTACK, FUNCTIONTIFFSTACK.NORMALISED
    invertedStack = FunctionTiffStack(obj, @FunctionTiffStack.inverted);
end