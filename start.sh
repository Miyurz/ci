#!/usr/bin/env bash


container="jenkins"
jenkins_port=8080
url="http://localhost:${jenkins_port}"

docker rm -f jenkins || echo true

#To do: what is port 50000 for ?
docker run --name ${container} -d -p 8080:8080 -p 50000:50000 jenkins

status_code=0
while [ "${status_code}" -ne 403 ]; do
    status_code=$(curl -o /dev/null --silent --head --write-out '%{http_code}\n' ${url})
    #echo status code = "${status_code}"
done

echo status_code = $status_code 

pass=$(docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword | sed 's/\r$//' )

echo password=${pass}

ret_code=1
while [ "${ret_code}" -ne 0 ]; do
    java -jar ./jenkins-cli.jar -s "${url}" -auth admin:${pass} 2> /dev/null 1> test
    ret_code=$?
    echo return code = $ret_code
done
