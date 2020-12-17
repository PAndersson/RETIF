function [filename, data, dimen, header,pathname] = read_nifti_dir_SPM(varargin)
%Opens all Nifti or Analyze files in a directory.
%Files needs to be named as: *JKLM.nii
%where JKLM represents three characters of which at least 
%M needs to be a number. 
%The file's number in the sequence is computed as str2num(filename(end-7:end-4))

    if nargin==0
         %Choose file
         [filename, pathname, ext] = uigetfile({'*.nii', 'Nifti files (*.nii)';'*.img','Nifti or Analyze files (*.img)'}, 'Select files','MultiSelect','on');
         if ext==1
             ext = '.nii';
         else
             ext = '.img';
         end
    elseif nargin==1
        if iscell(varargin{1})
            [pathname,filename,temp2] = fileparts(varargin{1}{1});
            pathname = [pathname,'\'];
            filename = cellfun(@(x) x(length(pathname)+1:end), varargin{1}, 'UniformOutput', false);
        else
            [pathname,filename,ext] = fileparts(varargin{1});
            if isempty(filename)
                filename = '*';
                ext = '.nii';
            end
            pathname = [pathname,'\'];
        end
    else
         filename = varargin{2};
         pathname = varargin{1};
         if pathname(end)~='\'
             pathname = [pathname '\'];
         end
         [temp1,filename,ext] = fileparts([pathname,filename]);
         
    end
    
    if ~iscell(filename)
        
        %Find all files
        if strcmp(ext,'.nii')
            temp = [pathname,filename,'.nii'];
        else
            temp = [pathname,filename,'.img'];
        end
        files = dir(temp);
        
        %Order the filenames according to number in string
        names = {files.name};
        num_vec = zeros(1,length(names));
        for i=1:length(names)
            file_nr = names{i};
            file_nr = file_nr(end-7:end-4);
            cn = isstrprop(file_nr, 'digit');
            file_nr(~cn) = '0';
            num_vec(i) = str2num(file_nr);
        end
        [num_vec,ind] = sort(num_vec);
        filename = names(ind);
    end
    
    fname = filename{1};
    avw = nifti([pathname,fname]);
    
    data1 = single(avw.dat(:,:,:));
   
    header = avw.descrip;
    
    %Open the rest of the files and store the data in a 4D matrix
    data = zeros([size(data1),length(filename)],'single');
    
    data(:,:,:,1) = data1;
    h = waitbar(0,'Loading...');
    for i=2:length(filename)
        waitbar(i / length(filename));
        fname = filename{i};
        
        avw = nifti([pathname,fname]);
        
        data(:,:,:,i) = single(avw.dat(:,:,:));
        
    end
    close(h)
    dimen = size(data);
    