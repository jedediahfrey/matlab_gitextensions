function varargout=git(varargin)
%GIT - Control GitExtensions from within MATLAB.
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
% Additionally it offers these command aliases:
%   lasthash      - returns the last commit hash.
%                       alias for git 
%   currbranch    - returns the current branch
%                       alias for git rev-parse --abbrev-ref HEAD
%   currentbranch - returns the current branch
%                       alias for git rev-parse --abbrev-ref HEAD
%   isclean       - returns true/false if the current branch is clean
%                       alias for git status --exit-code --ignore-submodules
%
% See also: http://code.google.com/p/gitextensions/,
% http://git-scm.com/documentation
%
% GitExtensions is Windows only and by extension so is this script.

% Author:         Jed Frey <github@exstatic.org>
% Git Repository: https://github.com/jedediahfrey/matlab_gitextensions

% Copyright (c) 2014, Jed Frey
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
% 
% 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
% 
% 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
% 
% 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

if ~ispc
    error('GitExtensions is only available for Windows machines');
end
% Paths for all required files.
paths.gitExtensions={'C:\Program Files\GitExtensions\GitExtensions.exe', ...
    'C:\Program Files (x86)\GitExtensions\GitExtensions.exe', ...
    'C:\Program Files (x86)\Git_Extensions\GitExtensions.exe'};
paths.sh={'C:\Program Files (x86)\Git\bin\sh.exe', ...
    'C:\Program Files\Git\bin\sh.exe',...
    'C:\Program Files\MSysGit\bin\sh.exe';};
paths.git={'C:\Program Files (x86)\Git\bin\git.exe',...
    'C:\Program Files\Git\bin\git.exe',...
    'C:\Program Files\MSysGit\bin\git.exe'};
