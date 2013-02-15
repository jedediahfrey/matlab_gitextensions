function varargout=git(varargin)
%git Control GitExtensions from within MATLAB.
% This is meant to serve as a half way point between the full git bash
% and TorgoiseGit. It is intended for users that prefer to be able to
% manipulate git from the MATLAB prompt but also like the added usefullness
% of the GitExtensions GUI.
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
% Paths for all required files.
paths.gitExtensions={'C:\Program Files\GitExtensions\GitExtensions.exe', ...
    'C:\Program Files (x86)\GitExtensions\GitExtensions.exe'};
paths.sh={'C:\Program Files (x86)\Git\bin\sh.exe', ...
    'C:\Program Files\Git\bin\sh.exe';};
paths.git={'C:\Program Files (x86)\Git\bin\git.exe',...
    'C:\Program Files\Git\bin\git.exe'};
% Required programs
progs=fieldnames(paths);
progs=reshape(progs,1,numel(progs));
script=mfilename;
for prog=progs
    prog=prog{1};
    if ~ispref(script,prog) || ... % if the preference is not set.
            ~exist(getpref(script,prog),'file') % or the old path no longer exists
        found=false;
        for path=paths.(prog)
            if exist(path{1},'file')
                setpref(script,prog,path{1});
                [~,n,e]=fileparts(path{1});
                fprintf('%s%s found and preferences saved (%s)\n',n,e,path{1});
                found=true;
                break;
            end
        end
        if ~found
            [~,n]=fileparts(path{1});
            [filename, pathname] = uigetfile(n, sprintf('%s not automatically found. Please select it:',n));
            if filename==0
                warning('git:canceled','User canceled executable selection');
                return;
            end
            setpref(script,prog,fullfile(pathname,filename));
        end
    end
end
% If nothing is given, show help and warn that a command is needed.
if nargin<1
    help(mfilename);
    warning('git:command','You must give at least one command\nSee: http://git-scm.com/documentation');
    return;
end
% Else grab the first input as a command.
command=varargin{1};
args='';
for i=2:nargin
    % If the input argument has spaces, escape it
    if strfind(varargin{i},' ')
        args=sprintf('%s "%s"',args,varargin{i});
    else
        args=sprintf('%s %s',args,varargin{i});
    end
end
% List of known working commands and any modifications that must be made to
% to the arguments before calling GitExtensions.exe
switch command
    % Arguments that take the [file] or [path] optonally.
    case {'browse','blame','clone','filehistory','fileeditor','init','openrepo','revert'}
        exec=getpref(mfilename,'gitExtensions');
        if nargin<2
            args=pwd;
        else
            args=abspath(varargin{2});
        end
    case {'about','add','apply','applypatch','branch','checkout','checkoutbranch','checkoutrevision','cherry', ...
            'cleanup','commit','formatpatch','gitbash','gitignore','merge','mergeconflicts','mergetool','pull','push',...
            'rebase','remotes','searchfile','settings','stash','synchronize','tag','viewdiff'}
        % The rest of the git commands.
        exec=getpref(mfilename,'gitExtensions');
    case {'lasthash'}
        cmd=sprintf('"%s" rev-parse HEAD',getpref(mfilename,'git'));
        [~,r]=dos(cmd);
        if nargout==1
            varargout{1}=r;
        else
            disp(r);
        end
        return;
    case 'bash'
        %% Bash
        % Not actually GitExtensions, but the GitBash from the Git package. Quick
        % way to jump to the actual bash shell.
        cmd=sprintf('"%s"  --login -i &',getpref(mfilename,'sh'));
        dos(cmd);
        return;
    otherwise
        cmd=sprintf('"%s" %s %s',getpref(mfilename,'git'),command,args);
        [~,r]=dos(cmd,'-echo');
        return;
end

%% For each input
cmd=sprintf('"%s" %s "%s"&',getpref(mfilename,'gitExtensions'),command,args);
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
