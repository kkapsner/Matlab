function [varargout] = plot(this, x, varargin)
%PLOT plots the model
    h = zeros(size(this));
    for i = 1:numel(this)
        if (nargin < 2 || isempty(x) )
            x = linspace(this(i).startX, this(i).endX, 200);
            h(i) = plot(x, this(i).feval(x), varargin{:}, 'DisplayName', this(i).getTextResult());
        elseif (~isnumeric(x))
            arg = x;
            x = linspace(this(i).startX, this(i).endX, 200);
            h(i) = plot(x, this(i).feval(x), arg, varargin{:}, 'DisplayName', this(i).getTextResult());
        else
            h(i) = plot(x, this(i).feval(x), varargin{:}, 'DisplayName', this(i).getTextResult());
        end
    end
    
%     for i = 1:numel(h)
%         ha = handle(h(i));
%         l = addlistener(this, 'change', @(~,~)update(ha, i));
%         addlistener(ha, 'ObjectBeingDestroyed', @(~,~)delete(l));
%     end
%     
%     function update(h_, i)
%         y = this.feval(x);
%         h_.YData = y(:, i);
%     end

    if (nargout > 0)
        varargout{1} = h;
    end
end

