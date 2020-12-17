
classdef RT_Aligner_boldreg < RT_Aligner
    
    properties
            %template = [];
            nr_iter = 50; % Number of iterations
            spline_ord = 2; % Spline order in the reslicing
            nr_sampl = 5000; % Number of spatial samples used for the cost function
    end
    
    methods
        %Constructor
        function C = RT_Aligner_boldreg(varargin)

            if nargin == 1
                C.template = single(varargin{1});
            elseif nargin == 2

                C.template = single(varargin{1});
                input = varargin{2};
                C.nr_iter = input{1};
                C.spline_ord = input{2};
                C.nr_sampl = input{3};    
            end

        end
        
        % set new image template
        function C = set_template(C,new_template)
            C.template = new_template;
        end
        
        % align image to template
        function [newD, estimated_motion] = align(C,newD)
           [newD, estimated_motion] = boldreg(C.template, newD, C.nr_iter, C.spline_ord, C.nr_sampl);
           newD(newD<0) = 0;
        end
        
    end %methods
        

    
end % classdef