function cpStructure = copyStructure(structure)
    isCell = iscell(structure);
    if (~isCell)
        structure = num2cell(structure);
    end
    cpStructure = cell(size(structure));
    originalStacks = {};
    copiedStacks = {};
    for idx = 1:numel(structure)
        [cpStructure{idx}, originalStacks, copiedStacks] = ...
            AbstractTiffStack.getCopiedStack(structure{idx}, originalStacks, copiedStacks);
    end
    if (~isCell)
        cpStructure = [cpStructure{:}];
    end
end