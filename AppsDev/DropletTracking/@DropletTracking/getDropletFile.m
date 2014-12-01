function file = getDropletFile(this, bfStack)
    number = regexprep(bfStack.char(), '\D', '');
    file = File(this.folder, sprintf('droplets_%s.mat', number));
    num = 0;
    while file.exists()
        num = num + 1;
        file = File(this.folder, sprintf('droplets_%s (%d).mat', number, num));
    end
end