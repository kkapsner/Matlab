function [varargout] = plot(this, x, varargin)
%PLOT plots the model
    if (~isnumeric(x))
        arg = x;
        x = linspace(this.startX, this.endX, 500);
        h = plot(x, this.feval(x), arg, varargin{:}, 'DisplayName', this.getTextResult());
    else
        h = plot(x, this.feval(x), varargin{:}, 'DisplayName', this.getTextResult());
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

