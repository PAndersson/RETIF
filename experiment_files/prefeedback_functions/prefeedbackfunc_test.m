function GUI = prefeedbackfunc_test(GUI)

    doreg = GUI.experiment.regon;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Pick up new data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    newdata = GUI.experiment.collector.data;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % If first volume, do stuff
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if GUI.experiment.collector.latest_dynnr==1
        
        %If template is empty, use first volume
        if isempty(GUI.experiment.template)
            GUI.experiment.template = newdata;
            doreg = false;
        else
            %if template not empty, first vol needs registration
            doreg = true;
        end
        
        %Create 3D rendering
        Ds = smooth3(GUI.experiment.template);
        GUI.brainmask = Ds>200;
        labels = bwlabeln(GUI.brainmask);
        stats = regionprops(labels,'Area');
        [temp,idx]=max([stats.Area]);
        GUI.brainmask = ismember(labels,idx);
        GUI.brainmask = imfill(GUI.brainmask,'holes');
        %GUI.brainmask(:,:,1:2) = false;
        sze_data = size(GUI.brainmask);
        
        axes(GUI.axes3D);
        hiso = patch(isosurface(Ds,200),'FaceColor',[1,.75,.65],'EdgeColor','none','FaceAlpha',0.5);
        lightangle(-90,50);
        view(-90,0);
        %daspect([1,1,1.0823]);
        hold on;
        axis off;
        
        if strcmp(GUI.experiment.maskfile,'')
            GUI.experiment.data.applymask(GUI.brainmask);
            GUI.experiment.localizer.selectvox(1:nnz(GUI.brainmask));
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Motion Correction
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if doreg
        
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
    % Display current voxel selection
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    axes(GUI.axes3D);
    for k = 1:GUI.experiment.localizer.nrcon
        if(GUI.experiment.collector.latest_dynnr == 1)
            GUI.sc(k) = plot3(1,1,1,'.');
            set(GUI.sc(k),'MarkerEdgeColor',GUI.colortemp(k,:));
        else
            
            temp = zeros(size(GUI.experiment.data.mask),'single');
            temp(GUI.experiment.data.mask) = GUI.experiment.localizer.tstats(:,k);
            
            [sa,i] = sort(temp(:),'descend');
            temp(i(GUI.experiment.localizer.nrkeep+1:end)) = 0;
            active = temp > 0;
            labels = bwlabeln(active);
            stats = regionprops(labels,'Area');
            idx = find([stats.Area] > GUI.experiment.localizer.minsze);
            active = ismember(labels,idx);
            active = find(active);
            [X,Y,Z] = ind2sub(GUI.experiment.size_data,active);
            set(GUI.sc(k),'XData',Y,'YData',X,'ZData',Z);
        end
    end
    drawnow;
    


end