# AKS Sample Application

Sample Kubernetes manifests for demonstrating StrongDM's AKS integration.

## Components

- **Deployment**: nginx web server with 2 replicas
- **Service**: ClusterIP service on port 80

## Usage

```bash
# Deploy the application
kubectl apply -f aks-sample-deploymnet.yaml
kubectl apply -f aks-sample-service.yaml

# Verify deployment
kubectl get deployments
kubectl get pods
kubectl get services
```

## Sample Operations

```bash
# Scale the deployment
kubectl scale deployment nginx-deployment --replicas=3

# View logs
kubectl logs -l app=nginx

# Execute commands in pod
kubectl exec -it $(kubectl get pod -l app=nginx -o name | head -1) -- /bin/bash
```

## Cleanup

```bash
kubectl delete -f aks-sample-service.yaml
kubectl delete -f aks-sample-deploymnet.yaml
```
