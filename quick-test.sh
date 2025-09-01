#!/bin/bash

echo "🚀 Starting PBS Kubernetes Backup Test"
echo "======================================"

# Check if secrets exist
echo "📋 Checking required secrets..."
if kubectl get secret pvc-backup-secret >/dev/null 2>&1; then
    echo "✅ pvc-backup-secret found"
else
    echo "❌ pvc-backup-secret not found"
    exit 1
fi

if kubectl get secret postgres-backup-secret >/dev/null 2>&1; then
    echo "✅ postgres-backup-secret found"
else
    echo "⚠️  postgres-backup-secret not found (PostgreSQL test will be skipped)"
    SKIP_POSTGRES=true
fi

echo ""
echo "🧪 Applying test jobs..."
kubectl apply -f example-job.yaml

echo ""
echo "⏳ Waiting for jobs to start..."
sleep 5

echo ""
echo "📊 Job status:"
kubectl get jobs -l app.kubernetes.io/name=pbs-k8s-backup 2>/dev/null || kubectl get jobs | grep -E "(pvc-backup-test|postgres-backup-test)"

echo ""
echo "🔍 Pod status:"
kubectl get pods -l job-name=pvc-backup-test 2>/dev/null || echo "PVC backup job not found"

if [ "$SKIP_POSTGRES" != "true" ]; then
    kubectl get pods -l job-name=postgres-backup-test 2>/dev/null || echo "PostgreSQL backup job not found"
fi

echo ""
echo "📝 To view logs, run:"
echo "kubectl logs -l job-name=pvc-backup-test -f"
if [ "$SKIP_POSTGRES" != "true" ]; then
    echo "kubectl logs -l job-name=postgres-backup-test -f"
fi

echo ""
echo "🧹 To clean up after testing:"
echo "kubectl delete job pvc-backup-test postgres-backup-test"