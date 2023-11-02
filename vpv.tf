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
  host  = "https://dbc-a08a98d4-658e.cloud.databricks.com/.cloud.databricks.com"

  token = "dapie8ebcd3fe10b28cc825ae00b54c1f625"
 
}

resource "databricks_job" "create_acxiom_views" {  

  token = "dapie73b2f894b4867fef3713a4647b9bf20"

}

resource "databricks_job" "create_multiple_task" {

  name       = "terraform_jobbbbbb"

  

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

    job_cluster_key ="j_cluster"

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
    task_key = "test_terra_task"
    run_if = "ALL_SUCCESS"
    job_cluster_key ="j_cluster"


    notebook_task {
      notebook_path = "/Shared/poc_terra"
    
    }
  } 


  
  task {
    task_key = "test_terra_task_2"
     depends_on {
      task_key = "test_terra_task"
    }

    job_cluster_key = "j_cluster"

    notebook_task {
       notebook_path = "/Shared/poc_terra"
    }
  } 
}  

