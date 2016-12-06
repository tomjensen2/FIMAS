function varargout = MAIN_GUI(varargin)
% Fluorescence Imaging Microscopy Analysis Software Ver 1.0
% Author: Kaiyu Zheng
% Email: k.zheng@ucl.ac.uk
% -------------------------------
% System Recommendation:
% CPU: Multi-Core System
% RAM: > 4GB depending on image data size, ideally 16GB for TCSPC
% HDD: > 4GB free
% Operating System: 64bit Matlab 2008b to 2016b on Linux/Mac/Windows
% PDF Manual: require xpdf on linux and default pdf viewer on Mac/Windows

% Last Modified by GUIDE v2.5 16-Jan-2015 19:23:44

%==============================================================
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @MAIN_GUI_OpeningFcn, ...
    'gui_OutputFcn',  @MAIN_GUI_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
%==============================================================

% --- Executes just before MAIN_GUI is made visible.
function MAIN_GUI_OpeningFcn(hObject, ~, handles, varargin)
% Choose default command line output for MAIN_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% initialise GUI as new
initialise(1,handles);

% --- Outputs from this function are returned to the command line.
function varargout = MAIN_GUI_OutputFcn(~, ~, handles)
% Get default command line output from handles structure
varargout{1} = handles.output;

%==============================================================
%#ok<*DEFNU>
%==============================================================
% create new analysis session
function PUSHTOOL_NEW_ClickedCallback(~, ~, handles)
global SETTING hDATA;
% Ask if want to start a new session
button = questdlg({'Are you sure you want to start a new session?  Unsaved data will be lost.',...
    'Make sure you have saved your work'},...
    'Check and Confirm','Yes','No','No');pause(0.001);
switch button
    case 'Yes'
        % inform user
        update_info(sprintf('%s\n','Starting New Session ...'),1,handles.EDIT_INFO);
        % update default path to the current selection
        SETTING.rootpath.raw_data=hDATA.path.import;
        SETTING.rootpath.exported_data=hDATA.path.export;
        SETTING.rootpath.saved_data=hDATA.path.saved;
        rootpath=SETTING.rootpath; %#ok<NASGU>
        % save to default path file
        save(cat(2,'.',filesep,'lib',filesep,'default_path.mat'),'rootpath','-mat');
        % clear all data handle before exiting
        % start new session
        initialise(1,handles);% initialise environment
        % inform user
        update_info(sprintf('%s\n','New Session Started'),1,handles.EDIT_INFO);
    case 'No'
        % cancel action and inform user
        update_info(sprintf('%s\n','Carry On!'),1,handles.EDIT_INFO);
end

%open existing analysis session
function PUSHTOOL_OPEN_ClickedCallback(~, ~, handles)
global hDATA;
% ask if want to open session file
button = questdlg({'Are you sure you want to open a new file?  Current unsaved data will be lost.',...
    'Make sure you have saved your work'},...
    'Check and Confirm','Yes','No','No');pause(0.001);
switch button
    case 'Yes'
        % tell user to wait
        update_info(sprintf('Loading ... Wait\n'),1,handles.EDIT_INFO);
        [ success, message ] = hDATA.data_open;% open file
        if success
            % file opened fine
            initialise(0,handles);% initialse GUI to use new data
            % inform user
            update_info(sprintf('%s\n',message),1,handles.EDIT_INFO);
        else
            % file open failed inform failed message
            update_info(sprintf('File Loading failed.\n%s\n',message),1,handles.EDIT_INFO);
        end
    case 'No'
        % action cancelled
        update_info(sprintf('%s\n','Carry On!'),1,handles.EDIT_INFO);
end

%save current analysis session
function PUSHTOOL_SAVE_ClickedCallback(~, ~, handles)
global hDATA;
% inform user
update_info(sprintf('%s\n','Saving Data ... '),1,handles.EDIT_INFO);
% save data
[ success, message ] = hDATA.data_save;
if success % data file saved fine
    % update data list names
    populate_list(handles.LIST_DATA,{hDATA.data.dataname},hDATA.current_data);
end
% output message successful or failed
update_info(sprintf('%s\n',message),1,handles.EDIT_INFO);

%---------------------------------------------------------------
% input local command to test
function EDIT_INFO_Callback(hObject, ~, ~)
% execute inputted command
text_command(hObject);

% --------------------------------------------------------------------
% display about text
function MENUITEM_ABOUT_Callback(~, ~, ~)
global SETTING;
% get help text from top of this function
helptext=help(mfilename);
% get icon
iconimg=imread(cat(2,SETTING.rootpath.icon_path,'about_icon.jpg'));
% output about message
hmsg=msgbox(helptext,'About:FIMAS','custom',iconimg,gray(16),'modal');
% change about window icon
javaFrame = get(hmsg,'JavaFrame');
javaFrame.setFigureIcon(javax.swing.ImageIcon(cat(2,SETTING.rootpath.icon_path,'main_icon.png')));

% Display help pdf file
function MENUITEM_HELP_Callback(~, ~, ~)
global SETTING;
% open manual document depending on arch
try
    switch computer
        case {'PCWIN','PCWIN64'}
            % PC
            winopen(SETTING.usage);
        case {'MACI','MACI64'}
            % MAC
            open(SETTING.usage);
        case {'GLNX86','GLNXA64'}
            % LINUX
            unix(cat(2,'xpdf ',SETTING.usage));
        otherwise
            % unknown system
            errordlg('Unknown computer achitecture','Error','modal');
    end
