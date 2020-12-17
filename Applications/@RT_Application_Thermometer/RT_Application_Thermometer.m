classdef RT_Application_Thermometer < RT_Application
    
    properties
        bgrcol = [0.2 0.2 0.2];
        bslcol = [0.5 0.5 0.5];
        poscol = [0.1 1.0 0.1];
        negcol = [1.0 0.1 0.1];
        
        margin = 0.02;
        L1 = 0.02;
        L2 = 0.1;
        outlinealpha = 0.3;
        marker_sze = 10;
        
        %%%%%%%%%%%%%%%%
        
        figapp
        FigH
        ax
        bar
        fix
        screennr
        bline
        oline
        
        %%%%%%%%%%%%%%%%
        com
        instructions
        instrnr
        GUI_tic 
        logfp
        nrdummy 
        
    end
    
    methods
    
        %Constructor
        function C = RT_Application_Thermometer(varargin) %screennr)
            
            if nargin == 1
                input = varargin{1};
                C.screennr = input{1};
                if length(input)==1
                    C.nrdummy = 0;
                else
                    C.nrdummy = input{2};
                end
            else
                C.screennr = 1;
                C.nrdummy = 0;
            end
                
            C.figapp = figure('Color',C.bgrcol,'Position',[0  0  500  500],'MenuBar','none','KeyPressFcn',@C.callback_keypress,'CloseRequestFcn', @(event, data) C.delete);

            if verLessThan('matlab', '8.4')
                C.FigH = C.figapp;
            else
                C.FigH = C.figapp.Number;
            end
 
            C.ax = axes;
            %C.ax.Units = 'Normalized';
            %axis(C.ax,'equal',[-0.5 0.5 -0.5 0.5],'off');
            %C.ax.Position = [0.3 0.3 0.4 0.4];
            set(C.ax, 'Units', 'Normalized');
            axis(C.ax);
            axis equal;axis off;
            set(C.ax, 'XLim', [-0.5 0.5], 'YLim', [-1 1]);%[-0.5 0.5], 'YLim', [-0.5 0.5]);
            set(C.ax, 'Position', [0.3 0.3 0.4 0.4]);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Baseline
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            x = [-0.2 -0.2 0.2 0.2]*2;
            y = [-0.01 0.01 0.01 -0.01]*2;
            C.bline = patch(x,y,C.bslcol);
%             p1.EdgeColor = 'none';
%             p1.FaceAlpha = C.outlinealpha;
            set(C.bline, 'EdgeColor', 'none');
            %set(C.bline, 'FaceAlpha', 0.9);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Outline
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            x = [-0.17 -0.17 0.17 0.17]*2;
            y = [-0.5 0.5 0.5 -0.5]*2;
            C.oline = patch(x,y,C.bslcol);
%             p1.EdgeColor = 'none';
%             p1.FaceAlpha = C.outlinealpha;
            set(C.oline, 'EdgeColor', 'none');
            set(C.oline, 'FaceAlpha', C.outlinealpha);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Feedback
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %hold on;
            x = [-0.15 -0.15 0.15 0.15]*2;
            y = [0.0 0.0 0.0 0.0]*2;
            C.bar = patch(x,y,C.poscol);

            set(C.bar, 'EdgeColor', 'none');
            set(C.bar, 'FaceAlpha', C.outlinealpha);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Fixation
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %hold on;
            x = [-0.1 -0.1 -0.02 -0.02 0.02 0.02 0.1  0.1  0.02  0.02  -0.02 -0.02]*1.5;
            y = [-0.02  0.02  0.02  0.1 0.1 0.02 0.02 -0.02 -0.02 -0.1 -0.1 -0.02]*1.5;
            C.fix =  patch(x,y, C.bslcol);
            set(C.fix, 'EdgeColor', 'none');
            set(C.fix, 'FaceAlpha', 0.7);%C.outlinealpha);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Move to second screen
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
%             FigPos = get(C.FigH, 'Position');
%             WindowAPI(C.FigH, 'Position', FigPos, C.screennr);
%             % Keep window visible if the monitors have different sizes:
%             WindowAPI(C.FigH, 'ToScreen');
%             % Special maximizing such that the inner figure fill the screen:
%             WindowAPI(C.FigH, 'Position', 'work');

        end
        
        function connect(C,instructions,GUI_tic,logfp)
            C.com = serial('COM3', 'BaudRate', 115200);
            set(C.com,'InputBufferSize',128);
          
            C.com.BytesAvailableFcnCount = 1;
            C.com.BytesAvailableFcnMode = 'byte';
            C.com.BytesAvailableFcn = @C.trigger_callback;
            fopen(C.com);
            
            C.GUI_tic = GUI_tic;
            C.logfp = logfp;
            
            C.instrnr = -1*C.nrdummy;
            C.instructions = instructions;

        end
        
        function trigger_callback(C,SerPor, eventData)
            %C.instrnr = C.instrnr
            if strcmp(fscanf(C.com,'%c',1),'5')

                C.instrnr = C.instrnr + 1;
                
                if C.instrnr>0
                    
                    switch C.instructions(C.instrnr)
                        case 0
                            set(C.fix,'FaceColor',C.bslcol);
                            temp = toc(C.GUI_tic);
                            fprintf(C.logfp,'Instruction\tGray\t%f\t%d\n',temp,C.instrnr);
                        case 1
                            set(C.fix,'FaceColor',C.poscol);
                            temp = toc(C.GUI_tic);
                            fprintf(C.logfp,'Instruction\tGreen\t%f\t%d\n',temp,C.instrnr);
                        case 2
                            set(C.fix,'FaceColor',C.negcol);
                            temp = toc(C.GUI_tic);
                            fprintf(C.logfp,'Instruction\tRed\t%f\t%d\n',temp,C.instrnr);
                    end
                else
                    temp = toc(C.GUI_tic);
                    fprintf(C.logfp,'Dummy trigger\t\t%f\t%d\n',temp,C.instrnr);
                end
            end

        end
        
        %Destructor
        function delete(C)
            delete(C.figapp);
            if  ~isempty(C.com)
                fclose(C.com);
                delete(C.com);
            end
                
        end
        
        function callback_keypress(C, hObject, callbackdata)
            
            switch callbackdata.Key
                case 'uparrow'
                    Y = get(C.bar, 'YData');
                    temp = min(Y(2) + 0.1, 1);
                    Y(2:3) = temp;
                    set(C.bar, 'YData', Y);
                case 'downarrow'
                    Y = get(C.bar, 'YData');
                    temp = max(Y(2) - 0.1, -1);
                    Y(2:3) = temp;
                    set(C.bar, 'YData', Y);
                case 'q'
                    delete(C);
                    return;
                otherwise
                    return;
                        
            end
            
            if temp<0
                set(C.bar, 'FaceColor', C.negcol);
            else
                set(C.bar, 'FaceColor', C.poscol);
            end
            
        end
        
        %Update feedback
        function update(C, level)

            Y = get(C.bar, 'YData');
            if level>0
                set(C.bar, 'FaceColor', C.poscol);
                level = min(level, 1);
            elseif level<0
                set(C.bar, 'FaceColor', C.negcol);
                level = max(level, -1);
            end
            
            Y(2:3) = level;
            set(C.bar, 'YData', Y);

        end
        
        
        
    end
    
end