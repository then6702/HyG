# HyG
Code base for HyG: A hydraulic geometry dataset derived from historical USGS stream gage measurements (https://zenodo.org/records/10425392). All analyses were done in MATLAB.

USGS discharge and drainage area records were downloaded from the USGS NWIS data portal using the scripts in bash_scripts. We do not provide these files as part of the HyG code base; users can explore downloading the files themselves. We note that USGS has made changes to their data portal since 2020; the scripts we provide have not been tested with the new data portal. 

At-a-station hydraulic geometry (AHG) parameters were derived from USGS manual measurements. These were downloaded as a single, large (715 MB) text file from the USGS NWIS portal. For convenience, we provide the relevant fields from that text file in individual vectors saved as .mat in mat_files. Additionally, we provide relevant data from the National Hydrography Dataset (NHD) in NHD_xls. 

AHG parameters were calculated using ataStationGeometry.m. 
Discharge records were QC'd with Q_records_10years.m
Discharge daily exceedance probabilities were calculated using Q_dailyExceedanceProbability.m
Downstream hydraulic geometry (DHG) was calculated at the HUC4 scale with DHG_HUC4_Qp.m
