function [v,parameters] = RT_spmreg(Vol1, Vol2, resolution)
% v = RT_spmreg(Vol1,Vol2,res): Coregisters Vol2 to Vol1
%
% v          -   the corrected version of Vol2
% parameters - the 3 translations and three rotations [xtr ytr ztr pitch roll yaw];
% Vol1    -   template 3D volume
% Vol2    -   3D volume to be adjusted
% resolution     -   resolution [rx ry rz]
%
% flags - a structure containing various options.  The fields are:
%         quality - Quality versus speed trade-off.  Highest quality
%                   (1) gives most precise results, whereas lower
%                   qualities gives faster realignment.
%                   The idea is that some voxels contribute little to
%                   the estimation of the realignment parameters.
%                   This parameter is involved in selecting the number
%                   of voxels that are used.
%
%         fwhm    - The FWHM of the Gaussian smoothing kernel (mm)
%                   applied to the images before estimating the
%                   realignment parameters.
%
%         sep     - the default separation (mm) to sample the images.
%
%         rtm     - Register to mean.  If field exists then a two pass
%                   procedure is to be used in order to register the
%                   images to the mean of the images after the first
%                   realignment.
%
%         PW      - a filename of a weighting image (reciprocal of
%                   standard deviation).  If field does not exist, then
%                   no weighting is done.
%
%         interp  - B-spline degree used for interpolation
%
%__________________________________________________________________________
%
%Adapted from spm_realign.m from SPM8


%Vol1 = 'C:\Dropbox\Work\CIMeC\Data\ImagineFaceHouse\19740731IESE_201410281300\LNiF_Schwarzbach_Jens_RTFmriiMAG\6_lnif_epi_3x3x3_dc_rt_fs_L_DiCo\Image_6_30_004.nii';
%Vol2 = 'C:\Dropbox\Work\CIMeC\Data\ImagineFaceHouse\19740731IESE_201410281300\LNiF_Schwarzbach_Jens_RTFmriiMAG\26_lnif_epi_3x3x3_dc_rt_fs_DiCo\Image_26_30_004.nii';

%Vol1 = load_untouch_nii(Vol1);
%Vol1 = single(Vol1.img);
%Vol2 = load_untouch_nii(Vol2);
%Vol2 = single(Vol2.img);

