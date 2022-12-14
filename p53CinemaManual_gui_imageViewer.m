%% p53CinemaManual_gui_imageViewer
% a simple gui to pause, stop, and resume a running MDA
function [f] = p53CinemaManual_gui_imageViewer(master, maxHeight)
%% Create the figure
maxHeight = maxHeight - 10*master.ppChar(2);

hheightaxes = min(master.obj_imageViewer.image_height, maxHeight);
hwidthaxes = hheightaxes * master.obj_imageViewer.image_width / master.obj_imageViewer.image_height;
hheightaxes = hheightaxes/master.ppChar(2);
hwidthaxes = hwidthaxes/master.ppChar(1);

fwidth = hwidthaxes;
fheight = hheightaxes + 5;

f = figure('Visible','off','Units','characters','MenuBar','none',...
    'Resize','off','Name','Image Viewer',...
    'Renderer','OpenGL','Position',[0 0 fwidth fheight],...
    'CloseRequestFcn',{@fCloseRequestFcn},...
    'KeyPressFcn',{@fKeyPressFcn},...
    'WindowButtonDownFcn',{@fWindowButtonDownFcn},...
    'WindowButtonMotionFcn',{@fHover},...
    'WindowScrollWheelFcn',{@fWindowScrollWheelFcn});

figurePosition = get(gcf, 'Position');

hx = 0; hy = figurePosition(4) - hheightaxes;

haxesImageViewer = axes('Units','characters','XTick',[], 'YTick', [],...
    'Position',[hx hy hwidthaxes  hheightaxes ],'YDir','reverse','Visible','on',...
    'XLim',[1-0.5,master.obj_imageViewer.image_width+0.5],'YLim',[1-0.5,master.obj_imageViewer.image_height+0.5]); %when displaying images the center of the pixels are located at the position on the axis. Therefore, the limits must account for the half pixel border.

%% Create an axes
% highlighted cell with hover haxesHighlight =
% axes('Units','characters','DrawMode','fast','color','none',...
%     'Position',[hx hy hwidth hheight],...
%     'XLim',[1,master.image_width],'YLim',[1,master.image_height]);
cmapHighlight = colormap(haxesImageViewer,jet(16)); %63 matches the number of elements in ang
%% object order
% # image
% # annotation layer
% # highlight
% # selected cell
colormap(haxesImageViewer,gray(255));
sourceImage = image('Parent',haxesImageViewer,'CData',master.obj_imageViewer.currentImage);
hold(haxesImageViewer, 'on');

currentCellTrace = plot(haxesImageViewer,1,1, 'Color', [1,0,0], 'LineWidth', 1);

neighborCellTrace = plot(haxesImageViewer,1,1, 'Color', [0.2,0.85,0.2], 'LineWidth', 1);

annotationNames = master.additionalAnnotationNames;
cellFateEventPatch = zeros(length(annotationNames),1);
colors = jet(length(cellFateEventPatch));
for i=1:length(annotationNames)
cellFateEventPatch(i) = patch('XData',[],'YData',[],...
    'EdgeColor','none','FaceColor','none','MarkerSize',20,...
    'Marker','o','MarkerEdgeColor',colors(i,:),'MarkerFaceColor',colors(i,:),...
    'Parent',haxesImageViewer);
end

divisionEventPatch = patch('XData',[],'YData',[],...
    'EdgeColor','none','FaceColor','none','MarkerSize',20,...
    'Marker','o','MarkerEdgeColor',[0.9,0.75,0],'MarkerFaceColor',[255 215 0]/255,...
    'Parent',haxesImageViewer);
customEventPatch = patch('XData',[],'YData',[],...
    'EdgeColor','none','FaceColor','none','MarkerSize',20,...
    'Marker','o','MarkerEdgeColor',[1,1,1],'MarkerFaceColor',[1 1 1],...
    'Parent',haxesImageViewer);
deathEventPatch = patch('XData',[],'YData',[],...
    'EdgeColor','none','FaceColor','none','MarkerSize',20,...
    'Marker','o','MarkerEdgeColor',[255,0,255]/255,'MarkerFaceColor',[139,0,139]/255,...
    'Parent',haxesImageViewer);

sisterCellPatch = patch('XData',[],'YData',[],...
    'EdgeColor','none','FaceColor','none','MarkerSize',20,...
    'Marker','h','MarkerFaceColor',[0,0.7,0.9], 'MarkerFaceColor',[0,0.5,0.9],...
    'Parent',haxesImageViewer);

mergeEventPatch = patch('XData',[],'YData',[],...
    'EdgeColor','none','FaceColor','none','MarkerSize',20,...
    'Marker','o','MarkerEdgeColor',[0.1,0.6,0.1],'MarkerFaceColor',[0.2,0.85,0.2],...
    'Parent',haxesImageViewer);

