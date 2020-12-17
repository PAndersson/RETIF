
classdef RT_Connector < handle
    
   methods (Abstract)
  
        connect(C)    % connect to the task/control program
        disconnect(C)    % disconnect 
        send(C)     % send classification values
            
    end % methods (Abstract)
    
end % classdef