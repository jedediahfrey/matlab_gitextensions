matlab_gitextensions
====================

Command wrapper for Git & GitExtensions in Matlab.

%GIT - Control GitExtensions from within MATLAB.
% This is meant to serve as a half way point between the full git bash
% and TorgoiseGit. It is intended for users that prefer to be able to
% manipulate git from the MATLAB prompt but also like the added usefullness
% of the GitExtensions GUI.
%
% To pass arguments directly to the git command line (bypassing GitExtensions)
% use --force as the first argument.
%
% Additionally it offers these command aliases:
%   lasthash      - returns the last commit hash.
%                       alias for git
%   currbranch    - returns the current branch
%                       alias for git rev-parse --abbrev-ref HEAD
%   currentbranch - returns the current branch
%                       alias for git rev-parse --abbrev-ref HEAD
%   isclean       - returns true/false if the current branch is clean
%                       alias for git diff-files --exit-code --ignore-submodules
%
% Examples:
%   git checkout % [GitExtensions Dialog]
%   edit newfile.m % [M-File Editor] Add text.
%   git add % [GitExtensions Dialog]
%   git commit % [GitExtensions Dialog]
%
%   git --force commit -am 'This is a direct commit bypassing the GitExtensions dialog'
%
% See also: http://code.google.com/p/gitextensions/,
% http://git-scm.com/documentation
%
% GitExtensions is Windows only and by extension so is this script.

% Author:         Jed Frey <github@exstatic.org>
% Git Repository: https://github.com/jedediahfrey/matlab_gitextensions
