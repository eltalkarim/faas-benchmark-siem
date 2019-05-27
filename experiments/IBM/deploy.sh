#!/bin/bash
#change params here:
IBM_API=https://eu-de.functions.cloud.ibm.com/api/v1/web/faas-benchmark_faas-benchmark-space/hello_world_package/hello_world.json
REGION=eu-de
ORG=faas-benchmark
SPACE=faas-benchmark-space
### end of params

#regex expression for response extraction
STATUS_CODE_REGEX="\"statusCode\": \"([^\"]*)\""
VM_ID_REGEX="\"vm_id\": \"([^\"]*)\""
BOOT_TIME_REGEX="\"boot_time\": \"([^\"]*)\""
MEMORY_REGEX="\"memory\": \"([^\"]*)\""
TIMEOUT_REGEX="\"timeout\": \"([^\"]*)\""
#end regex expression

rm -f IBM/Results/ibm-*.csv
rm -f IBM/Function/jmeter.log
cd IBM/Function
ibmcloud target -r ${REGION} -o ${ORG} -s ${SPACE}

#code change
ibmcloud fn undeploy --manifest manifest512mb.yml
rm -f index.js
cp index_v1.js index.js
ibmcloud fn deploy --manifest manifest512mb.yml

/usr/bin/jmeter -n -t ../../Load_Generator/load-generator.jmx -l ../Results/ibm-results-code.csv -Jurl=${IBM_API} \
-Jstatus_code_regex="${STATUS_CODE_REGEX}" -Jboot_time_regex="${BOOT_TIME_REGEX}" -Jvm_id_regex="${VM_ID_REGEX}" \
-Jmemory_regex="${MEMORY_REGEX}" -Jtimeout_regex="${TIMEOUT_REGEX}" &

sleep 30
rm -f jmeter.log
rm -f index.js
cp index_v2.js index.js
ibmcloud fn deploy --manifest manifest512mb.yml
wait
#config change
ibmcloud fn undeploy --manifest manifest512mb.yml
rm -f jmeter.log
rm -f index.js
cp index_v1.js index.js
ibmcloud fn deploy --manifest manifest512mb.yml
/usr/bin/jmeter -n -t ../../Load_Generator/load-generator.jmx -l ../Results/ibm-results-config.csv -Jurl=${IBM_API} \
-Jstatus_code_regex="${STATUS_CODE_REGEX}" -Jboot_time_regex="${BOOT_TIME_REGEX}" -Jvm_id_regex="${VM_ID_REGEX}" \
-Jmemory_regex="${MEMORY_REGEX}" -Jtimeout_regex="${TIMEOUT_REGEX}" &

sleep 30
ibmcloud fn deploy --manifest manifest128mb.yml
wait
ibmcloud fn undeploy --manifest manifest128mb.yml

