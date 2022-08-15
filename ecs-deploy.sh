#!/bin/bash
REGION="us-east-1"
BUCKET=""
STACKNAME="ecs"
#EXIT=0
if [ "${BUCKET}" == "" ] ; then
    TMP_BUCKET="ecs-tmp-$(LC_CTYPE=C tr -dc 'a-z0-9' </dev/urandom | fold -w 16 | head -n 1)"
    aws s3 mb s3://${TMP_BUCKET} --region ${REGION} 
    cat <<EOF > ./policy.json
{
   "Statement": [
      {
         "Effect": "Allow",
         "Principal": {"Service": "cloudformation.amazonaws.com"},
         "Action": ["s3:GetObject", "s3:ListBucket"],
         "Resource": ["arn:aws:s3:::${TMP_BUCKET}", "arn:aws:s3:::${TMP_BUCKET}/*"]
      }
   ]
}
EOF
    aws s3api put-bucket-policy --bucket ${TMP_BUCKET} --policy file://./policy.json --region ${REGION} || EXIT=$?
    BUCKET=${TMP_BUCKET}
fi
aws cloudformation package --template-file ecs.yaml \
  --s3-bucket ${BUCKET} \
  --output-template-file ecs-packaged.yaml
# wait
while [ ! -f "./ecs-packaged.yaml" ] ; do
  echo "..."
done     
aws cloudformation deploy --template-file ./ecs-packaged.yaml --stack-name ${STACKNAME} --region ${REGION} --capabilities CAPABILITY_IAM 
#> /dev/null &
#--parameter-overrides Key1=Value1 Key2=Value2 --tags Key1=Value1 Key2=Value2
# wait 5
# while [ 1 ]   # Endless loop.
# do
#     stack_Status=$(aws --output text --query "Stacks[0].StackStatus" cloudformation describe-stacks \
#                         --stack-name ${STACKNAME})
#     echo "Stack Status: $stack_Status"
#     if [[ $stack_Status == "CREATE_COMPLETE" || $stack_Status == "UPDATE_COMPLETE"  ]]; then
#         echo "Exiting stack status: $stack_Status"
#         exit 0
#     elif [[ $stack_Status == "CREATE_FAILED" || $stack_Status == "ROLLBACK_IN_PROGRESS" || $stack_Status == "ROLLBACK_COMPLETE" || $stack_Status == "UPDATE_ROLLBACK_COMPLETE" || $stack_Status == "DELETE_IN_PROGRESS" ]]; then
#         echo "Exiting stack status: $stack_Status"
#         exit 1
#     fi
#     sleep 1
# done    
aws s3 rb s3://${BUCKET} --force  
rm -f ./policy.json