trackedCellsPatch = patch('XData',[],'YData',[],...
    'EdgeColor','none','FaceColor','none','MarkerSize',10,...
    'Marker','o','MarkerEdgeColor',[0,0.75,1],'MarkerFaceColor',[0,0.25,1],...
    'Parent',haxesImageViewer);

completeCellsPatch = patch('XData',[],'YData',[],...
    'EdgeColor','none','FaceColor','none','MarkerSize',10,...
    'Marker','o','MarkerEdgeColor',[0,1,0],'MarkerFaceColor',[0,0.75,0.24],...
    'Parent',haxesImageViewer);

selectedCellPatch = patch('XData',[],'YData',[],...
    'EdgeColor','none','FaceColor','none','MarkerSize',10,...
    'Marker','o','MarkerEdgeColor',[1,0.75,0],'MarkerFaceColor',[1,0,0],...
    'Parent',haxesImageViewer);

cellsInRangePatch = patch('XData',[],'YData',[],...
    'EdgeColor','none','FaceColor','none','MarkerSize',1,...
    'Marker','o','MarkerEdgeColor',[1,0.75,0],'MarkerFaceColor',[1,0,0],...
    'Parent',haxesImageViewer);

closestCellPatch = patch('XData',[],'YData',[],...
    'EdgeColor','none','FaceColor','none','MarkerSize',5,...
    'Marker','o','MarkerEdgeColor',[0,0.75,0.24],'MarkerFaceColor',[0,1,0],...
    'Parent',haxesImageViewer);
hold(haxesImageViewer, 'off');

%% Create controls
% Slider bar and two buttons
hwidth = hwidthaxes;
hheight = 20/master.ppChar(2);
hmargin = 1;
hx = 0;
hy = 0;

sliderStep = 1/(master.obj_fileManager.numImages - 1);
hsliderExploreStack = uicontrol('Style','slider','Units','characters',...
    'Min',0,'Max',1,'BackgroundColor',[255 215 0]/255,...
    'Value',0,'SliderStep',[sliderStep sliderStep],'Position',[hx hy hwidth hheight],...
    'Callback',{@sliderExploreStack_Callback});
    addlistener(hsliderExploreStack,'ContinuousValueChange',@sliderExploreStack_Callback);
% try    % R2013b and older
%     addlistener(hsliderExploreStack,'ActionEvent',@sliderExploreStack_Callback);
% catch  % R2014a and newer
%     addlistener(hsliderExploreStack,'ContinuousValueChange',@sliderExploreStack_Callback);
% end

hx = 0;
hy = hy + hheight + 1;
hwidth = 60/master.ppChar(1);
hheight = 30/master.ppChar(2);

hpushbuttonFirstImage = uicontrol('Style','pushbutton','Units','characters',...
    'FontSize',10,'FontName','Arial','BackgroundColor',[255 215 0]/255,...
    'String','First Image','Position',[hx hy hwidth hheight],...
    'Visible','off','Enable','off',...
    'Callback',{@pushbuttonFirstImage_Callback});

hx = hwidth;
hpushbuttonLastImage = uicontrol('Style','pushbutton','Units','characters',...
    'FontSize',10,'FontName','Arial','BackgroundColor',[60 179 113]/255,...
    'String','Last Image','Position',[hx hy hwidth hheight],...
    'Visible','off','Enable','off',...
    'Callback',{@pushbuttonLastImage_Callback});

%hx = hwidth*2.25;
hx = hmargin;
htextMarkerSize = uicontrol('Style','text','Units','characters',...
    'FontSize',10,'FontName','Arial',...
    'String','Marker size','Position',[hx hy hwidth*1.5 hheight]);
%hx = hx + hmargin + hwidth;
hpopupMarkerSize = uicontrol('Style','popupmenu','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Select channel','Position',[hx, hy - hheight*0.5, hwidth*1.5, hheight],...
    'Enable', 'on', 'parent',f, 'Callback',{@popupMarkerSize_Callback});
set(hpopupMarkerSize, 'String', {'Large', 'Medium', 'Small'});
set(hpopupMarkerSize, 'Value', 1);
hx = hx + hmargin + hwidth*1.5;
hcheckboxShowTrack = uicontrol('Style','checkbox','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Show track','Position',[hx, hy, hwidth*1.5, hheight],...
    'Value',1,'parent',f, 'Callback',{@checkboxShowTrack_Callback});
hx = hx + hmargin + hwidth*1.5;
htextFrameNumber = uicontrol('Style','text','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','center',...
    'String','Frame 1','Position',[hx, hy, hwidth*2, hheight],...
    'parent',f);

hx = fwidth - 1.5*hwidth;
hcheckboxPreprocessFrame = uicontrol('Style','checkbox','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Preprocess','Position',[hx, hy+hheight*0.5, hwidth*1.5, hheight*0.5],...
    'Value',0,'parent',f, 'Callback',{@checkboxPreprocessFrame_Callback});
