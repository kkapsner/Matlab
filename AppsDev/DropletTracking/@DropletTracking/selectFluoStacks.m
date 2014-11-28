function selectFluoStacks(this)

    numBF = numel(this.bfStacks);
    this.numImages = Inf;
    this.numFluo = Inf;
    if (isempty(this.fluoStacks))
        this.fluoStacks = cell(numel(this.bfStacks), 1);
        for i = 1:numBF
            this.fluoStacks{i} = {};
        end
    end
    for i = 1:numBF
        stackManager = StackManager( ...
            ['select fluorescence images for ' this.bfStacks{i}.char()], ...
            this.fluoStacks{i}, ...
            this.folder ...
        );
        stackManager.wait();

        this.fluoStacks{i} = stackManager.stacks;

        this.numImages = min(this.numImages, this.bfStacks{i}.size);
        this.numFluo = min(this.numFluo, numel(this.fluoStacks{i}));
    end
end