% Copyright 2012 IMOS
% The script is distributed under the terms of the GNU General Public License
%
% this file tends to demonstrate how to use BioOptical data stored in the NetCDF format
%
% Syntax:  profileData=getAbsorptionData(ncFile,variable,profile)
%
% Inputs: ncFile   - string of the NetCDF location
%         variable - string of variable name
%         profile  - number of profile to grab data from
%         
% Outputs: profileData - structure with values and metadata of the profile
%
%
% Example:
%    profileData=getAbsorptionData('/this/is/thepath/IMOS_test.nc','ag',1)
%
% Other m-files
% required:
% Other files required:config.txt
% Subfunctions: mkpath
% MAT-files required: none
%
% See also:
%  getAbsorptionInfo,plotAbsorption,getAbsorptionData
%
% Author: Laurent Besnard, IMOS/eMII
% email: laurent.besnard@utas.edu.au
% Website: http://imos.org.au/  http://froggyscripts.blogspot.com
% Aug 2011; Last revision: 28-Nov-2012

%%%%% ABSORPTION DATA %%%%%%%
%% choose netcdf file
ncFile='/this/is/the/path/to/the/NetCDF/IMOS_SRS-OC-BODBAW_X_....nc';
[profileInfo,variableInfo,globalAttributes]=getAbsorptionInfo(ncFile);

%% choose variable and profile, for absorption files, only one variable per file.
%% In our example we choose ag, and the first profile
%% WARNING, there is only one measured variable per NetCDF files for Absorption
variable=variableInfo.ag;
profileIndex=profileInfo(1).index;
profileData=getAbsorptionData(ncFile,variable,profileIndex);
plotAbsorption(profileData) % plot many depth in same graph



%%%%% PIGMENT DATA  %%%%%%%%%%%%%
%% choose netcdf file
ncFile='/this/is/the/path/to/the/NetCDF/IMOS_SRS-OC-BODBAW_X_....nc';
[profileInfo,variableInfo,globalAttributes]=getPigmentInfo(ncFile);

%% choose variable and profile. In our example we choose CPHL_c3, and the first profile
%% WARNING, there are many different variables, and not all have data. You might encountered
%% many with NaN values.
variable=variableInfo.CPHL_c3;
profileIndex=profileInfo(1).index;
profileData=getPigmentData(ncFile,variable,profileIndex);
plotPigment(profileData)
