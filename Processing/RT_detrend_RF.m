function datadt = RT_detrend_RF(data,fdata,full,alpha)

    data = double(data)';
    fdata = fdata';
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % perform detrending
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %T = size(data,1); 
    if full
        datadt = zeros(size(data));
        for k = 2:size(data,1)
            fdata = 0.5*(1+alpha)*data(k,:) - 0.5*(1+alpha)*data(k-1,:) + alpha*fdata;
            datadt(k,:) = fdata;
        end
        %datadt = datadt + repmat(data(1,:),[T 1]);
    else
        datadt = 0.5*(1+alpha)*data(end,:) - 0.5*(1+alpha)*data(end-1,:) + alpha*fdata;
        %datadt = fdata + data(1,:);
    end

    datadt = single(datadt)';

end