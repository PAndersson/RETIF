
classdef RT_Aligner < handle
    
    properties
        template = [];% image template, that new images are aligned to
    end
    
   methods (Abstract)
  
        align(C)    % align image to template
        set_template(C)    % set new template
        
    end % methods (Abstract)
    
end % classdef