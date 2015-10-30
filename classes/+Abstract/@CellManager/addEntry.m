function addEntry(this, entry)
    if (~isempty(entry))
        if (~iscell(entry))
            entry = num2cell(entry);
        end
        
        for i = 1:numel(entry)
            
            filter = cellfun(@(s)entry{i} == s, this.content);
            entryIndex = find(filter, 1);
            if (isempty(entryIndex))
                this.content{end + 1} = entry{i};
                if (this.isOpen)
                    this.handles.entryPanels{end + 1} = this.addEntryPanel(entry{i});
                end
            end
        end
        this.colorizePanels();
        
        notify(this, 'entryAdded');
    end
end