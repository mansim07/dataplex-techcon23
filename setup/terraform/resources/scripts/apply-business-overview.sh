#!/bin/bash

export PROJECT_ID=$(gcloud config get-value project)

PROJECT_ID=$1
LOCATION=$2

entry_name=`curl -X GET -H "x-goog-user-project: ${PROJECT_ID}" -H  "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: application.json" https://datacatalog.googleapis.com/v1/entries:lookup?linkedResource=//bigquery.googleapis.com/projects/$PROJECT_ID}/datasets/customer_data_product/tables/customer_data&fields=name |  jq -r '.name'`

#Sample entry value: projects/dataplex-demo-377921/locations/<region>/entryGroups/@bigquery/entries/cHJvamVjdHMvZGF0YXBsZXgtZGVtby0zNzc5MjEvZGF0YXNldHMvY3VzdG9tZXJfZGF0YV9wcm9kdWN0L3RhYmxlcy9jdXN0b21lcl9kYXRh

curl -X POST -H "x-goog-user-project: ${PROJECT_ID}" -H  "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: application.json" https://datacatalog.googleapis.com/v1/${entry_name}:modifyEntryOverview -d "{\"entryOverview\":{\"overview\":\"<header><h1>Customer Demograhics Data Product</h1></header><br>This customer data table contains the data for customer demographics of all Bank of Mars retail banking customers. It contains PII information that can be accessed on \"need-to-know\" basis. <br> Customer data is the information that customers give us while interacting with our business through websites, applications, surveys, social media, marketing initiatives, and other online and offline channels. A good business plan depends on customer data. Data-driven businesses recognize the significance of this and take steps to guarantee that they gather the client data points required to enhance client experience and fine-tune business strategy over time. \"}}"