#!/bin/bash

# A script to configure UCP Org Structure

ucpurl='ucp.olly.dtcntr.net'

adminusr=admin
adminpw="hello"

org=fakeco
tm1=dev
tm1usr1=dave
tm2=ops
tm2usr1=oscar

# Create Org

echo "Create a New Org"
curl -skX POST "https://"${ucpurl}"/accounts/" \
    --user ${adminusr}:${adminpw} \
    -H  "accept: application/json" \
    -H  "content-type: application/json" -d \
    '{
      "name": "'"$org"'",
      "isOrg": true
     }'

# Dev Team     

echo "Create a Dev Team"
curl -skX POST "https://"${ucpurl}"/accounts/${org}/teams" \
    --user ${adminusr}:${adminpw} \
    -H  "accept: application/json" \
    -H  "content-type: application/json" -d \
    '{
      "name": "'${tm1}'"
    }'

echo "Create a Dev User"
curl -skX POST "https://"${ucpurl}"/accounts/" \
    --user ${adminusr}:${adminpw} \
    -H  "accept: application/json" \
    -H  "content-type: application/json" -d \
    '{
      "name": "'"${tm1usr1}"'",
      "password": "password"
     }'

echo "Put Dev User in Org"
curl -skX PUT "https://"${ucpurl}"/accounts/${org}/members/${tm1usr1}" \
    --user ${adminusr}:${adminpw} \
    -H  "accept: application/json" \
    -H  "content-type: application/json" -d \
    '{
      "isAdmin": false
     }'

echo "Put Dev User in Dev Team"
curl -skX PUT "https://"${ucpurl}"/accounts/${org}/teams/${tm1}/members/${tm1usr1}" \
    --user ${adminusr}:${adminpw} \
    -H  "accept: application/json" \
    -H  "content-type: application/json" -d \
    '{
      "isAdmin": false
     }'

# Ops Team

echo "Create a Dev Team"
curl -skX POST "https://"${ucpurl}"/accounts/${org}/teams" \
    --user ${adminusr}:${adminpw} \
    -H  "accept: application/json" \
    -H  "content-type: application/json" -d \
    '{
      "name": "'"${tm2}"'"
     }'

echo "Create a Ops User"
curl -skX POST "https://"${ucpurl}"/accounts/" \
    --user ${adminusr}:${adminpw} \
    -H  "accept: application/json" \
    -H  "content-type: application/json" -d \
    '{
      "name": "'"${tm2usr1}"'",
      "password": "password"
     }'

echo "Put Ops User in Org"
curl -skX PUT "https://"${ucpurl}"/accounts/${org}/members/${tm2usr1}" \
    --user ${adminusr}:${adminpw} \
    -H  "accept: application/json" \
    -H  "content-type: application/json" -d \
    '{
      "isAdmin": false
     }'

echo "Put Ops User in Ops Team"
curl -skX PUT "https://"${ucpurl}"/accounts/${org}/teams/${tm2}/members/${tm2usr1}" \
    --user ${adminusr}:${adminpw} \
    -H  "accept: application/json" \
    -H  "content-type: application/json" -d \
    '{
      "isAdmin": false
     }'
