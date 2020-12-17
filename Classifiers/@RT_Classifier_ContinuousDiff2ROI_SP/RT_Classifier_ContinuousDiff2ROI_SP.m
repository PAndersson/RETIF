classdef RT_Classifier_ContinuousDiff2ROI_SP < RT_Classifier
    
    properties
        threshold % 
        ROIs % 
        meanD
        stdD
        trainsel
        scale
        shift
    end
    
    methods
    
        %Constructor
        function C = RT_Classifier_ContinuousDiff2ROI_SP(input, selector)
            C.scale = input.scale;
            C.trainsel = selector;
            C.shift = 0;
        end
        
        % train classifier
        function C = train(C,ROIs,data,latest_dynnr)
            C.ROIs = ROIs;
            C.meanD = zeros(size(ROIs));
            C.stdD = zeros(size(ROIs));
            
            for k = 1:size(ROIs,2)
                                
%                 %extract data inside ROI
%                 D = data.D(ROIs(:,k),1:latest_dynnr);
                
%                 %detrend over ROI voxels
%                 D = RT_detrend_SP(double(D), 1, 200);

                D = data.detrender.detrend(data, 1, latest_dynnr, ROIs(:,k));
                data.Dfilt{k} = D(:,end);
                
                %compute mean
                C.meanD(ROIs(:,k),k) = mean(D(:,data.selector),2);
                
                %compute standard deviation
                C.stdD(ROIs(:,k),k) = std(D(:,data.selector),0,2);
                
                CS(k,:) = mean( (D-repmat(C.meanD(C.ROIs(:,k),k),1,size(D,2)) )./repmat(C.stdD(C.ROIs(:,k),k),1,size(D,2)));
                
            end
            
            C.scale = 3/max(abs(CS(1,:)-CS(2,:)));
        end
        
        % test data
        function prediction = test(C,data,latest_dynnr)
            
            avg = zeros(size(C.ROIs,2),1);
            
            for k=1:size(C.ROIs,2)
                
                %detrend test sample
                %D = RT_detrend_SP(data.D(C.ROIs(:,k),1:latest_dynnr), 0, 200);
                D = data.detrender.detrend(data, 0, latest_dynnr, C.ROIs(:,k));
                data.Dfilt{k} = D;
                
                %normalize test sample and compute averages inside ROI
                avg(k) = mean( (D-C.meanD(C.ROIs(:,k),k) )./C.stdD(C.ROIs(:,k),k));

            end
            
            prediction = C.scale*(avg(1)-avg(2)) + C.shift;

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