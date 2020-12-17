
%%
classdef RETIF < handle
    
    properties (Constant)
        bgrcol = [0.2,0.5,0.8]; % Color of GUI
        colortemp = [1,0,0;0,0,1;0,1,0;0.2,0.08,0.55;0.67,0.14,0.19];
    end
    
    properties
        
        experiment
        
        %%%%%%%%%%%%%%%%%%%
        % GUI components
        %%%%%%%%%%%%%%%%%%%
        figmain % main GUI window
        axesPanel % panel containing the axes
        axes3D % axes for 3D rendering
        axesReg % registration estimates
        axesDisp % axes for additional plots
        axesClass % axes for classification results
        
        %%%%%%%%%%%%%%%%%%%
        % Variables
        %%%%%%%%%%%%%%%%%%%
        
        plotXlim
        plotYlim
        plotXtotLim
        %connector % Connector object
        numvox
        brainmask
        %newdata

        %%%%%%%%%%%%%%%%%%%
        % Handles (plots etc)
        %%%%%%%%%%%%%%%%%%%
        listenerhandle
        sc
        ctrlsgnlplot 
        logfp
        tic
 
        
    end %properties
    
    methods
        
        %% Constructor
        function GUI = RETIF_101
            
            %ask for subject name
            subjname = inputdlg({'ID:','Age:','Gender (M or F):'}, 'Subject details', [1 35; 1 20; 1 20]);
            
            logfile = ['RETIFlog_' subjname{1} '.log'];
            
            % Write to log %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            GUI.logfp = fopen(logfile, 'wt');
            fprintf(GUI.logfp,'----------------------------------------\n');
            c=clock;
            c = [num2str(c(1)) '-' num2str(c(2)) '-' num2str(c(3)) ', ' num2str(c(4)) ':' num2str(c(5)) ':' num2str(fix(c(6)))];
            fprintf(GUI.logfp,'Starting RETIF %s\n\n',c);
            
            fprintf(GUI.logfp,'Subject ID: %s\n',subjname{1});
            fprintf(GUI.logfp,'Subject age: %s\n',subjname{2});
            fprintf(GUI.logfp,'Subject gender: %s\n\n',subjname{3});
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %    Create GUI components
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            GUI.plotXlim = [1 100];
            GUI.plotXtotLim = [1 100];
            
            % Create a new figure for the GUI
            GUI.figmain = figure('Color',GUI.bgrcol,'Position',[10  80  1300  620],'MenuBar','none','CloseRequestFcn', @(event, data) GUI.closefigure);
            set(GUI.figmain,'Colormap',gray(256));
            
            filemenu = uimenu(GUI.figmain,'Label','File');
            uimenu(filemenu,'Label','Open experiment file with parameters','Callback',@(event, data) GUI.openExperiment_callback);
            
            %uipanels for distributing components
            GUI.axesPanel = uipanel('Parent',GUI.figmain,'Position',[0.01 0.15 0.98 0.85], 'BackgroundColor', GUI.bgrcol);
            
            % Create axes for the GUI
            GUI.axes3D = axes('Parent', GUI.axesPanel, 'Units','pixels','Position',[10  270  200  200],'XTick',[],'YTick',[]);
            GUI.axesReg = axes('Parent', GUI.axesPanel, 'Units','pixels','Position',[310  385  930  110],'XLim',GUI.plotXlim,'YLim',[-3 3],'FontSize',8,'FontWeight','bold','XColor',[1 1 0],'YColor',[1 1 0],'NextPlot','replacechildren');
            GUI.axesDisp = axes('Parent', GUI.axesPanel, 'Units','pixels','Position',[310  230  930  110],'XLim',GUI.plotXlim,'YLim',[0 1],'FontSize',8,'FontWeight','bold','XColor',[1 1 0],'YColor',[1 1 0],'NextPlot','replacechildren');
            GUI.axesClass = axes('Parent', GUI.axesPanel, 'Units','pixels', 'Position', [40 50 1200 150],'XLim',GUI.plotXlim,'YLim',[-0.1 1.1],'FontSize',8,'FontWeight','bold','XColor',[1 1 0],'YColor',[1 1 0],'NextPlot','replacechildren');
            
            crap = uicontrol(GUI.axesPanel,'Style','text','String','Estimated Motion',...
                'Position',[700 500 150 15], 'BackgroundColor',GUI.bgrcol,...
                'FontSize',11,'FontWeight','bold','ForegroundColor',[1 1 0]);
            crap = uicontrol(GUI.axesPanel,'Style','text','String','Info',...
                'Position',[720 345 50 15], 'BackgroundColor',GUI.bgrcol,...
                'FontSize',11,'FontWeight','bold','ForegroundColor',[1 1 0]);
            crap = uicontrol(GUI.axesPanel,'Style','text','String','Control Signal',...
                'Position',[40 210 200 20], 'BackgroundColor',GUI.bgrcol,...
                'FontSize',11,'FontWeight','bold','ForegroundColor',[1 1 0]);
            
            % Create the start/stop pushbutton
            startButton = uicontrol(GUI.figmain,'String','Start','callback',@(event, data) GUI.start_callback,...
                'Position',[600 15 70 40]);
            stopButton = uicontrol(GUI.figmain,'String','Stop','callback',@(event, data) GUI.stop_callback,...
                'Position',[700 15 70 40]);
            resetButton = uicontrol(GUI.figmain,'String','Reset','callback',@GUI.reset_callback,...
                'Position',[800 15 70 40]);
            
            baselineUpButton = uicontrol(GUI.figmain,'String','Shift Up','callback',@(event, data) GUI.shiftUp_callback,...
                'Position',[1000 50 70 30]);
            baselineDownButton = uicontrol(GUI.figmain,'String','Shift Down','callback',@(event, data) GUI.shiftDown_callback,...
                'Position',[1000 10 70 30]);
            
            GUI.sc = 1;
            
        end % Constructor
        
        %%
        function start_callback(GUI,dummy)
            if isempty(GUI.tic)
                GUI.tic = tic; 
            end
            
            fprintf(GUI.logfp,'Starting collector \n\n');
            if GUI.experiment.Files.logTriggers
                set(GUI.figmain,'KeyPressFcn',@GUI.trigger_callback);
            end
            GUI.experiment.collector.start();
        end
        
        %%
        function stop_callback(GUI,dummy)
            
            GUI.experiment.collector.stop();
            
            if GUI.experiment.Files.logTriggers
                set(GUI.figmain,'KeyPressFcn',[]);
            end
            
            c=clock;
            c = [num2str(c(1)) '-' num2str(c(2)) '-' num2str(c(3)) ', ' num2str(c(4)) ':' num2str(c(5)) ':' num2str(fix(c(6)))];
            fprintf(GUI.logfp,'\n');
            fprintf(GUI.logfp,'Stopping RETIF %s\n',c);
            fprintf(GUI.logfp,'----------------------------------------\n\n');
            %close file
            fclose(GUI.logfp);
            
        end
        
        %%
        %%
        function shiftUp_callback(GUI,dummy)
            
            GUI.experiment.classifier.shiftUp();
            
        end
        function shiftDown_callback(GUI,dummy)
            
            GUI.experiment.classifier.shiftDown();
            
        end
        
        %% close GUI
        function closefigure(GUI,dummy)
            
            %fprintf(logfid,['--- Ending the RT-fMRI session --- ',datestr(now),'\n']);
            %fprintf(logfid,['%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%',...
            %   '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% \n\n']);
            %fclose(logfid);
            
            
            if isstruct(GUI.experiment)
                %isobject(GUI.experiment.collector)
                %Delete Collector
                GUI.experiment.collector.delete();
                %Delete Connector
                
            end

            %Delete GUI
            delete(GUI.figmain);
            if isfield(GUI.experiment, 'application')
                delete(GUI.experiment.application);
            end
            
        end
        
        %%
        function openExperiment_callback(GUI,dummy)
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            % Choose Experiment file and load parameters
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            [filename, pathname] = uigetfile('*.m', 'Choose Experiment setup file (.m)');
            if isequal(filename,0)
                return;
            end
            run([pathname,filename]);
            GUI.experiment = experiment; %#ok<CPROPLC>
            
            %number of voxels in a single image volume
            nrvox = prod(GUI.experiment.Data.sizeVol);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            % motion correction
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            switch GUI.experiment.MotionCorr.regmethod
            
                case 'None'
                    GUI.experiment.regon = false;
                case 'SPM'
                    GUI.experiment.regon = true;
                    % is a template defined 
                    if ~strcmp(GUI.experiment.MotionCorr.templFile,'')
                        if exist(GUI.experiment.MotionCorr.templFile)~=0
                            %temp = load_nii(filename);
                            temp = load_untouch_nii(GUI.experiment.MotionCorr.templFile);
                            temp = single(temp.img);
                            input{1} = GUI.experiment.MotionCorr.resolutionSPM;
                            GUI.experiment.aligner = RT_Aligner_spm(temp,input);
                        else
                            error('Can not find the template image file (for motion correction).');
                        end
                    else
                        %GUI.experiment.template = [];
                        input{1} = GUI.experiment.MotionCorr.resolutionSPM;
                        GUI.experiment.aligner = RT_Aligner_spm([],input);
                    end
                    
                case 'BOLDreg'
                    GUI.experiment.regon = true;
                    % is a template defined 
                    if ~strcmp(GUI.experiment.MotionCorr.templFile,'')
                        if exist(GUI.experiment.MotionCorr.templFile)~=0
                            %temp = load_nii(filename);
                            temp = load_untouch_nii(GUI.experiment.MotionCorr.templFile);
                            temp = single(temp.img);
                            input{1} = GUI.experiment.MotionCorr.nr_iter_boldreg;
                            input{2} = GUI.experiment.MotionCorr.spline_ord;
                            input{3} = GUI.experiment.MotionCorr.nr_sampl;
                            GUI.experiment.aligner = RT_Aligner_boldreg(temp,input);
                        else
                            error('Can not find the template image file (for motion correction).');
                        end
                    else
                        %GUI.experiment.template = [];
                        input{1} = GUI.experiment.MotionCorr.nr_iter_boldreg;
                        input{2} = GUI.experiment.MotionCorr.spline_ord;
                        input{3} = GUI.experiment.MotionCorr.nr_sampl;
                        GUI.experiment.aligner = RT_Aligner_boldreg([],input);
                    end 
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            % Pre-feedback
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            temp = dlmread(GUI.experiment.Files.prefeedbInstrFile);
            GUI.experiment.prefeedbackinstr = temp(:,1);
            if GUI.experiment.Data.nrPrefeed~=size(GUI.experiment.prefeedbackinstr,1)
                error('The prefeedback instructions are not equal to the nr of pre-feedback volumes.');
            end
            GUI.experiment.estimsel = logical(temp(:,2));
            GUI.experiment.trainsel = logical(temp(:,3));
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            % Localizer   
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            if ~strcmp(GUI.experiment.Localizer.type,'No localizer')
               
                 eval(['GUI.experiment.localizer = RT_' GUI.experiment.Localizer.type '(GUI.experiment.Localizer, nrvox);']);
