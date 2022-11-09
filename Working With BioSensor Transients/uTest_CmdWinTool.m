function uTest_CmdWinTool(doSpeed)
% Automatic test: CmdWinTool M and Mex
% This is a routine for automatic testing. It is not needed for processing and
% can be deleted or moved to a folder, where it does not bother.
%
% The methods of CmdWinTool depend on undocumented feature of Matlab. If a
% specific action fails on your platform, modify CmdWinTool. I appreciate
% reports or problems by email.
%
% uTest_CmdWinTool(doSpeed)
% INPUT:
%   doSpeed: If this is 0 or FALSE, a fast test is performed. For other values
%            or if omitted each actipon is shown for 0.5 seconds.
% OUTPUT:
%   On failure the test stops with an error.
%
% Tested: Matlab 7.7, 7.8, 7.13, 8.6, WinXP/32, Win7/64
% Author: Jan Simon, Heidelberg, (C) 2009-2015 matlab.2010(a)n(MINUS)simon.de

% $JRev: R-h V:007 Sum:fL2P2qIVRJ20 Date:20-Dec-2015 23:17:13 $
% $License: BSD (use/copy/change/redistribute on own risk, mention the author) $
% $File: Tools\UnitTests_\uTest_CmdWinTool.m $
% History:
% 001: 08-Jun-2011 10:56, First version.
% 004: 11-Oct-2011 13:51, Font and text color. New set/get method.

% Initialize: ==================================================================
LF = char(10);

if nargin == 0
   doSpeed = true;
end
if doSpeed
   Delay = 0.6;
else
   Delay = 0.05;
end

% Do the work: =================================================================
% Hello:
disp(['==== Test CmdWinTool:  ', datestr(now, 0), LF, ...
      '  Version: ', which('CmdWinTool'), LF]);
if usejava('desktop') == 0
   fprintf(2, '### %s: Not working without java\n', mfilename);
   return;
end

matlabV = [100, 1] * sscanf(version, '%d.', 2);
if matlabV < 605
   warning(['JSimon:', mfilename, ':BadMatlabV'], ...
      'CmdWinTool needs Matlab 6.5 or higher');
   return;
end

% Check the command to get the main frame's Java handle:
try
   CmdWinTool('$test');
catch ME
   if matlabV < 700  % This should work!
      error(['JSimon:', mfilename, ':Unexpected'], ...
         '*** %s: Unexpected version problem:%c  %s', ...
         mfilename, 10, ME.message);
   else
      error(['JSimon:', mfilename, ':NotMatching'], ...
         ['*** %s: CmdWinTool is not compatible with this Matlab version', ...
            '%c%s%cPlease edit the line marked with [USER_ADJUST]'], ...
         mfilename, 10, ME.message, 10);
   end
end

% Commands working under all tested platforms: ---------------------------------
try
   CmdWinTool('StatusText', ['Running ', mfilename]);
   fprintf('  ok: setStatusText\n');
catch ME
   error(['JSimon:', mfilename, ':Crash'], ...
      '*** %s: [setStatusText] crashed: %s', mfilename, ME.message);
end

try
   Status = CmdWinTool('StatusText');
   if strcmp(Status, ['Running ', mfilename])
      fprintf('  ok: setStatusText with output\n');
   else
      fprintf('  strange: setStatusText with output: [%s]\n', Status);
   end
catch ME
   error(['JSimon:', mfilename, ':Crash'], ...
      '*** %s: [setStatusText] with output crashed: %s', mfilename, ME.message);
end

try
   origTitle = CmdWinTool('Title');
   fprintf('  ok: get Title, ');
   pause(Delay);
   CmdWinTool('Title', 'Hello');
   fprintf('set Title\n');
   pause(Delay);
   CmdWinTool('Title', origTitle);
   pause(Delay);
catch ME
   fprintf('\n');
   error(['JSimon:', mfilename, ':Crash'], ...
      '*** %s: [Title] crashed: %s', mfilename, ME.message);
end

try
   CmdWinTool('toBack');
   fprintf('  ok: toBack, ');
   pause(Delay);
   CmdWinTool('toFront');
   fprintf('toFront\n');
   pause(Delay);
catch ME
   fprintf('\n');
   error(['JSimon:', mfilename, ':Crash'], ...
      '*** %s: [toBack], [toFront] crashed: %s', mfilename, ME.message);
end

try
   CmdWinTool('hide');
   fprintf('  ok: hide, ');
   pause(Delay);
   CmdWinTool('show');
   fprintf('show\n');
   pause(Delay);
catch ME
   fprintf('\n');
   error(['JSimon:', mfilename, ':Crash'], ...
      '*** %s: [hide], [show] crashed: %s', mfilename, ME.message);
end

try
   CmdWinTool('maximize');
   fprintf('  ok: maximize, ');
   pause(Delay);
   CmdWinTool('restore');
   fprintf('restore, ');
   pause(Delay);
   CmdWinTool('minimize');
   fprintf('minimize\n');
   pause(Delay);
   CmdWinTool('restore');
   pause(Delay);
catch ME
   fprintf('\n');
   error(['JSimon:', mfilename, ':Crash'], ...
      '*** %s: [maximize], [minimize], [restore] crashed: %s', ...
      mfilename, ME.message);
end

