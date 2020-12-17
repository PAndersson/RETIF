function GUI = startupfunc_test(GUI)
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
      
      
      