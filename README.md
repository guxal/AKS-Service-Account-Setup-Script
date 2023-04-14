# AKS-Service-Account-Setup-Script
Este script automatiza la creación de una cuenta de servicio y un secreto asociado en un clúster AKS de Azure para ser utilizado en una conexión de servicio de Kubernetes en Azure DevOps.

## Autor

ChatGPT-4

## Referencia:

https://developercommunity.visualstudio.com/t/MS-DevOps-Environment--Cannot-Add-Resou/10154315


## input en CHATGPT:

´´´
hola, creame un CLI apartir de esta solucion para un problema de devops con aks:

Hi Philippe
Thank you for posting in Developer Community.
After discussion with product team, we suppose that in the situation of Kubernetes 1.24.0, the “Azure Subscription” option is no longer available to create the Kubernetes service connection.
(In an existing AKS cluster, we can only upgrade the Kubernetes version not downgrade.)
As the workaround, the user needs to manually create the service account and manually generate the associated secret for the new service account.
The following is an example with the detailed steps:
1.Login to Azure Portal and open Azure Cloud Shell.
2.Execute below command lines to connect to the Azure subscription and the AKS cluster.

az account set -s {subscription Name or ID}
az aks get-credentials --resource-group {resource group name} --name {AKS name}
  

image.png

3.Execute below command line to create a service account to a specified namespace.
kubectl create serviceaccount {service account name} -n {namespace name}
image.png

4.Execute below command lines to create a custom role with some custom permissions.

kubectl apply -f -<<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: ado-sc-sa-role
  namespace: default
rules:
- apiGroups: ["*","apps","extensions"]
  resources: ["*"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
EOF
  

image.png

5.Execute below command lines to create a rolebinding for the service account.

kubectl apply -f -<<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ado-sc-sa-rolebinding
  namespace: default
subjects:
- kind: ServiceAccount
  name: ado-sc-sa
  namespace: default
roleRef:
  kind: Role
  name: ado-sc-sa-role
  apiGroup: rbac.authorization.k8s.io
EOF
  

image.png

6.Execute below command lines to create a secret associated with the service account.

kubectl apply -f -<<EOF
apiVersion: v1
kind: Secret
type: kubernetes.io/service-account-token
metadata:
  name: ado-sc-sa-secret
  annotations:
    kubernetes.io/service-account.name: "ado-sc-sa"
EOF
  

image.png
image.png

7.After successfully create a new service account and its associated secret, open Azure DevOps in a new browser window to create the Kubernetes service connection.
8.Select the “Service Account” option instead of “Azure Subscription”.
(When adding Kubernetes resource into the deployment environment, you should select the “Generic provide (existing service account)” option.)
9.On the Azure Cloud Shell opened previously, execute below command line to get the Server Url. Copy the output URL to the Server Url field of the service connection.
kubectl config view --minify -o jsonpath={.clusters[0].cluster.server}
image.png

10.On the Azure Cloud Shell, execute below command line to get the secret created above, and output it as the JSON context. Copy the whole output JSON context to the Secret field of the service connection.
kubectl get secret {secret name} -n {namespace name} -o json
image.png
image.png

We appreciate your time and we are sincerely looking forward to your reply.
´´´

## ERRORES:

olvido agregar en la metadata del secret el namespace con su variable, se agrego por el desarrollador

## Requisitos previos

- Azure CLI instalado y en el PATH.
- `kubectl` instalado y en el PATH.
- Tener acceso a una suscripción de Azure y un clúster AKS existente.

## Uso

1. Abre el archivo del script y reemplaza los valores de las variables entre corchetes con tus propias configuraciones:

   - `SUBSCRIPTION_NAME_OR_ID`: Nombre o ID de la suscripción de Azure.
   - `RESOURCE_GROUP_NAME`: Nombre del grupo de recursos de Azure que contiene el clúster AKS.
   - `AKS_NAME`: Nombre del clúster AKS.
   - `SERVICE_ACCOUNT_NAME`: Nombre de la cuenta de servicio que se creará.
   - `NAMESPACE_NAME`: Nombre del espacio de nombres en el que se creará la cuenta de servicio.

2. Guarda el archivo del script y asegúrate de que tenga permisos de ejecución:

chmod +x aks_service_account_setup.sh

3. Ejecuta el script:

./aks_service_account_setup.sh

El script imprimirá la URL del servidor y el JSON del secreto al finalizar.

4. Sigue los pasos 7-10 en la solución original para crear la conexión del servicio Kubernetes en Azure DevOps utilizando la URL del servidor y el JSON del secreto obtenidos en el paso 3.


nota: todo el anterior proyecto junto con el README fue creado con ChatGPT4

## Licencia

Este proyecto está licenciado bajo la licencia MIT. Consulta el archivo [LICENSE](LICENSE) para obtener más detalles.
