#!/bin/bash
#change params here:
GCLOUD_API=https://europe-west1-durable-return-228514.cloudfunctions.net/faas-benchmark-gcloud
REGION=europe-west1
FUNCTION_NAME=faas-benchmark-gcloud
### end of params

#regex expression for response extraction
STATUS_CODE_REGEX="\"statusCode\":\"([^\"]*)\""
VM_ID_REGEX="\"vm_id\":\"([^\"]*)\""
BOOT_TIME_REGEX="\"boot_time\":\"([^\"]*)\""
MEMORY_REGEX="\"memory\":\"([^\"]*)\""
TIMEOUT_REGEX="\"timeout\":\"([^\"]*)\""
#end regex expression

rm -f Google/Results/gcloud-results-*.csv
cd Google/Function

#code change
gcloud functions delete ${FUNCTION_NAME} --region ${REGION} -q || true
rm -f index.js
cp index_v1.js index.js

gcloud functions deploy ${FUNCTION_NAME} \
--entry-point handler \
--trigger-http \
--timeout 300 \
--memory 512 \
--runtime nodejs8 \
--region ${REGION}

rm -f index.js
cp index_v2.js index.js

/usr/bin/jmeter -n -t ../../Load_Generator/load-generator.jmx -l ../Results/gcloud-results-code.csv -Jurl=${GCLOUD_API} \
-Jstatus_code_regex="${STATUS_CODE_REGEX}" -Jboot_time_regex="${BOOT_TIME_REGEX}" -Jvm_id_regex="${VM_ID_REGEX}" \
-Jmemory_regex="${MEMORY_REGEX}" -Jtimeout_regex="${TIMEOUT_REGEX}" &

sleep 30

gcloud functions deploy ${FUNCTION_NAME} \
--entry-point handler \
--trigger-http \
--timeout 300 \
--memory 512 \
--runtime nodejs8 \
--region ${REGION}

wait
#config change
gcloud functions delete ${FUNCTION_NAME} --region ${REGION} -q

rm -f index.js
cp index_v1.js index.js
gcloud functions deploy ${FUNCTION_NAME} \
--entry-point handler \
--trigger-http \
--timeout 300 \
--memory 512 \
--runtime nodejs8 \
--region ${REGION}

/usr/bin/jmeter -n -t ../../Load_Generator/load-generator.jmx -l ../Results/gcloud-results-config.csv -Jurl=${GCLOUD_API} \
-Jstatus_code_regex="${STATUS_CODE_REGEX}" -Jboot_time_regex="${BOOT_TIME_REGEX}" -Jvm_id_regex="${VM_ID_REGEX}" \
-Jmemory_regex="${MEMORY_REGEX}" -Jtimeout_regex="${TIMEOUT_REGEX}" &

sleep 30

gcloud functions deploy ${FUNCTION_NAME} \
--entry-point handler \
--trigger-http \
--timeout 30 \
--memory 128 \
--runtime nodejs8 \
--region ${REGION}

wait
gcloud functions delete ${FUNCTION_NAME} --region ${REGION} -q


