function RT_makeROI

    bgrcol = [0.2,0.5,0.8];
    clrmap = [gray(255);1 0 0];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %    Create GUI components
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figmain = figure('Color', bgrcol, 'Position',[100  200  1000  500],'MenuBar','none');

    filemenu = uimenu(figmain,'Label','File');
    uimenu(filemenu,'Label','Open statistical map','Callback',@(event, data) openMenu_Callback);
    structmenu = uimenu(filemenu,'Label','Open structural');
    uimenu(structmenu,'Label','Single image','Callback',@(event, data) openImgMenu_Callback);
    uimenu(structmenu,'Label','Multiple images','Callback',@(event, data) openSerieMenu_Callback);
    uimenu(filemenu,'Label','Save ROI','Callback',@(event, data) saveMenu_Callback);
    toolmenu = uimenu(figmain,'Label','Tools');
    uimenu(toolmenu,'Label','Open mask','Callback',@(event, data) openROIMenu_Callback);
    uimenu(toolmenu,'Label','ROI info','Callback',@(event, data) infoMenu_Callback);

    axes_vol = axes('Parent', figmain, 'Units','pixels','Position',[50  150  300  300],'XTick',[],'YTick',[]);
    axes_edit = axes('Parent', figmain, 'Units','pixels','Position',[400  150  300  300],'XTick',[],'YTick',[]);

    rotate_vol = rotate3d(figmain);
    setAllowAxesRotate(rotate_vol, axes_vol , true);
    setAllowAxesRotate(rotate_vol, axes_edit , false);
    set(rotate_vol, 'Enable', 'on', 'ButtonDownFilter', @RotateFilter);
    
    slider_slice = uicontrol('Style', 'slider', 'Min',1,'Max',50,'Value',1,...
        'Position', [50 100 300 20],...
        'Callback', @(event, data) sliceSlider_Callback); 
    

    text_slice = uicontrol('Style','text', 'Position',[175 125 50 20], 'String','','BackgroundColor',bgrcol);

    popup_orient = uicontrol('Style', 'popup', 'String', 'Orientation 1|Orientation 2|Orientation 3',...
           'Position', [500 100 100 20],...
           'Callback', @(event, data) orientPopup_Callback);
       
    panel_1 = uipanel('Parent',figmain,'BackgroundColor',[0.4 0.4 0.4],...
             'Position',[.72 .2 .12 .7]);
    panel_2 = uipanel('Parent',figmain,'BackgroundColor',[0.4 0.4 0.4],...
             'Position',[.86 .2 .12 .7]);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Panel_1
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
         
    % Create the button group.
    bg_drawerase = uibuttongroup('parent',panel_1,'visible','on','Position',[0.1 0.5 .8 0.45]);
    % Create three radio buttons in the button group.
    radio_draw = uicontrol('Style','radiobutton','String','Draw',...
        'pos',[10 40 75 30],'parent',bg_drawerase,'HandleVisibility','on');
    radio_erase = uicontrol('Style','radiobutton','String','Erase',...
        'pos',[10 10 75 30],'parent',bg_drawerase,'HandleVisibility','on');
    % Initialize some button group properties.
    set(bg_drawerase,'SelectedObject',radio_draw);  % No selection
         
    button_Poly = uicontrol('parent', panel_1, 'Style', 'pushbutton', 'String', 'Polygon',...
        'Position', [35 250 50 20], 'Callback', @(event, data) ROIbutton_Callback);
    button_Pick = uicontrol('parent', panel_1, 'Style', 'pushbutton', 'String', 'Pick Cluster',...
        'Position', [25 290 70 20], 'Callback', @(event, data) ClusterButton_Callback);
    button_Sphere = uicontrol('parent', panel_1, 'Style', 'pushbutton', 'String', 'Keep Sphere',...
        'Position', [25 130 70 20], 'Callback', @(event, data) SphereButton_Callback);
    button_Clear = uicontrol('parent', panel_1, 'Style', 'pushbutton', 'String', 'Clear Slice',...
        'Position', [25 90 70 20], 'Callback', @(event, data) ClearButton_Callback);
    button_Plot = uicontrol('parent', panel_1, 'Style', 'pushbutton', 'String', 'Plot',...
        'Position', [25 50 70 20], 'Callback', @(event, data) PlotButton_Callback);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Panel_2
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    uicontrol('parent', panel_2, 'Style','text','BackgroundColor',[0.4 0.4 0.4],...
        'ForegroundColor',[1 1 1],'Position',[10 320 100 20], 'String','Threshold');
    edit_Thresh = uicontrol(panel_2,'Style','edit','Callback', @(event, data) TreshEdit_Callback,...
                'String','2.0', 'Position', [25 300 70 20]);
   
    button_Clean = uicontrol('parent', panel_2, 'Style', 'pushbutton', 'String', 'Clean',...
        'Position', [25 250 70 20], 'Callback', @(event, data) CleanButton_Callback);
    button_ClBg = uicontrol('parent', panel_2, 'Style', 'pushbutton', 'String', 'Clear Backgr.',...
        'Position', [25 210 70 20], 'Callback', @(event, data) BrainButton_Callback);
    button_Smooth = uicontrol('parent', panel_2, 'Style', 'pushbutton', 'String', 'Smooth',...
        'Position', [25 170 70 20], 'Callback', @(event, data) SmoothButton_Callback);
    
    radio_Lower = uicontrol('Style','radiobutton','String','Lower',...
        'BackgroundColor',[0.4 0.4 0.4],'ForegroundColor',[1 1 1],'pos',[30 100 75 30],'parent',panel_2); 
    button_Keep = uicontrol('parent', panel_2, 'Style', 'pushbutton', 'String', 'Keep',...
        'Position', [25 70 70 20], 'Callback', @(event, data) KeepButton_Callback);
    edit_Keep = uicontrol(panel_2,'Style','edit',...
                'String','100', 'Position', [25 40 70 20]);
    
    %Create variables
    handles.corr = [];
    handles.sze = [];
    handles.data = [];
    handles.visdata = [];
    handles.maximdata = [];
    handles.imsze = [];
    handles.im2maskX = [];
    handles.im2maskY = [];
    handles.im2maskZ = [];
    handles.mask2imX = [];
    handles.mask2imY = [];
    handles.mask2imZ = [];   
    handles.sc = [];
    handles.ps = [];
    handles.I = [];
    handles.X = [];
    handles.Y = [];
    handles.Z = [];
    handles.nii = [];
            
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Callback functions
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Open statistical map
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function openMenu_Callback(event, data)
       
        %Choose file with fMRI data
        [filename, pathname, filterindex] = uigetfile({'*.nii;*.img', 'Choose Nifti file';'*.img', 'Choose Analyze file';'*.mat', 'Choose mat file'});
        if isequal(filename,0)
            return;
        end
        disp(filename);
        if filterindex==1
            %Read Nifti file
            handles.nii = nifti([pathname,filename]);
            handles.corr = single(handles.nii.dat(:,:,:));
            handles.sze = size(handles.corr);
        elseif filterindex==2
            %Read Analyze file
            handles.corr = read_analyze(filename,pathname);
            handles.sze = size(handles.corr);
        elseif filterindex==3
            %Read mat file
            temp = load([pathname,filename]);
            handles.corr = eval(['temp.' filename(1:end-4) ';']);
            handles.sze = size(handles.corr);
        end
        
        if isempty(handles.visdata)
            handles.visdata = zeros(handles.sze);
            handles.maximdata = 0;
            handles.imsze = handles.sze;
            handles.im2maskX = round(linspace(1,handles.sze(1),handles.imsze(1)));
            handles.im2maskY = round(linspace(1,handles.sze(2),handles.imsze(2)));
            handles.im2maskZ = round(linspace(1,handles.sze(3),handles.imsze(3)));
            handles.mask2imX = round(linspace(1,handles.imsze(1),handles.sze(1)));
            handles.mask2imY = round(linspace(1,handles.imsze(2),handles.sze(2)));
            handles.mask2imZ = round(linspace(1,handles.imsze(3),handles.sze(3)));
        end
        
        handles.data = zeros(handles.sze);
        
        handles.threshold = str2num(get(edit_Thresh,'String'));
        if(handles.threshold>0)
            handles.data(handles.corr>=handles.threshold) = 1;
        else
            handles.data(handles.corr<=handles.threshold) = 1;
        end
        
        %  handles.imdata = zeros(handles.sze);
        %  handles.maximdata = 0;
        handles.imsze = handles.sze;
        
        %translation between data-coordinates and imdata-coordinates
        handles.im2maskX = round(linspace(1,handles.sze(1),handles.imsze(1)));
        handles.im2maskY = round(linspace(1,handles.sze(2),handles.imsze(2)));
        handles.im2maskZ = round(linspace(1,handles.sze(3),handles.imsze(3)));
        handles.mask2imX = round(linspace(1,handles.imsze(1),handles.sze(1)));
        handles.mask2imY = round(linspace(1,handles.imsze(2),handles.sze(2)));
        handles.mask2imZ = round(linspace(1,handles.imsze(3),handles.sze(3)));
        
        set(popup_orient,'Value',3);
        set(slider_slice,'Min',1,'Max',handles.sze(3),'Value',1,'SliderStep',[1,5]/handles.sze(3));
        
        ImageUpdate;
        
        axes(axes_vol);
        view(3);
        %setAllowAxesRotate(rotate_vol, axes_vol , true);
        %setAllowAxesRotate(rotate_vol, axes_edit , false);
        %set(rotate_vol, 'Enable', 'on');
        
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function openROIMenu_Callback
        %Choose file with mask and load it
        [filename, pathname, filterindex] = uigetfile({'*.nii;*.img', 'Choose Nifti file';'*.img', 'Choose Analyze file';'*.mat', 'Choose mat file'},'MultiSelect','on');
        if isequal(filename,0)
            return;
        end
        
        disp(filename);

        if filterindex==1
            %Read Nifti files
            if iscell(filename)
                
                mask = false(handles.sze);
                for k = 1:length(filename)
                    nii = nifti([pathname,filename{k}]);
                    mask(nii.dat(:,:,:)>0) = true;
                end
            else
                nii = nifti([pathname,filename]);
                mask = nii.dat(:,:,:)>0;
            end
            
            

        elseif filterindex==2
            %Read Analyze file
            mask = read_analyze(filename,pathname);
        elseif filterindex==3
            %Read mat file
            temp = load([pathname,filename]);
            mask = eval(['temp.' filename(1:end-4) ';']);
        end
        
        %Apply mask
        handles.corr(~mask) = 0;
        handles.data(~mask) = 0;

        ImageUpdate;
        
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function TreshEdit_Callback(event, ~)
        
        handles.data = zeros(handles.sze);
        threshold = str2num(get(edit_Thresh,'String'));
        if(threshold>0)
            handles.data(handles.corr>=threshold) = 1;
        else
            handles.data(handles.corr<=threshold) = 1;
        end
        
        ImageUpdate;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function CleanButton_Callback(event, data)
        %Removes clusters smaller than a chosen size
        
        answ = inputdlg({'Nr of voxels'},'Minimum cluster size',1,{'5'});
        minsze = str2num(answ{1});
        
        labels = bwlabeln(handles.data);
        stats = regionprops(labels,'Area');
        idx = find([stats.Area] >= minsze);
        handles.data = ismember(labels,idx);
        
        ImageUpdate;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function BrainButton_Callback(event, data)
        
        M = max(handles.imdata,[],4);
        M = M<150;
        handles.data(M) = 0;
        
        ImageUpdate;
        
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function SmoothButton_Callback(event, data)
        
        handles.corr = smooth3(handles.corr);
        TreshEdit_Callback([], []);
        ImageUpdate;
        
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function PlotButton_Callback(event, data)

        for k=1:size(handles.imdata,4)
            temp = handles.imdata(:,:,:,k);
            temp2 = temp(logical(handles.data));
            
            boldROI(k) = mean(temp2);
            
            nel = nnz(handles.data);
            stemp2 = sort(temp2,'descend');
            boldROI2(k) = mean(stemp2(1:floor(0.6*nel)));
            
        end

        figure;
        subplot(2,1,1);
        plot(boldROI);axis tight
        title('Mean of all voxels in ROI');
        subplot(2,1,2);
        plot(boldROI2);axis tight
        title('Mean of the highest 60% voxels in ROI');
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function openImgMenu_Callback(event, data)
        
        %Choose file with fMRI data
        [filename, pathname, filterindex] = uigetfile({'*.nii', 'Choose Nifti file';'*.img', 'Choose Analyze file'});
        if isequal(filename,0)
            return;
        end
        if filterindex==1
            avw = nifti([pathname,filename]);
            handles.visdata = single(avw.dat(:,:,:));
        elseif filterindex==2
            %Read Analyze file
            handles.visdata = read_analyze(filename,pathname);
            handles.visdata = flipdim(handles.visdata,1);
        end
        
        if ~isfield(handles, 'imdata')
            handles.imdata = handles.visdata;
        end
        
        %imdata = imdata-min(min(min(imdata)));
        %handles.imdata = imdata;
        handles.maximdata = max(handles.visdata(:));
        handles.imsze = size(handles.visdata);
        %translation between data-coordinates and imdata-coordinates
        handles.im2maskX = round(linspace(1,handles.sze(1),handles.imsze(1)));
        handles.im2maskY = round(linspace(1,handles.sze(2),handles.imsze(2)));
        handles.im2maskZ = round(linspace(1,handles.sze(3),handles.imsze(3)));
        handles.mask2imX = round(linspace(1,handles.imsze(1),handles.sze(1)));
        handles.mask2imY = round(linspace(1,handles.imsze(2),handles.sze(2)));
        handles.mask2imZ = round(linspace(1,handles.imsze(3),handles.sze(3)));
        
        ImageUpdate;
         
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function openSerieMenu_Callback(event, data)
        
        %Choose file with fMRI data
