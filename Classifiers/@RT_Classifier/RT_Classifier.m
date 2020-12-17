classdef RT_Classifier < handle
    
    methods (Abstract)
        train(C)    % train classifier
        test(C)     % test data
    end % methods (Abstract)
    
    methods
        
        function shiftUp(C)  % shift baseline down
        end
        function shiftDown(C)  % shift baseline up
        end
        
    end % methods
    
end