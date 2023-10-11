# Crossplane for AWS

## Requirements

* AWS Account
* `kind` cluster
* helm

## Initial Setup

### Installing Crossplane

Once you have the `kind` cluster up and running, You need to install crossplane
into your cluster.


Enable the Crossplane helm chart repository:

```shell
helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update
```

Install Crossplane:

```shell
helm install crossplane crossplane-stable/crossplane \
            --namespace crossplane-system --create-namespace
```

Verify Installation:

```shell
kubectl get pods -n crossplane-system
```

## Configuration

### Install AWS provider

Install AWS S3 provider into the `kind` cluster:

```shell
cat <<EOF | kubectl apply -f -
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-aws-s3
spec:
  package: xpkg.upbound.io/upbound/provider-aws-s3:v0.37.0
EOF
```

Verify Installation:

```shell
kubectl get providers
```

### Authenticate AWS to the provider

#### Import Credentials to a local file

To authenticate AWS to the provider, you need to have access to AWS IAM
and get `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`. 

*Note: If you have already installed `aws cli` in your machine, you
should have already the values in the directory `~/.aws/credentials` file (in case of Linux/MacOS)*

Just copy the values from either `~/.aws/credentials` or AWS IAM dashboard and create
a txt file called `credentials.txt` with the following contents:

```shell
[default]
aws_access_key_id = <your aws_access_key_id>
aws_secret_access_key = <your aws_secret_access_key>
```

#### Create Kubernetes Secret

With the file created, you can create the kubernetes secret in your 
newly created crossplane namespace `crossplane-system` as follows:

```shell
kubectl create secret generic aws-secret -n crossplane-system \
                      --from-file=creds=./aws-credentials.txt
```

View the secret:

```shell
kubectl describe secret aws-secret -n crossplane-system
```

### Configure the Provider

You can configure the provider with `ProviderConfig` (provided by Crossplane)

Apply the `ProviderConfig` on the AWS `Provider` with the secret 
being created:

```shell
cat <<EOF | kubectl apply -f -
apiVersion: aws.upbound.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  credentials:
    source: Secret
    secretRef:
      namespace: crossplane-system
      name: aws-secret
      key: creds
EOF
```

Now you are ready to create a resource in AWS using Crossplane!

Happy Platforming! :) 

