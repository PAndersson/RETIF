
classdef RT_Collector < handle
    
    properties
        latest_dynnr % latest volume nr
        data % latest data
        nrdummy % number of "dummy volumes"
    end
    events
        NewData; % Notify that new data is available
    end
    
   methods (Abstract)
  
        start(C)    % start waiting for new data
        stop(C)     % stop waiting for new data
        receiver(C) % fetches new data
        send(C)     % notify and hand over new data
            
    end % methods (Abstract)
    
end % classdef