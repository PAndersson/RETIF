classdef RT_Classifier_Continuous_Diff_2_ROIs < RT_Classifier
    
    properties
        ROIs 
        meanD
        stdD
        trainSelector
        scale
        shift
        
        fdata
        
    end
    
    methods
    
        %Constructor
        function C = RT_Classifier_Continuous_Diff_2_ROIs(input, selector, varargin)
            C.scale = input.scale;
            C.trainSelector = selector;
            C.shift = 0;

            if ~isempty(varargin)
                nrvox = varargin{1};
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % read ROIs
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if ~isempty(input.ROI1)
                
                nii = load_untouch_nii(input.ROI1);
                ROI1 = logical(nii.img);
                C.ROIs(:,1) = ROI1(:);
                nii = load_untouch_nii(input.ROI2);
                ROI2 = logical(nii.img);
                C.ROIs(:,2) = ROI2(:);
                
                C.ROIs = logical(C.ROIs);

            else
                C.ROIs = false(nrvox,2);

            end
            C.meanD = zeros(size(C.ROIs));
            C.stdD = zeros(size(C.ROIs));
            C.fdata = zeros(size(C.ROIs));
            
        end
        
        function C = applymask(C,newmask)

                %the ROIs will now be the union
                %of the previous ROIs and the new mask
                newmask = logical(newmask);

                C.ROIs = C.ROIs(newmask,:);
                C.meanD = C.meanD(newmask,:);
                C.stdD = C.stdD(newmask,:);

                C.fdata = C.fdata(newmask,:);
                
        end
        
        % train classifier
        function C = train(C, data, detrender, varargin)
            
            keep_std = false;
            keep_mean = false;
            selector = C.trainSelector;
            if ~isempty(varargin)
                input = varargin{1}; 
                if isfield(input,'keep_std')
                    keep_std = input.keep_std;
                end
                if isfield(input,'keep_mean')
              
                    keep_mean = input.keep_mean;
                end
                if isfield(input,'selector')
                    selector = input.selector;
                end
            end

            
            for k = 1:size(C.ROIs,2)
                
                if ~isempty(detrender)
                    D = detrender.detrend(data,C.fdata(:,k), true, C.ROIs(:,k));
                    C.fdata(C.ROIs(:,k),k) = D(:,end);
                else
                    D = data(C.ROIs(:,k),:);
                end
                
                if ~keep_mean
                    %compute mean
                    %C.meanD(C.ROIs(:,k),k) = mean(data(:,selector),2);
                    C.meanD(C.ROIs(:,k),k) = mean(D(:,selector),2);
                end
                
                if ~keep_std
                    %compute standard deviation
                    %C.stdD(C.ROIs(:,k),k) = std(data(:,selector),0,2);
                    C.stdD(C.ROIs(:,k),k) = std(D(:,selector),0,2);
                end
                
                %CS(k,:) = mean( (D-repmat(C.meanD(C.ROIs(:,k),k),1,size(D,2)) )./repmat(C.stdD(C.ROIs(:,k),k),1,size(D,2)));
                CS(k,:) = mean( (D - repmat(C.meanD(C.ROIs(:,k),k),1,size(D,2)) ) ./ repmat(C.stdD(C.ROIs(:,k),k),1,size(D,2)));
            end
            
            C.scale = 3/max(CS(1,:)-CS(2,:));
        end
        
        % test data
        function prediction = test(C,data, detrender)
            
            avg = zeros(size(C.ROIs,2),1);
            
            for k=1:size(C.ROIs,2)
                
                if ~isempty(detrender)
                    D = detrender.detrend(data,C.fdata(:,k), false, C.ROIs(:,k));
                else
                    D = data(C.ROIs(:,k),end);
                end
                
                %detrend test sample
                %D = RT_detrend_RF( data.D(C.ROIs(:,k),1:latest_dynnr), data.Dfilt{k}, 0, 0.95);
%                 D = data.detrender.detrend(data, false, C.ROIs(:,k));
%                 data.Dfilt{k} = D;
                
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