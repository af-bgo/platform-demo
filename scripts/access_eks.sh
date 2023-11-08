#!/usr/bin/env bash

echo "Getting secrets for kubeconfig for the new cluster"
kubectl -n argocd get secrets istio-eks-cluster \
  --output jsonpath="{.data.kubeconfig}" \
  | base64 -d \
  | tee kubeconfig.yaml
