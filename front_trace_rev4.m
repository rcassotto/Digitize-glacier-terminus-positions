
%% Authors: Mark Fahnestock, Ryan Cassotto
%% Revision: 4
%% NOTES: rev 3 processes non-annotated jpegs in the original filename format for Landsats 4, 5, 7, and 8

clc
close all
clear all


cd /Users/Ryan_old/Documents/1_Research/1_Data/Landsat/Landsat_Vis/Koge_Bugt/jpeg_frames_Koge/

glacier='KogeSouth';


inlist=dir('*.jpg');
numinfiles=size(inlist,1);

figure

infilenum=1;
stop=0;


while (stop==0 && infilenum<=numinfiles)
    
    stoploc=strfind(inlist(infilenum).name,'_B'); % find postion of "B8" in filename string
    infilename=inlist(infilenum).name; % current filename
    %     outfilename=[inlist(infilenum).name(1:(stoploc-1)) '_frontpos.mat'];
    outfilename=[inlist(infilenum).name(1:(stoploc-1)) ,'_',glacier,'_frontpos.mat']; % outfilename
    temp=dir(outfilename); % check to see if filename exists
    
    %% while loop to iterate infilenum to find image with not front position
    while((infilenum<=numinfiles && size(temp,1)>0)) % loop to iterate to next filename if matfile for current iteration exists
        infilenum=infilenum+1; % increment counter
        stoploc=strfind(inlist(infilenum).name,'_B'); % find postion of "B8" in filename string
        outfilename=[inlist(infilenum).name(1:(stoploc-1)) ,'_',glacier,'_frontpos.mat'];
        temp=dir(outfilename);
        infilename=inlist(infilenum).name;
    end
    
    
    if strcmp(infilename(1:2),'L7')
        %% Landsat 7 with format "L7223015_015yyyymmdd_B80.jpg"
        imagedatenum=datenum(infilename(14:21),'yyyymmdd'); % landsat 5-8
    elseif strcmp(infilename(1:4),'LE07')
        %% Landsat 7 with format "LE07_L1TP_ppprrr_yyyymmdd_yyyymmdd_01_T2_B8_b8bit.jpg"
        iStrLoc=strfind(infilename,'_');
        imagedatenum=datenum(infilename(iStrLoc(3)+1:iStrLoc(4)-1),'yyyymmdd');
    elseif strcmp(infilename(1:4),'LC08')
        %% Landsat 8 with format "LC08_L1GT_ppprrr_yyyymmdd_yyyymmdd_01_T2_B8_b8bit.jpg"
        iStrLoc=strfind(infilename,'_');
        imagedatenum=datenum(infilename(iStrLoc(3)+1:iStrLoc(4)-1),'yyyymmdd');
    elseif strcmp(infilename(1:4),'LT05')
        %% Landsat 8 with format "LT05_L1TP_ppprrr_yyyymmdd_yyyymmdd_01_T2_B8_b8bit.jpg"
        iStrLoc=strfind(infilename,'_');
        imagedatenum=datenum(infilename(iStrLoc(3)+1:iStrLoc(4)-1),'yyyymmdd');
    else
        cprintf('*r',['unrecognizied datestr. Exiting',newline])
        display(infilename)
        return
    end
    
    
    if(infilenum>numinfiles)
        fprintf(2,'all files traced in directory\n');
        exit();
    end
    
    %% read in jpeg
    clear imageA
    in_imageA=imadjust(imread(infilename));
    
    if ndims(in_imageA)<3
        for n=1:3; imageA(:,:,n)=in_imageA; end
    else
        imageA=in_imageA;
    end
    
    %% Get jpeg metadata
    infile_xml=dir([infilename(1:25) '*.xml']);
    
    fid=fopen(infile_xml.name,'r');
    A=fscanf(fid,' %s ');
    fclose(fid);
    kstart=findstr(A,'<GeoTransform>');
    kstop=findstr(A,'</GeoTransform>');
    C=sscanf(A(kstart:kstop),'<GeoTransform>%f,%f,%f,%f,%f,%f<');
    UTM.ulx=C(1);
    UTM.uly=C(4);
    UTM.delx=C(2);
    UTM.dely=C(6);
    
    
    datestr(imagedatenum)
    
    
    image(imageA)
    axis image
    %     title(strrep([num2str(infilenum),' / ',num2str(numinfiles),'   ',infilename], '_','-'))
    title([strrep([num2str(infilenum),' / ',num2str(numinfiles),'   ',infilename], '_','-'),'    ',datestr(imagedatenum)])
    
    hold on
    user_in=input('arrange window (zoom, etc) and hit return');
    button=1;
    numpts=0;
    while (button==1)
        [x,y,button]=ginput(1);
        if(button==1)
            numpts=numpts+1;
            pts_x(numpts)=x;
            pts_y(numpts)=y;
            pts_UTMx(numpts)=double(UTM.ulx)+(((pts_x(numpts))-0.5)*double(UTM.delx));
            pts_UTMy(numpts)=double(UTM.uly)+(((pts_y(numpts))-0.5)*double(UTM.dely));
            plot(x,y,'r+');
        else
            plot(pts_x(numpts),pts_y(numpts),'wo');
        end
    end
    if(numpts>=2)
        stoploc=findstr(inlist(infilenum).name,'_B');
        mfilename_script=mfilename;
        outfilename=[inlist(infilenum).name(1:(stoploc-1)) ,'_',glacier,'_frontpos.mat'];
        save(outfilename,'infilename','infile_xml','imagedatenum','pts_x','pts_y','pts_UTMx','pts_UTMy','numpts','mfilename_script');
    end
    
    user_in=input('hit return to do another, 0 to quit');
    if(user_in==0)
        stop=1;
    end
    
    hold off
    infilenum=infilenum+1;
    clear('infilename','infile_xml','imagedatenum','pts_x','pts_y','pts_UTMx','pts_UTMy','numpts');
end

