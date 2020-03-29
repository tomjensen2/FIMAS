function [ status, message ] = data_TJ_getcropping( obj )
% DATA_TJ_getcropping Opens a helper app to identify X cropping intervals
% for multi-line/multispiral scans so that Flyback and parking co-ordinates
% no new dataitems are generated
%%--------------------------------------------------------------------------
%   1. Click refresh then select datafile to inpect ScX/ScY data
%   2. Plot scan locations by altering fields Linenum (Y axis), XMin and
%   Xmax (set start and end of X period)
%   3. Once Xmin and Xmax are identified check this is consistant across
%   dataitems to be analysed
%   4. Click copy calibrated to copy calibrated Xmin and Xmax to be pasted
%   into data_crop parameters, for uncalibrated data (dX=1) click Copy
%   Pixel locs
%--------------------------------------------------------------------------
%   HEADER END

getcropping_ScXY
% evalin('base','getcropping_ScXY')
status=true
message='ran'
%% function complete
% assume worst
