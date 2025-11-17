#!/bin/bash
set -e

echo "=========================================="
echo "Stardew Valley Server - Test Deployment"
echo "=========================================="
echo ""

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "ERROR: kubectl is not installed or not in PATH"
    exit 1
fi

# Function to prompt for Steam credentials
setup_credentials() {
    echo "Setting up Steam credentials..."
    read -p "Enter your Steam username: " STEAM_USER
    read -s -p "Enter your Steam password: " STEAM_PASS
    echo ""
    read -p "Enter VNC password (for web interface): " VNC_PASSWORD
    echo ""

    # Create or update the secret
    kubectl create secret generic stardew-secrets \
        --from-literal=steam-password="$STEAM_PASS" \
        -n stardew-test \
        --dry-run=client -o yaml | kubectl apply -f -

    # Update ConfigMap with Steam username
    kubectl create configmap stardew-config \
        --from-literal=STEAM_USER="$STEAM_USER" \
        --from-literal=VNC_PASSWORD="$VNC_PASSWORD" \
        --from-literal=DISPLAY_WIDTH="1280" \
        --from-literal=DISPLAY_HEIGHT="720" \
        --from-literal=GAME_PORT="24642" \
        -n stardew-test \
        --dry-run=client -o yaml | kubectl apply -f -

    echo "✓ Credentials configured"
}

# Parse command line arguments
case "${1:-deploy}" in
    deploy)
        echo "Deploying Stardew Valley server to test namespace..."

        # Apply the manifest
        kubectl apply -f k8s-test-manifest.yaml

        # Prompt for credentials
        echo ""
        read -p "Do you want to set up Steam credentials now? (y/n) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            setup_credentials
        else
            echo "⚠ Remember to configure credentials manually:"
            echo "   kubectl create secret generic stardew-secrets --from-literal=steam-password='YOUR_PASSWORD' -n stardew-test"
            echo "   kubectl create configmap stardew-config --from-literal=STEAM_USER='YOUR_USERNAME' --from-literal=VNC_PASSWORD='changeme' -n stardew-test"
        fi

        echo ""
        echo "✓ Deployment created!"
        echo ""
        echo "Check status with:"
        echo "  kubectl get pods -n stardew-test"
        echo ""
        echo "View logs with:"
        echo "  kubectl logs -n stardew-test -l app=stardew-server -f"
        ;;

    delete)
        echo "Deleting test deployment..."
        kubectl delete namespace stardew-test
        echo "✓ Test deployment deleted"
        ;;

    status)
        echo "Checking deployment status..."
        echo ""
        kubectl get all -n stardew-test
        echo ""
        echo "Pod details:"
        kubectl get pods -n stardew-test -o wide
        ;;

    logs)
        echo "Showing logs (Ctrl+C to exit)..."
        kubectl logs -n stardew-test -l app=stardew-server -f
        ;;

    shell)
        POD=$(kubectl get pods -n stardew-test -l app=stardew-server -o jsonpath='{.items[0].metadata.name}')
        echo "Opening shell in pod: $POD"
        kubectl exec -it -n stardew-test $POD -- /bin/bash
        ;;

    vnc)
        echo "VNC Access Information:"
        echo ""
        NODE_PORT=$(kubectl get svc -n stardew-test stardew-server -o jsonpath='{.spec.ports[?(@.name=="vnc-web")].nodePort}')
        NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
        echo "Web VNC URL: http://${NODE_IP}:${NODE_PORT}"
        echo ""
        echo "Or use port-forward:"
        echo "  kubectl port-forward -n stardew-test svc/stardew-server 5800:5800"
        echo "  Then access: http://localhost:5800"
        ;;

    *)
        echo "Usage: $0 {deploy|delete|status|logs|shell|vnc}"
        echo ""
        echo "Commands:"
        echo "  deploy  - Deploy the server to test namespace"
        echo "  delete  - Delete the test deployment"
        echo "  status  - Check deployment status"
        echo "  logs    - View server logs"
        echo "  shell   - Open shell in server pod"
        echo "  vnc     - Get VNC access information"
        exit 1
        ;;
esac