%resolution = [3 3 3.6];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    Vol1 = single(Vol1);
    Vol2 = single(Vol2);
    
    flags.quality = 0.9;
    flags.interp = 2;
    flags.wrap = [0 0 0];
    flags.sep = 4;
    flags.fwhm = 5;
    flags.rtm = 1;
    flags.PW       = '';
    flags.graphics = 1;
    flags.lkp      = 1:6;
    
    VolStruct(1).dim = size(Vol1);
    VolStruct(2).dim = size(Vol2);
    VolStruct(1).mat = diag([resolution 1]);
    VolStruct(2).mat = diag([resolution 1]);
    
    VolStruct(1).dat = Vol1;
    VolStruct(2).dat = Vol2;
    
    
    %16 for float32 and 0 for endian-ness
    VolStruct(1).dt = [16 0];
    VolStruct(2).dt = [16 0];
    
    
    skip = sqrt(sum(VolStruct(1).mat(1:3,1:3).^2)).^(-1)*flags.sep;
    
    d    = VolStruct(1).dim;
    lkp = flags.lkp;
    rand('state',0); % want the results to be consistant.
    
    [x1,x2,x3] = ndgrid(1:skip(1):d(1)-.5, 1:skip(2):d(2)-.5, 1:skip(3):d(3)-.5);
    x1   = x1 + rand(size(x1))*0.5;
    x2   = x2 + rand(size(x2))*0.5;
    x3   = x3 + rand(size(x3))*0.5;
    
    x1   = x1(:);
    x2   = x2(:);
    x3   = x3(:);
    
    % Compute rate of change of chi2 w.r.t changes in parameters (matrix A)
    %-----------------------------------------------------------------------
    V   = smooth_vol(VolStruct(1), flags.interp, flags.wrap, flags.fwhm);
    deg = [flags.interp*[1 1 1]' flags.wrap(:)];
    
    [G, dG1, dG2, dG3] = spm_bsplins(V,x1,x2,x3,deg);
    clear V
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    A0 = make_A(VolStruct(1).mat,x1,x2,x3,dG1,dG2,dG3,lkp);
    
    
    V  = smooth_vol(VolStruct(2),flags.interp,flags.wrap,flags.fwhm);
    d  = [size(V) 1 1];
    d  = d(1:3);
    ss = Inf;
    countdown = -1;
    for iter=1:64
        % Rigid body transformation
        [y1,y2,y3] = coords([0 0 0  0 0 0],VolStruct(1).mat,VolStruct(2).mat,x1,x2,x3);
        
        msk        = find((y1>=1 & y1<=d(1) & y2>=1 & y2<=d(2) & y3>=1 & y3<=d(3)));
        if length(msk)<32, error_message(VolStruct(2)); end;
        
        F          = spm_bsplins(V, y1(msk),y2(msk),y3(msk),deg);
        
        
        A          = A0(msk,:);
        b1         = G(msk);
        sc         = sum(b1)/sum(F);
        b1         = b1-F*sc;
        soln       = (A'*A)\(A'*b1);
        
        p          = [0 0 0  0 0 0  1 1 1  0 0 0];
        p(lkp)     = p(lkp) + soln';
        VolStruct(2).mat   = inv(spm_matrix(p))*VolStruct(2).mat;
        
        pss        = ss;
        ss         = sum(b1.^2)/length(b1);
        if (pss-ss)/pss < 1e-8 && countdown == -1, % Stopped converging.
            countdown = 2;
        end;
        if countdown ~= -1,
            if countdown==0, break; end;
            countdown = countdown -1;
        end;
    end;
    
    [x1,x2] = ndgrid(1:VolStruct(1).dim(1),1:VolStruct(1).dim(2));
    C = spm_bsplinc(VolStruct(2), deg);
    v = zeros(VolStruct(1).dim);
    
    for x3 = 1:VolStruct(1).dim(3)
        [tmp,y1,y2,y3] = getmask(inv(VolStruct(1).mat\VolStruct(2).mat),x1,x2,x3,VolStruct(2).dim(1:3),flags.wrap);
        v(:,:,x3)      = spm_bsplins(C, y1,y2,y3, deg);
    end
    
    parameters = spm_imatrix(VolStruct(2).mat/VolStruct(1).mat);
    parameters = parameters(1:6);

%==========================================================================
function [Mask,y1,y2,y3] = getmask(M,x1,x2,x3,dim,wrp)
    tiny = 5e-2; % From spm_vol_utils.c
    y1   = M(1,1)*x1+M(1,2)*x2+(M(1,3)*x3+M(1,4));
    y2   = M(2,1)*x1+M(2,2)*x2+(M(2,3)*x3+M(2,4));
    y3   = M(3,1)*x1+M(3,2)*x2+(M(3,3)*x3+M(3,4));
    Mask = true(size(y1));
    if ~wrp(1), Mask = Mask & (y1 >= (1-tiny) & y1 <= (dim(1)+tiny)); end
    if ~wrp(2), Mask = Mask & (y2 >= (1-tiny) & y2 <= (dim(2)+tiny)); end
    if ~wrp(3), Mask = Mask & (y3 >= (1-tiny) & y3 <= (dim(3)+tiny)); end


%_______________________________________________________________________
function [y1,y2,y3]=coords(p,M1,M2,x1,x2,x3)
    % Rigid body transformation of a set of coordinates.
    M  = (inv(M2)*inv(spm_matrix(p))*M1);
    y1 = M(1,1)*x1 + M(1,2)*x2 + M(1,3)*x3 + M(1,4);
    y2 = M(2,1)*x1 + M(2,2)*x2 + M(2,3)*x3 + M(2,4);
    y3 = M(3,1)*x1 + M(3,2)*x2 + M(3,3)*x3 + M(3,4);
return;
%_______________________________________________________________________

%_______________________________________________________________________
function V = smooth_vol(P,hld,wrp,fwhm)
    % Convolve the volume in memory.
    s  = sqrt(sum(P.mat(1:3,1:3).^2)).^(-1)*(fwhm/sqrt(8*log(2)));
    x  = round(6*s(1)); x = -x:x;
    y  = round(6*s(2)); y = -y:y;
    z  = round(6*s(3)); z = -z:z;
    x  = exp(-(x).^2/(2*(s(1)).^2));
    y  = exp(-(y).^2/(2*(s(2)).^2));
    z  = exp(-(z).^2/(2*(s(3)).^2));
    x  = x/sum(x);
    y  = y/sum(y);
    z  = z/sum(z);
    
    i  = (length(x) - 1)/2;
    j  = (length(y) - 1)/2;
    k  = (length(z) - 1)/2;
    d  = [hld*[1 1 1]' wrp(:)];
    V  = spm_bsplinc(P,d);
    spm_conv_vol(V,V,x,y,z,-[i j k]);
return;
%_______________________________________________________________________

%_______________________________________________________________________
function A = make_A(M,x1,x2,x3,dG1,dG2,dG3,lkp)
    % Matrix of rate of change of weighted difference w.r.t. parameter changes
    p0 = [0 0 0  0 0 0  1 1 1  0 0 0];
    A  = zeros(numel(x1),length(lkp));
    for i=1:length(lkp)
        pt         = p0;
        pt(lkp(i)) = pt(i)+1e-6;
        [y1,y2,y3] = coords(pt,M,M,x1,x2,x3);
        tmp        = sum([y1-x1 y2-x2 y3-x3].*[dG1 dG2 dG3],2)/(-1e-6);
        A(:,i) = tmp;
    end
return;
%_______________________________________________________________________
