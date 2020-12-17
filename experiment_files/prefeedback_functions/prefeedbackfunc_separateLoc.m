function GUI = prefeedbackfunc_separateLoc(GUI)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Pick up new data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    newdata = GUI.experiment.collector.data;
 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Motion Correction
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if GUI.experiment.regon
        %Register volume to template
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         [newdata, GUI.experiment.estimated_motion(GUI.experiment.collector.latest_dynnr,:)] = ...
%             RT_spmreg(GUI.experiment.template, newdata, [3 3 3.6]);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [newdata, GUI.experiment.estimated_motion(GUI.experiment.collector.latest_dynnr,:)] = ...
            boldreg(GUI.experiment.template, newdata,...
            GUI.experiment.regpar(1),...
            GUI.experiment.regpar(2),...
            GUI.experiment.regpar(3));
        newdata(newdata<0) = 0;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Add new data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    add_data(GUI.experiment.data, newdata, GUI.experiment.collector.latest_dynnr);
    clear newdata;


end