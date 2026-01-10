# Runbook: Debugging Pod CrashLoopBackOff

## 1. Trigger
Alert: `KubePodCrashLooping` or user report of "App is down".

## 2. Quick Checks
1.  **Check Pod Status**:
    ```bash
    kubectl get pods -n <namespace>
    ```
2.  **Check Logs** (Previous instance often holds the clue):
    ```bash
    kubectl logs -p <pod-name> -n <namespace>
    ```
    *If no logs, check current:* `kubectl logs <pod-name>`
3.  **Check Events**:
    ```bash
    kubectl describe pod <pod-name> -n <namespace>
    ```
    Look for `OOMKilled`, `Liveness probe failed`, or `Back-off restarting failed container`.

## 3. Common Resolution Paths

### A. OOMKilled (Out of Memory)
**Signal**: State terminates with `OOMKilled`.
**Fix**:
1. Check current limit: `kubectl get pod <name> -o yaml | grep memory`
2. Bump particular limit in `values.yaml` or Deployment.
3. Validate JVM/NodeJS heap settings match container limits.

### B. Liveness Probe Failure
**Signal**: events show `Liveness probe failed: Get http://...: connection refused`.
**Fix**:
1. Is app slow to start? Increase `initialDelaySeconds`.
2. Is app stuck? Restart is the correct behavior, but "why" is the root cause (deadlock, database dependency).
3. Check application logs for connection timeouts.

### C. Config/Secret Missing
**Signal**: Log says "FileNotFound" or "Env var missing".
**Fix**: Verify `ConfigMap` and `Secret` mounting.
