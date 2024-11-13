# Digitize-glacier-terminus-positions
MATLAB programs to manually digitize glacier terminus positions from satellite images. They are a bit old but still work quite nicely. 

**front_trace_rev4.m**: performs the digitization on jpegs of the satellite images in question. It requires *.xml images, one for each satellite image, with the geolocation information for the associated satellite scene. 

These *.xml files are generated during the conversion of geotiff images to jpegs using gdal (the Geospatial Data Abstraction Library; http://gdal.org). For example, 
  
          *gdal_translate -of JPEG -projwin <ulx> <uly> <lrx> <lry> <infilename>.tif <outfilename>.jpg*
  
will generate two files:
    1) a jpeg of the original satellite image, cropped to the projection window defined by upper left and lower right coordinates specified. 
    2) an associated *xml file with the geolocation information of the cropped jpeg scene. 


**digitize_font_position_Radarsat1.m**: performs the digitziation of Sentinel-1 geotiff images. It operates similiarly to front_trace_rev4.m above, except that it operates on geotiffs and does not require associated *.xml files to read in geolocation infomration. 

Although this script is written for Radarsat1, it could easily be adapted for other satellites after modifying the code to reflect updated sensor names and filename nomenclature.
  
