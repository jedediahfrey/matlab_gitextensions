matlab_gitextensions
====================

Command wrapper for GitExtensions in 

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