function [varData,varAtt]=getVarNetCDF(varName,ncid)
%%getVarNetCDF gets the varData from a NetCDF for one variable only.
% The script lists all the Variables in the NetCDF file. If the 
% variable is called TIME (case does not matter), then the variable is
% converted to a matlab time value, by adding the time offset ... following
% the CF conventions 
% If the variable to load is not TIME, the data is extracted, and all values
% are modified according to the attributes of the variable following the CF
% convention (such as value_min value_max, scale-factor , _Fillvalue ...)
% http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.1/cf-conventions.html
% Syntax:  [varData,varAtt]=getVarNetCDF(varName,ncid)
%
% Inputs:
%       ncid         : result from netcdf.open
%       varName      : string of variable name to load. To get list of
%                      variable names, type listVarNC(ncid)
% Outputs:
%    varData         : ready to use data (modified according to the
%                      variable attributes)
%    varAtt          : variable attributes
%
% Example:
%    ncid=netcdf.open('IMOS_AUV_B_20070928T014025Z_SIRIUS_FV00.nc','NC_NOWRITE');
%    [varData,varAtt]=getVarNetCDF('TIME',ncid)
%
% Other m-files required:
% Other files required: 
% Subfunctions: none
% MAT-files required: none
%
% See also: netcdf.open,listVarNC,getGlobAttNC
%
% Author: Laurent Besnard, IMOS/eMII
% email: laurent.besnard@utas.edu.au
% Website: http://imos.org.au/  http://froggyscripts.blogspot.com
% Oct 2012; Last revision: 30-Oct-2012
%
% Copyright 2012 IMOS
% The script is distributed under the terms of the GNU General Public License 


ii=1;
Bool=1;
% preallocation
[~,nvars,~,~] = netcdf.inq(ncid);% nvar is actually the number of Var + dim.
allVarnames=cell(1,nvars);
allVaratts=cell(1,nvars);

while  Bool==1
    try
        [varname, ~, ~, varatts] = netcdf.inqVar(ncid,ii-1);
        allVarnames{ii}=varname;
        allVaratts{ii}=varatts;
        ii=ii+1;
        Bool=1;
    catch
        Bool=0;
    end
end
%
%% get only varData for varName


if ~strcmpi(varName,'TIME')
    varData=[];
    varAtt=struct;
    idxVar= strcmpi(allVarnames,varName)==1;
    strVarName=allVarnames{idxVar};
    varData=netcdf.getVar(ncid,netcdf.inqVarID(ncid,strVarName));
    
    %% get all variable attributes and put information into a structure
    
    for ii=0:allVaratts{idxVar}-1
        varid = netcdf.inqVarID(ncid,allVarnames{idxVar});
        attname = netcdf.inqAttName(ncid,varid,ii);
        if ~isempty(strfind(attname,'_FillValue'))
            varAtt.('FillValue')=netcdf.getAtt(ncid,varid,attname);
        else
            varAtt.(attname)=netcdf.getAtt(ncid,varid,attname);
        end
    end
    
    
    %% modify varData according to the attributes
    if isfield(varAtt,'valid_min')
        varData(varData<varAtt.valid_min)=NaN;
    end
    
    if isfield(varAtt,'valid_max')
        varData(varData>varAtt.valid_max)=NaN;
    end
    
    if isfield(varAtt,'FillValue')
        varData(varData==varAtt.FillValue)=NaN;
    end
    
    if isfield(varAtt,'scale_factor') && ~isfield(varAtt,'add_offset')
        varData=varData*varAtt.scale_factor;
    elseif isfield(varAtt,'scale_factor') && isfield(varAtt,'add_offset')
        varData=varData*varAtt.scale_factor+varAtt.add_offset;
    elseif ~isfield(varAtt,'scale_factor') && isfield(varAtt,'add_offset')
        varData=varData+varAtt.add_offset;
    end
    
    
else
    %% we grab the date dimension
    idxTIME= strcmpi(allVarnames,'TIME')==1;
    TimeVarName=allVarnames{idxTIME};
    
    date_var_id=netcdf.inqVarID(ncid,TimeVarName);
    
    try
        date_dim_id=netcdf.inqDimID(ncid,TimeVarName);
        [~, dimlen] = netcdf.inqDim(ncid,date_dim_id);
    catch
        %if TIME is not a dimension
        [~, dimlen] = netcdf.inqVar(ncid,date_var_id);
    end
    
    
    
    varData=[];
    varAtt=struct;
    if dimlen >0
        preDATA = netcdf.getVar(ncid,date_var_id);
        
        
        %% get all variable attributes and put information into a structure
        for ii=0:allVaratts{idxTIME}-1
            varid = netcdf.inqVarID(ncid,TimeVarName);
            attname = netcdf.inqAttName(ncid,varid,ii);
            if ~isempty(strfind(attname,'_FillValue'))
                varAtt.('FillValue')=netcdf.getAtt(ncid,varid,attname);
            else
                varAtt.(attname)=netcdf.getAtt(ncid,varid,attname);
            end
        end
        
        %read time offset from ncid
        strOffset=netcdf.getAtt(ncid,date_var_id,'units');
        indexNum=regexp(strOffset,'[^0-9]*(\d{4})-(\d{2})-(\d{2})[^0-9]*(\d{2})[^0-9]*(\d{2})[^0-9]*(\d{2})*','tokens');
        
        Y_off =str2double(indexNum{1}{1});
        M_off =str2double(indexNum{1}{2});
        D_off =str2double(indexNum{1}{3});
        H_off =str2double(indexNum{1}{4});
        MN_off=str2double(indexNum{1}{5});
        S_off =str2double(indexNum{1}{6});
        
        if ~isempty(strfind(strOffset,'days'))
            NumDay=double(D_off+preDATA);
            preDATAmodified=datenum(Y_off, M_off, NumDay, H_off, MN_off, S_off);
            varData=preDATAmodified;
            
        elseif ~isempty(strfind(strOffset,'seconds'))
            NumSec=double(S_off+preDATA);
            preDATAmodified=datenum(Y_off, M_off, D_off, H_off, MN_off, NumSec);
            varData=preDATAmodified;
        end
        
    elseif dimlen ==0
        disp('File is corrupted, or variable Time is badly spelled')
        varData=[];
    end
    
end
end
