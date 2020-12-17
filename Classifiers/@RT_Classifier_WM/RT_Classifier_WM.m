classdef RT_Classifier_WM < RT_Classifier
    
    properties
        threshold % 
        ROIs % 
        meanD
        stdD
        trainsel
    end
    
    methods
    
        %Constructor
        function C = RT_Classifier_WM(input, selector)
            C.threshold = input{1};
            C.trainsel = selector;
        end
        
        % train classifier
        function C = train(C,ROIs,data,latest_dynnr)
            C.ROIs = ROIs;
            C.meanD = zeros(size(ROIs));
            C.stdD = zeros(size(ROIs));
            thresh = 0.1:.1:3;

            %extract data inside ROI
            D = data.D(ROIs,1:latest_dynnr);
                
            %detrend over ROI voxels
            D =  RT_detrend_SP( double(D), 1,200);
                
            %compute mean
            C.meanD(ROIs) = mean(D(:,data.selector),2);
                
            %compute standard deviation
            C.stdD(ROIs) = std(D(:,data.selector),0,2);
                
            %Determine thresholds by estimating false positives
            temp = mean( ( D-repmat(C.meanD(ROIs),1, latest_dynnr) )...
                ./repmat(C.stdD(ROIs),1, latest_dynnr));
            temp = temp(C.trainsel);
            for m=1:length(thresh) 
                fp(m) = nnz(temp>thresh(m))/length(temp);
            end
            fp = abs(fp - 0.2);
            [temp,ind] = min(fp);
            C.threshold = thresh(ind);
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
            
            if sum(avg>C.threshold)==0
                prediction = 0;
            else
                [temp1,temp2] = max(avg);
                prediction = 1;
            end
            
        end
        
    end
    
end