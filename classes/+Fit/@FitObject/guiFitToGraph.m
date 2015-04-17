function result = guiFitToGraph(this, graph, varargin)
    if (nargin < 2)
        graph = gco;
    end
    
    x = get(graph, 'XData');
    y = get(graph, 'YData');
    
    result = this.guiFit(y, 'XData', x, varargin{:});
end