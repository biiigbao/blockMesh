function TriaxialTestWithPentagonCore(caseDir,toolboxDir)

% Generating mesh for triaxial soil test, i.e. simply a cylindrical volume.
%
% The core is filled with a pentagon.
%
% Johan Roenby, DHI Water & Environment

if nargin < 1
    caseDir = pwd;
end
if nargin < 2
    toolboxDir = ['..' filesep '..' filesep 'meshingTools'];
end

%Making case file structure and copying generating m-files to case directory
meshDir = makeCaseDir(caseDir,toolboxDir);
%Copy generating code to case dir
copyGeneratingCode(meshDir,toolboxDir,mfilename('fullpath'));

compress = 0; %1 to compress output files 
writePrec = 12; %Write precision in output files

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Defining dimensions

%Vertical
z1 = 0;
z2 = 2;
%Radial
r1 = 1;
r2 = 2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Defining grid control parameters

nz = 10; %Number of height bins
nth = 10*4; %Number of azimuthal bins - MUST BE DIVISIBLE BY 4 AND 10!!!
nr2 = 8;

prec = 1e-6; %Precision in determining whether two points are identical
%Rescaling factor for mesh
fac = 1e-3; %mm -> m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Constructing mesh
z = z1 + (z2-z1)*[0:nz]/nz;
b = pentagonInCircle(nth/10,nr2,r1,r2,z);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Merging patches
ind = patchesInPlane(b,[0 0 z(end)],[0 0 1],prec);
b = mergePatches(b,ind,'top','patch');

ind = patchesInPlane(b,[0 0 z(1)],[0 0 -1],prec);
b = mergePatches(b,ind,'bottom','patch');

patchInd = strfind(b.boundary.patchName,'patch');
ind = zeros(length(patchInd),1);
for n = 1:length(patchInd)
    if ~isempty(patchInd{n})
        ind(n) = 1;
    end
end
ind = find(ind);
b = mergePatches(b,ind,'side','patch');

%Rescaling and printing mesh
b.points = fac*b.points;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Writing to OpenFOAM polyMesh files
writePolyMesh(b,meshDir,writePrec,compress)