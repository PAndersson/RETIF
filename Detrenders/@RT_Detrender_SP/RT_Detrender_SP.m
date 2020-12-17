
classdef RT_Detrender_SP < RT_Detrender
    
    properties
        lambda = 200; %
    end
    
    methods
        %Constructor
        function C = RT_Detrender_SP(input)
            C.lambda = input.lambda;
        end
        
        % detrend data
        function datadt = detrend(C,data,fdata,full,varargin)%,latest_dynnr,varargin)

%             if isempty(varargin)
%                 D = data.D(:,1:latest_dynnr);
%             else
%                 %extract data inside ROI
%                 ROI = varargin{1};
%                 D = data.D(ROI,1:latest_dynnr);
%             end
            if ~isempty(varargin)
                ROI = varargin{1};
                data = data(ROI,:);
            end
            
            datadt = RT_detrend_SP(double(data),full,C.lambda);        
            
        end
        
        
    end %methods
        
    
    
end % classdef