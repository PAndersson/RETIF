% recursive filtering
classdef RT_Detrender_RF < RT_Detrender
    
    properties
        alpha = 0.95; %
    end
    
    methods
        %Constructor
        function C = RT_Detrender_RF(input)
            C.alpha = input.alpha;
        end
        
        % detrend data
        function datadt = detrend(C,data,fdata,full, varargin)%C,data,fdata,full)
            
            if ~isempty(varargin)
                ROI = varargin{1};
                data = data(ROI,:);
                fdata = fdata(ROI);
            end
            
            datadt = RT_detrend_RF(data,fdata,full,C.alpha);
            
        end
        
        
    end %methods
        
    
    
end % classdef