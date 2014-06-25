function str = char(stack)
%CHAR cast function to char
    [~, foldername] = fileparts(stack.folder);
    str = sprintf('%s: %s', foldername, stack.fileSchema);
end

