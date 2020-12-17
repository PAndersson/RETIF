
classdef RT_Classifier_Continuous1ROI_SP < RT_Classifier
    
    properties
        threshold % 
        ROI % 
        meanD
        stdD
        trainsel
        scale
        shift
    end
    
    methods
    
        %Constructor
        function C = RT_Classifier_Continuous1ROI_SP(input,selector)
            C.trainsel = selector;
            C.shift = 0;
        end
        
        % train classifier
        function C = train(C,ROI,data,latest_dynnr)
            C.ROI = ROI;
            C.meanD = zeros(size(ROI));
            C.stdD = zeros(size(ROI));
                 
            %extract data inside ROI
            D = data.D(ROI,1:latest_dynnr);
            
            %detrend over ROI voxels
            D = RT_detrend_SP(double(D), 1, 200);
            data.Dfilt = D(:,end);
            
            %compute mean
            C.meanD(ROI) = mean(D(:,data.selector),2);
            
            %compute standard deviation
            C.stdD(ROI) = std(D(:,data.selector),0,2);

            CS = mean( (D-repmat(C.meanD(C.ROI),1,size(D,2)) )./repmat(C.stdD(C.ROI),1,size(D,2)));
            %CS = mean( (D-repmat(C.meanD(C.ROI),1,size(D,2)) ));
            %CS = mean(D);
            
            C.scale = 3/max(CS);
            
        end
        
        % test data
        function prediction = test(C,data,latest_dynnr)
            
            %detrend test sample
            D = RT_detrend_SP(data.D(C.ROI,1:latest_dynnr), 0, 200);
            %D = data.D(C.ROI, latest_dynnr);
            data.Dfilt = D;
            
            %normalize test sample and compute averages inside ROI
            prediction = C.scale*mean( (D-C.meanD(C.ROI) )./C.stdD(C.ROI)) + C.shift;
            %prediction = C.scale*mean( (D-C.meanD(C.ROI) ));
            %prediction = mean(D);
            
            
            
        end
        
        % shift baseline down
        function shiftUp(C)  
        
            C.shift = C.shift + 0.2;
            
        end
        
        % shift baseline up
        function shiftDown(C)  
            C.shift = C.shift - 0.2;
        end
        
    end
    
end