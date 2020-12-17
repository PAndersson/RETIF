 % C = RT_Data(input)
 %       input{1} = size_data (image volume size [nx ny nz])
 %       input{2} = size_t    (nr of time points, volumes)
 %       input{3} = selector (determines timepoints used for mean and std)
 %       input{4} = mask     (3D binary mask selecting voxels to use)

classdef RT_Data < handle
    
    properties
        mask       % 3D mask selecting the data voxels
        D       % (raw) data, 2D 'nr voxels'x'nr time points'
        Dfilt   % Room for filtered data. Needed e.g. for detrending by recursive filtering.
        prediction % the result of the classification
        selector   % timepoints to be included in sdv and mean estimation
        %detrender % detrender object for detrending data 
    end
    
    methods 
        %Constructor
        function C = RT_Data(Data,selector)%size_data, size_t, varargin)
            
            %read mask
            if ~strcmp(Data.maskFile,'')
                %temp = load_nii(filename);
                temp = load_untouch_nii(Data.maskFile);
                temp = logical(single(temp.img));
                C.mask = temp;
            else
                C.mask = true(Data.sizeVol);
            end
            
            %size_data = input{1};
            size_t = Data.nrPrefeed+Data.nrFeed;
            
%             if isempty(input{3})
%                 C.selector = false(1,size_t);
%             else
%                 C.selector = false(1,size_t);
%                 C.selector(1:length(input{3})) = logical(selector);
%             end
            C.selector = logical(selector);
            
            C.D = zeros(nnz(C.mask(:)),size_t);                

%             switch Detrending.detmethod
%                 case 'SP'
%                     C.detrender = RT_Detrender_SP(Detrending);
%                 case 'RF'
%                     C.detrender = RT_Detrender_RF(Detrending);
%                 case 'No detrending'
%                     C.detrender = [];
%             end
            
            C.prediction = NaN(1,size_t);
        end

        
        function C = add_data(C,newdata,nr)
            if ndims(newdata)==2
                C.D(:,nr) = newdata;
            elseif ndims(newdata)==3
                newdata = newdata(C.mask);
                C.D(:,nr) = newdata;
            elseif ndims(newdata)==4
                for k=1:size(newdata,4)
                    temp = squeeze(newdata(:,:,:,k));
                    C.D(:,nr+k-1) = temp(C.mask);
                end
            end
            
        end
        
        function m = mean(C)
            m = mean(C.D(:,C.selector),2);
        end
        
        function s = std(C)
            s = std(C.D(:,C.selector),0,2);
        end
        
        function C = applymask(C,newmask)
          
            if ndims(newmask)==3
                %the mask will now be the union
                %of the previous mask and the new mask
                newmask = logical(newmask);
                temp_mask = newmask(C.mask);%make 1D mask of current data size
                C.mask = C.mask & newmask;
            else %1D
                C.mask(C.mask) = logical(newmask);
                temp_mask = logical(newmask);
            end
  
            C.D = C.D(temp_mask,:);
            
        end
        
%         function datadt = detrend(C,full)
%             datadt = C.detrender.detrend(C,full);
%         end
            
     end % methods 
    
end % classdef