classdef RT_Classifier_Highest_Average_4_ROIs < RT_Classifier
    
    properties
        threshold % 
        ROIs % 
        meanD
        stdD
        trainsel
    end
    
    methods
    
        %Constructor
        function C = RT_Classifier_Highest_Average_4_ROIs(input, selector)
            C.threshold = input{1};
            C.trainsel = selector;
        end
        
        % train classifier
        function C = train(C,ROIs,data,latest_dynnr)
            C.ROIs = ROIs;
            C.meanD = zeros(size(ROIs));
            C.stdD = zeros(size(ROIs));
            
            for k = 1:size(ROIs,2)
                
                %extract data inside ROI
                D = data.D(ROIs(:,k),1:latest_dynnr);
                
                %detrend over ROI voxels
                D =  RT_detrend_SP( double(D), 1,200);
                
                %compute mean
                C.meanD(ROIs(:,k),k) = mean(D(:,data.selector),2);
                
                %compute standard deviation
                C.stdD(ROIs(:,k),k) = std(D(:,data.selector),0,2);
                
            end
            
        end
        
        % test data
        function prediction = test(C,data,latest_dynnr)
            
            avg = zeros(size(C.ROIs,2),1);
            
            for k=1:size(C.ROIs,2)
                
                %detrend test sample
                D =  RT_detrend_SP( data.D(C.ROIs(:,k),1:latest_dynnr), 0,200);
                
                %normalize test sample and compute averages inside ROI
                avg(k) = mean( (D-C.meanD(C.ROIs(:,k),k) )./C.stdD(C.ROIs(:,k),k));

            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%
            % OBS!! Add contrast property
            %%%%%%%%%%%%%%%%%%%%%%%%%
            avg = (1/3)*[3 -1 -1 -1;-1 3 -1 -1 ; -1 -1 3 -1; -1 -1 -1 3]*avg;
 
            if sum(avg>C.threshold)==0
                prediction = 0;
            else
                [temp1,temp2] = max(avg);
                
                switch temp2
                    case 1;
                        prediction = 3;
                    case 2;
                        prediction = 7;
                    case 3;
                        prediction = 1;
                    case 4;
                        prediction = 5;
                end
                
                
            end
            
        end
        
    end
    
end