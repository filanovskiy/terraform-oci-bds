#!/bin/bash
# List buckets
# oci os bucket list --compartment-id $COMPARTMENT_OCID --name cloudsqlworkshop
# Create Bucket
BUCKET_NAME=${1:-weather_download}

echo "Adding weather data"
echo "... creating bucket $BUCKET_NAME"
oci os bucket create --compartment-id $COMPARTMENT_OCID --name $BUCKET_NAME
echo "... retrieving weather data from NOAA and uploading to bucket $BUCKET_NAME"
echo "... find more info about data set here:  https://www.ncdc.noaa.gov/cdo-web/search?datasetid=GHCND"
curl -sS -k -L --post302 -X GET "https://www.ncei.noaa.gov/access/services/data/v1?dataset=daily-summaries&dataTypes=PRCP,SNOW,SNWD,TMAX,TMIN&stations=USW00094728&startDate=2019-01-01&endDate=2019-12-31&format=csv&units=standard" | oci os object put --content-type text/csv --force --bucket-name $BUCKET_NAME --name "weather/central-park.csv" --file -