catch exception
    message=[exception.message,data2clip(exception.stack)];
    update_info(sprintf('%s\n',message),1,handles.EDIT_INFO);
end

% -------------------------------------------------------------
% open graphic control panel
function PUSHTOOL_GRAPHCONTROLPANEL_ClickedCallback(~, ~, ~)
% find if the panel has opened already
gc_fig=findall(0,'Name','GUI_GRAPH_CONTROL');
if isempty(gc_fig)
    %figure is closed, then open it
    GUI_GRAPH_CONTROL;
else
    %figure is already open, bring to focus
    figure(gc_fig);
end

% --- CHANGE PANEL SELECTION ---
function LABEL_PANEL_DATA_dt_ButtonDownFcn(~, ~, handles)
global SETTING;
% switch panel
[success,message,axeshandle]=SETTING.change_panel('PANEL_DATA_dt');
if success
    % set current axes handle
    set(handles.MAIN_GUI,'CurrentAxes',axeshandle);
    % switch to graphic control panel
    PUSHTOOL_GRAPHCONTROLPANEL_ClickedCallback([], [], []);
end
update_info(sprintf('%s\n',message),1,handles.EDIT_INFO);

function LABEL_PANEL_DATA_MAP_ButtonDownFcn(~, ~, handles)
global SETTING;
% switch panel
[success,message,axeshandle]=SETTING.change_panel('PANEL_DATA_MAP');
if success
    % set current axes handle
    set(handles.MAIN_GUI,'CurrentAxes',axeshandle);
    % switch to graphic control panel
    PUSHTOOL_GRAPHCONTROLPANEL_ClickedCallback([], [], []);
end
update_info(sprintf('%s\n',message),1,handles.EDIT_INFO);

function LABEL_PANEL_DATA_gT_ButtonDownFcn(~, ~, handles)
global SETTING;
% switch panel
[success,message,axeshandle]=SETTING.change_panel('PANEL_DATA_gT');
if success
    % set current axes handle
    set(handles.MAIN_GUI,'CurrentAxes',axeshandle);
    % switch to graphic control panel
    PUSHTOOL_GRAPHCONTROLPANEL_ClickedCallback([], [], []);
end
update_info(sprintf('%s\n',message),1,handles.EDIT_INFO);

function LABEL_PANEL_RESULT_param_ButtonDownFcn(~, ~, handles)
global SETTING;
% switch panel
[success,message,axeshandle]=SETTING.change_panel('PANEL_RESULT_param');
if success
    % set current axes handle
    set(handles.MAIN_GUI,'CurrentAxes',axeshandle);
    % switch to graphic control panel
    PUSHTOOL_GRAPHCONTROLPANEL_ClickedCallback([], [], []);
end
update_info(sprintf('%s\n',message),1,handles.EDIT_INFO);

function LABEL_PANEL_RESULT_MAP_ButtonDownFcn(~, ~, handles)
global SETTING;
% switch panel
[success,message,axeshandle]=SETTING.change_panel('PANEL_RESULT_MAP');
if success
    % set current axes handle
    set(handles.MAIN_GUI,'CurrentAxes',axeshandle);
    % switch to graphic control panel
    PUSHTOOL_GRAPHCONTROLPANEL_ClickedCallback([], [], []);
end
update_info(sprintf('%s\n',message),1,handles.EDIT_INFO);

function LABEL_PANEL_RESULT_gT_ButtonDownFcn(~, ~, handles)
global SETTING;
% switch panel
[success,message,axeshandle]=SETTING.change_panel('PANEL_RESULT_gT');
if success
    % set current axes handle
    set(handles.MAIN_GUI,'CurrentAxes',axeshandle);
    % switch to graphic control panel
    PUSHTOOL_GRAPHCONTROLPANEL_ClickedCallback([], [], []);
end
update_info(sprintf('%s\n',message),1,handles.EDIT_INFO);

function LABEL_PANEL_aux_ButtonDownFcn(~, ~, handles)
global SETTING;
% switch panel
[success,message,axeshandle]=SETTING.change_panel('PANEL_aux');
if success
    % set current axes handle
    set(handles.MAIN_GUI,'CurrentAxes',axeshandle);
    % switch to graphic control panel
    PUSHTOOL_GRAPHCONTROLPANEL_ClickedCallback([], [], []);
end
update_info(sprintf('%s\n',message),1,handles.EDIT_INFO);
% --------------------------------------------------------------------

% --- Executes when user attempts to close MAIN_GUI.
function MAIN_GUI_CloseRequestFcn(hObject, ~, handles)
global hDATA SETTING;
% ask for confirmation
button = questdlg({'Are you sure you want to quit?',...
    'Make sure you have saved your work'},...
    'Check and Confirm','Yes','No','No');
