classdef RT_incGLM < handle
    
    properties
        
        nrkeep
        minsze
        
        regrfile
        nrvox
        regressors
        contrasts
        nrscan
        tstats
        nrcon
        nrbf
        bn
        cn
        dn
        s2n
    end
    
    methods
        %Constructor
        function C = RT_incGLM(input, nrvox)
            
            C.regrfile = input.nameRegressor;
            C.nrkeep = input.nrkeep;
            C.minsze = input.minsze;
            C.nrvox = nrvox;
            
            if strcmp(C.regrfile,'')
                error('You need to specify a regressor file.');
            elseif exist(C.regrfile)==0
                error('Can not find the regressor file.');
            end
            temp = load(C.regrfile);
            
            %             if GUI.experiment.nrprefeedback~=size(temp.regressors,1)
            %                 error('The regressors length are not equal to the nr of pre-feedback volumes.');
            %             end
            
            C.regressors = temp.regressors;
            C.contrasts = temp.contrasts;
            C.nrcon = size(temp.contrasts,1);
            
            [C.nrscan,C.nrbf] = size(C.regressors);
            C.bn = zeros(C.nrvox,C.nrbf);
            C.cn = zeros(C.nrbf,C.nrbf);
            C.dn = zeros(C.nrvox,C.nrbf);
            C.s2n = zeros(C.nrvox,1);
            
            C.tstats = zeros(C.nrvox,C.nrcon);
        end
        
        function C = selectvox(C,index)
           
            C.nrvox = length(index);
            C.bn = C.bn(index,:);
            C.dn = C.dn(index,:);
            C.s2n = C.s2n(index);
            C.tstats = C.tstats(index,:);

        end
        
        function C = applymask(C,mask)
            mask = logical(mask(:));
            C.nrvox = sum(mask);
            C.bn = C.bn(mask,:);
            C.dn = C.dn(mask,:);
            C.s2n = C.s2n(mask);
            C.tstats = C.tstats(mask,:);

        end
        
        function C = update(C,rt_data,tpoint)
            
            newdata = rt_data.D(:,tpoint);
            newdata = newdata(:);
            
            ft = C.regressors(tpoint,:)';
            
            % update Cn matrix
            C.cn = (tpoint-1)*C.cn/tpoint + ft*ft'/tpoint;
            
            % update Dn matrix
            C.dn = C.dn + newdata*ft';
            
            % sigma n
            C.s2n = C.s2n + newdata.*newdata;
            
            % compute cholesky decomposition to get the normalization matrix Nn
            [nn,p] = chol(C.cn);
            
            if (p == 0) % positive definite
                
                % compute the inverse of nn
                invnn = inv(nn');
                
                % compute An matrix (auxiliary coefficients)
                an = C.dn*invnn'/tpoint;
                
                % compute Bn (regression coefficient matrix)
                C.bn = an*invnn;
                
                % compute sum-of-squares error
                e2n = C.s2n/tpoint - sum(an.*an,2);
                
                e2n = tpoint*e2n/(tpoint-C.nrbf);
                
                % check for errors in e2n, it should be positive
                e2n(e2n <= 0.0) = 1e10;
                
                for k = 1:C.nrcon
                    % estimate new contrast
                    nc = invnn*C.contrasts(k,:)';
                    % compute t-tstat
                    C.tstats(:,k) = (an*nc)./sqrt(e2n.*(nc'*nc)/tpoint);
                end
                %tstats = reshape(tstatR,sze_data);
                
            end
        end
        
    end
    
end