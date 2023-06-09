/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

####################################################################################
# Variables
####################################################################################
variable "project_id" {}
variable "location" {}
variable "dataplex_process_bucket_name" {}
variable "dataplex_bqtemp_bucket_name" {}



resource "google_storage_bucket" "storage_bucket_process" {
  project                     = var.project_id
  name                        = var.dataplex_process_bucket_name
  location                    = var.location
  force_destroy               = true
  uniform_bucket_level_access = true


}

resource "google_storage_bucket" "storage_bucket_bqtemp" {
  project                     = var.project_id
  name                        = var.dataplex_bqtemp_bucket_name
  location                    = var.location
  force_destroy               = true
  uniform_bucket_level_access = true

  depends_on = [google_storage_bucket.storage_bucket_process]
}


resource "null_resource" "setup_code" {
  provisioner "local-exec" {
    command = <<-EOT
      cd ./resources/
      java -cp common/tagmanager-1.0-SNAPSHOT.jar  com.google.cloud.dataplex.setup.CreateTagTemplates ${var.project_id} ${var.location} data_product_information
      java -cp common/tagmanager-1.0-SNAPSHOT.jar  com.google.cloud.dataplex.setup.CreateTagTemplates ${var.project_id} ${var.location} data_product_classification
      java -cp common/tagmanager-1.0-SNAPSHOT.jar  com.google.cloud.dataplex.setup.CreateTagTemplates ${var.project_id} ${var.location} data_product_quality
      java -cp common/tagmanager-1.0-SNAPSHOT.jar  com.google.cloud.dataplex.setup.CreateTagTemplates ${var.project_id} ${var.location} data_product_exchange
      java -cp common/tagmanager-1.0-SNAPSHOT.jar  com.google.cloud.dataplex.setup.CreateDLPInspectionTemplate ${var.project_id} global marsbank_dlp_template
      sed -i s/_project_datagov_/${var.project_id}/g code/customer-source-configs/dq_customer_data_product.yaml
      sed -i s/_project_datagov_/${var.project_id}/g code/customer-source-configs/dq_customer_gcs_data.yaml
      sed -i s/_project_datagov_/${var.project_id}/g code/customer-source-configs/dq_tokenized_customer_data_product.yaml
      sed -i s/_project_datagov_/${var.project_id}/g code/customer-source-configs/data-product-classification-tag-auto.yaml
      sed -i s/_project_datagov_/${var.project_id}/g code/customer-source-configs/data-product-quality-tag-auto.yaml
      sed -i s/_region_/${var.location}/g code/customer-source-configs/dq_customer_data_product.yaml
      sed -i s/_region_/${var.location}/g code/customer-source-configs/dq_customer_gcs_data.yaml
      sed -i s/_region_/${var.location}/g code/customer-source-configs/dq_tokenized_customer_data_product.yaml
      gsutil -m cp -r * gs://${var.dataplex_process_bucket_name}
    EOT
    }
    depends_on = [
                  google_storage_bucket.storage_bucket_process,
                  google_storage_bucket.storage_bucket_bqtemp]

  }