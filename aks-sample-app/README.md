# AKS Sample Application for StrongDM Azure Lab

## Overview

This directory contains sample Kubernetes manifests for demonstrating StrongDM's integration with Azure Kubernetes Service (AKS). The sample application provides a simple web service that can be used to showcase container access control, kubectl operations, and StrongDM's Kubernetes management capabilities.

## Sample Application Components

### Deployment (`aks-sample-deploymnet.yaml`)
- **Application**: Simple nginx web server
- **Replicas**: 2 pods for basic high availability demonstration
- **Image**: Standard nginx:1.14.2 image
- **Port**: Container listens on port 80
- **Labels**: Properly labeled for service discovery

### Service (`aks-sample-service.yaml`)
- **Type**: ClusterIP (internal cluster access)
- **Port Mapping**: Service port 80 → target port 80
- **Selector**: Routes traffic to pods with app=nginx label
- **Internal Access**: Accessible within the cluster network

## Use Cases for Partner Training

1. **Kubectl Access Control**: Demonstrate secure kubectl access through StrongDM
2. **Container Workload Management**: Show pod deployment and scaling operations
3. **Service Discovery**: Illustrate Kubernetes service networking concepts
4. **Application Lifecycle**: Demonstrate deployment, updates, and rollback procedures
5. **Multi-Container Environments**: Show how StrongDM manages access to complex containerized applications

## Deployment Instructions

### Prerequisites
- AKS cluster deployed and accessible through StrongDM
- kubectl configured to access the cluster through StrongDM
- Appropriate Kubernetes RBAC permissions

### Deploy the Sample Application

```bash
# Connect to AKS cluster through StrongDM
# (StrongDM handles the kubectl configuration automatically)

# Deploy the application
kubectl apply -f aks-sample-deploymnet.yaml

# Deploy the service
kubectl apply -f aks-sample-service.yaml

# Verify deployment
kubectl get deployments
kubectl get pods
kubectl get services
```

### Verify Application Status

```bash
# Check deployment status
kubectl rollout status deployment/nginx-deployment

# View pod details
kubectl describe pods -l app=nginx

# Check service endpoints
kubectl get endpoints nginx-service

# View application logs
kubectl logs -l app=nginx
```

## Sample Operations for Training

### Basic Operations
```bash
# List all resources
kubectl get all

# Scale the deployment
kubectl scale deployment nginx-deployment --replicas=3

# View scaled pods
kubectl get pods -l app=nginx

# Check resource usage
kubectl top pods
kubectl top nodes
```

### Advanced Operations
```bash
# Port forward to access application locally
kubectl port-forward service/nginx-service 8080:80

# Execute commands in a pod
kubectl exec -it $(kubectl get pod -l app=nginx -o name | head -1) -- /bin/bash

# View pod logs in real-time
kubectl logs -f deployment/nginx-deployment

# Describe the service
kubectl describe service nginx-service
```

### Configuration Management
```bash
# Create a ConfigMap
kubectl create configmap nginx-config --from-literal=index.html="<h1>Hello from StrongDM Lab!</h1>"

# Update deployment to use ConfigMap (requires manifest modification)
kubectl edit deployment nginx-deployment

# View configuration
kubectl get configmap nginx-config -o yaml
```

## StrongDM Integration Benefits

### Session Recording
All kubectl commands executed through StrongDM are recorded and auditable:
- Command history and parameters
- Resource modifications and deployments
- Pod access and container operations
- Configuration changes and updates

### Access Control
StrongDM provides fine-grained control over Kubernetes access:
- Time-limited access to clusters
- Role-based permissions through Kubernetes RBAC
- Audit trail of all cluster operations
- Just-in-time access provisioning

### Security Features
- No direct cluster credentials on user machines
- Centralized authentication and authorization
- Encrypted connections to cluster API
- Integration with enterprise identity providers

## Cleanup Instructions

```bash
# Remove the sample application
kubectl delete -f aks-sample-service.yaml
kubectl delete -f aks-sample-deploymnet.yaml

# Verify cleanup
kubectl get deployments
kubectl get services
kubectl get pods
```

## Troubleshooting

### Common Issues

1. **Deployment Fails**:
   ```bash
   # Check events for error details
   kubectl get events --sort-by=.metadata.creationTimestamp
   
   # Check pod status
   kubectl describe pods -l app=nginx
   ```

2. **Service Not Accessible**:
   ```bash
   # Verify service configuration
   kubectl describe service nginx-service
   
   # Check pod labels match service selector
   kubectl get pods --show-labels
   ```

3. **StrongDM Connectivity Issues**:
   - Verify StrongDM connection to AKS cluster
   - Check Kubernetes RBAC permissions
   - Ensure cluster networking allows StrongDM access

### Useful Debugging Commands

```bash
# Check cluster status
kubectl cluster-info
kubectl get nodes

# View resource quotas
kubectl describe resourcequota

# Check network policies
kubectl get networkpolicies

# View persistent volumes
kubectl get pv,pvc
```

## Sample Application Modifications

### Adding Environment Variables
```yaml
# Add to deployment spec.template.spec.containers
env:
- name: ENVIRONMENT
  value: "StrongDM Lab"
- name: VERSION
  value: "1.0"
```

### Adding Health Checks
```yaml
# Add to deployment spec.template.spec.containers
livenessProbe:
  httpGet:
    path: /
    port: 80
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /
    port: 80
  initialDelaySeconds: 5
  periodSeconds: 5
```

## Learning Objectives

By working with this sample application, users will learn:

1. **Kubernetes Fundamentals**: Pod, Service, and Deployment concepts
2. **kubectl Usage**: Command-line tool for cluster management
3. **Application Lifecycle**: Deployment, scaling, and maintenance procedures
4. **StrongDM Integration**: How StrongDM secures and audits container access
5. **Troubleshooting**: Common issues and debugging techniques
6. **Security Best Practices**: Secure container and cluster management

This sample application provides a foundation for demonstrating StrongDM's powerful Kubernetes integration capabilities in a hands-on, practical manner.
