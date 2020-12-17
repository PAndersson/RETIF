function GUI = prepfunc_test(GUI)

    %update localizer
    GUI.experiment.localizer.update(GUI.experiment.data,GUI.experiment.collector.latest_dynnr);
    
    %display selections
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
    GUI.experiment.classifier.train(ROIs,...
        GUI.experiment.data,...
        GUI.experiment.collector.latest_dynnr);

end