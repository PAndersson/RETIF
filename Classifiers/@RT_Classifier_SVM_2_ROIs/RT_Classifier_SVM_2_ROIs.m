classdef RT_Classifier_SVM_2_ROIs < RT_Classifier
    
    properties
        threshold % 
        ROIs % 
        meanD
        stdD
        trainsel
        SVM
    end
    
    methods
    
        %Constructor
        function C = RT_Classifier_SVM_2_ROIs(input, varargin)
            C.threshold = input{1};
            if isempty(varargin)
                C.trainsel = [];
            elseif length(varargin)==1
                C.trainsel = varargin{1};
            end
        end
        
        % train classifier
        function C = train(C,ROIs,data,instructions,latest_dynnr)
            
            %Merge ROIs
            C.ROIs = ROIs(:,1)|ROIs(:,2);
             
            %extract data inside ROI
            D = data.D(C.ROIs,1:latest_dynnr);
                
            %detrend over ROI voxels
            %D = RT_detrend_RF( double(D), zeros(nnz(ROIs),1), 1, 0.95);
            %data.Dfilt = D(:,end);
                
            %compute mean
            C.meanD = mean(D(:,data.selector),2);
                
            %compute standard deviation
            C.stdD = std(D(:,data.selector),0,2);
                
            %normalize training data
            D = (D-repmat(C.meanD,1,latest_dynnr))./repmat(C.stdD,1,latest_dynnr);
           
            %-q   : quiet
            %-t 0 : linear kernel
            %-c 1 : C-parameter
            %-s 0 : C-SVC (multi-class)
            C.SVM = svmtrain_RETIF(instructions(C.trainsel), double(D(:,C.trainsel))', '-q -t 0 -c 1 -s 0');
            
            
        end
        
        % test data
        function [prediction, prob_est, accuracy] = test(C,data,latest_dynnr)
           
            %detrend test sample
            %D =  RT_detrend_RF(data.D(C.ROIs,1:latest_dynnr), data.Dfilt, 0, 0.95);
            %data.Dfilt = D;
                
            %extract data inside ROI
            D = data.D(C.ROIs,latest_dynnr);
            
            %normalize test sample
            D = (D-C.meanD)./C.stdD;
            [prediction, accuracy, prob_est] = svmpredict_RETIF(1, double(D)', C.SVM, '-q');

      
        end
        
    end
    
end