%         [filename, pathname, filterindex] = uigetfile({'*.nii', 'Choose 4D Nifti file';'*.nii', 'Choose 3D Nifti files';'*.img', 'Choose Analyze file'});
%         if isequal(filename,0)
%             return;
%         end
%         if filterindex==1
            %Read Nifti file
            %[filename, pathname] = uigetfile('*.nii', 'Choose Nifti file');
%             avw = nifti([pathname,filename]);
%             handles.imdata = single(avw.dat(:,:,:,:));
%             handles.visdata = squeeze(handles.imdata(:,:,:,1));
%         elseif filterindex==2
            %Read Nifti files
            [filename, handles.imdata, dimen, header] = read_nifti_dir_SPM;%([pathname,filename]);
            handles.visdata = squeeze(handles.imdata(:,:,:,1));
            
%         elseif filterindex==3
%             %Read Analyze files
%             [filename, handles.imdata, dimen, header] = read_analyze_dir([filename,pathname]);
%             handles.visdata = squeeze(handles.imdata(:,:,:,1));
%             
%         end
        handles.maximdata = max(handles.visdata(:));
        handles.imsze = size(handles.visdata);
        %translation between data-coordinates and imdata-coordinates
        handles.im2maskX = round(linspace(1,handles.sze(1),handles.imsze(1)));
        handles.im2maskY = round(linspace(1,handles.sze(2),handles.imsze(2)));
        handles.im2maskZ = round(linspace(1,handles.sze(3),handles.imsze(3)));
        handles.mask2imX = round(linspace(1,handles.imsze(1),handles.sze(1)));
        handles.mask2imY = round(linspace(1,handles.imsze(2),handles.sze(2)));
        handles.mask2imZ = round(linspace(1,handles.imsze(3),handles.sze(3)));
        
        ImageUpdate;
        
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function saveMenu_Callback(event, data)
        
        if ~isempty(handles.nii)
            [FileName,PathName] = uiputfile({'*.nii','Nifti'},'Save ROI as Nifti.');
            %-if Cancel
            if isequal(FileName,0)|isequal(PathName,0)
                return;
            end
            write_nifti(double(handles.data),handles.nii,[PathName,'\',FileName]);
           
        end
        
       
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function orientPopup_Callback(event, data)
        
        %reset to slice one
        switch get(popup_orient,'Value')
            case 1
                st1 = 1/(handles.sze(1)-1);
                st2 = 5/(handles.sze(1)-1);
                temp1 = handles.sze(1);
            case 2
                st1 = 1/(handles.sze(2)-1);
                st2 = 5/(handles.sze(2)-1);
                temp1 = handles.sze(2);
            case 3
                st1 = 1/(handles.sze(3)-1);
                st2 = 5/(handles.sze(3)-1);
                temp1 = handles.sze(3);
        end
        set(slider_slice,'sliderstep',[st1 st2], 'max', temp1,'min',1,'Value',1);
        
        %Update images
        ImageUpdate;
        
    end

%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%
% function axes1_ButtonDownFcn(hObject, eventdata, handles)
% % hObject    handle to axes1 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% if strcmp( get(handles.figure1,'selectionType') , 'normal')
% disp('Left Click')
% end
% if strcmp( get(handles.figure1,'selectionType') , 'open')
% disp('Left Double Click')
% end
%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function editImage(event, data)
        
        currentslice = round(get(slider_slice,'Value'));
        point = round(get(gca,'CurrentPoint'));
        
        switch get(popup_orient,'Value')
            case 1
                
                pcol = handles.im2maskZ(point(1,1));
                prow = handles.im2maskY(point(1,2));
                
                if strcmp(get(figmain,'selectionType'),'normal')
                %if(get(bg_drawerase,'SelectedObject')==radio_draw)
                    handles.data(currentslice,prow,pcol) = 1;
                else
                    handles.data(currentslice,prow,pcol) = 0;
                end
                
            case 2
                
                pcol = handles.im2maskZ(point(1,1));
                prow = handles.im2maskX(point(1,2));
                
                if strcmp(get(figmain,'selectionType'),'normal')
                %if(get(bg_drawerase,'SelectedObject')==radio_draw)
                    handles.data(prow,currentslice,pcol) = 1;
                else
                    handles.data(prow,currentslice,pcol) = 0;
                end
                
            case 3
                
                pcol = handles.im2maskY(point(1,1));
                prow = handles.im2maskX(point(1,2));
                
                if strcmp(get(figmain,'selectionType'),'normal')
                %if(get(bg_drawerase,'SelectedObject')==radio_draw)
                    handles.data(prow,pcol,currentslice) = 1;
                else
                    handles.data(prow,pcol,currentslice) = 0;
                end
                
        end
        
        ImageUpdate;
        
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function sliceSlider_Callback(event, data)
                
        nr1 = round(get(slider_slice,'Value'));
        
        switch get(popup_orient,'Value')
            case 1
                nr2 = handles.sze(1) - nr1 + 1;
            case 2
                nr2 = handles.sze(2) - nr1 + 1;
            case 3
                nr2 = handles.sze(3) - nr1 + 1;
        end
        
        set(text_slice,'String', [num2str(nr1),' (',num2str(nr2),')']);
        
        ImageUpdate;
        
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function ClusterButton_Callback(event, data)
        
        set(rotate_vol, 'Enable', 'off');
        
        set(figmain,'Pointer','cross');
        
        set(handles.I,'ButtonDownFCN','');
        
        scol = get(handles.I,'Xdata');scol = scol(2);
        srow = get(handles.I,'Ydata');srow = srow(2);
        
        waitforbuttonpress;
        currentslice = round(get(slider_slice,'Value'));
        point = round(get(gca,'CurrentPoint'));
        if( point(1,1)<=scol && ...
                point(1,1)>=0 && ...
                point(1,2)<=srow && ...
                point(1,2)>=0)
            
            switch get(popup_orient,'Value')
                case 1
                    
                    pcol = handles.im2maskZ(point(1,1));
                    prow = handles.im2maskY(point(1,2));
                    %Point described in linear indexing
                    point_lin = sub2ind(handles.sze,currentslice,prow,pcol);
                    
                case 2
                    
                    pcol = handles.im2maskZ(point(1,1));
                    prow = handles.im2maskX(point(1,2));
                    %Point described in linear indexing
                    point_lin = sub2ind(handles.sze,prow,currentslice,pcol);
                    
                case 3
                    
                    pcol = handles.im2maskY(point(1,1));
                    prow = handles.im2maskX(point(1,2));
                    
                    %Point described in linear indexing
                    point_lin = sub2ind(handles.sze,prow,pcol,currentslice);
                    
            end
            
            %Find (possible) chosen cluster
            mask = logical(handles.data);
            labels = bwlabeln(mask);
            stats = regionprops(labels,'PixelIdxList');
            NumLbl=max(labels(:));
            %Loop over connected regions
            for j=1:NumLbl
                %if chosen point is contained in region
                if ismember(point_lin,[stats(j).PixelIdxList]);
                    %if in 'draw' mode - keep region & erase other regions
                    %if in 'erase' mode - erase region and keep other regions
                    if(get(bg_drawerase,'SelectedObject')==radio_draw)
                        handles.data = zeros(size(handles.data));
                        handles.data([stats(j).PixelIdxList]) = 1;
                    else
                        handles.data([stats(j).PixelIdxList]) = 0;
                    end
                    
                    %break loop if region is found
                    break;
                end
            end
            
        end
        
        set(figmain,'Pointer','arrow');
        
        ImageUpdate;
        
        set(rotate_vol, 'Enable', 'on');
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function ROIbutton_Callback(event, data)
        
        set(rotate_vol, 'Enable', 'off');
        
        set(figmain, 'Pointer', 'cross');
        ROIx = [];
        ROIy = [];
        
        set(handles.I,'ButtonDownFCN','');
        
        %dim = size(squeeze(handles.data(:,:,1)));
        scol = get(handles.I,'Xdata');scol = scol(2);
        srow = get(handles.I,'Ydata');srow = srow(2);
        while(~waitforbuttonpress)
            point = round(get(gca,'CurrentPoint'));
            
            if( point(1,1)<=scol && ...
                    point(1,1)>=0 && ...
                    point(1,2)<=srow && ...
                    point(1,2)>=0)        
                
                ROIx(end+1) = point(1,1);
                ROIy(end+1) = point(1,2);
                hold on;
                axis manual;
                plot(ROIx,ROIy,'-g');
                hold off;
            end
        end
        
        ROIx(end+1) = ROIx(1);
        ROIy(end+1) = ROIy(1);
        
        axes(axes_edit);
        hold on;
        axis manual;
        poly = plot(ROIx,ROIy,'-g');
        hold off;
        currentslice = round(get(slider_slice,'Value'));
        switch get(popup_orient,'Value')
            case 1
                for k=1:length(ROIx)
                    ROIx(k) = handles.im2maskZ(ROIx(k));
                    ROIy(k) = handles.im2maskY(ROIy(k));
                end
                dim1 = handles.sze(2);
                dim2 = handles.sze(3);
                I = squeeze(handles.data(currentslice,:,:));
            case 2
                for k=1:length(ROIx)
                    ROIx(k) = handles.im2maskZ(ROIx(k));
                    ROIy(k) = handles.im2maskX(ROIy(k));
                end
                dim1 = handles.sze(1);
                dim2 = handles.sze(3);
                I = squeeze(handles.data(:,currentslice,:));
            case 3
                for k=1:length(ROIx)
                    ROIx(k) = handles.im2maskY(ROIx(k));
                    ROIy(k) = handles.im2maskX(ROIy(k));
                end
                dim1 = handles.sze(1);
                dim2 = handles.sze(2);
                I = squeeze(handles.data(:,:,currentslice));
        end
        
        %dim = size(squeeze(handles.data(:,:,1)))
        bw = poly2mask(ROIx,ROIy,dim1,dim2);
        %currentslice = round(get(handles.sliceSlider,'Value'));
        %I = squeeze(handles.data(:,:,currentslice));
        if(get(bg_drawerase,'SelectedObject')==radio_draw)
            I(bw) = 1;
        else
            I(bw) = 0;
        end
        %handles.data(:,:,currentslice) = I;
        switch get(popup_orient,'Value')
            case 1
                handles.data(currentslice,:,:) = I;
            case 2
                handles.data(:,currentslice,:) = I;
            case 3
                handles.data(:,:,currentslice) = I;
        end
        set(figmain,'Pointer','arrow');
        
        ImageUpdate;
        
        set(rotate_vol, 'Enable', 'on');
        
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function openmaskMenu_Callback(event, data)
        
        %Choose file
        [filename, pathname, filterindex] = uigetfile({'*.nii;*.img', 'Choose Nifti file';'*.img', 'Choose Analyze file'});
        if isequal(filename,0)
            return;
        end
        disp(filename)
        if filterindex==1
            %Read Nifti file
            %nii = load_nii([pathname,filename]);
            %handles.corr = nii.img;
            nii = nifti([pathname,filename]);
            mask = logical(nii.dat(:,:,:));
        elseif filterindex==2
            %Read Analyze file
            mask = read_analyze(filename,pathname);
            mask = logical(mask);
        end

        handles.data(~mask) = 0;
        
        ImageUpdate;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function SphereButton_Callback(event, data)
        
        set(rotate_vol, 'Enable', 'off');
        
        %select center voxel by clicking
        set(figmain,'Pointer','cross');
        set(handles.I,'ButtonDownFCN','');
        
        scol = get(handles.I,'Xdata');scol = scol(2);
        srow = get(handles.I,'Ydata');srow = srow(2);
        
        waitforbuttonpress;
        currentslice = round(get(slider_slice,'Value'));
        point = round(get(gca,'CurrentPoint'));

        answ = inputdlg({'Radius'},'Sphere',1,{'5'});
        R = str2num(answ{1});
        
        if( point(1,1)<=scol && ...
                point(1,1)>=0 && ...
                point(1,2)<=srow && ...
                point(1,2)>=0)
            
            switch get(popup_orient,'Value')
                case 1
                    
                    pcol = handles.im2maskZ(point(1,1));
                    prow = handles.im2maskY(point(1,2));
                    [xx yy zz] = meshgrid(1:handles.sze(1),1:handles.sze(2),1:handles.sze(3));
                    S = sqrt((xx-prow).^2+(yy-currentslice).^2+(zz-pcol).^2)<=R;
                    
                case 2
                    
                    pcol = handles.im2maskZ(point(1,1));
                    prow = handles.im2maskX(point(1,2));
                    [xx yy zz] = meshgrid(1:handles.sze(1),1:handles.sze(2),1:handles.sze(3));
                    S = sqrt((xx-currentslice).^2+(yy-prow).^2+(zz-pcol).^2)<=R;
                    
                case 3
                    
                    pcol = handles.im2maskY(point(1,1));
                    prow = handles.im2maskX(point(1,2));
                    
                    %Point described in linear indexing
                    point_lin = sub2ind(handles.sze,prow,pcol,currentslice);
                    [xx yy zz] = meshgrid(1:handles.sze(1),1:handles.sze(2),1:handles.sze(3));
                    S = sqrt((xx-pcol).^2+(yy-prow).^2+(zz-currentslice).^2)<=R;
                    
            end
                        
            %Find (possible) chosen cluster
            handles.data(~S) = 0;

            
        end
        
        set(figmain,'Pointer','arrow');
        
        ImageUpdate;
        
        set(rotate_vol, 'Enable', 'on');
        
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function ClearButton_Callback(event, data)
        
        currentslice = round(get(slider_slice,'Value'));
        switch get(popup_orient,'Value')
            case 1
                handles.data(currentslice,:,:) = 0;
            case 2
                handles.data(:,currentslice,:) = 0;
            case 3
                handles.data(:,:,currentslice) = 0;
        end
        ImageUpdate;
        
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function infoMenu_Callback(event, data)
        
        str = sprintf('Nr of voxels: %d',nnz(handles.data));
        disp(str);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function KeepButton_Callback(event, data)
        
        %Remove all nrkeep voxels higher or lower than the current slice
        
        nrkeep = round(str2num(get(edit_Keep,'String')));
        
        currentslice = round(get(slider_slice,'Value'));
        
        if get(radio_Lower,'Value')
            
            switch get(popup_orient,'Value')
                case 1
                    handles.data(currentslice:end,:,:) = 0;
                case 2
                    handles.data(:,currentslice:end,:) = 0;
                case 3
                    handles.data(:,:,currentslice:end) = 0;
            end
            
        else
            switch get(popup_orient,'Value')
                case 1
                    handles.data(1:currentslice,:,:) = 0;
                case 2
                    handles.data(:,1:currentslice,:) = 0;
                case 3
                    handles.data(:,:,1:currentslice) = 0;
            end
        end
        
        temp = handles.corr;
        temp(~handles.data) = 0;
        [sa,i]=sort(temp(:),'descend');
        
        disp(['Corresponding threshold value : ', num2str(sa(nrkeep))]);
        
        handles.data(i(nrkeep+1:end)) = 0;
        
        ImageUpdate;
        
        
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function ImageUpdate
        
        %set(rotate_vol, 'Enable', 'off');
        
        currentslice = round(get(slider_slice,'Value'));
        
        %Extract slices
        switch get(popup_orient,'Value')
            case 1
                currentslice_im = handles.mask2imX(currentslice);
                imslice = squeeze(handles.visdata(currentslice_im,:,:,1));
                
                handles.Mask = logical(squeeze(handles.data(currentslice,:,:)));
                handles.Mask = imresize(handles.Mask,[handles.imsze(2) handles.imsze(3)]);
                
                x = [currentslice currentslice; currentslice currentslice];
                y = [1 handles.sze(2); 1 handles.sze(2)];
                z = [1 1; handles.sze(3) handles.sze(3)];
                
            case 2
                currentslice_im = handles.mask2imY(currentslice);
                imslice = squeeze(handles.visdata(:,currentslice_im,:,1));
                
                handles.Mask = logical(squeeze(handles.data(:,currentslice,:)));
                handles.Mask = imresize(handles.Mask,[handles.imsze(1) handles.imsze(3)]);
                
                z = [1 1; handles.sze(3) handles.sze(3)];
                y = [currentslice currentslice; currentslice currentslice];
                x = [1 handles.sze(1); 1 handles.sze(1)];
                
            case 3
                currentslice_im = handles.mask2imZ(currentslice);
                imslice = squeeze(handles.visdata(:,:,currentslice_im,1));
                
                handles.Mask = logical(squeeze(handles.data(:,:,currentslice)));
                handles.Mask = imresize(handles.Mask,[handles.imsze(1) handles.imsze(2)]);
                
%                 z = [currentslice; currentslice; currentslice; currentslice];
%                 y = [0; handles.sze(2); handles.sze(2); 0];
%                 x = [0; 0; handles.sze(1); handles.sze(1)];
                z = [currentslice currentslice; currentslice currentslice];
                x = [1 handles.sze(2); 1 handles.sze(2)];
                y = [1 1; handles.sze(1) handles.sze(1)];
        end
        imslice = int16(imslice/max(handles.maximdata,10^-5)*254+1);
        %keep for current slice marker
        slicemarker = imslice;
        
        %Show slice
        imslice(handles.Mask) = 256;
        axes(axes_edit);
        handles.I = imshow(imslice,[1 256]);
        %handles.I = imshow(imslice,clrmap);
        set(handles.I,'ButtonDownFCN',@editImage);%@(event, data) editImage);
        
        %Show clusters
        axes(axes_vol)
        [az,el] = view;
        active = find(handles.data);
        [handles.X,handles.Y,handles.Z] = ind2sub(size(handles.data),active);
        handles.sc = scatter3(handles.Y,handles.X,handles.Z,'r','.');
        set(handles.sc,'HitTest','off');
        
        %Show Marker for current slice
        %tcolor(1,1,1:3) = [0 0 1];
        %handles.ps = patch(y,x,z,tcolor);
        %set(handles.ps,'FaceAlpha',0.3,'HitTest','off','EdgeColor','none');
        %set(axes_vol,'XLim',[0 handles.sze(2)],'YLim',[0 handles.sze(1)],'ZLim',[0 handles.sze(3)],'DataAspectRatio',[1,1,1]);
        
        handles.ps = surface('XData',y,'YData',x,'ZData',z,...
	      'CData', uint8(slicemarker)' ,...
	      'FaceColor','texturemap',...
	      'EdgeColor','none',...
	      'LineStyle','none',...
	      'Marker','none',...
	      'MarkerFaceColor','none',...
	      'MarkerEdgeColor','none',...
	      'CDataMapping','direct',...
          'FaceAlpha',0.6);
      set(axes_vol,'XLim',[0 handles.sze(2)],'YLim',[0 handles.sze(1)],'ZLim',[0 handles.sze(3)],'DataAspectRatio',[1,1,1]);  
      
      
        view([az,el]);
        
        colormap(clrmap);
        
        %setAllowAxesRotate(rotate_vol, axes_vol , true);
        setAllowAxesRotate(rotate_vol, axes_edit , false);
        %set(rotate_vol, 'Enable', 'on');

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [disallowRotation] = RotateFilter(obj,event_obj)
 
        disallowRotation = false;
        % if a ButtonDownFcn has been defined for the object, then use that
        if isfield(get(obj),'ButtonDownFcn')
            disallowRotation = ~isempty(get(obj,'ButtonDownFcn'));
        end
         
    end
    
end