%                  eval(['GUI.experiment.localizer = ' GUI.experiment.Localize.type '(nrvox,GUI.experiment.localize.input);']);
%                  GUI.experiment.localizer.selectvox(1:nnz(GUI.experiment.mask));
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%
            % Application   
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            if ~strcmp(GUI.experiment.Application.application,'No application')%isfield(GUI.experiment, 'apply')
                eval(['GUI.experiment.application = RT_Application_' GUI.experiment.Application.application '(GUI.experiment.Application);']);
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            % Pre-feedback function   
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            if exist(GUI.experiment.Files.prefeedbFcn)~=2
                error('Can not find the pre-feedback function.');
            else
                eval(['GUI.experiment.prefeedback = @' GUI.experiment.Files.prefeedbFcn ';']);
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            % Preparation function   
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            if exist(GUI.experiment.Files.prepFcn)~=2
                error('Can not find the preparation function.');
            else
                eval(['GUI.experiment.preparation = @' GUI.experiment.Files.prepFcn ';']);
            end

            
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            % Feedback function   
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            if exist(GUI.experiment.Files.feedbFcn)~=2
                error('Can not find the feedback function.');
            else
                eval(['GUI.experiment.feedback = @' GUI.experiment.Files.feedbFcn ';']);
            end
            temp = dlmread(GUI.experiment.Files.feedbInstrFile);
            GUI.experiment.feedbackinstr = temp(:,1);
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            % Classifier   
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            eval(['GUI.experiment.classifier = RT_Classifier_' GUI.experiment.Classifier.classifier '(GUI.experiment.Classifier,GUI.experiment.trainsel,nrvox);']);
            

            %%%%%%%%%%%%%%%%%%%%%%%%%%
            % Data   
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            GUI.plotXtotLim = GUI.experiment.Data.nrPrefeed+GUI.experiment.Data.nrFeed;
%             GUI.experiment.data = RT_Data(GUI.experiment.Data.sizeVol, GUI.plotXtotLim, ...
%                 GUI.experiment.estimsel, GUI.experiment.mask);
            GUI.experiment.data = RT_Data(GUI.experiment.Data,GUI.experiment.estimsel);
            %GUI.experiment.data.applymask(GUI.experiment.mask);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            % Detrender   
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            switch GUI.experiment.Detrending.detmethod
                case 'SP'
                    GUI.experiment.detrender = RT_Detrender_SP(GUI.experiment.Detrending);
                case 'RF'
                    GUI.experiment.detrender = RT_Detrender_RF(GUI.experiment.Detrending);
                case 'No detrending'
                    GUI.experiment.detrender = [];
            end
            
            % Make matrix for motion parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            GUI.experiment.estimated_motion = zeros(GUI.plotXtotLim, 6,'single');
            
            % Collector %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            eval(['GUI.experiment.collector = RT_Collector_' GUI.experiment.Data.format '(GUI.experiment.Data);']);
            
            %add listener for new data
            GUI.listenerhandle = addlistener(GUI.experiment.collector,'NewData',@(src,evnt)processdata(GUI,src,evnt));
            
            % Startup
            if exist(GUI.experiment.Files.startupFcn)~=2
                error('Can not find the startup function.');
            else
                eval(['GUI.experiment.startup = @' GUI.experiment.Files.startupFcn ';']);
            end
            
            %call start_function           
            GUI = GUI.experiment.startup(GUI);
   
        end
        
        function trigger_callback(GUI,fig, event)
            if (event.Key=='5' || event.Key=='t') && ~isempty(GUI.tic)
                disp('Trigger detected');
                
                temp = toc(GUI.tic);
                fprintf(GUI.logfp, 'Trigger detected\t%f\n',temp);
            end
        end
        
        
        function processdata(GUI,collectorobj,dummy)


            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Pre-feedback
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if GUI.experiment.collector.latest_dynnr < GUI.experiment.Data.nrPrefeed
                
                fprintf(GUI.logfp,'Calling Prefeedback function \n');
                GUI = GUI.experiment.prefeedback(GUI);
                
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Feedback Preparation
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            elseif GUI.experiment.collector.latest_dynnr == GUI.experiment.Data.nrPrefeed
                
                fprintf(GUI.logfp,'Calling Preparation function \n');
                GUI = GUI.experiment.preparation(GUI);
                
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Feedback
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            elseif GUI.experiment.collector.latest_dynnr < GUI.plotXtotLim
                
                fprintf(GUI.logfp,'Calling Feedback function \n');
                GUI = GUI.experiment.feedback(GUI);
                
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Last volume
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            else
                fprintf(GUI.logfp,'Calling Feedback function \n');
                GUI = GUI.experiment.feedback(GUI);
                
                collectorobj.stop();
                disp('Finished!');
            end
           
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Update plots
            %%%%%%%%%%%%%%%%%%%%%%%%%%%
            % estimated motion
            axes(GUI.axesReg);
            regplot = plot(1:GUI.plotXtotLim,10*GUI.experiment.estimated_motion(:,1:3), 'b', ...
                           1:GUI.plotXtotLim,GUI.experiment.estimated_motion(:,4:6),'r');
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Restart Collector    
            %%%%%%%%%%%%%%%%%%%%%%%%%%%
            if GUI.experiment.collector.latest_dynnr < GUI.plotXtotLim
                collectorobj.start();
            end
        end
    end

    
    
end % classdef


