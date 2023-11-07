terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {}


provider "databricks" {
  host  = "${var.hostname}"
  token ="${var.token}"
 
}



resource "databricks_job" "datascience_features_store_job" {

  name       = "datascience_features_store_job"

  

  email_notifications {
    on_start =["spindi@petsmart.com"]
    on_success =["spindi@petsmart.com"]
    on_failure =["spindi@petsmart.com"] 
  }
  schedule {
    quartz_cron_expression = "6 2 12 * * ?"
    timezone_id = "UTC"
    pause_status = "PAUSED"
  }
  max_concurrent_runs=1
  

job_cluster {

    job_cluster_key ="datascience_cluster"

    new_cluster {

      autoscale {

        min_workers = 0

        max_workers = 0

      }

      driver_node_type_id = "i3.xlarge"

      node_type_id = "i3.xlarge"

      spark_version = "14.1.x-cpu-ml-scala2.12"

      

 

      spark_conf = {

                    "spark.databricks.cluster.profile singleNode" = "true"
                    "spark.sql.hive.metastore.jars" = "maven"
                    "spark.sql.hive.metastore.version" = "3.1.0"
                    "spark.hadoop.javax.jdo.option.ConnectionDriverName":"org.mariadb.jdbc.Driver"
                    "spark.databricks.delta.preview.enabled":"True"

      }
    }
  }


task {
    task_key = "merch_hierarchy"
    run_if = "ALL_SUCCESS"
    job_cluster_key ="datascience_cluster"


    notebook_task {
      notebook_path = "/Shared/poc_terra"
    
    }
  } 


} 
resource "databricks_job" "universe" {

  name       = "universe"

  

  email_notifications {
    on_start =["spindi@petsmart.com"]
    on_success =["spindi@petsmart.com"]
    on_failure =["spindi@petsmart.com"] 
  }
 
  max_concurrent_runs=1
  

job_cluster {

    job_cluster_key ="universe_cluster"

    new_cluster {

      autoscale {

        min_workers = 0

        max_workers = 0

      }

      driver_node_type_id = "i3.xlarge"

      node_type_id = "i3.xlarge"

      spark_version = "14.1.x-cpu-ml-scala2.12"

      

 

      spark_conf = {

                    "spark.databricks.cluster.profile singleNode" = "true"
                    "spark.sql.hive.metastore.jars" = "maven"
                    "spark.sql.hive.metastore.version" = "3.1.0"
                    "spark.hadoop.javax.jdo.option.ConnectionDriverName":"org.mariadb.jdbc.Driver"
                    "spark.databricks.delta.preview.enabled":"True"

      }
    }
  }



  
  task {
    task_key = "universe"
    run_if = "ALL_SUCCESS"
    job_cluster_key ="universe_cluster"


    notebook_task {
      notebook_path = "/Shared/poc_terra"
    
    }
  }
  
}
resource "null_resource" "job_2_dependency" {
  triggers = {
    job1_id = databricks_job.datascience_features_store_job.id
  }
  depends_on = [databricks_job.datascience_features_store_job]
}   

