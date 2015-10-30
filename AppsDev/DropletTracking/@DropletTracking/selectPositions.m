function selectPositions(this)
    positionManager = PositionManager('select positions', this.positions, this.folder);
    positionManager.open();
    positionManager.wait();
    
    filter = cellfun(@(p)numel(p.stacks) ~= 0, positionManager.content);
    this.positions = positionManager.content(filter);
    
    
    this.numImages = Inf;
    this.numFluo = Inf;
    for i = 1:numel(this.positions)
        this.numImages = min(this.numImages, this.positions{i}.stacks{1}.size);
        this.numFluo = min(this.numFluo, numel(this.positions{i}.stacks) - 1);
    end
end