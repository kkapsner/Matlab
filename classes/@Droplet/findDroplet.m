function index = findDroplet(obj, pos, dataIndex)
%findDroplet searches the droplet array for a droplet that is positioned at
%a certain position in space and time
%   INDEX = DROPLETS.findDroplet(POSITION)
%   INDEX = DROPLETS.findDroplet(POSITION, DATAINDEX)

    if (nargin < 3)
        dataIndex = 1;
    end

%     dPos = vertcat(obj.p(dataIndex, :));
%     dists = sum((ones(numel(obj), 1) * pos(1:2) - dPos).^2, 2);
%     filter = dists <= vertcat(obj.radius(dataIndex));
%     index = find(filter);
    index = 0;
    for i = 1:numel(obj)
        o = obj(i);
        if ( ...
            ~isnan(o.radius(dataIndex)) && ...
            sum((pos - o.p(dataIndex, :)) .^2) <= o.radius(dataIndex)^2 ...
        )
            index = i;
            break;
        end
    end
end