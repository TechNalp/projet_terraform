project_id = 
region  = 
zone    = 

private_key_location = 
access_token_target_service_account = 
docker_registry_address = 

path_to_manifests = "../src/k8s-manifests"
pvc_manifest = [ "db-data-pvc.yaml" ]
deployment_manifests = ["pgsql-deployment.yaml","redis-deployment.yaml","worker-deployment.yaml","result-deployment.yaml","vote-deployment.yaml"]
service_manifests = ["pgsql-service.yaml", "redis-service.yaml", "result-service.yaml", "vote-service.yaml"]
job_manifests = ["seed-job.yaml"]
