#!/bin/bash
#change params here:
AWS_API=https://le74edrz1e.execute-api.eu-central-1.amazonaws.com/dev/invoke
TRIGGER=arn:aws:execute-api:eu-central-1:562730218312:le74edrz1e/*/GET/invoke
REGION=eu-central-1
FUNCTION_NAME=faas-benchmark-aws
ROLE=arn:aws:iam::562730218312:role/service-role/faas-benchmark-role
### end of params

#regex expression for response extraction
STATUS_CODE_REGEX="\"statusCode\":\"([^\"]*)\""
VM_ID_REGEX="\"vm_id\":\"([^\"]*)\""
BOOT_TIME_REGEX="\"boot_time\":\"([^\"]*)\""
MEMORY_REGEX="\"memory\":\"([^\"]*)\""
TIMEOUT_REGEX="\"timeout\":\"([^\"]*)\""
#end regex expression

rm -f AWS/Results/aws-results-*.csv
cd AWS/Function


function createLambda() {
rm -f index.js
rm -f function.zip
cp ./index_v1.js index.js
zip function.zip index.js

aws lambda create-function \
--runtime nodejs8.10 \
--timeout 300 \
--memory-size 512 \
--function-name ${FUNCTION_NAME} \
--role ${ROLE} \
--handler index.handler \
--region ${REGION} \
--zip-file fileb://function.zip

#https://docs.aws.amazon.com/cli/latest/reference/lambda/add-permission.html
aws lambda add-permission \
--function-name ${FUNCTION_NAME} \
--statement-id apigateway-karim-test-2 \
--action lambda:InvokeFunction \
--principal apigateway.amazonaws.com \
--source-arn  ${TRIGGER} \
--region ${REGION}
 }


#code change
aws lambda delete-function --function-name ${FUNCTION_NAME} --region ${REGION} || true

createLambda
rm -f index.js
rm -f function.zip
cp ./index_v2.js index.js
zip function.zip index.js

/usr/bin/jmeter -n -t ../../Load_Generator/load-generator.jmx -l ../Results/aws-results-code.csv -Jurl=${AWS_API} \
-Jstatus_code_regex="${STATUS_CODE_REGEX}" -Jboot_time_regex="${BOOT_TIME_REGEX}" -Jvm_id_regex="${VM_ID_REGEX}" \
-Jmemory_regex="${MEMORY_REGEX}" -Jtimeout_regex="${TIMEOUT_REGEX}" &

sleep 30

aws lambda update-function-code \
--function-name ${FUNCTION_NAME} \
--region ${REGION} \
--zip-file fileb://function.zip

wait
#config change
aws lambda delete-function --function-name ${FUNCTION_NAME} --region ${REGION} || true

createLambda

/usr/bin/jmeter -n -t ../../Load_Generator/load-generator.jmx -l ../Results/aws-results-config.csv -Jurl=${AWS_API} \
-Jstatus_code_regex="${STATUS_CODE_REGEX}" -Jboot_time_regex="${BOOT_TIME_REGEX}" -Jvm_id_regex="${VM_ID_REGEX}" \
-Jmemory_regex="${MEMORY_REGEX}" -Jtimeout_regex="${TIMEOUT_REGEX}" &
sleep 30

aws lambda update-function-configuration \
--function-name ${FUNCTION_NAME} \
--region ${REGION} \
--timeout 30 \
--memory-size 128 \

wait

aws lambda delete-function --function-name ${FUNCTION_NAME} --region ${REGION}