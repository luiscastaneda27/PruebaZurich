#!/bin/bash
echo "Branch Origen: $BITBUCKET_BRANCH Branch Destino: $BITBUCKET_PR_DESTINATION_BRANCH"
if [ "${BITBUCKET_PR_DESTINATION_BRANCH}" = "INTEG_2" ]; then
  echo ${INTEG_CI_SFDX_URL_2} > env.sfdx
  sfdx force:auth:sfdxurl:store -d -a ${INTEG_CI_SFDX_URL_2} -f env.sfdx
  rm -rf env.sfdx
  sfdx force:source:deploy -c -x releases/package.xml --targetusername ${INTEG_CI_SFDX_URL_2} --verbose
elif [ "${BITBUCKET_PR_DESTINATION_BRANCH}" = "QA_2" ]; then
  echo ${QA_SFDX_URL_2} > env.sfdx               
  sfdx force:auth:sfdxurl:store -d -a ${QA_SFDX_URL_2} -f env.sfdx
  rm -rf env.sfdx
  sfdx force:source:deploy -c -x releases/package.xml --targetusername ${QA_SFDX_URL_2} --verbose
elif [ "${BITBUCKET_PR_DESTINATION_BRANCH}" = "UAT_2" ]; then               
  echo ${UAT_SFDX_URL_2} > env.sfdx
  sfdx force:auth:sfdxurl:store -d -a ${UAT_SFDX_URL_2} -f env.sfdx
  rm -rf env.sfdx
  sfdx force:source:deploy -c -x releases/package.xml --targetusername ${UAT_SFDX_URL_2} --verbose
elif [ "${BITBUCKET_PR_DESTINATION_BRANCH}" = "INTEG_GLB" ]; then               
  echo ${INTEG_GLB_SFDX_URL} > env.sfdx
  sfdx force:auth:sfdxurl:store -d -a ${INTEG_GLB_SFDX_URL} -f env.sfdx
  rm -rf env.sfdx
  sfdx force:source:deploy -c -x releases/package.xml --targetusername ${INTEG_GLB_SFDX_URL} --verbose
elif [ "${BITBUCKET_PR_DESTINATION_BRANCH}" = "UAT_Z" ]; then               
  echo ${UAT_Z_SFDX_URL} > env.sfdx
  sfdx force:auth:sfdxurl:store -d -a ${UAT_Z_SFDX_URL} -f env.sfdx
  rm -rf env.sfdx
  sfdx force:source:deploy -c -x releases/package.xml --targetusername ${UAT_Z_SFDX_URL} --verbose
elif [ "${BITBUCKET_PR_DESTINATION_BRANCH}" = "master" ]; then               
  echo ${MASTER_SFDX_URL} > env.sfdx
  sfdx force:auth:sfdxurl:store -d -a ${MASTER_SFDX_URL} -f env.sfdx
  rm -rf env.sfdx
  sfdx force:source:deploy -c -x releases/package.xml --targetusername ${MASTER_SFDX_URL} --verbose
fi