matlab_gitextensions
====================

Command wrapper for GitExtensions in Matlab.

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
%   currbranch    - returns the current branch
%   currentbranch - returns the current branch
%
% See also: http://code.google.com/p/gitextensions/,
% http://git-scm.com/documentation
%
% GitExtensions is Windows only and by extension so is this script.

% Author:         Jed Frey <github@exstatic.org>
% Git Repository: https://github.com/jedediahfrey/matlab_gitextensions
