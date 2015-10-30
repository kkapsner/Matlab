function selectBFStacks(this)
    stackManager = StackManager('select BF images', this.bfStacks, this.folder);
    stackManager.open();
    stackManager.wait();

    this.bfStacks = stackManager.stacks;
end