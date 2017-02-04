function [ status, message ] = data_export( obj, index )
%DATA_EXPORT export selected data from a session
%  only export selected data for future import

%% function complete

status=false;
try
    [filename,pathname,~]=uiputfile({'*.edf','exported data file (*.edf)';...
        '*.*','All Files (*.*)'},...
        'Select Exported Data Analysis File',obj.path.export);
    if pathname~=0     %if files selected
        filename=cat(2,pathname,filename);
        dataitem=obj.data(index); %#ok<NASGU>
        % clear handles
        dataitem.datainfo.panel=[];
        dataitem.roi(2:end).panel=[];
        dataitem.roi(2:end).handle=[];
        %to cope with large file size
        save(filename,'dataitem','-mat','-v7.3');
        %update saved path
        obj.path.export=pathname;
        message=sprintf('data item %g exported\n',index);
        status=true;
    else
        %action cancelled
        message=sprintf('%s\n','file export action cancelled');
    end
catch exception%error handle
    message=sprintf('%s\n',exception.message);
end