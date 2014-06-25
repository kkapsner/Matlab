classdef ArbitraryEventData < event.EventData
    %ArbitratyEventData provides a way to store arbitraty data in the
    %event-data.
    
    properties
        data
    end
    
    methods
        function this = ArbitraryEventData(data)
            this.data = data;
        end
    end
    
end

