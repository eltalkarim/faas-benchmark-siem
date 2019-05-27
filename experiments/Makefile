.DEFAULT_GOAL := benchmark_all


benchmark_aws:
	echo 'Benchmarking AWS Lambda'
	./AWS/deploy.sh

benchmark_gcloud:
	echo 'Benchmarking Gcloud Functions'
	./Google/deploy.sh

benchmark_ibm:
	echo 'Benchmarking IBM Cloud Functions'
	./IBM/deploy.sh

benchmark_azure:
	echo 'Benchmarking Azure Cloud Functions'
	./Azure/deploy.sh


benchmark_all: benchmark_aws benchmark_gcloud benchmark_ibm benchmark_azure
	echo 'Done Benchmarking'