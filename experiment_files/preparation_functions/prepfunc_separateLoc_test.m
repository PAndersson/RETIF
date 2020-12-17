function GUI = prepfunc_separateLoc_test(GUI)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Pick up new data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    newdata = GUI.experiment.collector.data;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Motion Correction
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if GUI.experiment.regon
        %Register volume to template
        [newdata, GUI.experiment.estimated_motion(GUI.experiment.collector.latest_dynnr,:)] = ...
            boldreg(GUI.experiment.template, newdata,...
            GUI.experiment.regpar(1),...
            GUI.experiment.regpar(2),...
            GUI.experiment.regpar(3));
        newdata(newdata<0) = 0;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Add new data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    add_data(GUI.experiment.data, newdata, GUI.experiment.collector.latest_dynnr);
    clear newdata;
    
    %update classifier with new mean
    %temp = GUI.experiment.data.mean();
    %GUI.experiment.classifier.meanD = temp(GUI.experiment.classifier.ROIs);

    %display prediction prob_estimates
    axes(GUI.axesDisp);
    set(GUI.axesDisp,'YLim',[-5.1 5.1]);
    plot(1:GUI.experiment.nrfeedback,nan(1,GUI.experiment.nrfeedback));
    
end


