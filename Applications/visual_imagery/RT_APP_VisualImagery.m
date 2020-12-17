function RT_APP_VisualImagery()

bgrcol = [0.2 0.2 0.2];
fgrcol = [0.5 0.5 0.5];
markcol = [0.8 0.1 0.1];

margin = 0.02;
L1 = 0.02;
L2 = 0.1;
outlinealpha = 0.3;
marker_sze = 10;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figapp = figure('Color',bgrcol,'Position',[0  0  500  500],'MenuBar','none','KeyPressFcn',@Callback_keypress);
FigH = figapp.Number;
%set(figapp,'Colormap',gray(256),'Units','normalized');

ax = axes;
ax.Units = 'Normalized';
axis(ax,'equal',[0 1 0 1],'off');
ax.Position = [0.3 0.3 0.4 0.4];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outline
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

x = [0 0  L1 L1 L2 L2] + margin;
y = [0 L2 L2 L1 L1 0]  + margin;
p1 = patch(x,y,fgrcol);
p1.EdgeColor = 'none';
p1.FaceAlpha = outlinealpha;

x = [0 0 L2 L2 L1 L1] + margin;
y = [0 L2 L2 L2-L1 L2-L1 0] - margin + (1-L2);
p2 = patch(x,y,fgrcol);
p2.EdgeColor = 'none';
p2.FaceAlpha = outlinealpha;

x = [0 L2 L2 L2-L1 L2-L1 0] - margin + (1-L2);
y = [L2 L2 0 0 L2-L1 L2-L1] - margin + (1-L2);
p3 = patch(x,y,fgrcol);
p3.EdgeColor = 'none';
p3.FaceAlpha = outlinealpha;


x = [0 0 L2-L1 L2-L1 L2 L2] - margin + (1-L2);
y = [0 L1 L1 L2 L2 0] + margin;
p4 = patch(x,y,fgrcol);
p4.EdgeColor = 'none';
p4.FaceAlpha = outlinealpha;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Feedback
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hold on;
cL = plot(margin, L2, 'o', 'MarkerFaceColor', markcol, 'Color', markcol);
cR = plot(1-margin, L2, 'o', 'MarkerFaceColor', markcol, 'Color', markcol);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


FigPos = get(FigH, 'Position');
WindowAPI(FigH, 'Position', FigPos, 2);

% Keep window visible if the monitors have different sizes:
WindowAPI(FigH, 'ToScreen');
Pos    = WindowAPI(FigH, 'Position');
FigPos = Pos.Position;
%
% Special maximizing such that the inner figure fill the screen:
WindowAPI(FigH, 'Position', 'work');
% % pause(2);
% % WindowAPI(FigH, 'Position', 'full');  % Complete monitor
% % pause(2);
% % WindowAPI(FigH, 'OuterPosition', 'work');


    function Callback_keypress(hObject,callbackdata)
        
        switch callbackdata.Key
            case 'uparrow'
                
                %animate the movement from old point to new point
                
                cL.YData = min(cL.YData + 0.1, 1-L2);
                cR.YData = min(cR.YData + 0.1, 1-L2);
            case 'downarrow'
                cL.YData = max(cL.YData - 0.1, L2);
                cR.YData = max(cR.YData - 0.1, L2);
        end
    end

end
