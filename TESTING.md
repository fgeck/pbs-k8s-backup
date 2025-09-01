# Testing Guide

## Prerequisites
✅ Secrets are already configured in your cluster:
- `pvc-backup-secret` (contains PBS and Telegram credentials)
- `postgres-backup-secret` (contains PostgreSQL credentials)

## Step 1: Test PVC Backup

First, let's test the PVC backup functionality:

```bash
# Apply the PVC backup test job
kubectl apply -f example-job.yaml

# Check if the job was created
kubectl get jobs

# Monitor the job progress
kubectl get pods -l job-name=pvc-backup-test

# View logs to see what's happening
kubectl logs -l job-name=pvc-backup-test -f
```

## Step 2: Test PostgreSQL Backup (if you have PostgreSQL)

If you have a PostgreSQL instance running:

```bash
# First, check if your PostgreSQL service exists
kubectl get svc | grep postgres

# If it exists, run the PostgreSQL backup test
kubectl get pods -l job-name=postgres-backup-test

# View logs
kubectl logs -l job-name=postgres-backup-test -f
```

## Step 3: Clean up test jobs

After testing:

```bash
# Delete the test jobs
kubectl delete job pvc-backup-test postgres-backup-test
```

## Troubleshooting

### Check if secrets exist:
```bash
kubectl get secrets | grep -E "(pvc-backup-secret|postgres-backup-secret)"
```

### Check secret contents (without revealing values):
```bash
kubectl describe secret pvc-backup-secret
kubectl describe secret postgres-backup-secret
```

### If jobs fail, check events:
```bash
kubectl get events --sort-by=.metadata.creationTimestamp
```

## Next Steps

Once testing is successful:
1. Apply the cronjobs: `kubectl apply -f example-cronjob.yaml`
2. Monitor cronjob schedules: `kubectl get cronjobs`
3. Check cronjob history: `kubectl get jobs`