hx = fwidth - 1.5*hwidth;
hpopupViewerChannel = uicontrol('Style','popupmenu','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Select channel','Position',[hx, hy, hwidth * 1.5, hheight*0.5],...
    'Enable', 'on', 'parent',f, 'Callback',{@popupViewerChannel_Callback});
fileManagerHandles = guidata(master.obj_fileManager.gui_fileManager);
set(hpopupViewerChannel, 'String', get(fileManagerHandles.hpopupPimaryChannel, 'String'));
set(hpopupViewerChannel, 'Value', get(fileManagerHandles.hpopupPimaryChannel, 'Value'));

%%
% store the uicontrol handles in the figure handles via guidata()
handles.axesImageViewer = haxesImageViewer;

handles.currentCellTrace = currentCellTrace;
handles.neighborCellTrace = neighborCellTrace;

handles.pushbuttonFirstImage = hpushbuttonFirstImage;
handles.pushbuttonLastImage = hpushbuttonLastImage;
handles.hsliderExploreStack = hsliderExploreStack;
handles.cmapHighlight = cmapHighlight;
handles.cellFateEventPatch = cellFateEventPatch;
handles.divisionEventPatch = divisionEventPatch;
handles.customEventPatch = customEventPatch;
handles.deathEventPatch = deathEventPatch;
handles.sisterCellPatch = sisterCellPatch;
handles.mergeEventPatch = mergeEventPatch;
handles.trackedCellsPatch = trackedCellsPatch;
handles.completeCellsPatch = completeCellsPatch;
handles.selectedCellPatch = selectedCellPatch;
handles.cellsInRangePatch = cellsInRangePatch;
handles.closestCellPatch = closestCellPatch;
handles.sourceImage = sourceImage;
handles.hpopupViewerChannel = hpopupViewerChannel;
handles.htextFrameNumber = htextFrameNumber;
handles.hcheckboxPreprocessFrame = hcheckboxPreprocessFrame;
handles.hcheckboxShowTrack = hcheckboxShowTrack;

guidata(f,handles);
%%
% make the gui visible
set(f,'Visible','on');

%% Callbacks
%
%%
%
    function fCloseRequestFcn(~,~)
        master.obj_imageViewer.delete;
    end
