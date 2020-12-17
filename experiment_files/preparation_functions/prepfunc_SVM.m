function GUI = prepfunc_SVM(GUI)

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

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Update localizer
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    GUI.experiment.localizer.update(GUI.experiment.data,GUI.experiment.collector.latest_dynnr);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Display final voxel selection
    % and save as ROIs
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    axes(GUI.axes3D);
    ROIs = false(GUI.experiment.localizer.nrvox,GUI.experiment.localizer.nrcon);
    for k = 1:GUI.experiment.localizer.nrcon
        
        temp = zeros(size(GUI.experiment.data.mask),'single');
        temp(GUI.experiment.data.mask) = GUI.experiment.localizer.tstats(:,k);
        
        [sa,i] = sort(temp(:),'descend');
        temp(i(GUI.experiment.localizer.nrkeep+1:end)) = 0;
        active = temp > 0;
        labels = bwlabeln(active);
        stats = regionprops(labels,'Area');
        idx = find([stats.Area] > GUI.experiment.localizer.minsze);
        active = ismember(labels,idx);
        ROIs(:,k) = active(GUI.experiment.data.mask);
        active = find(active);
        [X,Y,Z] = ind2sub(GUI.experiment.size_data,active);
        set(GUI.sc(k),'XData',Y,'YData',X,'ZData',Z);
    end
    drawnow;
    
    %train the classifier
    %shift instructions 3 TRs to account for bold delay
    %instr = [0;0;0;GUI.experiment.prefeedbackinstr(1:end-3)];
    instr = GUI.experiment.prefeedbackinstr;
    GUI.experiment.classifier.train(ROIs,...
        GUI.experiment.data,...
        instr,...
        GUI.experiment.collector.latest_dynnr);

    %display prediction prob_estimates
    axes(GUI.axesDisp);
    set(GUI.axesDisp,'YLim',[-5.1 5.1]);
    plot(1:GUI.experiment.nrfeedback,nan(1,GUI.experiment.nrfeedback));
    
end

