classdef RT_Application_VisImag1 < RT_Application
    
    properties
        bgrcol = [0.2 0.2 0.2];
        fgrcol = [0.5 0.5 0.5];
        markcol = [0.8 0.1 0.1];
        
        margin = 0.02;
        L1 = 0.02;
        L2 = 0.1;
        outlinealpha = 0.3;
        marker_sze = 10;
        
        %%%%%%%%%%%%%%%%
        
        figapp
        FigH
        ax
        cL
        cR
        screennr
        
    end
    
    methods
    
        %Constructor
        function C = RT_Application_VisImag1(varargin) %screennr)
            
            if nargin == 1
                input = argin(1);
                C.screennr = input{1};
            else
                C.screennr = 1;
            end
                
            C.figapp = figure('Color',C.bgrcol,'Position',[0  0  500  500],'MenuBar','none','KeyPressFcn',@C.callback_keypress);
            C.FigH = C.figapp.Number;
            
            C.ax = axes;
            C.ax.Units = 'Normalized';
            axis(C.ax,'equal',[-0.5 0.5 -0.5 0.5],'off');
            C.ax.Position = [0.3 0.3 0.4 0.4];
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Outline
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            x = [0 0  C.L1 C.L1 C.L2 C.L2] + C.margin - 0.5;
            y = [0 C.L2 C.L2 C.L1 C.L1 0]  + C.margin - 0.5;
            p1 = patch(x,y,C.fgrcol);
            p1.EdgeColor = 'none';
            p1.FaceAlpha = C.outlinealpha;
            
            x = [0 0 C.L2 C.L2 C.L1 C.L1] + C.margin - 0.5;
            y = [0 C.L2 C.L2 C.L2-C.L1 C.L2-C.L1 0] - C.margin + (1-C.L2) - 0.5;
            p2 = patch(x,y,C.fgrcol);
            p2.EdgeColor = 'none';
            p2.FaceAlpha = C.outlinealpha;
            
            x = [0 C.L2 C.L2 C.L2-C.L1 C.L2-C.L1 0] - C.margin + (1-C.L2) - 0.5;
            y = [C.L2 C.L2 0 0 C.L2-C.L1 C.L2-C.L1] - C.margin + (1-C.L2) - 0.5;
            p3 = patch(x,y,C.fgrcol);
            p3.EdgeColor = 'none';
            p3.FaceAlpha = C.outlinealpha;
            
            x = [0 0 C.L2-C.L1 C.L2-C.L1 C.L2 C.L2] - C.margin + (1-C.L2) - 0.5;
            y = [0 C.L1 C.L1 C.L2 C.L2 0] + C.margin - 0.5;
            p4 = patch(x,y,C.fgrcol);
            p4.EdgeColor = 'none';
            p4.FaceAlpha = C.outlinealpha;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Feedback
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            hold on;
            C.cL = plot(C.margin-0.5, 0, 'o', 'MarkerFaceColor', C.markcol, 'Color', C.markcol);
            C.cR = plot(1-C.margin-0.5, 0, 'o', 'MarkerFaceColor', C.markcol, 'Color', C.markcol);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Move to second screen
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            FigPos = get(C.FigH, 'Position');
            WindowAPI(C.FigH, 'Position', FigPos, C.screennr);
            % Keep window visible if the monitors have different sizes:
            WindowAPI(C.FigH, 'ToScreen');
            % Special maximizing such that the inner figure fill the screen:
            %WindowAPI(C.FigH, 'Position', 'work');



        end
        
        %Destructor
        function delete(C)
            delete(C.figapp);
        end
        
        function callback_keypress(C,hObject,callbackdata)
            
            switch callbackdata.Key
                case 'uparrow'
                    
                    %animate the movement from old point to new point
    
                    C.cL.YData = min(C.cL.YData + 0.1, 0.5-C.L2);
                    C.cR.YData = min(C.cR.YData + 0.1, 0.5-C.L2);
                case 'downarrow'
                    C.cL.YData = max(C.cL.YData - 0.1, C.L2-0.5);
                    C.cR.YData = max(C.cR.YData - 0.1, C.L2-0.5);
                case 'q'
                    delete(C);
            end
        end
        
        %Update feedback
        function update(C, changeL, changeR)

                if changeL>0
                    C.cL.YData = min(C.cL.YData + changeL, 0.5-C.L2);
                elseif changeL<0
                    C.cL.YData = max(C.cL.YData + changeL, C.L2-0.5);
                end
                
                if changeR>0
                    C.cR.YData = min(C.cR.YData + changeR, 0.5-C.L2);
                elseif changeL<0
                    C.cR.YData = max(C.cR.YData + changeR, C.L2-0.5);
                end

        end
        
        
        
    end
    
end