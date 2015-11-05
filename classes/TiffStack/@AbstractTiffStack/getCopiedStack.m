function [cpStack, originalStacks, copiedStacks] = getCopiedStack(stack, originalStacks, copiedStacks)
    match = cellfun(@(o)o == stack, originalStacks);
    stackIdx = find(match, 1, 'first');
    if (isempty(stackIdx))
        [cpStack, originalStacks, copiedStacks] = stack.copyStructureElement(originalStacks, copiedStacks);
    else
        cpStack = copiedStacks{stackIdx};
    end
end