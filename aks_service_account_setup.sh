#!/bin/bash

SUBSCRIPTION_NAME_OR_ID="{subscription Name or ID}"
RESOURCE_GROUP_NAME="{resource group name}"
AKS_NAME="{AKS name}"
SERVICE_ACCOUNT_NAME="{service account name}"
NAMESPACE_NAME="{namespace name}"
SECRET_NAME="ado-sc-sa-secret"

az account set -s $SUBSCRIPTION_NAME_OR_ID
az aks get-credentials --resource-group $RESOURCE_GROUP_NAME --name $AKS_NAME

kubectl create serviceaccount $SERVICE_ACCOUNT_NAME -n $NAMESPACE_NAME

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: ado-sc-sa-role
  namespace: $NAMESPACE_NAME
rules:
- apiGroups: ["*","apps","extensions"]
  resources: ["*"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
EOF

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ado-sc-sa-rolebinding
  namespace: $NAMESPACE_NAME
subjects:
- kind: ServiceAccount
  name: $SERVICE_ACCOUNT_NAME
  namespace: $NAMESPACE_NAME
roleRef:
  kind: Role
  name: ado-sc-sa-role
  apiGroup: rbac.authorization.k8s.io
EOF

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
type: kubernetes.io/service-account-token
metadata:
  name: $SECRET_NAME
  namespace: $NAMESPACE_NAME
  annotations:
    kubernetes.io/service-account.name: "$SERVICE_ACCOUNT_NAME"
EOF

SERVER_URL=$(kubectl config view --minify -o jsonpath={.clusters[0].cluster.server})
SECRET_JSON=$(kubectl get secret $SECRET_NAME -n $NAMESPACE_NAME -o json)

echo "Server URL: $SERVER_URL"
echo "Secret JSON: $SECRET_JSON"

