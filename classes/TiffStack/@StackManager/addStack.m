function addStack(this, stacks)
    if (~isempty(stacks))
        if (~iscell(stacks))
            stacks = mat2cell(stacks, ones(size(stacks, 1), 1), ones(size(stacks, 2), 1)); %#ok<MMTC>
        end
        
        for i = 1:numel(stacks)
            
            filter = cellfun(@(s)stacks{i} == s, this.stacks);
            stackIndex = find(filter, 1);
            if (isempty(stackIndex))
                this.stacks{end + 1} = stacks{i};
                this.handles.stackPanels{end + 1} = this.addStackPanel(stacks{i});
            end
        end
        this.arrangeStackContainer();
        notify(this, 'stackAdded');%, stacks);
    end
end