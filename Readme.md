# SIEM: An Experiment-Based Method for Evaluating Qualities of Operational Tasks in Serverless Infrastructure

### Prerequisites 

1) Make sure to install CLI for AWS, IBM, GCloud and Azure.

2) Install make by running `sudo apt-get install  make`

3) Install Node.JS

    `sudo apt-get update`
   
    `sudo apt-get install nodejs`

4) Use node.js 8 `nvm use 8`

5) Install JMeter under usr/bin and the following line to your /usr/share/jmeter/user.properties file:
 
    `sample_variables=statusCode,vm_id,boot_time`
    
6) Change the variables in the deploy.sh files according to your setup  
 
 
### Run Benchmark
 
run `make benchmark-all`
 
happy benchmarking!
