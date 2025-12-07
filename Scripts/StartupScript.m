% Open a live script from the current project
open('SysComposer_Workshop.mlx'); 

% Create 'Working' directory if it does not exist
dirName = 'Working';
if ~exist(dirName, 'dir')
    mkdir(dirName);
end

% Change the current directory to 'Working'
cd(dirName);


