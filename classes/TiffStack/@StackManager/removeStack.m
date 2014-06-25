function removeStack(this, stack)
    filter = ~cellfun(@(s)stack == s, this.stacks);
    stackIndex = find(~filter);
    
    if (~isempty(stackIndex))
        this.stacks = this.stacks(filter);
        delete(this.handles.stackPanels{stackIndex});
        this.handles.stackPanels = this.handles.stackPanels(filter);
        this.arrangeStackContainer();
        
        notify(this, 'stackRemoved');%, stack);
    end
end