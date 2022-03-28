# detroit_caps
Prepping for geocoding and aggregating data to census area levels

Please ensure that headers are named consistently with what is described below; otherwise, change the instances of these headers in the script.

wm_GeocodePrep.R 
- takes as input Excel file with headers provided by Wayne Metro, including "Physical Address 1", Physical City, Physical State, Physical Zip
- removes duplicates and writes to a CSV
- new CSV file is entitled AddressesUnique which can be used for Geocodio

wm_aggregator.R
- takes as input CSV file with headers provided by Wayne Metro, including "Physical Address 1", Physical City, Physical State, Physical Zip and corresponding "Latitude" and "Longitude" columns from Geocodio
(if using Excel file to begin, Save As CSV)
- gets block group geometries and household numbers from Census, finds which block groups and census tracts the accounts fall under
- writes a new CSV with private information removed (i.e. name, phone, address) and with corresponding GEOID of the accounts' block group and census tract