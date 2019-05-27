#!/bin/bash
#change params here:
AZURE_API_LINUX=https://faas-benchmark-azure-linux.azurewebsites.net/api/myhttptrigger
AZURE_API_WINDOWS=https://faas-benchmark-azure-windows.azurewebsites.net/api/myhttptrigger
RESOURCE_GROUP=faas-benchmarkresgroup
STORAGE=faasbenchmark
PLAN=faas-benchmarkplan
REGION=westeurope
FUNCTION_NAME=faas-benchmark-azure
### end of params
rm -f Azure/Results/azure-*.csv
cd Azure/Function/

#regex expression for response extraction
STATUS_CODE_REGEX="\"statusCode\": \"([^\"]*)\""
VM_ID_REGEX="\"vm_id\": \"\\\\\"([^\\\\]*)\\\\\""
BOOT_TIME_REGEX="\"boot_time\": \"([^\"]*)\""
#end regex expression

##linux
rm -f MyHttpTrigger/index.js
cp index_v1.js MyHttpTrigger/index.js
echo "creating ${FUNCTION_NAME}-linux function on linux"
az group create --name "${RESOURCE_GROUP}" --location "${REGION}"
az storage account create --name "${STORAGE}" --location "${REGION}" --resource-group "${RESOURCE_GROUP}" --sku Standard_LRS
az appservice plan create --name "${PLAN}" --resource-group "${RESOURCE_GROUP}" --sku B1 --is-linux
az functionapp create --resource-group "${RESOURCE_GROUP}" --consumption-plan-location westus --os-type Linux --name "${FUNCTION_NAME}"-linux --storage-account "${STORAGE}" --runtime node
echo 'function created'
func azure functionapp publish "${FUNCTION_NAME}"-linux
rm -f MyHttpTrigger/index.js
cp index_v2.js MyHttpTrigger/index.js
/usr/bin/jmeter -n -t ../../Load_Generator/load-generator.jmx -l ../Results/azure-linux-results-code.csv -Jurl=${AZURE_API_LINUX} -Jduration=180 \
-Jstatus_code_regex="${STATUS_CODE_REGEX}" -Jboot_time_regex="${BOOT_TIME_REGEX}" -Jvm_id_regex="${VM_ID_REGEX}" &
sleep 30
func azure functionapp publish "${FUNCTION_NAME}"-linux
wait

#windows
rm -f MyHttpTrigger/index.js
cp index_v1_windows.js MyHttpTrigger/index.js
echo 'deleting resource group this might take some time'
az group delete --name "${RESOURCE_GROUP}" --yes
echo 'creating faas-benchmark-azure function on windows'
az group create --name "${RESOURCE_GROUP}" --location "${REGION}"
az storage account create --name "${STORAGE}" --location "${REGION}" --resource-group "${RESOURCE_GROUP}" --sku Standard_LRS
az functionapp create --resource-group "${RESOURCE_GROUP}" --consumption-plan-location "${REGION}" --os-type Windows --name "${FUNCTION_NAME}"-windows --storage-account "${STORAGE}" --runtime node
echo 'function created'
func azure functionapp publish "${FUNCTION_NAME}"-windows
rm -f MyHttpTrigger/index.js
cp index_v2_windows.js MyHttpTrigger/index.js
/usr/bin/jmeter -n -t ../../Load_Generator/load-generator.jmx -l ../Results/azure-windows-results-code.csv -Jurl=${AZURE_API_WINDOWS}  \
-Jstatus_code_regex="${STATUS_CODE_REGEX}" -Jboot_time_regex="${BOOT_TIME_REGEX}" -Jvm_id_regex="${VM_ID_REGEX}" &
sleep 30
func azure functionapp publish "${FUNCTION_NAME}"-windows
wait
az group delete --name "${RESOURCE_GROUP}" --yes