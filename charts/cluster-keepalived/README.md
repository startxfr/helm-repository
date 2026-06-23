# cluster-keepalived

Helm chart used to patch the OpenShift cluster network configuration for external IP support.

This chart provides a focused solution for configuring the cluster network to allow external IP assignment. It patches the Network CRD (config.openshift.io/v1) to register external IP pools, which is essential for exposing applications via Keepalived VIPs or other load balancing solutions.

Additionally, it provides optional templates for deploying complementary components (Keepalived operator, IngressController, and services) that work with the network configuration.

## Features

- **Network Configuration**: Patch cluster network to enable external IP pools
- **External IP Support**: Configure autoAssignCIDRs and policy for external IPs
- **Optional Keepalived Support**: Deploy Keepalived operator and KeepalivedGroup resources
- **Optional IngressController**: Create custom ingress controllers for public routes
- **Flexible Deployment**: All components can be enabled/disabled independently

## Prerequisites

- Kubernetes 1.30.0+
- Helm 3.0+
- OpenShift 4.0+ (for IngressController and Network resources)
- The keepalived operator installed (via this chart's operator dependency)

## Architecture: Network Configuration for External IP Support

This chart's primary purpose is to patch the cluster Network CRD to enable external IP support:

```
┌──────────────────────────────────────────────────────────┐
│ Network CRD Patch (PRIMARY)                              │
│ - externalIP.autoAssignCIDRs: [10.99.10.237/32]         │
│ - externalIP.policy.allowedCIDRs: [10.99.10.237/32]     │
│ - Enables cluster to use 10.99.10.237 for services      │
│ - Applied with ArgoCD sync-wave: 1                      │
└──────────────────────────────────────────────────────────┘
                    │
        ┌───────────┴───────────┐
        │                       │
        ▼                       ▼
┌──────────────────┐    ┌──────────────────────┐
│ Keepalived VIP   │    │ IngressController +  │
│ (Optional)       │    │ Service (Optional)   │
│ - Maintains VIP  │    │ - Routes traffic     │
│ - No ArgoCD Wave │    │ - No ArgoCD Wave     │
│ - Manual or      │    │ - Manual or separate │
│   separate mgmt  │    │   deployment         │
└──────────────────┘    └──────────────────────┘
        │                       │
        └───────────┬───────────┘
                    │
                    ▼
        Application Services
        (use external IP)
```

### Component Roles

1. **Network Configuration** (PRIMARY - With ArgoCD Wave 1)
   - Registers external IP pool in cluster config
   - Allows services/routes to use the external IP
   - Essential prerequisite for external IP support

2. **Keepalived VIP Management** (OPTIONAL - No ArgoCD Wave)
   - Maintains high availability for the VIP
   - Runs on worker nodes with VRRP protocol
   - Can be managed independently or via this chart

3. **IngressController + Service** (OPTIONAL - No ArgoCD Wave)
   - Routes traffic from external IP to applications
   - Serves routes with specific labels
   - Can be managed independently or via this chart

## Installation

### Basic Installation (Network Config Only)

Patch the cluster network to enable external IP support:

```bash
helm install my-keepalived ./cluster-keepalived \
  --set clusterNetwork.enabled=true \
  --set clusterNetwork.externalIP.autoAssignCIDRs[0]=10.99.10.237/32 \
  --set clusterNetwork.externalIP.policy.allowedCIDRs[0]=10.99.10.237/32
```

Or use values file:

```bash
helm install my-keepalived ./cluster-keepalived \
  -f values-example.yaml
```

### With Optional Components

To also deploy Keepalived operator, KeepalivedGroup, and IngressController:

```bash
helm install my-keepalived ./cluster-keepalived \
  -f values-example.yaml \
  --set operator.enabled=true \
  --set keepalived.enabled=true \
  --set ingressController.enabled=true \
  --set ingressControllerService.enabled=true
```

**Note**: Optional components (keepalived, ingressController, service) do NOT use ArgoCD sync-waves. They are deployed independently and can be managed separately from the network configuration.

### Creating Public Routes

Once the network is configured, create routes that use the external IP:

```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: my-app
  namespace: default
spec:
  host: mydomain.example.com
  port:
    targetPort: 8080
  to:
    kind: Service
    name: my-app
    weight: 100
  tls:
    termination: edge
```

## Configuration

### clusterNetwork

Configure the cluster network and external IP assignments:

```yaml
clusterNetwork:
  enabled: true
  networkType: OVNKubernetes
  clusterNetwork:
    - cidr: 10.128.0.0/14
      hostPrefix: 23
  serviceNetwork:
    - 172.30.0.0/16
  externalIP:
    autoAssignCIDRs:
      - 10.99.10.237/32
    policy:
      allowedCIDRs:
        - 10.99.10.237/32
```

**Parameters:**
- `enabled`: Enable cluster network configuration (default: false)
- `networkType`: Network plugin (OVNKubernetes or OpenShiftSDN)
- `clusterNetwork`: Pod network CIDR and host prefix
- `serviceNetwork`: Service network CIDR
- `externalIP.autoAssignCIDRs`: CIDRs available for external IP assignment
- `externalIP.policy.allowedCIDRs`: CIDRs allowed for external IP usage

### ingressController

Create a custom OpenShift IngressController:

```yaml
ingressController:
  enabled: true
  name: public
  namespace: openshift-ingress-operator
  domain: apps.public.example.com
  replicas: 3
  routeSelector:
    matchLabels:
      ingress: public
  nodePlacement:
    nodeSelector:
      matchLabels:
        node-role.kubernetes.io/infra: ""
    tolerations:
      - effect: NoSchedule
        key: node-role.kubernetes.io/infra
        operator: Exists
  defaultCertificate:
    name: public-ingress-cert
  tuningOptions:
    reloadInterval: 0s
  endpointPublishingStrategy:
    type: Private
```

**Key Parameters:**
- `enabled`: Enable ingress controller creation
- `name`: IngressController name
- `domain`: Domain for routes (e.g., apps.public.example.com)
- `replicas`: Number of controller replicas
- `routeSelector`: Label selector for routes to accept
- `nodePlacement`: Pod affinity configuration (nodeSelector + tolerations)
- `defaultCertificate`: TLS certificate secret name
- `endpointPublishingStrategy`: How to publish endpoints (Private, HostNetwork, etc.)

### ingressControllerService

Expose the IngressController via a service with external IP:

```yaml
ingressControllerService:
  enabled: true
  name: router-public-lb
  namespace: openshift-ingress
  type: ClusterIP
  externalIPs:
    - 10.99.10.237
  clusterIP: 172.30.183.172
  clusterIPs:
    - 172.30.183.172
  ipFamilies:
    - IPv4
  ipFamilyPolicy: SingleStack
  ports:
    - name: http
      protocol: TCP
      port: 80
      targetPort: http
    - name: https
      protocol: TCP
      port: 443
      targetPort: https
  selector:
    ingresscontroller.operator.openshift.io/deployment-ingresscontroller: public
```

**Key Parameters:**
- `enabled`: Enable service creation
- `name`: Service name
- `externalIPs`: External IP addresses to assign
- `type`: Service type (ClusterIP recommended with externalIPs)
- `ports`: Service ports configuration
- `selector`: Pod selector (typically selects ingress controller pods)

### keepalived.groups

Configure keepalived groups with the following structure:

- `enabled`: Enable creation of keepalived groups (default: true)
- `list`: Array of keepalived group configurations
  - `name`: Name of the keepalived group
  - `namespace`: Target namespace (defaults to keepalived.namespace)
  - `spec`: YAML spec for the KeepalivedGroup resource

For more information about the keepalived groups please visit : https://github.com/redhat-cop/keepalived-operator

Example group configuration:

```yaml
groups:
  enabled: true
  list:
    - name: cluster-vip
      namespace: openshift-operators
      spec: |
        virtual_ips:
          - ip: 10.99.10.237
            mask: 32
        interface: eth0
        vrid: 51
        priority: 100
        authentication:
          type: PASS
          password: mypassword
```

### operator

Configuration for the keepalived operator installation:

- `enabled`: Enable operator installation (default: false)
- `subscription.enabled`: Create operator subscription
- `subscription.channel`: Operator channel (default: stable)
- `operatorGroup.enabled`: Create operator group

### project

Configuration for the project namespace (via project chart dependency):

- `enabled`: Enable project creation (default: false)
- `project.enabled`: Create the project namespace
- `project.name`: Project namespace name

## Values Schema

See `values.schema.json` for detailed schema validation and IDE support.

## Best Practices

### IP Address Management
- The external IP (e.g., 10.99.10.237/32) must be reserved and not used elsewhere
- Add the CIDR to `clusterNetwork.externalIP.autoAssignCIDRs` to allow cluster assignment
- Add the same CIDR to `clusterNetwork.externalIP.policy.allowedCIDRs` for policy enforcement

### Keepalived Configuration
- Use `blacklistRouterIDs` to avoid conflicts with other VRRP instances
- Ensure the interface (e.g., br-ex) exists on all worker nodes
- Monitor keepalived logs for VRRP failover events

### IngressController Management
- Always place ingress controllers on infrastructure nodes using `nodePlacement`
- Use `routeSelector` to control which routes are served by each controller
- Apply different TLS certificates using `defaultCertificate` secrets

### High Availability
- Deploy at least 2 replicas of the ingress controller
- Ensure keepalived runs on multiple nodes for redundancy
- Monitor the external IP using cluster monitoring tools

## Troubleshooting

### VIP Not Available
**Symptom**: Cannot reach the external IP (10.99.10.237)

**Diagnosis**:
```bash
# Check keepalived status
oc get keepalivedgroups -n openshift-ingress
oc get pods -n openshift-ingress -l app=keepalived

# Check the service
oc get svc -n openshift-ingress router-public-lb
oc describe svc -n openshift-ingress router-public-lb

# Check VRRP on nodes
oc debug node/worker-node -- chroot /host ip addr show | grep 10.99.10.237
```

**Solution**:
- Verify `clusterNetwork.enabled` is true and configuration is applied
- Check that keepalived pods are running and logs don't show errors
- Ensure interface br-ex exists and is accessible on all nodes
- Verify no firewall rules block traffic on the external subnet

### Ingress Controller Not Routing Traffic
**Symptom**: Routes don't work even though ingress controller is running

**Diagnosis**:
```bash
# Check ingress controller
oc get ingresscontroller public -n openshift-ingress-operator
oc logs -n openshift-ingress -l ingresscontroller.operator.openshift.io/deployment-ingresscontroller=public

# Check if route has public label
oc get routes -A -L ingress
```

**Solution**:
- Ensure routes have the `ingress: public` label in metadata
- Verify the ingress controller domain matches route host
- Check ingress controller logs for routing errors
- Ensure certificate secret exists if TLS is required

### External IP Not Assigned to Service
**Symptom**: `externalIPs` shows 10.99.10.237 but traffic doesn't route through it

**Diagnosis**:
```bash
# Check network policy
oc get network cluster -o yaml | grep -A 10 externalIP

# Verify IP is in allowed CIDRs
oc get network cluster -o yaml | grep -A 5 allowedCIDRs
```

**Solution**:
- Ensure `clusterNetwork.externalIP.policy.allowedCIDRs` includes the IP CIDR
- Restart service pods to refresh IP assignment
- Check firewall and SDN policies for blocking

## Maintenance

For more information, updates, and release notes, visit:
- Chart Documentation: https://helm-repository.readthedocs.io/en/latest/charts/cluster-keepalived
- GitHub Repository: https://github.com/startxfr/helm-repository/tree/master/charts/cluster-keepalived

## License

This Helm chart is part of the STARTX Helm Repository and is licensed under the MIT License.
