#!/bin/bash

# A script to configure UCP Org Structure

ucpurl='https://ucp.olly.dtcntr.net/'

adminusr=admin
adminpw="&0C2Ybb7P$&@a#1U"

org=fakeco
tm1=dev
tm1usr1=dave
tm2=ops
tm2usr1=oscar


# Login
echo "Grab Login Tokin"

token=$(curl -X POST "'"${ucpurl}"'/id/login" \
    -H "accept: application/json" \
    -H "content-type: application/json" \
    -d '{"username": "'"$adminusr"'", "password": "'$adminpw'"}')
#    | jq '.sessionToken')

echo "my token is '${token}'" 

# Create Org

#echo "Create a New Org"
#curl -X POST "'${ucpurl}"'/accounts/" \
#    -H  "accept: application/json" \
#    -H  "Authorization: Bearer ${token}" \
#    -H  "content-type: application/json" -d \
#    '{
#      "name": "'"$org"'",
#      "isOrg": true
#     }'
#
## Dev Team     
#
#echo "Create a Dev Team"
#curl -X POST "${ucpurl}/accounts/${org}/teams" \
#    -H  "accept: application/json" \
#    -H  "Authorization: Bearer ${token}" \
#    -H  "content-type: application/json" -d \
#    '{
#      "name": "'"${tm1}"'"
#     }'
#
#echo "Create a Dev User"
#curl -X POST "${ucpurl}/accounts/" \
#    -H  "accept: application/json" \
#    -H  "Authorization: Bearer ${token}" \
#    -H  "content-type: application/json" -d \
#    '{
#      "name": "'"${tm1usr1}"'",
#      "password": "password"
#     }'
#
#echo "Put Dev User in Org"
#curl -X PUT "${ucpurl}/accounts/${org}/members/${tm1usr1}" \
#    -H  "accept: application/json" \
#    -H  "Authorization: Bearer ${token}" \
#    -H  "content-type: application/json" -d \
#    '{
#      "isAdmin": false
#     }'
#
#echo "Put Dev User in Dev Team"
#curl -X PUT "${ucpurl}/accounts/${org}/teams/${tm1}/members/${tm1usr1}" \
#    -H  "accept: application/json" \
#    -H  "Authorization: Bearer ${token}" \
#    -H  "content-type: application/json" -d \
#    '{
#      "isAdmin": false
#     }'
#
## Ops Team
#
#echo "Create a Dev Team"
#curl -X POST "${ucpurl}/accounts/${org}/teams" \
#    -H  "accept: application/json" \
#    -H  "Authorization: Bearer ${token}" \
#    -H  "content-type: application/json" -d \
#    '{
#      "name": "'"${tm2}"'"
#     }'
#
#echo "Create a Ops User"
#curl -X POST "${ucpurl}/accounts/" \
#    -H  "accept: application/json" \
#    -H  "Authorization: Bearer ${token}" \
#    -H  "content-type: application/json" -d \
#    '{
#      "name": "'"${tm2usr1}"'",
#      "password": "password"
#     }'
#
#echo "Put Ops User in Org"
#curl -X PUT "${ucpurl}/accounts/${org}/members/${tm2usr1}" \
#    -H  "accept: application/json" \
#    -H  "Authorization: Bearer ${token}" \
#    -H  "content-type: application/json" -d \
#    '{
#      "isAdmin": false
#     }'
#
#echo "Put Ops User in Ops Team"
#curl -X PUT "${ucpurl}/accounts/${org}/teams/${tm2}/members/${tm2usr1}" \
#    -H  "accept: application/json" \
#    -H  "Authorization: Bearer ${token}" \
#    -H  "content-type: application/json" -d \
#    '{
#      "isAdmin": false
#     }'
