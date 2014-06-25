function h = showImage(stack, index, varargin)
    h = Image.show(stack.getImage(index), varargin{:});
end