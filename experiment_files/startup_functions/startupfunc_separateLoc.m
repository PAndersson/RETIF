function GUI = startupfunc_separateLoc(GUI)
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % Set plots and axes properties
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      GUI.plotXlim = [1 GUI.experiment.nrfeedback];
      GUI.plotYlim = [-0.1 2.1];     
      
      set(GUI.axesReg,'colororder',GUI.colortemp,'XLim',...
          [1 GUI.plotXtotLim]);
      set(GUI.axesDisp,'colororder',GUI.colortemp,'XLim',GUI.plotXlim);
      
      set(GUI.axesClass,'colororder',GUI.colortemp,'XLim',GUI.plotXlim,'YLim',GUI.plotYlim);
      blockplot(GUI.experiment.feedbackinstr,[-0.1 2.1]);
      hold on;
      GUI.ctrlsgnlplot = plot(1:GUI.experiment.nrfeedback,...
          NaN(1,GUI.experiment.nrfeedback),...
          'LineWidth',2);
      
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % files and folders
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      epi_folder = 'C:\Dropbox\Work\CIMeC\Data\ImagineFaceHouse\19740731IESE_201410281300\LNiF_Schwarzbach_Jens_RTFmriiMAG\10_lnif_epi_3x3x3_dc_rt_fs_L_DiCo\';
      ROI_file1 = 'C:\Dropbox\Work\CIMeC\Analysis\ImagineFaceHouse\19740731IESE_201410281300\10_LocImag_001\F-H__max100LT5.nii';
      ROI_file2 = 'C:\Dropbox\Work\CIMeC\Analysis\ImagineFaceHouse\19740731IESE_201410281300\10_LocImag_001\H-F__max100LT5.nii';
      instruction = 'C:\Dropbox\Work\CIMeC\Analysis\ImagineFaceHouse\19740731IESE_201410281300\instr_ImagFH_LocImag-04-001.txt';
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % create brainmask from first image
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      temp = 'C:\Dropbox\Work\CIMeC\Data\ImagineFaceHouse\19740731IESE_201410281300\LNiF_Schwarzbach_Jens_RTFmriiMAG\6_lnif_epi_3x3x3_dc_rt_fs_L_DiCo\';
      files = dir([temp,'r*.nii']);
      nii = load_untouch_nii([temp,files(1).name]);
      brainmask = double(nii.img);
      Ds = smooth3(brainmask);
      brainmask = Ds>200;
      labels = bwlabeln(brainmask);
      stats = regionprops(labels,'Area');
      [temp,idx] = max([stats.Area]);
      brainmask = ismember(labels, idx);
      brainmask = imfill(brainmask, 'holes');
      
      axes(GUI.axes3D);
      hiso = patch(isosurface(Ds,200),'FaceColor',[1,.75,.65],'EdgeColor','none','FaceAlpha',0.5);
      lightangle(-90,50);
      view(-90,0);
      %daspect([1,1,1.0823]);
      hold on;
      axis off;
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % read ROIs
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      nii = load_untouch_nii(ROI_file1);
      ROI1 = logical(nii.img);
      nii = load_untouch_nii(ROI_file2);
      ROI2 = logical(nii.img);
      %ROI1 = ROI1 & brainmask;
      %ROI2 = ROI2 & brainmask;
      %mask = ROI1|ROI2;
      ROIs(:,1)=ROI1(brainmask);ROIs(:,2)=ROI2(brainmask);

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % read instructions
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      instr = dlmread(instruction);
      labels_train = instr(:,1);
      select_train = logical(instr(:,3));
      select_estim = logical(instr(:,2));
      GUI.experiment.classifier.trainsel = select_train;
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % read data
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
      files = dir([epi_folder,'r*.nii']);
      nrvols = length(files);
      D = RT_Data(size(ROI1), nrvols, select_estim, brainmask);
      for n = 1:nrvols
          nii = load_untouch_nii([epi_folder,files(n).name]);
          temp = single(nii.img);
          D = add_data(D,temp,n);
      end

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % train classifier
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      GUI.experiment.classifier.train(ROIs, D, labels_train, nrvols);
      
      GUI.experiment.data.applymask(brainmask);
      
      