try
   JPos = CmdWinTool('JPosition');
   fprintf('  ok: get JPosition, ');
   CmdWinTool('xmax');
   fprintf('xmax, ');
   pause(Delay);
   CmdWinTool('JPosition', JPos);
   fprintf('set JPosition, ');
   pause(Delay);
   CmdWinTool('ymax');
   fprintf('ymax\n');
   pause(Delay);
catch ME
   fprintf('\n');
   msg = ME.message;
   try
      CmdWinTool('JPosition', JPos);  % Restore former position
   catch
   end
   error(['JSimon:', mfilename, ':Crash'], ...
      '*** %s: [JPosition], [maxx], [maxy] crashed:\n%s', ...
      mfilename, msg);
end

try
   CmdWinTool('lean');
   fprintf('  ok: lean, ');
   pause(Delay);
   CmdWinTool('fat');
   fprintf('fat\n');
   pause(Delay);
catch ME
   fprintf('\n');
   error(['JSimon:', mfilename, ':Crash'], ...
      '*** %s: [lean], [fat] crashed: %s', ...
      mfilename, ME.message);
end

try
   HWnd = CmdWinTool('getHWnd');  %#ok<NASGU>
   fprintf('  ok: getHWnd\n');
catch ME
   fprintf('\n');
   error(['JSimon:', mfilename, ':Crash'], ...
      '*** %s: [getHWnd] crashed: %s', ...
      mfilename, ME.message);
end

% Command demanding for WindowAPI:
if not(ispc) || isempty(which('WindowAPI'))
   disp('== No Position, setFocus, toScreen without WindowAPI');
else
   try
      pos = CmdWinTool('Position');  %#ok<NASGU>
      fprintf('  ok: get Position, ');
      pause(Delay);
      CmdWinTool('Position', [20, 20, 200, 300]);
      fprintf('set Position, ');
      pause(Delay);
      CmdWinTool('JPosition', JPos);  % Restore former position
      fprintf('reset\n');
   catch ME
      fprintf('\n');
      msg = ME.message;
      try
         CmdWinTool('JPosition', JPos);  % Restore former position
      catch
      end
      error(['JSimon:', mfilename, ':Crash'], ...
         '*** %s: [Position] crashed:\n%s', ...
         mfilename, msg);
   end
   
   try
      CmdWinTool('Position', [-100, -100, 200, 300]);
      pause(Delay);
      CmdWinTool('toScreen');  % This will confuse in debug mode  ;-)
      fprintf('  ok: toScreen\n');
      pause(Delay);
      CmdWinTool('JPosition', JPos);  % Restore former position
   catch ME
      fprintf('\n');
      error(['JSimon:', mfilename, ':Crash'], ...
         '*** %s: [toScreen] crashed: %s', mfilename, ME.message);
   end
   
   try
      CmdWinTool('setFocus');  % This will confuse in debug mode  ;-)
      fprintf('  ok: setFocus\n');
   catch ME
      fprintf('\n');
      error(['JSimon:', mfilename, ':Crash'], ...
         '*** %s: [setFocus] crashed: %s', mfilename, ME.message);
   end
end

% ------------------------------------------------------------------------------
if matlabV > 700
   disp('== Commands for Matlab > 7.0:');
   
   try
      CmdWinTool('top', 1);
      fprintf('  ok: top(1), ');
      pause(Delay);
      CmdWinTool('top', 0);
      fprintf('top(0)\n');
      pause(Delay);
   catch ME
      fprintf('\n');
      error(['JSimon:', mfilename, ':Crash'], ...
         '*** %s: [top] crashed: %s', mfilename, ME.message);
   end
   
   try
      Str = CmdWinTool('getText');
      fprintf('  ok: getText: Last 50 characters:\n---->\n%s\n<----\n', ...
         Str(end - 50:end - 1));
   catch ME
      error(['JSimon:', mfilename, ':Crash'], ...
         '*** %s: [getText] crashed: %s', mfilename, ME.message);
   end
   
   % Get and set font:
   try
      origFont = CmdWinTool('Font');
      fprintf('  ok: get font, ');
      Font.Name = 'serif';
      Font.Size = 24;
      CmdWinTool('Font', Font);
      pause(Delay);  % Just for optics
      fprintf('set font, ');
      CmdWinTool('Font', origFont);
      fprintf('reset font\n');
   catch ME
      fprintf('\n');
      error(['JSimon:', mfilename, ':Crash'], ...
         '*** %s: Get or set font crashed: %s', ...
         mfilename, ME.message);
   end
   
   % Get and set font:
   ColorCmd = {'Foreground', 'Background'};
   for iC = 1:2
      Cmd = ColorCmd{iC};
      try
         origColor = CmdWinTool(Cmd);
         fprintf('  ok: %s: get color, ', Cmd);
         CmdWinTool(Cmd, [1, 0, 1]);
         pause(Delay);  % Just for optics
         fprintf('set color, ');
         CmdWinTool(Cmd, origColor);
         fprintf('reset color\n');
      catch ME
         fprintf('\n');
         error(['JSimon:', mfilename, ':Crash'], ...
            '*** %s: Get or set text colors crashed: %s', ...
            mfilename, ME.message);
      end
   end
end

% Goodbye:
fprintf('\nCmdWinTool passed the tests.\n');

return;
