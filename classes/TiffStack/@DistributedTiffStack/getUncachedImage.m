function image = getUncachedImage(stack, index)
    
    image = imread(stack.parsePath(index), 'tif', 'Index', 1);
end

