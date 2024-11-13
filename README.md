# Digitize-glacier-terminus-positions
MATLAB programs to manually digitize glacier terminus positions from satellite images. They are a bit old but still work quite nicely. 

**front_trace_rev4.m**: performs the digitization on jpegs of the satellite images in question. It requires *.xml images, one for each satellite image, with the geolocation information for the associated satellite scene. These *.xml files are generated during the conversion of geotiff images to jpegs using gdal (the Geospatial Data Abstraction Library; http://gdal.org)