%% Required programs
% Get program names
progs=fieldnames(paths);
% Reshape program names so it can be looped through
progs=reshape(progs,1,numel(progs));
% Get the current name of the script
script=mfilename;
% For each of the programs
for prog=progs
    % Pull current program name out of the cell array
    prog=prog{1};
    if ~ispref(script,prog) || ... % if the preference is not set.
            ~exist(getpref(script,prog),'file') % or the old path no longer exists
        % Set the found variable to false (the program hasn't been found yet)
        found=false;
        % Reshape the cell array so it can be looped through
        paths.(prog)=reshape(paths.(prog),1,numel(paths.(prog)));
        % For each of the paths
        for path=paths.(prog)
            % Pull current path out of the single cell array
            path=path{1};
            % If the path exists!
            if exist(path,'file')
                % Set the path to the program as a preference for the script
                setpref(script,prog,path);
                % Get each of the parts
                [~,n,e]=fileparts(path);
                % Echo to the user that it has been found.
                fprintf('%s%s found and preferences saved (%s)\n',n,e,path);
                % Set the found variable to true.
                found=true;
                % Break the loop.
                break;
            end
        end
        % If it hasn't been found by now.
        if ~found
            % Get the file name
            [~,n]=fileparts(path{1});
            % Prompt the user to select the file
            [filename, pathname] = uigetfile(n, sprintf('%s not automatically found. Please select it:',n));
            % If the user cancels
            if filename==0
                % Throw a warning and exit.
                warning('git:canceled','User canceled executable selection');
                return;
            end
            % Otherwise save the full path to the file.
            setpref(script,prog,fullfile(pathname,filename));
        end
    end
end

%% If nothing is given, show help and warn that a command is needed.
if nargin<1
    help(mfilename);
    warning('git:command','You must give at least one command\nSee: http://git-scm.com/documentation');
    return;
end

%% Command processing
% Grab the first input as a command.
command=varargin{1};
% Set command arguments to nothing.
args='';
% List of known working commands and any modifications that must be made to
% to the arguments before calling GitExtensions.exe
switch command
    % Arguments that take the [file] or [path] command
    case {'browse','blame','clone','commit','filehistory','fileeditor','init','openrepo','revert'}
        % If no extra argument is given, use the current directory.
        if nargin<2
            args=pwd;
        else % Otherwise pass the absolute path
            args=abspath(varargin{2});
        end
        % The rest of the git commands that GitExtensions accepts
    case {'about','add','apply','applypatch','branch','checkout','checkoutbranch','checkoutrevision','cherry', ...
            'cleanup','formatpatch','gitbash','gitignore','merge','mergeconflicts','mergetool','pull','push',...
            'rebase','remotes','searchfile','settings','stash','synchronize','tag','viewdiff'}
        % Our custom alias for returning the last hash
    case {'lasthash'}
        % Command to get the current hash.
        cmd=sprintf('"%s" log --max-count=1 --pretty=%%H',getpref(mfilename,'git'));
        % Run the command
        [~,hash]=dos(cmd);
        % Replace the newline with nothing.
        hash=strrep(hash,char(10),'');
        % If this is used with a return send it to varargout, otherwise print
        % it.
        if nargout==1
            varargout{1}=hash;
        else
            disp(hash);
        end
        return;    
    case {'shorthash'}
        % Command to get the current hash.
        cmd=sprintf('"%s" log --max-count=1 --pretty=format:%%h',getpref(mfilename,'git'));
        % Run the command
        [~,hash]=dos(cmd);
        % Replace the newline with nothing.
        hash=strrep(hash,char(10),'');
        % If this is used with a return send it to varargout, otherwise print
        % it.
        if nargout==1
            varargout{1}=hash;
        else
            disp(hash);
        end
        return;
    case {'currbranch','currentbranch'}
        % Command to get the current branch
        cmd=sprintf('"%s" rev-parse --abbrev-ref HEAD',getpref('git','git'));
        [~,branch]=dos(cmd);
        % Replace the newline with nothing.
        branch=strrep(branch,char(10),'');
        % If this is used with a return send it to varargout, otherwise print
        % it.
        if nargout==1
            varargout{1}=branch;
        else
            disp(branch);
        end
        return;
    case {'isclean'}
        % Command to get the current branch
        cmd=sprintf('"%s" diff --exit-code --ignore-submodules',getpref('git','git'));
        [notclean,~]=dos(cmd);
        isclean=logical(~notclean);
        % If this is used with a return send it to varargout, otherwise print
        % it.
        if nargout==1
            varargout{1}=isclean;
        else
            disp(isclean);
        end
        return;
    case 'bash'
        %% Bash
        % Not actually GitExtensions, but the GitBash from the Git package. Quick
        % way to jump to the actual bash shell.
        cmd=sprintf('"%s" --login -i &',getpref(mfilename,'sh'));
        dos(cmd);
        return;
    case '--force'
        % Force passing the options on to the command line version of git
        % instead of git extensions.
        
        % Add additional inputs as arguments.
        for i=2:nargin
            args=sprintf('%s "%s"',args,varargin{i});
        end
        % Directly call the git command and return the output.
        cmd=sprintf('"%s" %s',getpref(mfilename,'git'),args);
        if nargout==1
            [~,varargout{1}]=dos(cmd);
        else
            dos(cmd,'-echo');
        end
        return;
    otherwise
        % Add additional inputs as arguments.
        for i=2:nargin
            args=sprintf('%s "%s"',args,varargin{i});
        end
        % Directly call the git command and return the output.
        cmd=sprintf('"%s" %s %s',getpref(mfilename,'git'),command,args);
        if nargout==1
            [~,varargout{1}]=dos(cmd);
        else
            dos(cmd,'-echo');
        end
        return;
end
% Process the command.
cmd=sprintf('"%s" %s %s&',getpref(mfilename,'gitExtensions'),command,args);
dos(cmd);
end

%% AbsPath
% Get the absolute path for the given partial path.
function [absolutepath]=abspath(partialpath)
% Taken from xlswrite.
% parse partial path into path parts
[pathname,filename,ext] = fileparts(partialpath);
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
