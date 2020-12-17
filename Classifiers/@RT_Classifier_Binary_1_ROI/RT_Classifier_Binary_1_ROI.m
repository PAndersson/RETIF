classdef RT_Classifier_Binary_1_ROI < RT_Classifier
    
    properties
        threshold % 
        ROI % 
        meanD
        stdD
        trainsel
    end
    
    methods
    
        %Constructor
        function C = RT_Classifier_Binary_1_ROI(input,selector)
            C.trainsel = selector;
        end
        
        % train classifier
        function C = train(C,ROI,data,latest_dynnr)
            C.ROI = ROI;
            C.meanD = zeros(size(ROI));
            C.stdD = zeros(size(ROI));
                 
            %extract data inside ROI
            D = data.D(ROI,1:latest_dynnr);
            
            %detrend over ROI voxels
            D = RT_detrend_RF( double(D), zeros(nnz(ROI),1), 1, 0.95);
            data.Dfilt = D(:,end);
            
            %compute mean
            C.meanD(ROI) = mean(D(:,data.selector),2);
            
            %compute standard deviation
            C.stdD(ROI) = std(D(:,data.selector),0,2);

        end
        
        % test data
        function prediction = test(C,data,latest_dynnr)
            
            %detrend test sample
            D = RT_detrend_RF( data.D(C.ROI,1:latest_dynnr), data.Dfilt, 0, 0.95);
            data.Dfilt = D;
            
            %normalize test sample and compute averages inside ROI
            prediction = mean( (D-C.meanD(C.ROI) )./C.stdD(C.ROI));


        end
        
    end
    
end