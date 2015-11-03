function cp = copyEntry(this, original)
    
    if (isempty(this.content))
        index = 0;
    else
        index = max(cellfun(@(c)c.index, this.content)) + 1;
    end
    
    cp = copy(original);
    cp.index = index;
end

