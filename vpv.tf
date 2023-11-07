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
  host  = var.hostname
  token =  var.token
 
}



resource "databricks_job" "datascience_rfmt_clr_scoring" {

  name       = "datascience_rfmt_clr_scoring"

  

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

    job_cluster_key ="datascience_scoring"

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
    task_key = "RFMT_CLV_model_scoring"
    run_if = "ALL_SUCCESS"
    job_cluster_key ="datascience_cluster"


    notebook_task {
      notebook_path = "/Shared/poc_terra"
    
    }
  } 


} 
resource "databricks_job" "datascience_core_mllib_clv" {

  name       = "datascience_core_mllib_clv"

  

  email_notifications {
    on_start =["spindi@petsmart.com"]
    on_success =["spindi@petsmart.com"]
    on_failure =["spindi@petsmart.com"] 
  }
 
  max_concurrent_runs=1
  

job_cluster {

    job_cluster_key ="datascience_clv_score_mllib"

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
    task_key = "score_clv_mllib"
    run_if = "ALL_SUCCESS"
    job_cluster_key ="datascience_clv_score_mllib"


    notebook_task {
      notebook_path = "/Shared/poc_terra"
    
    }
  }
  
}

resource "databricks_job" "datascience_customer_360_job" {

  name       = "datascience_customer_360_job"

  

  email_notifications {
    on_start =["spindi@petsmart.com"]
    on_success =["spindi@petsmart.com"]
    on_failure =["spindi@petsmart.com"] 
  }
 
  max_concurrent_runs=1
  

job_cluster {

    job_cluster_key ="datascience_360_job_cluster"

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
    task_key = "customer_360_current"
    run_if = "ALL_SUCCESS"
    job_cluster_key ="datascience_360_job_cluster"


    notebook_task {
      notebook_path = "/Shared/poc_terra"
    
    }
  }
  task {
    task_key = "customer_360_history"
    depends_on {
      task_key = "customer_360_current"
    }
    run_if = "ALL_SUCCESS"
    job_cluster_key ="datascience_360_job_cluster"


    notebook_task {
      notebook_path = "/Shared/poc_terra"
    
    }
  }
  task {
    task_key = "write_to_snowflake"
    depends_on {
      task_key = "customer_360_current"
    }
    run_if = "ALL_SUCCESS"
    job_cluster_key ="datascience_360_job_cluster"


    notebook_task {
      notebook_path = "/Shared/poc_terra"
    
    }
  }
  task {
    task_key = "write_to_sf_history"
    depends_on {
      task_key = "customer_360_history"
    }
    run_if = "ALL_SUCCESS"
    job_cluster_key ="datascience_360_job_cluster"


    notebook_task {
      notebook_path = "/Shared/poc_terra"
    
    }
  }
  
}

