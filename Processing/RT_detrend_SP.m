function datadt = RT_detrend_SP(data,full,lambda)

    data = double(data)';

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % perform detrending
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    T = size(data,1);  
    I = speye(T);
    D2 = spdiags(ones(T-2,1)*[1 -2 1],[0:2],T-2,T);
    datadt = (I-inv(I+lambda^2*(D2'*D2)))*data;
    
    if full
        datadt = datadt + repmat(data(1,:),[T 1]);
    else
        datadt = datadt(end,:) + data(1,:);
    end

    datadt = single(datadt)';

end