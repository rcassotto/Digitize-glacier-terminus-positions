clc
close all
clear

%% Author: Ryan K. Cassotto
%% Ver. Date: March 6, 2020
%%



%% Input values
FigureNum=0;
markersize=10;
fontsize=14;
diag=1;


%%% constants for nsidc polarstereo conversion
EARTHRADIUS=6378137;
ECCENTRICITY=0.08181919;
LAT_TRUE=70;
LON_POSY=-45;

%%% region of interest for Koge Bugt - Central
roi_x_master=[179856 191363];
roi_y_master=[-2732112 -2723019];


% utm_lat_band_north_list=['N P Q R S T U V W X'];
% utm_lat_band_south_list=['C D E F G H J K L M'];


%% Directories and Paths
% image_dir='/Users/Ryan_old/Documents/1_Research/1_Data/RADARSAT-1/Geotiffs_and_metaData/'; %
% image_dir='/Users/Ryan_old/Documents/1_Research/1_Data/RADARSAT-1/Geotiffs_and_metaData_cropped/cropped/FN1/';
% image_dir='/Users/Ryan_old/Documents/1_Research/1_Data/RADARSAT-1/Geotiffs_and_metaData_cropped/cropped_Koge_South/SWA_SWB/';
% image_dir='/Users/Ryan_old/Documents/1_Research/1_Data/RADARSAT-1/Geotiffs_and_metaData_cropped/cropped_Koge_South/FN1/';
image_dir='/Users/Ryan_old/Documents/1_Research/1_Data/RADARSAT-1/Geotiffs_and_metaData_cropped/cropped_Koge_North/FN1/';
% image_dir='/Users/Ryan_old/Documents/1_Research/1_Data/RADARSAT-1/Geotiffs_and_metaData_cropped/cropped_Koge_North/SWA_SWB/';
% image_dir='/Users/Ryan_old/Documents/1_Research/1_Data/RADARSAT-1/Geotiffs_and_metaData_cropped/cropped_Koge_North/FN1/';


% glacier='KogeCentral';
glacier='KogeNorth';



% image_dir='/Users/Ryan_old/Documents/1_Research/1_Data/RADARSAT-1/Geotiffs_and_metaData_cropped/cropped/SWA_SWB/';

FigureNum=FigureNum+1;  figure(FigureNum);
% set(gcf,'position',[37    34   952   771]) % 2 x 2 subplot
% set(gcf,'position',[           37         289        1404         516]) % 1 x 3  subplot

%% Loop over files
indir=dir([image_dir, '*.tif']);
imagedatenum=zeros(1,length(indir));



numinfiles=size(indir,1);

infilenum=1;
stop=0;



for n=1:length(indir)
    %   infilenum=n;
    disp([num2str(n), ' of ' , num2str(length(indir))])
    
    
    %% do a check for projection, if PS use PS, if UTM use UTM
    kk=geotiffinfo([indir(n).folder, '/', indir(n).name]);
    pcs=kk.GeoTIFFCodes.PCS;
    
    %% Get datenum
    meta_data_filename=strrep(indir(n).name,'_EPSG_32624_KogeBugt.tif','.L.txt');
    imagedatenum=read_ASF_RADARSAT1_datenum(indir(n).folder, meta_data_filename);
    
    %% Check if front position file exists
    %%% Traditional filenames
    outfilename=strrep(indir(n).name,'.tif',['_',datestr(imagedatenum,'yyyymmdd'),'_frontpos.mat']);
    check_file=exist([indir(n).folder, '/', outfilename],'file');

    %%% Automated digitzed front position filenames
    outfilename_2=strrep(indir(n).name,'.tif',['_digitizedFrontpos_',datestr(imagedatenum,'yyyymmdd'),'.mat']);
        check_file_2=exist([indir(n).folder, '/', outfilename_2],'file');

    
    if check_file==2 | check_file_2==2
        cprintf('r',[outfilename, ' already exists.....moving on\n'])
        continue
    else
        %% Read in image
        [inImage,R]=geotiffread([indir(n).folder, '/', indir(n).name]);
        inImage=imadjust(inImage);
        
        [utmX, utmY]=read_Georef_info(R);
        
        inimage_gray=uint8(zeros(size(inImage,1), size(inImage,2)));
        for nn=1:3; inimage_gray(:,:,nn)=inImage; end
        
        %% plot image
        imagesc(utmX, utmY, inimage_gray)
        axis image
        axis xy
        title([num2str(n),'/',num2str(length(indir)),'   ',strrep(indir(n).name,'_','-'), ':    ', datestr(imagedatenum)])
        
        %% Resize and position image
        hold on
        figure(FigureNum)
        user_in=input('arrange window (zoom, etc) and hit return');
        
        %% Digitize front
        button=1;
        numpts=0;
        while (button==1)
            [x,y,button]=ginput(1);
            if(button==1)
                numpts=numpts+1;
                pts_UTMx(numpts)=x;
                pts_UTMy(numpts)=y;
                %                       pts_UTMx(numpts)=double(UTM.ulx)+(((pts_x(numpts))-0.5)*double(UTM.delx));
                %                       pts_UTMy(numpts)=double(UTM.uly)+(((pts_y(numpts))-0.5)*double(UTM.dely));
                plot(x,y,'r+');
            else
                plot(pts_UTMx(numpts),pts_UTMy(numpts),'wo');
            end
        end
        
        
        %% Reproject UTM points to NSIDC polarstereo
        [x,y,utmzone_0] = deg2utm(kk.CornerCoords.Lat, kk.CornerCoords.Lon);
        clear x y
        utmzone=repmat(utmzone_0(1,:),length(pts_UTMx),1);
        [Lat,Lon] = utm2deg(pts_UTMx, pts_UTMy,utmzone);
        [pts_psX, pts_psY]=polarstereo_fwd(Lat, Lon,EARTHRADIUS,ECCENTRICITY,LAT_TRUE,LON_POSY);
        
        
        
        %% Save front position information if numpts> 2
        if(numpts>=2)
            infilename=indir(n).name;
            infile_path=indir(n).folder;
            mfilename_script=mfilename;
            numpts=length(pts_UTMx);
            date_created=datestr(now);
            
            disp(['Saving file: ',outfilename, ' to ', indir(n).folder])
            save([indir(n).folder, '/', outfilename],'infilename','infile_path','imagedatenum','pts_UTMx','pts_UTMy','numpts','mfilename_script', 'date_created','pts_psX', 'pts_psY','glacier');
        end
        
        %% check to exit routine
        user_in=input('hit return to do another, 0 to quit');
        if(user_in==0)
            cprintf('b','stopping...\n')
            return
        end
    end
    clf
end


