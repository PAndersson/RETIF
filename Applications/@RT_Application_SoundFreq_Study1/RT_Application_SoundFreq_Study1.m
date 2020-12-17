classdef RT_Application_SoundFreq_Study1 < RT_Application
    
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
        
        %oldlevel
        newlevel
        fs = 2048; % Hz
        f = linspace(200,1000,21);%[200,300,400,500,600,700,800,900,1000]; % Hz
        t  % seconds
        tones

        instr1 
        instr2 
        fsinstr
        
        %%%%%%%%%%%%%%%%
        
        figapp
        FigH
        ax
        fix
        screennr

        
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
        function C = RT_Application_SoundFreq_Study1(varargin) %screennr)
            
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
                
            %C.oldlevel = 0;
            C.newlevel = 0;
            C.t = 0:1/C.fs:0.4; % seconds
            C.tones = zeros(length(C.f),length(C.t));
            temp = [1,0.7,0.6,0.5,0.5,0.5,0.5,0.5,0.5,0.4,0.4,0.4,0.4,0.4,0.4,0.4,0.4,0.4,0.4,0.5,1];
            for k =1:length(C.f)
                C.tones(k,:) = temp(k)*sin(2.*pi.*C.f(k).*C.t);
            end
            
            temp = fileparts(which('RT_Application_SoundFreq_Study1'));
            [C.instr1, C.fsinstr] = wavread([temp '\Right.wav']);
            [C.instr2, C.fsinstr] = wavread([temp '\Stop.wav']);
            
            C.instr1 = 5*C.instr1;
            C.instr2 = 5*C.instr2;
            
            C.figapp = figure('Color',C.bgrcol,'Position',[0  0  500  500],'MenuBar','none','KeyPressFcn',@C.callback_keypress,'CloseRequestFcn', @(event, data) C.delete);

            if verLessThan('matlab', '8.4')
                C.FigH = C.figapp;
            else
                C.FigH = C.figapp.Number;
            end
 
            C.ax = axes;
            set(C.ax, 'Units', 'Normalized');
            axis(C.ax);
            axis equal;axis off;
            set(C.ax, 'XLim', [-0.5 0.5], 'YLim', [-1 1]);%[-0.5 0.5], 'YLim', [-0.5 0.5]);
            set(C.ax, 'Position', [0.3 0.3 0.4 0.4]);
            

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Fixation
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %hold on;
            x = [-0.1 -0.1 -0.02 -0.02 0.02 0.02 0.1  0.1  0.02  0.02  -0.02 -0.02]*1;
            y = [-0.02  0.02  0.02  0.1 0.1 0.02 0.02 -0.02 -0.02 -0.1 -0.1 -0.02]*1;
            C.fix =  patch(x,y, C.bslcol);
            set(C.fix, 'EdgeColor', 'none');
            set(C.fix, 'FaceAlpha', 0.7);%C.outlinealpha);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Move to second screen
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            FigPos = get(C.FigH, 'Position');
            WindowAPI(C.FigH, 'Position', FigPos, 2);%C.screennr);
            % Keep window visible if the monitors have different sizes:
            WindowAPI(C.FigH, 'ToScreen');
            % Special maximizing such that the inner figure fill the screen:
            WindowAPI(C.FigH, 'Position', 'work');

        end
        
        function connect(C,instructions,GUI_tic,logfp)
            C.com = serial('COM3', 'BaudRate', 115200);
            set(C.com,'InputBufferSize',128);
            %warning    off all; %THIS IS NASTY!!! We do this because of timeout warning !!!!!!
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
                        case 1
                            %set(C.fix,'FaceColor',C.poscol);
                            sound(C.instr1,C.fsinstr);
                            temp = toc(C.GUI_tic);
                            fprintf(C.logfp,'Instruction\tImagine\t%f\t%d\n',temp,C.instrnr);
                        case 2
                            %set(C.fix,'FaceColor',C.negcol);
                            sound(C.instr2,C.fsinstr);
                            temp = toc(C.GUI_tic);
                            fprintf(C.logfp,'Instruction\tRest\t%f\t%d\n',temp,C.instrnr);
%                         case 0
%                             set(C.fix,'FaceColor',C.bslcol);
%                             temp = toc(C.GUI_tic);
%                             fprintf(C.logfp,'Instruction\tGray\t%f\t%d\n',temp,C.instrnr);
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
                    %play higher frequency
                    %C.oldlevel = C.newlevel;
                    C.newlevel = min(C.newlevel + 0.1, 1);
                case 'downarrow'
                    %play lower frequency
                    %C.oldlevel = C.newlevel;
                    C.newlevel = max(C.newlevel - 0.1, -1);
                case 'q'
                    delete(C);
                    return;
                otherwise
                    return;       
            end
            
            %ol = round(10*C.oldlevel) + 11;
            nl = round(10*C.newlevel) + 11;
            %playtone = [C.tones(ol,1:length(C.t)/2) C.tones(nl,:)];
            playtone = C.tones(nl,:);
            sound(playtone,C.fs);
        end
        
        %Update feedback
        function update(C, level)

            if level>0
                level = min(level, 1);
            elseif level<0
                level = max(level, -1);
            end

            %level = 4*level;
            
            %C.oldlevel = C.newlevel;
            C.newlevel = level;

            
            if C.instructions(C.instrnr)==0
                %ol = round(10*C.oldlevel) + 11;
                nl = round(10*C.newlevel) + 11;
                %playtone = [C.tones(ol,1:length(C.t)/2) C.tones(nl,:)];
                playtone =  C.tones(nl,:);
                sound(playtone,C.fs);
                temp = toc(C.GUI_tic);
                fprintf(C.logfp,'Gives Feedback\t\t%f\t%d\n',temp,C.instrnr);
            end
            
        end
        
        
        
    end
    
end