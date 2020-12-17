function RT_instructions2regressors(instructionsfile, TR, P)
% Writes a mat-file with regressors, created from an instructions file.
% 
% FORMAT RT_instructions2regressors(instructionsfile, TR, [p])
% instructionsfile    - name of instructions file
% TR   - repetition time
% p    - parameters of the response function (see spm_hrf)



    % Create hrf model using SPM
    if nargin > 2
        hrf = spm_hrf(TR,P);
    else
        hrf = spm_hrf(TR);
    end
    
    %read instructions
    ff = which(instructionsfile);
    instr = dlmread(ff);
    instr = instr(:,1);
    
    %allocate regressors
    regressors = zeros(size(instr,1),max(instr)+2);
    
    %add regressors from instructions
    for k = 1:max(instr)
       temp = double(instr == k); 
       temp = conv(hrf,temp);
       regressors(:,k) = temp(1:size(instr,1));
    end

    %add constant regressor
    regressors(:,end-1) = 1;
    
    %add linear regressor
    regressors(:,end) = linspace(0,1,size(regressors,1));

    %make basic contrasts
    contrasts = eye(size(regressors,2));
    contrasts = contrasts(1:end-2,:);
    
    %save regressors to instructionsfile + '_Regressors.mat'
    [pathstr,name,ext] = fileparts(ff);
    save([pathstr '\' name '_Regressors.mat' ], 'regressors', 'contrasts');


