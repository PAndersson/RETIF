function experiment = RT_Experiment_Setup

    %% Initialize setup with defaults
    experiment.Data.format = 'dicom';
    experiment.Data.nameTemplate = '001_000001_$$$$$$.dcm';
    experiment.Data.forceOrder = true;
    experiment.Data.dumpDirectory = 'C:\Dropbox\Work\SUBIC\Projects\Mina\Neurofeedback-Stroke_1\Pilot\export';
    experiment.Data.sizeVol = [64 64 52];
    experiment.Data.nrDummy = 0;
    experiment.Data.nrPrefeed = 15;
    experiment.Data.nrFeed = 90;
    experiment.Data.maskFile = '';
    
    experiment.Files.startupFcn = 'startup function';
    experiment.Files.prefeedbFcn = 'pre-feedback function';
    experiment.Files.prepFcn = 'preparation function';
    experiment.Files.feedbFcn = 'feedback function';
    experiment.Files.prefeedbInstrFile = 'prefeedb instr';
    experiment.Files.feedbInstrFile = 'feedb instr';
    experiment.Files.logTriggers = true;
    
    experiment.MotionCorr.templFile = '';
    experiment.MotionCorr.regmethod = 'SPM';
    experiment.MotionCorr.resolutionSPM = [1 1 1];
    experiment.MotionCorr.nr_iter_boldreg = 50;
    experiment.MotionCorr.spline_ord = 2;
    experiment.MotionCorr.nr_sampl = 5000;
    experiment.Detrending.detmethod = 'SP';
    experiment.Detrending.lambda = 200;
    experiment.Detrending.alpha = 0.95;
    
    experiment.Classifier.classifier = 'Binary_1_ROI';
    experiment.Classifier.scale = 1;
    experiment.Classifier.shift = 0;
    experiment.Classifier.threshold = 0;
    experiment.Classifier.ROI1 = '';
    experiment.Classifier.ROI2 = '';
    experiment.Classifier.ROI3 = '';
    experiment.Classifier.ROI4 = '';
    
    experiment.Application.application = 'No application';
    experiment.Application.screennr = 1;
    experiment.Application.nrDummy = 0;
    
    
    experiment.Localizer.type = 'No localizer';
    experiment.Localizer.nameRegressor = '';
    experiment.Localizer.nrkeep = 50;
    experiment.Localizer.minsze = 1;
    
    %% Figure and tabgroup
    % Create figure
    fig = uifigure('Name', 'Experiment Setup','Position',[20, 60, 750, 600]);
        
    % Create tab group
    tg = uitabgroup(fig, 'Position', [20 20 600 550]);
    
    % 'Open Experiment' button
    btn_open = uibutton(fig,'push','text','Open',...
               'Position',[650, 500, 70, 22],...
               'ButtonPushedFcn', @(btn,event) openButtonPushed(btn));
    % 'Save Experiment' button
    btn_save = uibutton(fig,'push','text','Save',...
               'Position',[650, 450, 70, 22],...
               'ButtonPushedFcn', @(btn,event) saveButtonPushed(btn));
    % 'Run Experiment' button
    btn_run = uibutton(fig,'push','text','Run',...
               'Position',[650, 400, 70, 22],...
               'ButtonPushedFcn', @(btn,event) runButtonPushed(btn));        
           
    
    %% Add tab for Data
    t_Data = uitab(tg, 'Title', 'Data');
    t_Data.Scrollable = 'on';
    
    % format of image files
    label = uilabel(t_Data, 'Position', [10 495 100 15], 'Text','Data file format:');
    dd_format = uidropdown(t_Data,'Position',[10 470 140 22],'Items',{'dicom','nifti','analyze'},'Value',experiment.Data.format);
    
    % name template for image files
    label = uilabel(t_Data, 'Position', [10 445 100 15], 'Text','Name template:');
    ef_nameTemplate = uieditfield(t_Data,'text','Position',[10 420 200 22],'Value',experiment.Data.nameTemplate);
    
    % Enforce subsequent number for new volume
    cb_forceOrder = uicheckbox(t_Data,'Position',[10 390 140 22],'Text','Force order','Value', experiment.Data.forceOrder);
    
    % export directory
    label = uilabel(t_Data, 'Position', [10 365 100 15], 'Text','Export directory:');
    ef_dumpDirectory = uieditfield(t_Data,'text','Position',[10 340 550 22],'Value',experiment.Data.dumpDirectory);
    
    % size of image volume
    label = uilabel(t_Data, 'Position', [10 315 140 15], 'Text','Image volume size:');
    ef_sizeVol = uieditfield(t_Data,'text','Position',[10 290 200 22],'Value',num2str(experiment.Data.sizeVol));
    
    % number of dummy volumes
    label = uilabel(t_Data, 'Position', [10 255 140 15], 'Text','Nr dummy volumes:');
    ef_nrDummy = uieditfield(t_Data,'text','Position',[10 230 200 22],'Value',num2str(experiment.Data.nrDummy));
    
    % number of pre-feedback volumes
    label = uilabel(t_Data, 'Position', [10 205 140 15], 'Text','Nr pre-feedback volumes:');
    ef_nrPrefeed = uieditfield(t_Data,'text','Position',[10 180 200 22],'Value',num2str(experiment.Data.nrPrefeed));
    
    % number of feedback volumes
    label = uilabel(t_Data, 'Position', [10 155 140 15], 'Text','Nr feedback volumes:');
    ef_nrFeed = uieditfield(t_Data,'text','Position',[10 130 200 22],'Value',num2str(experiment.Data.nrFeed));
    
    % mask volume file
    label = uilabel(t_Data, 'Position', [10 95 140 15], 'Text','Mask volume file:');
    ef_maskFile = uieditfield(t_Data,'text','Position',[10 70 200 22],'Value',experiment.Data.maskFile);
    
    
    %% Add tab for Callback functions and Files
    t_Files = uitab(tg, 'Title', 'Callback and Files');
    t_Files.Scrollable = 'on';
    
    % name startup function
    label = uilabel(t_Files, 'Position', [10 495 200 15], 'Text','Name of startup function:');
    ef_startupFcn = uieditfield(t_Files,'text','Position',[10 470 200 22],'Value',experiment.Files.startupFcn);
    
    % name prefeedback function
    label = uilabel(t_Files, 'Position', [10 445 200 15], 'Text','Name of pre-feedback function:');
    ef_prefeedbFcn = uieditfield(t_Files,'text','Position',[10 420 200 22],'Value',experiment.Files.prefeedbFcn);
    
    % name prepare function
    label = uilabel(t_Files, 'Position', [10 395 200 15], 'Text','Name of preparation function:');
    ef_prepFcn = uieditfield(t_Files,'text','Position',[10 370 200 22],'Value',experiment.Files.prepFcn);
    
    % name feedback function
    label = uilabel(t_Files, 'Position', [10 345 200 15], 'Text','Name of feedback function:');
    ef_feedbFcn = uieditfield(t_Files,'text','Position',[10 320 200 22],'Value',experiment.Files.feedbFcn);
    
    % prefeedback instructions file
    label = uilabel(t_Files, 'Position', [10 285 200 15], 'Text','Pre-feedback instructions file:');
    ef_prefeedbInstrFile = uieditfield(t_Files,'text','Position',[10 260 200 22],'Value',experiment.Files.prefeedbInstrFile);
    
    % Feedback instructions file
    label = uilabel(t_Files, 'Position', [10 235 200 15], 'Text','Feedback instructions file:');
    ef_feedbInstr = uieditfield(t_Files,'text','Position',[10 210 200 22],'Value',experiment.Files.feedbInstrFile);
    
    % Log timing of triggers from scanner
    cb_logTriggers = uicheckbox(t_Files,'Position',[10 160 140 22],'Text','Log triggers','Value', experiment.Files.logTriggers);
    
    %% Add tab for Motion Correction
    t_MotionCorr = uitab(tg, 'Title', 'Motion Correction');
    t_MotionCorr.Scrollable = 'on';
    
    % template
    label = uilabel(t_MotionCorr, 'Position', [10 495 200 15], 'Text','Motion correction template volume:');
    ef_templFile = uieditfield(t_MotionCorr,'text','Position',[10 470 550 22],'Value',experiment.MotionCorr.templFile);
    
    % registration method
    label = uilabel(t_MotionCorr, 'Position', [10 445 170 15], 'Text','Registration method:');
    dd_regmethod = uidropdown(t_MotionCorr,'Position',[10 420 140 22],'Items',{'SPM','BOLDreg','None'},'Value',experiment.MotionCorr.regmethod,...
        'ValueChangedFcn',@(dd,event) showpar_align(dd));
    
    % resolution, for spm motion correction
    label_resolutionSPM = uilabel(t_MotionCorr, 'Position', [10 395 140 15], 'Text','Resolution:');
    ef_resolutionSPM = uieditfield(t_MotionCorr,'text','Position',[10 370 200 22],'Value',num2str(experiment.MotionCorr.resolutionSPM));
    
    % nr of iteration, for boldreg motion correction
    label_nr_iter_boldreg = uilabel(t_MotionCorr, 'Position', [10 395 140 15], 'Text','Nr iterations:', 'Visible', false);
    ef_nr_iter_boldreg = uieditfield(t_MotionCorr,'text','Position',[10 370 200 22],'Value',num2str(experiment.MotionCorr.nr_iter_boldreg), 'Visible', false);
    % spline order, for boldreg motion correction
    label_spline_ord = uilabel(t_MotionCorr, 'Position', [10 345 140 15], 'Text','Spline order:', 'Visible', false); 
    ef_spline_ord = uieditfield(t_MotionCorr,'text','Position',[10 320 200 22],'Value',num2str(experiment.MotionCorr.spline_ord), 'Visible', false);
    % nr samples, for boldreg motion correction
    label_nr_sampl = uilabel(t_MotionCorr, 'Position', [10 295 140 15], 'Text','Nr samples:', 'Visible', false);
    ef_nr_sampl = uieditfield(t_MotionCorr,'text','Position',[10 270 200 22],'Value',num2str(experiment.MotionCorr.nr_sampl), 'Visible', false);
    
    
    %% Add tab for Detrending
    t_Detrending = uitab(tg,'Title','Detrending');
    t_Detrending.Scrollable = 'on';
    
    % detrending method
    label = uilabel(t_Detrending, 'Position', [10 495 170 15], 'Text','Detrending method:');
    dd_detmethod = uidropdown(t_Detrending,'Position',[10 470 140 22],'Items',{...
        'SP',...
        'RF',...
        'No detrending'},...
        'Value',experiment.Detrending.detmethod,'ValueChangedFcn',@(dd,event) showpar_detrending(dd));
    
    % lambda, for SP detrending
    label_lambda = uilabel(t_Detrending, 'Position', [10 445 140 15], 'Text','Lambda:');
    ef_lambda = uieditfield(t_Detrending,'text','Position',[10 420 200 22],'Value',num2str(experiment.Detrending.lambda));
    
    % alpha, for RF detrending
    label_alpha = uilabel(t_Detrending, 'Position', [10 395 140 15], 'Text','Alpha:');
    ef_alpha = uieditfield(t_Detrending,'text','Position',[10 370 200 22],'Value',num2str(experiment.Detrending.alpha));
    
    
    
    %% Add tab for Classifier
    t_Classifier = uitab(tg, 'Title', 'Classifier');
    t_Classifier.Scrollable = 'on';
    
    % classifier
    label = uilabel(t_Classifier, 'Position', [10 495 170 15], 'Text','Classifier:');
    dd_classifier = uidropdown(t_Classifier,'Position',[10 470 240 22],'Items',{...
        'Binary_1_ROI',...
        'Continuous_1_ROI',...
        'Continuous_Diff_2_ROIs',...
        'Highest_Average_2_ROIs',...
        'Highest_Average_4_ROIs',...
        'SVM_2_ROIs'},...
        'Value',experiment.Classifier.classifier,'ValueChangedFcn',@(dd,event) showpar_classifier(dd));
    
    % scaling, for classification
    label_scale = uilabel(t_Classifier, 'Position', [10 445 140 15], 'Text','Scaling:');
    ef_scale = uieditfield(t_Classifier,'text','Position',[10 420 200 22],'Value',num2str(experiment.Classifier.scale));
     
    % shift, for classification
    label_shift = uilabel(t_Classifier, 'Position', [10 395 140 15], 'Text','Shift:');
    ef_shift = uieditfield(t_Classifier,'text','Position',[10 370 200 22],'Value',num2str(experiment.Classifier.shift));
        
    % threshold, for classification
    label_threshold = uilabel(t_Classifier, 'Position', [10 345 140 15], 'Text','Threshold:');
    ef_threshold = uieditfield(t_Classifier,'text','Position',[10 320 200 22],'Value',num2str(experiment.Classifier.threshold));
    
    % ROI1, for classification
    label_ROI1 = uilabel(t_Classifier, 'Position', [10 295 140 15], 'Text','ROI 1:');
    ef_ROI1 = uieditfield(t_Classifier,'text','Position',[10 270 550 22],'Value',experiment.Classifier.ROI1);
    
    % ROI2, for classification
    label_ROI2 = uilabel(t_Classifier, 'Position', [10 245 140 15], 'Text','ROI 2:');
    ef_ROI2 = uieditfield(t_Classifier,'text','Position',[10 220 550 22],'Value',experiment.Classifier.ROI2);
    
    % ROI3, for classification
    label_ROI3 = uilabel(t_Classifier, 'Position', [10 195 140 15], 'Text','ROI 3:');
    ef_ROI3 = uieditfield(t_Classifier,'text','Position',[10 170 550 22],'Value',experiment.Classifier.ROI3);
    
    % ROI4, for classification
    label_ROI4 = uilabel(t_Classifier, 'Position', [10 145 140 15], 'Text','ROI 4:');
    ef_ROI4 = uieditfield(t_Classifier,'text','Position',[10 120 550 22],'Value',experiment.Classifier.ROI4);
    
    
    %% Add tab for Application
    t_Application = uitab(tg, 'Title', 'Application');
    t_Application.Scrollable = 'on';
    
    % application
    label = uilabel(t_Application, 'Position', [10 495 170 15], 'Text','Application:');
    dd_application = uidropdown(t_Application,'Position',[10 470 140 22],'Items',{...
        'No application',...
        'Falling'},...
        'Value',experiment.Application.application,'ValueChangedFcn',@(dd,event) showpar_application(dd));
    
    % Screen number to send the window to
    label_screennr = uilabel(t_Application, 'Position', [10 445 150 15], 'Text','Screen nr for application:');
    ef_screennr = uieditfield(t_Application,'text','Position',[10 420 140 22],'Value',num2str(experiment.Application.screennr));
   
    % number of dummy volumes for application  
    label_AppNrDummy = uilabel(t_Application, 'Position', [10 395 190 15], 'Text','Nr dummy scans for application:');
    ef_AppNrDummy = uieditfield(t_Application,'text','Position',[10 370 140 22],'Value',num2str(experiment.Application.nrDummy));
    
    
    %% Add tab for Localizer
    t_Localizer = uitab(tg, 'Title', 'Localizer');
    t_Localizer.Scrollable = 'on';
    
    % localizer
    label = uilabel(t_Localizer, 'Position', [10 495 170 15], 'Text','Localizer:');
    dd_localizer = uidropdown(t_Localizer,'Position',[10 470 140 22],'Items',{...
        'No localizer',...
        'incGLM'},...
        'Value',experiment.Localizer.type,'ValueChangedFcn',@(dd,event) showpar_localizer(dd));
    
    % name regressor file for incGLM
    label_Regressor = uilabel(t_Localizer, 'Position', [10 445 150 15], 'Text','Name regressor file:');
    ef_nameRegressor = uieditfield(t_Localizer,'text','Position',[10 420 550 22],'Value',experiment.Localizer.nameRegressor);
   
    % number of voxels to keep for ROI
    label_nrkeep = uilabel(t_Localizer, 'Position', [10 395 150 15], 'Text','Nr voxels to keep for ROI:');
    ef_nrKeep = uieditfield(t_Localizer,'text','Position',[10 370 100 22],'Value',num2str(experiment.Localizer.nrkeep));
    
    % minimum number of voxels in clusters to keep for ROI
    label_minsze = uilabel(t_Localizer, 'Position', [10 345 150 15], 'Text','Minimum cluster size:');
    ef_minSze = uieditfield(t_Localizer,'text','Position',[10 320 100 22],'Value',num2str(experiment.Localizer.minsze));
    
    
    %% run callback functions once to set GUI according to default selections
    showpar_classifier(dd_classifier);
    showpar_align(dd_regmethod);
    showpar_detrending(dd_detmethod);
    showpar_application(dd_application);
    showpar_localizer(dd_localizer);
    
    %% Update-function
    function update()
        
        experiment.Data.format = dd_format.Value;
        experiment.Data.nameTemplate = ef_nameTemplate.Value;
        experiment.Data.forceOrder = cb_forceOrder.Value;
        experiment.Data.dumpDirectory = ef_dumpDirectory.Value;
        experiment.Data.sizeVol = str2num(ef_sizeVol.Value);
        experiment.Data.nrDummy = str2num(ef_nrDummy.Value);
        experiment.Data.nrPrefeed = str2num(ef_nrPrefeed.Value);
        experiment.Data.nrFeed = str2num(ef_nrFeed.Value);
        experiment.Data.maskFile = ef_maskFile.Value;
        experiment.Files.startupFcn = ef_startupFcn.Value;
        experiment.Files.prefeedbFcn = ef_prefeedbFcn.Value;
        experiment.Files.prepFcn = ef_prepFcn.Value;
        experiment.Files.feedbFcn = ef_feedbFcn.Value;
        experiment.Files.prefeedbInstrFile = ef_prefeedbInstrFile.Value;
        experiment.Files.feedbInstrFile = ef_feedbInstr.Value;
        experiment.Files.logTriggers = cb_logTriggers.Value;
        experiment.MotionCorr.templFile = ef_templFile.Value;
        experiment.MotionCorr.regmethod = dd_regmethod.Value;
        experiment.MotionCorr.resolutionSPM = str2num(ef_resolutionSPM.Value);
        experiment.MotionCorr.nr_iter_boldreg = str2num(ef_nr_iter_boldreg.Value);
        experiment.MotionCorr.spline_ord = str2num(ef_spline_ord.Value);
        experiment.MotionCorr.nr_sampl = str2num(ef_nr_sampl.Value);
        experiment.Detrending.detmethod = dd_detmethod.Value;
        experiment.Detrending.lambda = str2num(ef_lambda.Value);    
        experiment.Detrending.alpha = str2num(ef_alpha.Value);
        experiment.Classifier.classifier = dd_classifier.Value;
        experiment.Classifier.scale = str2num(ef_scale.Value);
        experiment.Classifier.shift = str2num(ef_shift.Value);
        experiment.Classifier.threshold = str2num(ef_threshold.Value);
        experiment.Classifier.ROI1 = ef_ROI1.Value;
        experiment.Classifier.ROI2 = ef_ROI2.Value;
        experiment.Classifier.ROI3 = ef_ROI3.Value;
        experiment.Classifier.ROI4 = ef_ROI4.Value;
 
        experiment.Application.application = dd_application.Value;
        experiment.Application.screennr = str2num(ef_screennr.Value);
        experiment.Application.nrDummy = str2num(ef_AppNrDummy.Value);
        
        experiment.Localizer.type = dd_localizer.Value;
        experiment.Localizer.nameRegressor = ef_nameRegressor.Value;
        experiment.Localizer.nrkeep = str2num(ef_nrKeep.Value);
        experiment.Localizer.minsze = str2num(ef_minSze.Value);
        
    end
    
    %% function
    function showpar_detrending(dd)

        switch dd.Value
            case 'SP'
                label_lambda.Visible = true;
                ef_lambda.Visible = true;
                label_alpha.Visible = false;
                ef_alpha.Visible = false;
            case 'RF'
                label_lambda.Visible = false;
                ef_lambda.Visible = false;
                label_alpha.Visible = true;
                ef_alpha.Visible = true;
            case 'No detrending'
                label_lambda.Visible = false;
                ef_lambda.Visible = false;
                label_alpha.Visible = false;
                ef_alpha.Visible = false;
        end

    end    
    
    %% function
    function showpar_classifier(dd)

        
        switch dd.Value
            case 'Binary_1_ROI'
                label_scale.Visible = true;
                ef_scale.Visible = true;
                label_shift.Visible = true;
                ef_shift.Visible = true;
                label_threshold.Visible = true;
                ef_threshold.Visible = true;
                label_ROI1.Visible = true;
                ef_ROI1.Visible = true;
                label_ROI2.Visible = false;
                ef_ROI2.Visible = false;
                label_ROI3.Visible = false;
                ef_ROI3.Visible = false;
                label_ROI4.Visible = false;
                ef_ROI4.Visible = false;

            case 'Continuous_1_ROI'
                label_scale.Visible = true;
                ef_scale.Visible = true;
                label_shift.Visible = true;
                ef_shift.Visible = true;
                label_threshold.Visible = false;
                ef_threshold.Visible = false;
                label_ROI1.Visible = true;
                ef_ROI1.Visible = true;
                label_ROI2.Visible = false;
                ef_ROI2.Visible = false;
                label_ROI3.Visible = false;
                ef_ROI3.Visible = false;
                label_ROI4.Visible = false;
                ef_ROI4.Visible = false;
                
            case 'Continuous_Diff_2_ROIs'
                label_scale.Visible = true;
                ef_scale.Visible = true;
                label_shift.Visible = true;
                ef_shift.Visible = true;
                label_threshold.Visible = false;
                ef_threshold.Visible = false;
                label_ROI1.Visible = true;
                ef_ROI1.Visible = true;
                label_ROI2.Visible = true;
                ef_ROI2.Visible = true;
                label_ROI3.Visible = false;
                ef_ROI3.Visible = false;
                label_ROI4.Visible = false;
                ef_ROI4.Visible = false;
                
            case 'Highest_Average_2_ROIs'
                label_scale.Visible = true;
                ef_scale.Visible = true;
                label_shift.Visible = true;
                ef_shift.Visible = true;
                label_threshold.Visible = false;
                ef_threshold.Visible = false;
                label_ROI1.Visible = true;
                ef_ROI1.Visible = true;
                label_ROI2.Visible = true;
                ef_ROI2.Visible = true;
                label_ROI3.Visible = false;
                ef_ROI3.Visible = false;
                label_ROI4.Visible = false;
                ef_ROI4.Visible = false;
                
            case 'Highest_Average_4_ROIs'
                label_scale.Visible = true;
                ef_scale.Visible = true;
                label_shift.Visible = true;
                ef_shift.Visible = true;
                label_threshold.Visible = false;
                ef_threshold.Visible = false;
                label_ROI1.Visible = true;
                ef_ROI1.Visible = true;
                label_ROI2.Visible = true;
                ef_ROI2.Visible = true;
                label_ROI3.Visible = true;
                ef_ROI3.Visible = true;
                label_ROI4.Visible = true;
                ef_ROI4.Visible = true;
                
            case 'SVM_2_ROIs'
                label_scale.Visible = false;
                ef_scale.Visible = false;
                label_shift.Visible = false;
                ef_shift.Visible = false;
                label_threshold.Visible = false;
                ef_threshold.Visible = false;
                label_ROI1.Visible = true;
                ef_ROI1.Visible = true;
                label_ROI2.Visible = true;
                ef_ROI2.Visible = true;
                label_ROI3.Visible = false;
                ef_ROI3.Visible = false;
                label_ROI4.Visible = false;
                ef_ROI4.Visible = false;                

        end

    end

    %% function
    function showpar_align(dd)

        switch dd.Value
            case 'BOLDreg'
                label_resolutionSPM.Visible = false;
                ef_resolutionSPM.Visible = false;
                label_nr_iter_boldreg.Visible = true;
                ef_nr_iter_boldreg.Visible = true;
                label_spline_ord.Visible = true;
                ef_spline_ord.Visible = true;
                label_nr_sampl.Visible = true;
                ef_nr_sampl.Visible = true;
            case 'SPM'
                label_resolutionSPM.Visible = true;
                ef_resolutionSPM.Visible = true;
                label_nr_iter_boldreg.Visible = false;
                ef_nr_iter_boldreg.Visible = false;
                label_spline_ord.Visible = false;
                ef_spline_ord.Visible = false;
                label_nr_sampl.Visible = false;
                ef_nr_sampl.Visible = false;
            case 'None'
                label_resolutionSPM.Visible = false;
                ef_resolutionSPM.Visible = false;
                label_nr_iter_boldreg.Visible = false;
                ef_nr_iter_boldreg.Visible = false;
                label_spline_ord.Visible = false;
                ef_spline_ord.Visible = false;
                label_nr_sampl.Visible = false;
                ef_nr_sampl.Visible = false;
        end

    end

    %% function
    function showpar_application(dd)

        switch dd.Value
            case 'No application'
                label_screennr.Visible = false;
                ef_screennr.Visible = false;
                label_AppNrDummy.Visible = false;
                ef_AppNrDummy.Visible = false;
            case 'Falling'
                label_screennr.Visible = true;
                ef_screennr.Visible = true;
                label_AppNrDummy.Visible = true;
                ef_AppNrDummy.Visible = true;
        end

    end

    %% function
    function showpar_localizer(dd)

        switch dd.Value
            case 'No localizer'
                label_Regressor.Visible = false;
                ef_nameRegressor.Visible = false;
                label_nrkeep.Visible = false;
                ef_nrKeep.Visible = false;
                label_minsze.Visible = false;
                ef_minSze.Visible = false;
            case 'incGLM'
                label_Regressor.Visible = true;
                ef_nameRegressor.Visible = true;
                label_nrkeep.Visible = true;
                ef_nrKeep.Visible = true;
                label_minsze.Visible = true;
                ef_minSze.Visible = true;
        end

    end

    % Callback function for the Save button
    function openButtonPushed(btn)

         [FileName,PathName] = uigetfile({'*.m','experiment setup script'},'Open experiment setup');
         %-if Cancel
         if isequal(FileName,0)|isequal(PathName,0)
             return;
         end
         run([PathName,FileName]);
        
        dd_format.Value = experiment.Data.format;
        ef_nameTemplate.Value = experiment.Data.nameTemplate;
        cb_forceOrder.Value = experiment.Data.forceOrder;
        ef_dumpDirectory.Value = experiment.Data.dumpDirectory;
        ef_sizeVol.Value = num2str(experiment.Data.sizeVol);
        ef_nrDummy.Value = num2str(experiment.Data.nrDummy);
        ef_nrPrefeed.Value = num2str(experiment.Data.nrPrefeed);
        ef_nrFeed.Value = num2str(experiment.Data.nrFeed);
        ef_maskFile.Value = experiment.Data.maskFile;
        ef_startupFcn.Value = experiment.Files.startupFcn;
        ef_prefeedbFcn.Value = experiment.Files.prefeedbFcn;
        ef_prepFcn.Value = experiment.Files.prepFcn;
        ef_feedbFcn.Value = experiment.Files.feedbFcn;
        ef_prefeedbInstrFile.Value = experiment.Files.prefeedbInstrFile;
        ef_feedbInstr.Value = experiment.Files.feedbInstrFile;
        cb_logTriggers.Value = experiment.Files.logTriggers;
        ef_templFile.Value = experiment.MotionCorr.templFile;
        dd_regmethod.Value = experiment.MotionCorr.regmethod;
        ef_resolutionSPM.Value = num2str(experiment.MotionCorr.resolutionSPM);
        ef_nr_iter_boldreg.Value = num2str(experiment.MotionCorr.nr_iter_boldreg);
        ef_spline_ord.Value = num2str(experiment.MotionCorr.spline_ord);
        ef_nr_sampl.Value = num2str(experiment.MotionCorr.nr_sampl);
        dd_detmethod.Value = experiment.Detrending.detmethod;
        ef_lambda.Value = num2str(experiment.Detrending.lambda);    
        ef_alpha.Value = num2str(experiment.Detrending.alpha);
        
        dd_classifier.Value = experiment.Classifier.classifier;
        showpar_classifier(dd_classifier);
        ef_scale.Value = num2str(experiment.Classifier.scale);
        ef_shift.Value = num2str(experiment.Classifier.shift);
        ef_threshold.Value = num2str(experiment.Classifier.threshold);
        ef_ROI1.Value = experiment.Classifier.ROI1;
        ef_ROI2.Value = experiment.Classifier.ROI2;
        ef_ROI3.Value = experiment.Classifier.ROI3;
        ef_ROI4.Value = experiment.Classifier.ROI4;
        
        dd_localizer.Value = experiment.Localizer.type;
        showpar_localizer(dd_localizer);
        ef_nameRegressor.Value = experiment.Localizer.nameRegressor;
        ef_nrKeep.Value = num2str(experiment.Localizer.nrkeep);
        ef_minSze.Value = num2str(experiment.Localizer.minsze);
        

        dd_regmethod.Value = experiment.MotionCorr.regmethod;
        showpar_align(dd_regmethod);
        ef_templFile.Value = experiment.MotionCorr.templFile;
        ef_resolutionSPM.Value = num2str(experiment.MotionCorr.resolutionSPM);
        ef_nr_iter_boldreg.Value = num2str(experiment.MotionCorr.nr_iter_boldreg);
        ef_spline_ord.Value = num2str(experiment.MotionCorr.spline_ord);
        ef_nr_sampl.Value = num2str(experiment.MotionCorr.nr_sampl);

        dd_detmethod.Value = experiment.Detrending.detmethod;
        showpar_detrending(dd_detmethod);
        ef_lambda.Value = num2str(experiment.Detrending.lambda);    
        ef_alpha.Value = num2str(experiment.Detrending.alpha);
        
        dd_application.Value = experiment.Application.application;
        showpar_application(dd_application);
        ef_screennr.Value = num2str(experiment.Application.screennr);
        ef_AppNrDummy.Value = num2str(experiment.Application.nrDummy);
        
        figure(fig);
    end



    % Callback function for the Save button
    function saveButtonPushed(btn)

         update();
        
         [FileName,PathName] = uiputfile({'*.m','experiment setup script'},'Save experiment setup');
         %-if Cancel
         if isequal(FileName,0)|isequal(PathName,0)
             return;
         end
         matlab.io.saveVariablesToScript([PathName,FileName],'experiment');
        
        
    end

end

