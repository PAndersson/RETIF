
classdef RT_Aligner_spm < RT_Aligner
    
    properties
            %template = [];
            resolution = [1,1,1];
    end
    
    methods
        %Constructor
        function C = RT_Aligner_spm(varargin)
            
            if nargin == 1
                C.template = single(varargin{1});
            elseif nargin == 2
                C.template = single(varargin{1});
                input = varargin{2};
                C.resolution = input{1};
            end

        end
        
        % set new image template
        function C = set_template(C,new_template)
            C.template = new_template;
        end
        
                % align image to template
        function [newD, estimated_motion] = align(C,newD)
            [newD, estimated_motion] = RT_spmreg(C.template, newD, C.resolution);
           newD(newD<0) = 0;
            
        end
        
    end %methods
        

    
end % classdef