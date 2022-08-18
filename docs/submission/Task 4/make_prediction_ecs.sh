#!/usr/bin/env bash

PORT=80
ELB="ECSALB-1307862323.us-east-1.elb.amazonaws.com"
EXPECTED="20.35373177134412"
#echo "Port: $PORT"

 GREEN='\033[0;32m'       
 RED='\033[0;31m'        
 NC='\033[0m' 
print_prediction () {
 echo "EXPECTED: ${EXPECTED}  ACTUAL: ${ACTUAL}"
 if [ $1 == $2 ]; then
   printf "TEST: ${GREEN}PASSED${NC}\n"
 else
   printf "TEST: ${RED}FAILED${NC}\n"
 fi
}
test_prediction () {
echo "Testing App prediction service via elastic load balancer port: $PORT"
echo "AWS ECS : $ELB"
if test -n "$1"; then
 ACTUAL=$(grep -oh "$1")
 print_prediction $ACTUAL $EXPECTED
elif test ! -t 0; then
 read ACTUAL; 
 print_prediction $ACTUAL $EXPECTED
fi
}
# POST method predict
curl -d '{  
   "CHAS":{  
      "0":0
   },
   "RM":{  
      "0":6.575
   },
   "TAX":{  
      "0":296.0
   },
   "PTRATIO":{  
      "0":15.3
   },
   "B":{  
      "0":396.9
   },
   "LSTAT":{  
      "0":4.98
   }
}'\
     -H "Content-Type: application/json" \
     -X POST ${ELB}:${PORT}/predict \
| jq -r ."prediction[]" | test_prediction