switch button
    case 'Yes'
        % update default path to the current selection
        SETTING.rootpath.raw_data=hDATA.path.import;
        SETTING.rootpath.exported_data=hDATA.path.export;
        SETTING.rootpath.saved_data=hDATA.path.saved;
        rootpath=SETTING.rootpath; %#ok<NASGU>
        % save to default path file
        save(cat(2,'.',filesep,'lib',filesep,'default_path.mat'),'rootpath','-mat');
        % clear all data handle before exiting
        %delete(hDATA);
        %delete(SETTING);
        %clear global hDATA SETTING;
        % close other GRAPHIC CONTROL GUI if open
        gc_gui=findall(0,'Name','GUI_GRAPH_CONTROL');
        if ~isempty(gc_gui)
            delete(gc_gui);
        end
        % clsoe main GUI
        delete(hObject);
    case 'No'
        %cancel closure
        update_info(sprintf('%s\n','Return to work'),1,handles.EDIT_INFO);
end

% --------------------------------------------------------------------
% --- Executes on selection change in LIST_DATA.
function LIST_DATA_Callback(hObject, ~, handles)
global hDATA;
% get selected data index
data_idx=get(hObject,'Value');
% display data info (of the first selected)
hDATA.display_datainfo(data_idx(1),handles.TABLE_DATAINFO);
% get button click type
clicktype=get(handles.MAIN_GUI,'SelectionType');
switch clicktype
    case 'normal'
        % single left click
        if ~isempty(hDATA.data(hDATA.current_data).datainfo.operator)
            % found operator update MENU_USEROP
            contents = cellstr(get(handles.MENU_USEROP,'String'));
            opidx=find(cellfun(@(x)~isempty(x),(strfind(contents,hDATA.data(hDATA.current_data).datainfo.operator))));
            set(handles.MENU_USEROP,'Value',opidx);
        end
        update_info(sprintf('data (%s)\n %s \nselected.\n',...
            num2str(data_idx),...
            char(cellfun(@(x)cat(2,x,', '),{hDATA.data(data_idx).dataname},'UniformOutput',false))'),...
            1,handles.EDIT_INFO);
    case 'open'
        % left double click
        % display data
        % only display the first one selected
        % display roi and related info
        update_info(sprintf('%s\n','wait...'),1,handles.EDIT_INFO);
        [ message ]=hDATA.data_select(data_idx);
        update_info(sprintf('%s\n',message),0,handles.EDIT_INFO);
        update_info(sprintf('%s\n','wait...'),0,handles.EDIT_INFO);
        pause(0.001);
        data_idx=data_idx(1);
        [ ~, message ]=hDATA.display_datamap(handles,'data_idx',data_idx,'notify',true);
        update_info(sprintf('%s\n',message),0,handles.EDIT_INFO);
        pause(0.001);
        populate_list(handles.LIST_ROI,{hDATA.data(data_idx).roi.name},hDATA.data(data_idx).current_roi);
        set(handles.MAIN_GUI,'SelectionType','normal');
end

% --- Executes on key press with focus on LIST_DATA and none of its controls.
function LIST_DATA_KeyPressFcn(~, eventdata, handles)
switch eventdata.Key
    case {'uparrow','downarrow','alt','shift','control'}
        % do nothing for normal navigation and meta keys
    case 'delete'
        % delete data/datas
        MENUITEM_DATA_DELETE_Callback(handles.MENUITEM_DATA_DELETE, [], handles)
    case {'f1'}
        % display metainfo
        MENUITEM_DATA_METAINFO_Callback(handles.MENUITEM_DATA_METAINFO, [], handles);
    case {'f2'}
        % import
        MENUITEM_DATA_IMPORT_Callback(handles.MENUITEM_DATA_IMPORT, [], handles);
    case {'f3'}
        % export
        MENUITEM_DATA_EXPORT_Callback(handles.MENUITEM_DATA_EXPORT, [], handles);
    otherwise
        update_info(sprintf('%s key assignment unknown.\n',eventdata.Key),1,handles.EDIT_INFO);
end

% --------------------------------------------------------------------
% display data metainfo in a new window
function MENUITEM_DATA_METAINFO_Callback(~, ~, handles)
global hDATA SETTING;
% get current selected data
data_idx=get(handles.LIST_DATA,'Value');
% only display the first selected and don't sort fields otherwise we won't
% be able to understand structured data fields
[success,message]=hDATA.display_metainfo(data_idx(1),false,[]);
if success
    % if we have meta info returned correctly create temporory table
    temp = figure(...
        'WindowStyle','normal',...% able to use
        'MenuBar','none',...% no menu
        'Resize','off',... % disallow resize
        'Position',[100,100,800,500],...% fixed size
        'Name',cat(2,'Raw DATA meta info: ',hDATA.data(data_idx(1)).dataname));% use data name
    % change metainfo window icon
    javaFrame = get(temp,'JavaFrame');
    javaFrame.setFigureIcon(javax.swing.ImageIcon(cat(2,SETTING.rootpath.icon_path,'main_icon.png')));
    % get new figure position
    pos=get(temp,'Position');
    % create table to display information
    uitable(...
        'Parent',temp,...
        'Data',message,...% output metainfo
        'ColumnName',{'Field','Value'},...
        'Position',[0 0 pos(3:4)],...% maximise table
        'ColumnWidth',{floor(pos(3)/2)-10 floor(2*pos(3)/5)-10},...
        'ColumnEditable',[false false]);% no editing required
else
    % something went wrong, inform error
    update_info(sprintf('%s\n',message),1,handles.EDIT_INFO);
end

% import data files
function MENUITEM_DATA_IMPORT_Callback(~, ~, handles)
global hDATA;
% tell user to wait
update_info(sprintf('%s\n','Importing Data ... '),1,handles.EDIT_INFO);
% import data
[ success, message ] = hDATA.data_import;
if success % data file imported
    % update data list and select the last one added
    populate_list(handles.LIST_DATA,{hDATA.data.dataname},numel(hDATA.data));
    % update data info table and output figure
    LIST_DATA_Callback(handles.LIST_DATA,[],handles);
end
% update info window
update_info(sprintf('%s\n',message),1,handles.EDIT_INFO);

% export selected data
function MENUITEM_DATA_EXPORT_Callback(~, ~, handles)
global hDATA;
% tell user to wait
update_info(sprintf('%s\n','Exporting Data ... '),1,handles.EDIT_INFO);
% get current selected data
data_idx=get(handles.LIST_DATA,'Value');
% export data
[ ~, message ] = hDATA.data_export(data_idx);
% update info window
update_info(sprintf('%s\n',message),1,handles.EDIT_INFO);

% delete selected data
function MENUITEM_DATA_DELETE_Callback(~, ~, handles)
global hDATA;
% get current selected data index
data_idx=get(handles.LIST_DATA,'Value');
% ask for confirmation
answer=questdlg(sprintf('Are you sure you want to delete %g selected data?',numel(data_idx)),...
    'Delete Data','Yes','No','Yes');
switch answer
    case 'Yes'
        %tell user to wait
        update_info(sprintf('Deleting data.  Please Wait...\n'),1,handles.EDIT_INFO);
        [ success, message ]=hDATA.data_delete(data_idx);
        if success
            % update data list and select the one above deletion selection
            populate_list(handles.LIST_DATA,{hDATA.data.dataname},max(1,min(data_idx)-1));
            % update data info table and output figure
            LIST_DATA_Callback(handles.LIST_DATA,[],handles);
        end
        % update info window
        update_info(sprintf('%s\n',message),1,handles.EDIT_INFO);
    case 'No'
        % action cancelled
        update_info(sprintf('%s\n','Data Deletion Action Cancelled'),1,handles.EDIT_INFO);
end

%---------------------------------------------------------------
% --- Executes when entered data in editable cell(s) in TABLE_DATAINFO.
function TABLE_DATAINFO_CellEditCallback(hObject, eventdata, handles)
global hDATA;
% get current datainfo data
content=get(hObject,'Data');
% get selected field
fieldname=content{eventdata.Indices(1,1),1};
% get current selected data indices
item_idx=get(handles.LIST_DATA,'Value');
% loop through and apply changes to all selected data items
for idx=1:numel(item_idx)
    [success,message]=hDATA.edit_datainfo(item_idx(idx),fieldname,eventdata.EditData);
    if ~success
        fprintf('%s\n',message);
    end
end
% update data info display
hDATA.display_datainfo(hDATA.current_data,hObject);
% check for dataname change
if eventdata.Indices(1,1)==1
    % update LIST_DATA list if we have changed dataname
    populate_list(handles.LIST_DATA,{hDATA.data.dataname},hDATA.current_data);
end

%---------------------------------------------------------------

% --- Executes on selection change in MENU_USEROP.
function MENU_USEROP_Callback(hObject, ~, handles)
global hDATA;
% get user operation names
contents = cellstr(get(hObject,'String'));
% get current selected user operation index
idx=get(hObject,'Value');
% get current selected user operation name
operator=contents{idx};
% set UserData field for quick access
set(hObject,'UserData',operator);
% display help text in the EDIT_INFO field for selected user operation
hDATA.display_data_operator(handles.EDIT_INFO,idx);

% --- Executes on button press in BUTTON_CALCULATE.
function BUTTON_CALCULATE_Callback(~, ~, handles)
% apply selected user operation to selected data
global hDATA;
% get userop
contents = cellstr(get(handles.MENU_USEROP,'String'));
% get function name
func=contents{get(handles.MENU_USEROP,'Value')};
% to find out if this is operator or processor
temp=regexp(func,'_','split');
optype=temp{1};
% get selected data
item_idx=get(handles.LIST_DATA,'Value');
% inform user we are starting
update_info(sprintf('Calculating %s using %s\n',...
    char(cellfun(@(x)cat(2,x,', '),{hDATA.data(item_idx).dataname},'UniformOutput',false))'),0,handles.EDIT_INFO);
success=false;message='';% initialise to false and null message
switch optype
    case 'data'
        % data processor
        evalc(cat(2,'[ success, message ] = ',func,'(hDATA,item_idx);'));
    case 'op'
        % data operator take extra options
        
        if strmatch(func,hDATA.data(hDATA.current_data).datainfo.operator,'exact')
            % generated by this op
            evalc(cat(2,'[ success, message ] = ',func,'(hDATA,''calculate_data'',''data_index'',item_idx);'));
        else
            % need to add new data structure for this op
            evalc(cat(2,'[ success, message ] = ',func,'(hDATA,''add_data'',''data_index'',item_idx);'));
        end
end
if success
    % repopulate list in case new data added
    populate_list(handles.LIST_DATA,{hDATA.data.dataname},hDATA.current_data); %#ok<UNRCH>
    populate_list(handles.LIST_ROI,{hDATA.data(hDATA.current_data).roi.name},hDATA.data(hDATA.current_data).current_roi);
    update_info(sprintf('Output of %s: %s\n',func,message),1,handles.EDIT_INFO);
else
    update_info(sprintf('Error Messages: %s\n from %s\n',message,func),0,handles.EDIT_INFO);
end
beep;pause(0.001);

%---------------------------------------------------------------
% ROI FUNCTIONS
% --- Executes on key press with focus on LIST_ROI and none of its controls.
function LIST_ROI_KeyPressFcn(~, eventdata, handles)
persistent combkey;%for combination keys
switch eventdata.Key
    case {'uparrow','downarrow'}
        % don't display anything for utility keys
    case {'control','shift'}
        % don't display anything for utility keys
        combkey=eventdata.Key;
    case {'d','D'}
        %display
        if strmatch(combkey,'control','exact');
            MENUITEM_ROI_DISPLAY_Callback([],[],handles);
        end
        combkey='';
    case {'h','H'}
        %histogram
        if strmatch(combkey,'control','exact');
            MENUITEM_ROI_HISTOGRAM_Callback([],[],handles);
        end
        combkey='';
    case {'c','C'}
        %copy
        if strmatch(combkey,'control','exact');
            MENUITEM_ROI_COPY_Callback([],[],handles);
        end
        combkey='';
    case {'v','V'}
        %paste
        if strmatch(combkey,'control','exact');
            MENUITEM_ROI_PASTE_Callback([],[],handles);
        end
        combkey='';
    case {'s','S'}
        %save
        if strmatch(combkey,'control','exact');
            MENUITEM_ROI_SAVE_Callback([],[],handles);
        end
        combkey='';
    case {'f5'}
        % display roi
        MENUITEM_ROI_DISPLAY_Callback([],[],handles);
    case {'f6'}
        % roi histogram
        MENUITEM_ROI_HISTOGRAM_Callback([],[],handles);
    case {'f9'}
        %rename
        MENUITEM_ROI_RENAME_Callback([],[],handles);
    case {'f10'}
        %copy
        MENUITEM_ROI_COPY_Callback([],[],handles);
    case {'f11'}
        %paste
        MENUITEM_ROI_PASTE_Callback([],[],handles);
    case {'f12'}
        %save
        MENUITEM_ROI_SAVE_Callback([],[],handles);
    case {'delete'}
        %delete
        MENUITEM_ROI_DELETE_Callback([],[],handles);
    otherwise
        update_info(sprintf('%s key assignment unknown.\n',eventdata.Key),1,handles.EDIT_INFO);
end

% --- Executes on selection change in LIST_ROI.
function LIST_ROI_Callback(hObject, ~, handles)
global hDATA;
selected_roi=get(hObject,'Value');
clicktype=get(handles.MAIN_GUI,'SelectionType');
switch clicktype
    case 'normal'
        % single left click
        % just select and display roi
        [ ~, message ]=hDATA.roi_select(selected_roi);
    case 'open'
        % left double click
        % calculate and display result
        [ ~, message ]=hDATA.roi_display('display',handles);
end
update_info(sprintf('%s\n',message),1,handles.EDIT_INFO);

% add point roi to data
function BUTTON_ROIPT_Callback(~, ~, handles)
global hDATA;
[ success, message ]=hDATA.roi_add('impoint',[]);
if success
    % update roi list
    populate_list(handles.LIST_ROI,{hDATA.data(hDATA.current_data).roi.name},hDATA.data(hDATA.current_data).current_roi);
end
%print command output from the user function steps
update_info(sprintf('%s\n',message),0,handles.EDIT_INFO);

% add rectangular roi to data
function BUTTON_ROIRECT_Callback(~, ~, handles)
global hDATA;
[ success, message ]=hDATA.roi_add('imrect',[]);
if success
    % update roi list
    populate_list(handles.LIST_ROI,{hDATA.data(hDATA.current_data).roi.name},hDATA.data(hDATA.current_data).current_roi);
end
%print command output from the user function steps
update_info(sprintf('%s\n',message),0,handles.EDIT_INFO);

% add polygon roi to data
function BUTTON_ROIPOLY_Callback(~, ~, handles)
global hDATA;
[ success, message ]=hDATA.roi_add('impoly',[]);
if success
    % update roi list
    populate_list(handles.LIST_ROI,{hDATA.data(hDATA.current_data).roi.name},hDATA.data(hDATA.current_data).current_roi);
end
%print command output from the user function steps
update_info(sprintf('%s\n',message),0,handles.EDIT_INFO);

% --------------------------------------------------------------------
% display traces from roi
function MENUITEM_ROI_DISPLAY_Callback(~, ~, handles)
global hDATA;
[ ~, message ]=hDATA.roi_display('display',handles);
%print command output from the user function steps
update_info(sprintf('%s\n',message),0,handles.EDIT_INFO);

% display histogram from roi
function MENUITEM_ROI_HISTOGRAM_Callback(~, ~, handles)
global hDATA;
[ ~, message ]=hDATA.roi_display('histogram',handles);
%print command output from the user function steps
update_info(sprintf('%s\n',message),0,handles.EDIT_INFO);

% --------------------------------------------------------------------
% rename roi
function MENUITEM_ROI_RENAME_Callback(~, ~, handles)
global hDATA;
current_data=hDATA.current_data;
current_roi=hDATA.data(current_data).current_roi;
% we cannot rename the roi ALL
current_roi=current_roi(current_roi>1);
% ask for name template
roi_name={hDATA.data(current_data).roi(current_roi).name};
options.WindowStyle='modal';
set(0,'DefaultUicontrolBackgroundColor','w');
set(0,'DefaultUicontrolForegroundColor','k');
if ~isempty(roi_name)
    answer = inputdlg(roi_name,'Rename ROIs',1,roi_name,options);
    set(0,'DefaultUicontrolBackgroundColor','k');
    set(0,'DefaultUicontrolForegroundColor','w');
    if ~isempty(answer)
        % rename all selected
        for idx=1:numel(current_roi)
            hDATA.data(current_data).roi(current_roi(idx)).name=answer{idx};
        end
        % update roi list
        populate_list(handles.LIST_ROI,{hDATA.data(current_data).roi.name},hDATA.data(current_data).current_roi);
        update_info(sprintf('%g roi renamed\n',numel(current_roi)),0,handles.EDIT_INFO);
    else
        % rename cancelled
        update_info(sprintf('renaming cancelled\n'),0,handles.EDIT_INFO);
    end
else
    update_info(sprintf('nothing to renaming\n'),0,handles.EDIT_INFO);
end

% copy roi
function MENUITEM_ROI_COPY_Callback(~, ~, handles)
global hDATA;
[ ~, message ]=hDATA.roi_add('copy');
update_info(sprintf('%s\n',message),0,handles.EDIT_INFO);

% paste roi
function MENUITEM_ROI_PASTE_Callback(~, ~, handles)
global hDATA;
[ success, message ]=hDATA.roi_add('paste');
if success
    populate_list(handles.LIST_ROI,{hDATA.data(hDATA.current_data).roi.name},hDATA.data(hDATA.current_data).current_roi);
end
update_info(sprintf('%s\n',message),0,handles.EDIT_INFO);

% save roi
function MENUITEM_ROI_SAVE_Callback(~, ~, handles)
global hDATA;

[ success, message ]= hDATA.roi_save;
if success
    populate_list(handles.LIST_DATA,{hDATA.data.dataname},hDATA.current_data);
    populate_list(handles.LIST_ROI,{hDATA.data(hDATA.current_data).roi.name},hDATA.data(hDATA.current_data).current_roi);
end
update_info(sprintf('%s\n',message),0,handles.EDIT_INFO);

% delete roi
function MENUITEM_ROI_DELETE_Callback(~, ~, handles)
global hDATA;
to_remove=get(handles.LIST_ROI,'Value');
hDATA.data(hDATA.current_data).current_roi=to_remove;
[ success, message ]=hDATA.roi_delete;
if success
    populate_list(handles.LIST_ROI,{hDATA.data(hDATA.current_data).roi.name},hDATA.data(hDATA.current_data).current_roi);
end
update_info(sprintf('%s\n',message),0,handles.EDIT_INFO);

%--------------------------------------------------------------
% --- Executes on selection change in MENU_DATA_Z
function MENU_DATA_Z_Callback(hObject, ~, handles)
global SETTING;
% get Z slice index
slice_idx=get(hObject,'Value');
% get T page index
page_idx=get(handles.MENU_DATA_T,'Value');
% loop through dt,MAP,gT plots
for p_idx=[1,2,3]
    % check if is a sequence data
    if SETTING.panel(p_idx).Z_seq
        % try find line plot
        curplot=findobj(SETTING.panel(p_idx).handle,'Tag','line');
        if isempty(curplot)
            % no line plot try find surf plot
            curplot=findobj(SETTING.panel(p_idx).handle,'Tag','surf');
            if isempty(curplot)
                % nothing plotted
            else
                % found surf plot
                % get userdata
                slice_data=get(SETTING.panel(p_idx).handle,'UserData');
                % nnZT
                if page_idx>size(slice_data,4)
                    % possible XT plot where T is permuted
                    page_idx=1;
                end
                set(curplot,'ZData',squeeze(slice_data(:,:,slice_idx,page_idx)));
            end
        else
            % found line plot
            % get userdata
            slice_data=get(SETTING.panel(p_idx).handle,'UserData');
            ydata=slice_data(:,slice_idx,:);
            if numel(ydata)==numel(get(curplot,'XData'))
                set(curplot,'YData',squeeze(ydata(:,:,:)));
            else
                set(curplot,'YData',squeeze(ydata(:,:,page_idx)));
            end
        end
    end
end

% --- Executes on selection change in MENU_DATA_T.
function MENU_DATA_T_Callback(hObject, ~, handles)
global SETTING;
% get T page index
page_idx=get(hObject,'Value');
% get Z slice index
slice_idx=get(handles.MENU_DATA_Z,'Value');
% loop through dt and MAP plots
for p_idx=[1,2]
    % check if is a squence data
    if SETTING.panel(p_idx).T_seq
        % try find line plot
        curplot=findobj(SETTING.panel(p_idx).handle,'Tag','line');
        if isempty(curplot)
            % no line plot try find surf plot
            curplot=findobj(SETTING.panel(p_idx).handle,'Tag','surf');
            if isempty(curplot)
                % nothing plotted
            else
                % surf plot
                % get user data
                slice_data=get(SETTING.panel(p_idx).handle,'UserData');
                if ndims(slice_data)>2
                    set(curplot,'ZData',squeeze(slice_data(:,:,slice_idx,page_idx)));
                end
            end
        else
            % line plot
            % get userdata
            slice_data=get(SETTING.panel(p_idx).handle,'UserData');
            if ndims(slice_data)>2
                set(curplot,'YData',squeeze(slice_data(:,slice_idx,page_idx)));
            end
        end
    end
end


% --- Executes on button press in BUTTON_LINK.
function BUTTON_LINK_Callback(hObject, ~, ~)
global SETTING;
if get(hObject,'Value')
    %link
    iconimg=imread(cat(2,SETTING.rootpath.icon_path,'link.png'));
    set(hObject,'CData',iconimg);
else
    %unlink
    iconimg=imread(cat(2,SETTING.rootpath.icon_path,'link_break.png'));
    set(hObject,'CData',iconimg);
end

% --- Executes on selection change in MENU_PARAMETER.
function MENU_PARAMETER_Callback(hObject, eventdata, handles)
global SETTING;
% get T page index
page_idx=get(handles.MENU_RESULT_T,'Value');
% get Z slice index
slice_idx=get(handles.MENU_RESULT_Z,'Value');
% get P index
param_idx=get(hObject,'Value');
% loop through dt and MAP plots
for p_idx=[4,5,6]
    % check if is a squence data
    if SETTING.panel(p_idx).T_seq
        % try find line plot
        curplot=findobj(SETTING.panel(p_idx).handle,'Tag','line');
        if isempty(curplot)
            % no line plot try find surf plot
            curplot=findobj(SETTING.panel(p_idx).handle,'Tag','surf');
            if isempty(curplot)
                % nothing plotted
            else
                % surf plot
                % get user data
                slice_data=get(SETTING.panel(p_idx).handle,'UserData');
                if ndims(slice_data)>2
                    set(curplot,'ZData',squeeze(slice_data(param_idx,:,:,slice_idx,page_idx)));
                end
            end
        else
            % line plot
            % get userdata
            slice_data=get(SETTING.panel(p_idx).handle,'UserData');
            if ndims(slice_data)>2
                set(curplot,'YData',squeeze(slice_data(param_idx,:,:,slice_idx,:)));
            end
        end
    end
end

% --- Executes on selection change in MENU_RESULT_Z.
function MENU_RESULT_Z_Callback(hObject, eventdata, handles)
global SETTING;
% get T page index
page_idx=get(handles.MENU_RESULT_T,'Value');
% get Z slice index
slice_idx=get(hObject,'Value');
% get P index
param_idx=get(handles.MENU_PARAMETER,'Value');
% loop through dt and MAP plots
for p_idx=[4,5]
    % check if is a squence data
    if SETTING.panel(p_idx).Z_seq
        % try find line plot
        curplot=findobj(SETTING.panel(p_idx).handle,'Tag','line');
        if isempty(curplot)
            % no line plot try find surf plot
            curplot=findobj(SETTING.panel(p_idx).handle,'Tag','surf');
            if isempty(curplot)
                curplot=findobj(SETTING.panel(p_idx).handle,'Tag','mod_surf');
                if isempty(curplot)
                    % nothing plotted
                else
                    %mod surf
                    % get user data
                    slice_data=get(SETTING.panel(p_idx).handle,'UserData');
                    if ndims(slice_data{1})>2
                        set(curplot,'ZData',squeeze(slice_data{1}(1,:,:,slice_idx,page_idx)));
                        set(curplot,'CData',squeeze(slice_data{2}(1,:,:,slice_idx,:)));
                    end
                end
            else
                % surf plot
                % get user data
                slice_data=get(SETTING.panel(p_idx).handle,'UserData');
                if ndims(slice_data)>2
                    set(curplot,'ZData',squeeze(slice_data(param_idx,:,:,slice_idx,page_idx)));
                    
                end
            end
        else
            % line plot
            % get userdata
            slice_data=get(SETTING.panel(p_idx).handle,'UserData');
            if ndims(slice_data)>2
                set(curplot,'YData',squeeze(slice_data(:,slice_idx,page_idx)));
            end
        end
    end
end
if get(handles.BUTTON_LINK,'Value')
    set(handles.MENU_DATA_Z,'Value',slice_idx);
    MENU_DATA_Z_Callback(handles.MENU_DATA_Z, [], handles);
end

% --- Executes on selection change in MENU_RESULT_T.
function MENU_RESULT_T_Callback(hObject, eventdata, handles)
global SETTING;
% get T page index
page_idx=get(hObject,'Value');
% get Z slice index
slice_idx=get(handles.MENU_RESULT_Z,'Value');
% get P index
param_idx=get(handles.MENU_PARAMETER,'Value');
% loop through dt and MAP plots
for p_idx=[4,5]
    % check if is a squence data
    if SETTING.panel(p_idx).T_seq
        % try find line plot
        curplot=findobj(SETTING.panel(p_idx).handle,'Tag','line');
        if isempty(curplot)
            % no line plot try find phasor plot
            curplot=findobj(SETTING.panel(p_idx).handle,'Tag','phasor_scatter');
            if isempty(curplot)
                % no line plot try find surf plot
                curplot=findobj(SETTING.panel(p_idx).handle,'Tag','surf');
                if isempty(curplot)
                    % nothing plotted
                else
                    % surf plot
                    % get user data
                    slice_data=get(SETTING.panel(p_idx).handle,'UserData');
                    if ndims(slice_data)>2
                        set(curplot,'ZData',squeeze(slice_data(param_idx,:,:,slice_idx,page_idx)));
                    end
                end
            else
                % phasor scatter plot
                slice_data=get(SETTING.panel(p_idx).handle,'UserData');
                if ndims(slice_data)>2
                    data=squeeze(slice_data(:,slice_idx,page_idx));
                    set(curplot,'XData',data(1,:));
                    set(curplot,'YData',data(2,:));
                end
            end
        else
            % line plot
            % get userdata
            slice_data=get(SETTING.panel(p_idx).handle,'UserData');
            if ndims(slice_data)>2
                set(curplot,'YData',squeeze(slice_data(:,slice_idx,page_idx)));
            end
        end
    end
end
if get(handles.BUTTON_LINK,'Value')
    set(handles.MENU_DATA_T,'Value',page_idx);
    MENU_DATA_T_Callback(handles.MENU_DATA_T, [], handles);
end

% =====================================================================
% =====================================================================
% initialise system
function initialise(isnew,handles)
global hDATA SETTING;
if isnew
    % clear and declare new data handle
    clear global hDATA SETTING;    % clear global data handle
    global hDATA SETTING; %#ok<REDEF,TLEV>
    hDATA=fimdata_handle; %#ok<NASGU>
    SETTING=gui_option; %#ok<NASGU>
    set(handles.MAIN_GUI,'Name','FIMAS');
    temp=load(cat(2,'.',filesep,'lib',filesep,'default_path.mat'),'-mat');% load default paths
    if isunix
        temp.rootpath=structfun(@(x)regexprep(x,'\',filesep),temp.rootpath,'UniformOutput',false);
    end
    SETTING.rootpath=temp.rootpath;%#ok<STRNU> % update SETTING rootpath
    % update hDATA path
    hDATA.path.import=temp.rootpath.raw_data; %#ok<STRNU>
    hDATA.path.export=temp.rootpath.exported_data; %#ok<STRNU>
    hDATA.path.saved=temp.rootpath.saved_data; %#ok<STRNU>
    
    % make button icons
    iconimg=imread(cat(2,SETTING.rootpath.icon_path,'control_panel_icon.png'));%#ok<NODEF>
    set(handles.PUSHTOOL_GRAPHCONTROLPANEL,'CData',iconimg);
    iconimg=imread(cat(2,SETTING.rootpath.icon_path,'calculator_icon.png'));%#ok<NODEF>
    set(handles.BUTTON_CALCULATE,'CData',iconimg);
    iconimg=imread(cat(2,SETTING.rootpath.icon_path,'roi_point_icon.png'));%#ok<NODEF>
    set(handles.BUTTON_ROIPT,'CData',iconimg);
    iconimg=imread(cat(2,SETTING.rootpath.icon_path,'roi_rect_icon.png'));%#ok<NODEF>
    set(handles.BUTTON_ROIRECT,'CData',iconimg);
    iconimg=imread(cat(2,SETTING.rootpath.icon_path,'roi_poly_icon.png'));%#ok<NODEF>
    set(handles.BUTTON_ROIPOLY,'CData',iconimg);
    iconimg=imread(cat(2,SETTING.rootpath.icon_path,'link_break.png'));%#ok<NODEF>
    set(handles.BUTTON_LINK,'CData',iconimg);
    % change main window icon
    javaFrame = get(handles.MAIN_GUI,'JavaFrame');
    javaFrame.setFigureIcon(javax.swing.ImageIcon(cat(2,SETTING.rootpath.icon_path,'main_icon.png')));%#ok<NODEF>
    % get display panel information and initialise
    SETTING.find_panels(handles,[]);%#ok<NODEF>
    SETTING.change_panel(1);%#ok<NODEF>%set to initial first panel
    % update data operator menu
    hDATA.display_data_operator(handles.MENU_USEROP,[]); %#ok<NODEF>
    set(handles.MENU_USEROP,'Value',1);
    content=get(handles.MENU_USEROP,'String');
    set(handles.MENU_USEROP,'UserData',content{1});
else
    % reset graphics e.g. open new data file
    
end
%{
% clear axes
for panelidx=1:numel(SETTING.PANEL_NAME_LIST)
    SETTING.current_panel=panelidx;
    SETTING.update_panel_control('clear');
end
%}
% update data list and roi list
populate_list(handles.LIST_DATA,{hDATA.data.dataname},1); %#ok<NODEF>
populate_list(handles.LIST_ROI,{hDATA.data(1).roi.name},1); %#ok<NODEF>

% update info window
update_info(sprintf('%s\n','New Session Initialised'),1,handles.EDIT_INFO);