%%
%
    function fKeyPressFcn(~,keyInfo)
        switch keyInfo.Key
            case 'period'
                master.obj_imageViewer.nextFrame;
            case 'comma'
                master.obj_imageViewer.previousFrame;
            case 'rightarrow'
                breakpoints = getTrackBreakpoints(master.obj_imageViewer.obj_cellTracker.centroidsTracks);
                if(~isempty(breakpoints))
                    jumpFrame = find(breakpoints > master.obj_imageViewer.currentFrame,1,'first');
                    if(~isempty(jumpFrame))
                        master.obj_imageViewer.setFrame(breakpoints(jumpFrame));
                    end
                end
            case 'leftarrow'
                breakpoints = getTrackBreakpoints(master.obj_imageViewer.obj_cellTracker.centroidsTracks);
                if(~isempty(breakpoints))
                    jumpFrame = find(breakpoints < master.obj_imageViewer.currentFrame,1,'last');
                    if(~isempty(jumpFrame))
                        master.obj_imageViewer.setFrame(breakpoints(jumpFrame));
                    end
                end
            case 'downarrow'
                breakpoints = getTrackBreakpoints(master.obj_imageViewer.obj_cellTracker.centroidsDivisions);
                if(~isempty(breakpoints))
                    jumpFrame = find(breakpoints > master.obj_imageViewer.currentFrame,1,'first');
                    if(~isempty(jumpFrame))
                        master.obj_imageViewer.setFrame(breakpoints(jumpFrame));
                    end
                end
            case 'uparrow'
                breakpoints = getTrackBreakpoints(master.obj_imageViewer.obj_cellTracker.centroidsDivisions);
                if(~isempty(breakpoints))
                    jumpFrame = find(breakpoints < master.obj_imageViewer.currentFrame,1,'last');
                    if(~isempty(jumpFrame))
                        master.obj_imageViewer.setFrame(breakpoints(jumpFrame));
                    end
                end
            case 'backspace'
                currentCentroid = master.obj_imageViewer.obj_cellTracker.centroidsTracks.getCentroid(master.obj_imageViewer.currentTimepoint, master.obj_imageViewer.selectedCell);
                if(currentCentroid(1) > 0)
                    master.obj_imageViewer.obj_cellTracker.centroidsTracks.deleteCentroid(master.obj_imageViewer.currentTimepoint, master.obj_imageViewer.selectedCell);
                    master.obj_imageViewer.obj_cellTracker.centroidsDivisions.setCentroid(master.obj_imageViewer.currentTimepoint, master.obj_imageViewer.selectedCell, [0,0], 0);
                    master.obj_imageViewer.obj_cellTracker.centroidsDeath.setCentroid(master.obj_imageViewer.currentTimepoint, master.obj_imageViewer.selectedCell, [0,0], 0);
                    master.obj_imageViewer.setImage;
                else
                    master.obj_imageViewer.deleteSelectedCellTrack();
                end
                master.obj_imageViewer.setImage;
            case 'space'
                master.obj_imageViewer.obj_cellTracker.setDivisionEvent;
                master.obj_imageViewer.setImage;
            case 'control'
                master.obj_imageViewer.obj_cellTracker.setDeathEvent;
                master.obj_imageViewer.setImage;
            case 'tab'
                master.obj_imageViewer.obj_cellTracker.firstClick = 1;
        end
    end

    function breakpoints = getTrackBreakpoints(centroidsObject)
        selectedCell = master.obj_imageViewer.selectedCell;
        if(master.obj_imageViewer.selectedCell > 0)
            currentTrack = centroidsObject.getCellTrack(selectedCell);
            currentTrack = currentTrack(master.obj_fileManager.currentImageTimepoints,:);
            activeTimepoints = find(currentTrack(:,1) > 0);
            if(~isempty(activeTimepoints))
                breakpoints = unique([1, find(diff(activeTimepoints) > 1)'+1, length(activeTimepoints)]);
                breakpoints = activeTimepoints(breakpoints);
            else
                breakpoints = [];
            end
        else
            breakpoints = [];
        end
    end

%%
%
    function fWindowButtonDownFcn(~,~)
        master.obj_imageViewer.obj_cellTracker.triggerTracking(get(master.obj_imageViewer.gui_imageViewer,'SelectionType'));
    end

    function fWindowScrollWheelFcn(~,event)
        newFrame = master.obj_imageViewer.currentFrame + event.VerticalScrollCount;
        master.obj_imageViewer.setFrame(newFrame);
    end
%%
% Translate the mouse position into the pixel location in the source image
    function fHover(~,~)
        set(f, 'HandleVisibility', 'on');
        set(0, 'currentfigure', f);
        % This function is redundant with the setImage function
        currentPoint = master.obj_imageViewer.getPixelxy;
        if(isempty(currentPoint))
            return;
        end
        
        if(~master.obj_fileManager.preprocessMode)
            return;
        end
        master.obj_imageViewer.setImage;
    end
%%
%
    function sliderExploreStack_Callback(~,~)
        frame = get(hsliderExploreStack,'Value');
        sliderStep = get(hsliderExploreStack,'SliderStep');
        targetFrame = round((frame / sliderStep(1)) + 1);
        master.obj_imageViewer.setFrame(targetFrame);
    end
%%
%
    function pushbuttonFirstImage_Callback(~,~)
        master.obj_imageViewer.setFrame(1);
    end
%%
%
    function pushbuttonLastImage_Callback(~,~)
        master.obj_imageViewer.setFrame(length(master.obj_fileManager.currentImageFilenames));
    end

%%
%
    function popupMarkerSize_Callback(~,~)
        markerSizeMap = [20, 10, 5; 10, 5, 3; 8, 3, 2];
        sizeOption = get(hpopupMarkerSize, 'Value');
        for index=1:length(cellFateEventPatch)
            set(cellFateEventPatch(index), 'MarkerSize', markerSizeMap(sizeOption, 1));
        end
        set(divisionEventPatch, 'MarkerSize', markerSizeMap(sizeOption, 1));
        set(customEventPatch, 'MarkerSize', markerSizeMap(sizeOption, 1));
        set(deathEventPatch, 'MarkerSize', markerSizeMap(sizeOption, 1));
        set(sisterCellPatch, 'MarkerSize', markerSizeMap(sizeOption, 1));
        set(mergeEventPatch, 'MarkerSize', markerSizeMap(sizeOption, 1));
        set(trackedCellsPatch, 'MarkerSize', markerSizeMap(sizeOption, 2));
        set(completeCellsPatch, 'MarkerSize', markerSizeMap(sizeOption, 2));
        set(selectedCellPatch, 'MarkerSize', markerSizeMap(sizeOption, 2));
        set(closestCellPatch, 'MarkerSize', markerSizeMap(sizeOption, 3));
        
    end

%%
%
    function popupViewerChannel_Callback(~,~)
        master.obj_imageViewer.setFrame(master.obj_imageViewer.currentFrame);
    end

%%
%
    function checkboxPreprocessFrame_Callback(~,~)
        master.obj_imageViewer.setFrame(master.obj_imageViewer.currentFrame);
    end

    function checkboxShowTrack_Callback(~,~)
        master.obj_imageViewer.setImage;
    end
end