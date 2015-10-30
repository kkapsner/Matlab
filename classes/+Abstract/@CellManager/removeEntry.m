function removeEntry(this, entry)
    filter = ~cellfun(@(s)entry == s, this.content);
    entryIndex = find(~filter);
    
    if (~isempty(entryIndex))
        this.content = this.content(filter);
        this.handles.innerAPI.removePanel(this.handles.entryPanels{entryIndex});
        this.handles.entryPanels = this.handles.entryPanels(filter);
        
        this.colorizePanels();
        
        notify(this, 'entryRemoved');
    end
end