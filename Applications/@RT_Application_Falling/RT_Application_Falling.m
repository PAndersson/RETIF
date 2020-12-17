classdef RT_Application_Falling < RT_Application
    
    properties
        bgrcol = [0.2 0.2 0.2];
        bslcol = [0.5 0.5 0.5];
        poscol = [0.1 1.0 0.1];
        negcol = [1.0 0.1 0.1];
        
        nrx = 11;
        nry = 11;
        threshold = 0.5;  
        openStart = 3;%steps of 1/nrx
        openStop = 7;%steps of 1/nrx
        floorY = 0.3; 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        xlocations 
        ylocations 
        blockX 
        blockY 
      
        %%%%%%%%%%%%%%%%
        
        figapp
        FigH
        ax
        block
        screennr
        floorL 
        floorR
        reset
        instrcue
        
        %%%%%%%%%%%%%%%%
        %com
        instructions
        instrnr
        GUI_tic 
        logfp
        nrdummy 
        
    end
    
    methods
    
        %Constructor
        function C = RT_Application_Falling(varargin) %screennr)
            
            rng('default');
            
            if nargin == 1
                input = varargin{1};
                C.screennr = input.screennr;
                C.nrdummy = input.nrDummy;
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
            set(C.ax, 'Units', 'Normalized');
            axis(C.ax);
            %axis equal;
            axis off;
            set(C.ax, 'XLim', [0 1], 'YLim', [-C.floorY 1]);
            set(C.ax, 'Position', [0 0 1 1]);
            

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Moving square
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            C.xlocations = [0:C.nrx]/C.nrx;
            C.ylocations = [0:C.nry-1]/C.nry;
            
            C.blockX = round(C.nrx/2);
            C.blockY = C.nry;
            C.block = rectangle('Position',[10,10,1/C.nrx,1/C.nry],'EdgeColor',C.bslcol,'FaceColor',C.bslcol);
            
            C.floorL = rectangle('Position', [0, -C.floorY, C.xlocations(C.openStart), C.floorY],'EdgeColor','k','FaceColor',C.bslcol, 'visible', 'off');
            C.floorR = rectangle('Position', [C.xlocations(C.openStop), -C.floorY, 1, C.floorY],'EdgeColor', 'k','FaceColor',C.bslcol, 'visible', 'off');
            
            C.reset = true;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Instruction cue
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
            C.instrcue = annotation('arrow');
            C.instrcue.Color = C.bslcol;
            C.instrcue.LineWidth = 5;
            C.instrcue.HeadWidth = 50;
            C.instrcue.HeadLength = 50;
            C.instrcue.Position = [0.45 0.6 0.1 0];
            C.instrcue.Visible = false;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Move to screen 'screennr'
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
            FigPos = get(C.FigH, 'Position');
            WindowAPI(C.FigH, 'Position', FigPos, C.screennr);
            % Keep window visible if the monitors have different sizes:
            WindowAPI(C.FigH, 'ToScreen');
            % Special maximizing such that the inner figure fill the screen:
            WindowAPI(C.FigH, 'Position', 'work');

        end
        
        function connect(C,instructions,GUI_tic,logfp)

            
        end
        
        function trigger_callback(C,SerPor, eventData)

        end
        
        %Destructor
        function delete(C)
            delete(C.figapp);
        end
        
        function callback_keypress(C, hObject, callbackdata)
            
            %Check if key is 'q' for quit
            switch callbackdata.Key
                case 'q'
                    delete(C);
                    return;     
            end
            
            if C.reset == true && ~any(strcmp(callbackdata.Key,{'r','l','c'})) 
                C.instrcue.Visible = false;
                
                C.blockY =  C.nry;
                C.blockX = round(C.nrx/2);
                C.reset = false;
                set(C.block,'FaceColor',C.bslcol,'Visible','on');
                
                C.openStart = randi(8);%steps of 1/nrx
                C.openStop = C.openStart+4;%steps of 1/nrx
                if C.openStart == 1
                    set(C.floorL, 'visible', 'off');
                else
                    set(C.floorL, 'Position', [0, -C.floorY, C.xlocations(C.openStart), C.floorY], 'FaceColor',C.bslcol, 'visible', 'on');
                end
                set(C.floorR, 'Position', [C.xlocations(C.openStop), -C.floorY, 1, C.floorY], 'FaceColor',C.bslcol, 'visible', 'on');
                
            else
                switch callbackdata.Key
                    case 'uparrow'
                        set(C.block,'Visible','on');
                        C.instrcue.Visible = false;
                        C.floorL.Visible = true;
                        C.floorR.Visible = true;
                        C.blockY = min([C.blockY + 1, C.nry]);
                    case 'downarrow'
                        set(C.block,'Visible','on');
                        C.instrcue.Visible = false;
                        C.floorL.Visible = true;
                        C.floorR.Visible = true;
                        %C.blockY = max([C.blockY - 1, 1]);
                        C.blockY = C.blockY - 1;
                    case 'leftarrow'
                        set(C.block,'Visible','on');
                        C.instrcue.Visible = false;
                        C.blockX = max([C.blockX - 1, 1]);
                        C.floorL.Visible = true;
                        C.floorR.Visible = true;
                    case 'rightarrow'
                        set(C.block,'Visible','on');
                        C.instrcue.Visible = false;
                        C.blockX = min([C.blockX + 1, C.nrx]);
                        C.floorL.Visible = true;
                        C.floorR.Visible = true;
                case 'r'
                    set(C.instrcue,'Position',[0.45 0.6 0.1 0],'LineWidth', 5, ...
                        'HeadWidth', 50, 'HeadLength', 50, 'Visible','on');
                    set(C.block,'Visible','off');
                    set(C.floorL,'Visible','off');
                    set(C.floorR,'Visible','off');
                case 'l'
                    set(C.instrcue,'Position',[0.55 0.6 -0.1 0],'LineWidth', 5, ...
                        'HeadWidth', 50, 'HeadLength', 50, 'Visible','on');
                    set(C.block,'Visible','off');
                    set(C.floorL,'Visible','off');
                    set(C.floorR,'Visible','off');
                case 'c'
                    set(C.instrcue,'Position',[0.52 0.6 -0.04 0],'LineWidth', 50, ...
                        'HeadWidth', 0, 'HeadLength', 0, 'Visible','on');
                    set(C.block,'Visible','off');
                    set(C.floorL,'Visible','off');
                    set(C.floorR,'Visible','off');
                otherwise
                    return;
                end
            end
            
            %if block below floor, check if it made it
            %through the opening
            if C.blockY<1
                
                C.reset = true;
                
                %if through the hole
                if C.blockX>C.openStart-1 & C.blockX<C.openStop
                    set(C.block,'Position',[C.xlocations(C.blockX),-C.ylocations(2),1/C.nrx,1/C.nry],'FaceColor',[0,0.5,0]);
                else
                    set(C.block,'Visible','off');
                    set(C.floorL,'FaceColor',[0.5,0,0]);
                    set(C.floorR,'FaceColor',[0.5,0,0]);
                end
            else
                set(C.block,'Position',[C.xlocations(C.blockX),C.ylocations(C.blockY),1/C.nrx,1/C.nry]);
            end
        end
        
        function updateInstr(C, instr)
            switch instr
                case 'r'
                    set(C.instrcue,'Position',[0.45 0.6 0.1 0],'LineWidth', 5, ...
                        'HeadWidth', 50, 'HeadLength', 50, 'Visible','on');
                    set(C.block,'Visible','off');
                    set(C.floorL,'Visible','off');
                    set(C.floorR,'Visible','off');
                case 'l'
                    set(C.instrcue,'Position',[0.55 0.6 -0.1 0],'LineWidth', 5, ...
                        'HeadWidth', 50, 'HeadLength', 50, 'Visible','on');
                    set(C.block,'Visible','off');
                    set(C.floorL,'Visible','off');
                    set(C.floorR,'Visible','off');
                case 'c'
                    set(C.instrcue,'Position',[0.52 0.6 -0.04 0],'LineWidth', 50, ...
                        'HeadWidth', 0, 'HeadLength', 0, 'Visible','on');
                    set(C.block,'Visible','off');
                    set(C.floorL,'Visible','off');
                    set(C.floorR,'Visible','off');
                otherwise
                    return;
            end
        end
        
        %Update feedback
        function update(C, level)
            
            if C.reset == true
                C.instrcue.Visible = false;
                
                C.blockY =  C.nry;
                C.blockX = round(C.nrx/2);
                C.reset = false;
                set(C.block,'FaceColor',C.bslcol,'Visible','on');
                rng('default');rng shuffle;
                C.openStart = randi(8);%steps of 1/nrx
                C.openStop = C.openStart+4;%steps of 1/nrx
                if C.openStart == 1
                    set(C.floorL, 'visible', 'off');
                else
                    set(C.floorL, 'Position', [0, -C.floorY, C.xlocations(C.openStart), C.floorY], 'FaceColor',C.bslcol, 'visible', 'on');
                end
                set(C.floorR, 'Position', [C.xlocations(C.openStop), -C.floorY, 1, C.floorY], 'FaceColor',C.bslcol, 'visible', 'on');

            else

                %if level > threshold move right
                %if level < -threshold move left
                if level>C.threshold
                    C.blockX = min([C.blockX + 1, C.nrx]);
                elseif level<(-1*C.threshold)
                    C.blockX = max([C.blockX - 1, 1]);
                end
                
                %move one step down
                C.blockY = C.blockY - 1;
                
            end
            
            %if block below floor, check if it made it
            %through the opening
            if C.blockY<1
                
                C.reset = true;
                
                %if through the hole
                if C.blockX>C.openStart-1 & C.blockX<C.openStop
                    set(C.block,'Position',[C.xlocations(C.blockX),-C.ylocations(2),1/C.nrx,1/C.nry],'FaceColor',[0,0.5,0]);
                else
                    set(C.block,'Visible','off');
                    set(C.floorL,'FaceColor',[0.5,0,0]);
                    set(C.floorR,'FaceColor',[0.5,0,0]);
                end
            else
                set(C.block,'Position',[C.xlocations(C.blockX),C.ylocations(C.blockY),1/C.nrx,1/C.nry]);
            end
            
            
        end
        
        
        
    end
    
end