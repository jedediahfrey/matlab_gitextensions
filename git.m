function git(varargin)
%git Control GitExtensions from within MATLAB.
% This is meant to serve as a half way point between the full git bash
% and TorgoiseGit. It is intended for users that prefer to be able to
% manipulate git from the MATLAB prompt but also like the added usefullness
% of the GitExtensions GUI.
%
% Note:
%   Before commits the script will save all open *.m files and *.mdl files.
%   Before checkouts the script will close all open *.m files and *.mdl
%   files. (The script can be edited to disable these features).
%
% If you want a full command line version there are other
% wrappers for just the git command.
%
% Examples:
%   git checkout [GitExtensions Dialog]
%   edit newfile.m [M-File Editor] Add text.
%   git add [GitExtensions Dialog]
%   git commit [GitExtensions Dialog]
%
% See also: http://code.google.com/p/gitextensions/,
% http://git-scm.com/documentation

% Edit these variables to suit your workflow.
% Valid Options: true, false or 'ask'.
SAVE_ON_COMMIT=true;    % Before a 'git commit' all open *.m and *.mdl files are saved so that they are in the commit
% 'true', 'false', or 'ask'.
CLOSE_ON_CHECKOUT='ask'; % Anytime 'git checkout' is run it closes all *.m and *.mdl files so that they aren't open when they get switched by the checkout.

% GitExtensions is Windows only.
if ~ispc
    error('GitExtensions is only available for Windows machines');
end

% If the user doesn't have git setup
if ~ispref('git','gitExtensions_path') || ... % If the preference is not set.,
        ~exist(getpref('git','gitExtensions_path'),'file') % Or the old path no longer exists
    path1='C:\Program Files\GitExtensions\GitExtensions.exe';
    path2='C:\Program Files (x86)\GitExtensions\GitExtensions.exe';
    if exist(path1,'file')
        setpref('git','gitExtensions_path',path1);
        disp('GitExtensions.exe found and preferences saved');
    elseif exist(path2,'file')
        setpref('git','gitExtensions_path',path2);
        disp('GitExtensions.exe found and preferences saved');
    else
        [filename, pathname] = uigetfile('GitExtensions.exe', 'GitExtensions.exe not automatically found. Select it:');
        if filename==0
            warning('git:canceled','User canceled executable selection');
            return;
        end
        setpref('git','gitExtensions_path',fullfile(pathname,filename));
    end
end
if ~ispref('git','sh_path') || ... % If the preference is not set.
        ~exist(getpref('git','sh_path'),'file') % Or the old path no longer exists
    path1='C:\Program Files (x86)\Git\bin\sh.exe';
    path2='C:\Program Files\Git\bin\sh.exe';
    if exist(path1,'file')
        setpref('git','sh_path',path1);
        disp('sh.exe found and preferences saved');
    elseif exist(path2,'file')
        setpref('git','sh_path',path2);
        disp('sh.exe found and preferences saved');
    else
        [filename, pathname] = uigetfile('sh.exe', 'sh.exe not automatically found. Select it:');
        if filename==0
            warning('git:canceled','User canceled executable selection');
            return;
        end
        setpref('git','sh_path',fullfile(pathname,filename));
    end
end
% If nothing is given, show help and warn that a command is needed.
if nargin<1
    help(mfilename);
    warning('git:command','You must give at least one command\nSee: http://git-scm.com/documentation');
    return;
else
    % Else grab the first input as a command.
    command=varargin{1};
end
% List of known working commands and any modifications that must be made to
% to the arguments before calling GitExtensions.exe
argument='';
switch command
    % Arguments that take the [file] or [path] optonally.
    case {'browse','blame','clone','filehistory','fileeditor','openrepo','revert'}
        if nargin==2
            argument=abspath(varargin{2});
        end
    case 'init'
        if nargin<2
            argument=pwd;
        else
            argument=abspath(varargin{2});
        end
    case 'bash'
        %% Bash
        % Not actually GitExtensions, but the GitBash from the Git package. Quick
        % way to jump to the actual bash shell.
        cmd=sprintf('"%s"  --login -i &',getpref('git','sh_path'));
        dos(cmd);
        return;
    case 'checkout'
        if strcmpi(CLOSE_ON_CHECKOUT,'ask')
            button=questdlg('Close all open .m and .mdl files before checking out? This reduces post checkout errors and the chance that you will resave the current version in the branch you switch to','Close Open Files?','Yes','No','No');
            if strcmpi(button,'yes')
                closeall;
            end
        elseif CLOSE_ON_CHECKOUT %#ok<BDLGI>
            closeall;
        end
    case 'commit'
        try %#ok<TRYNC>
            if strcmpi(SAVE_ON_COMMIT,'ask')
                button=questdlg('Close all open .m and .mdl files before checking out? This reduces post checkout errors and the chance that you will resave the current version in the branch you switch to','Close Open Files?','Yes','No','No');
                if strcmpi(button,'yes')
                    saveall;
                end
            elseif SAVE_ON_COMMIT
                saveall;
            end
        end
end

%% For each input
cmd=sprintf('"%s" "%s" "%s"&',getpref('git','gitExtensions_path'),command,argument);
dos(cmd);
end

% Get the absolute path of a file.
function [absolutepath]=abspath(partialpath)
% Taken from xlswrite.
% parse partial path into path parts
[pathname filename ext] = fileparts(partialpath);
% no path qualification is present in partial path; assume parent is pwd, except
% when path string starts with '~' or is identical to '~'.
if isempty(pathname) && isempty(strmatch('~',partialpath))
    Directory = pwd;
elseif isempty(regexp(partialpath,'(.:|\\\\)','once')) && ...
        isempty(strmatch('/',partialpath)) && ...
        isempty(strmatch('~',partialpath));
    % path did not start with any of drive name, UNC path or '~'.
    Directory = [pwd,filesep,pathname];
else
    % path content present in partial path; assume relative to current directory,
    % or absolute.
    Directory = pathname;
end
% construct absulute filename
absolutepath = fullfile(Directory,[filename,ext]);
end

function saveall
try % Don't fail the whole commit because something went wrong here.
    % Save all simulink models & open .m files before commiting.
    if exists('.git','directory') % If we are in a working directory.
        % Get all open Simulink models.
        openSystems=find_system('SearchDepth',0);
        % Get all M-files open in the Matlab Editor.
        openM=char(com.mathworks.mlservices.MLEditorServices.builtinGetOpenDocumentNames);
        for i=1:numel(openSystems)
            try %#ok<*TRYNC> % Try to save every system, if it fails continue on to the next one.
                save_system(openSystems{1})
            end
        end
        for i=1:size(openM,1)
            try % Try to save every M-file, if one fails move
                % on to the next one.
                com.mathworks.mlservices.MLEditorServices.saveDocument(strtrim(openM(i,:)));
            end
        end
    end
end
end

function closeall
try % Don't fail the whole checkout because this fails.
    % Close all simulink models and *.m files before checkout
    bdclose('all');
    com.mathworks.mlservices.MLEditorServices.closeAll;
end
end
