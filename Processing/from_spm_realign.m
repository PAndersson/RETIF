function P = from_spm_realign%(P,flags)
% Estimation of within modality rigid body movement parameters
% FORMAT P = spm_realign(P,flags)
%
% P     - matrix of filenames {one string per row}
%         All operations are performed relative to the first image.
%         ie. Coregistration is to the first image, and resampling
%         of images is into the space of the first image.
%         For multiple sessions, P should be a cell array, where each
%         cell should be a matrix of filenames.
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
% Inputs
% A series of *.img conforming to SPM data format (see 'Data Format').
%
% Outputs
% If no output argument, then an updated voxel to world matrix is written
% to the headers of the images (a .mat file is created for 4D images).
% The details of the transformation are displayed in the
% results window as plots of translation and rotation.
% A set of realignment parameters are saved for each session, named:
% rp_*.txt.
%__________________________________________________________________________
%
% The voxel to world mappings.
%
% These are simply 4x4 affine transformation matrices represented in the
% NIFTI headers (see http://nifti.nimh.nih.gov/nifti-1 ).
% These are normally modified by the `realignment' and `coregistration'
% modules.  What these matrixes represent is a mapping from
% the voxel coordinates (x0,y0,z0) (where the first voxel is at coordinate
% (1,1,1)), to coordinates in millimeters (x1,y1,z1).
%  
% x1 = M(1,1)*x0 + M(1,2)*y0 + M(1,3)*z0 + M(1,4)
% y1 = M(2,1)*x0 + M(2,2)*y0 + M(2,3)*z0 + M(2,4)
% z1 = M(3,1)*x0 + M(3,2)*y0 + M(3,3)*z0 + M(3,4)
%
% Assuming that image1 has a transformation matrix M1, and image2 has a
% transformation matrix M2, the mapping from image1 to image2 is: M2\M1
% (ie. from the coordinate system of image1 into millimeters, followed
% by a mapping from millimeters into the space of image2).
%
% These matrices allow several realignment or coregistration steps to be
% combined into a single operation (without the necessity of resampling the
% images several times).  The `.mat' files are also used by the spatial
% normalisation module.
%__________________________________________________________________________
% Ref:
% Friston KJ, Ashburner J, Frith CD, Poline J-B, Heather JD & Frackowiak
% RSJ (1995) Spatial registration and normalization of images Hum. Brain
% Map. 2:165-189
%__________________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

% John Ashburner
% $Id: spm_realign.m 4152 2011-01-11 14:13:35Z volkmar $


flags.quality = 0.9;
flags.interp = 2;
flags.wrap = [0 0 0];
flags.sep = 4;
flags.fwhm = 5;
flags.rtm = 1;
flags.PW       = '';
flags.graphics = 1;
flags.lkp      = 1:6;

P = 'C:\Dropbox\Work\CIMeC\Data\ImagineFaceHouse\19740731IESE_201410281300\LNiF_Schwarzbach_Jens_RTFmriiMAG\6_lnif_epi_3x3x3_dc_rt_fs_L_DiCo\Image_6_30_004.nii';
P = [P ; 'C:\Dropbox\Work\CIMeC\Data\ImagineFaceHouse\19740731IESE_201410281300\LNiF_Schwarzbach_Jens_RTFmriiMAG\26_lnif_epi_3x3x3_dc_rt_fs_DiCo\Image_26_30_004.nii'];

tmp = cell(1); 
tmp{1} = P; 
P = tmp;

%Get header information for images.
P = spm_vol(P{1});

skip = sqrt(sum(P(1).mat(1:3,1:3).^2)).^(-1)*flags.sep;

d    = P(1).dim(1:3);                                                                                                                        
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
V   = smooth_vol(P(1), flags.interp, flags.wrap, flags.fwhm);
deg = [flags.interp*[1 1 1]' flags.wrap(:)]; 

[G, dG1, dG2, dG3] = spm_bsplins(V,x1,x2,x3,deg);
clear V

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
A0 = make_A(P(1).mat,x1,x2,x3,dG1,dG2,dG3,lkp);


V  = smooth_vol(P(2),flags.interp,flags.wrap,flags.fwhm);
d  = [size(V) 1 1];
d  = d(1:3);
ss = Inf;
countdown = -1;
for iter=1:64,
    % Rigid body transformation
    [y1,y2,y3] = coords([0 0 0  0 0 0],P(1).mat,P(2).mat,x1,x2,x3);
    
    msk        = find((y1>=1 & y1<=d(1) & y2>=1 & y2<=d(2) & y3>=1 & y3<=d(3)));
    if length(msk)<32, error_message(P(2)); end;
    
    F          = spm_bsplins(V, y1(msk),y2(msk),y3(msk),deg);
    
    
    A          = A0(msk,:);
    b1         = G(msk);
    sc         = sum(b1)/sum(F);
    b1         = b1-F*sc;
    soln       = (A'*A)\(A'*b1);
    
    p          = [0 0 0  0 0 0  1 1 1  0 0 0];
    p(lkp)     = p(lkp) + soln';
    P(2).mat   = inv(spm_matrix(p))*P(2).mat;
    
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now second image is coregistered
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% P(2).mat  is corrected

[x1,x2] = ndgrid(1:P(1).dim(1),1:P(1).dim(2));
C = spm_bsplinc(P(2), deg);
v = zeros(P(1).dim);

for x3 = 1:P(1).dim(3)
    [tmp,y1,y2,y3] = getmask(inv(P(1).mat\P(2).mat),x1,x2,x3,P(2).dim(1:3),flags.wrap);
    v(:,:,x3)      = spm_bsplins(C, y1,y2,y3, deg);
end
            
3;

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
