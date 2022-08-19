## Example of background mode 

Yaml signing policy supports background mode.

- VerifyManifest rule
```
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: validate-resources
spec:
  validationFailureAction: enforce
  background: true
  webhookTimeoutSeconds: 30
  failurePolicy: Fail  
  rules:
    - name: validate-resources
      match:
        any:
        - resources:
            kinds:
              - ConfigMap
            name: test*
      validate:
        manifests:
          attestors:
          - entries:
            - keys: 
                publicKeys:  |-
                  -----BEGIN PUBLIC KEY-----
                  MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEyQfmL5YwHbn9xrrgG3vgbU0KJxMY
                  BibYLJ5L4VSMvGxeMLnBGdM48w5IE//6idUPj3rscigFdHs7GDMH4LLAng==
                  -----END PUBLIC KEY-----
```

- The existing resources
```
$ kubectl get cm -n test-ns
NAME                   DATA   AGE
kube-root-ca.crt       1      2m5s
test-configmap         1      113s
test-no-signature-cm   0      2m1s
```
- Policy report of test-ns

```
$ kubectl get policyreport polr-ns-test-ns -n test-ns -o yaml
```

```yaml
apiVersion: wgpolicyk8s.io/v1alpha2
kind: PolicyReport
metadata:
  creationTimestamp: "2022-08-19T11:54:56Z"
  generation: 1
  labels:
    managed-by: kyverno
  name: polr-ns-test-ns
  namespace: test-ns
  ownerReferences:
  - apiVersion: v1
    controller: true
    kind: Namespace
    name: kyverno
    uid: 34bad092-fbb7-4f53-8406-568e190f7d0b
  resourceVersion: "198345"
  uid: 854f1a8d-f5fc-46c3-baf4-754322787bc6
results:
- message: 'manifest verification failed; verifiedCount 0; requiredCount 1; message
    .attestors[0].entries[0].keys: YAML manifest not found for this resource: message
    not found'
  policy: validate-resources
  resources:
  - apiVersion: v1
    kind: ConfigMap
    name: test-no-signature-cm
    namespace: test-ns
    uid: 0e026987-190f-4314-b411-f642ed4912f7
  result: fail
  rule: validate-resources
  scored: true
  source: Kyverno
  timestamp:
    nanos: 0
    seconds: 1660910094
- message: 'verified manifest signatures; manifest verification succeeded; verifiedCount
    1; requiredCount 1; message singed by a valid signer: '
  policy: validate-resources
  resources:
  - apiVersion: v1
    kind: ConfigMap
    name: test-configmap
    namespace: test-ns
    uid: 77bf7bd2-6237-4b00-8d59-1d5b96acfdd4
  result: pass
  rule: validate-resources
  scored: true
  source: Kyverno
  timestamp:
    nanos: 0
    seconds: 1660910094
summary:
  error: 0
  fail: 1
  pass: 1
  skip: 0
  warn: 0
```