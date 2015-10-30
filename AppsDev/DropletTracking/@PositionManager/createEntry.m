function entry = createEntry(this)
    
    if (isempty(this.content))
        index = 0;
    else
        index = max(cellfun(@(c)c.index, this.content)) + 1;
    end
    
    entry = Position(index);
end

