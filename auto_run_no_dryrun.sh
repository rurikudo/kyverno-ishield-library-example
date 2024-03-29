# !/bin/bash

# Copyright 2022 IBM Corporation.

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

# http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if [ -z "$KYVERNO_DIR" ]; then
    echo "KYVERNO_DIR is empty. Please set your directry."
    exit 1
fi

echo "[1] Creating test namespace"
ns=`kubectl get ns | grep test-ns | wc -l`
counts=`echo $ns`
if [ "$counts" = "1" ]; then
echo "test-ns already exists..."
exit
fi
kubectl create ns test-ns

echo ""
echo "[2] Installing Kyverno"
kubectl create -f $KYVERNO_DIR/config/install.yaml

echo ""
echo "----------"
echo "[3] Checking if Kyverno pod is ready"
while :
do 
  ready=`kubectl get pod -n kyverno | grep kyverno | awk '{print $2}'`
  if [ "$ready" != "1/1" ]; then
    echo "Pod is not ready..."
    sleep 5
  else
    echo "Pod is ready"
    break
  fi
done

echo ""
echo "----------"
echo "[4] Installing Kyverno cluster-policies"
kubectl create -f deploy/kyverno-policy-validate-rule-no-dryrun.yaml


echo ""
echo "----------"
echo "[5] Checking if policy is ready to serve admission requests"
while :
do 
  logs=`kubectl logs deployment.apps/kyverno -n kyverno | grep "policy is ready to serve admission requests" | wc -l`
  counts=`echo $logs`
  if [ "$counts" >= "1" ]; then
    echo "Policy is not ready..."
    sleep 5
  else
    echo "Policy is ready"
    break
  fi
done

echo ""
echo "----------"
echo "[6] Testing....."
echo ""
echo "--------------------"
echo "        Role        "
echo "--------------------"
echo "[TEST 1] Resource without Signature should be blocked"
kubectl create -f deploy/test-role.yaml -n test-ns

sleep 2
echo ""
echo ""
echo "[TEST 2] Resource with Signature should be allowed"
kubectl create -f deploy/test-role.yaml.signed -n test-ns


sleep 2
echo ""
echo ""
echo "--------------------"
echo "     RoleBinding    "
echo "--------------------"
echo "[TEST 1] Resource without Signature should be blocked"
kubectl create -f deploy/test-rolebinding.yaml -n test-ns

sleep 2
echo ""
echo ""
echo "[TEST 2] Resource with Signature should be allowed"
kubectl create -f deploy/test-rolebinding.yaml.signed -n test-ns


sleep 2
echo ""
echo ""
echo "--------------------"
echo "     ClusterRole    "
echo "--------------------"
echo "[TEST 1] Resource without Signature should be blocked"
kubectl create -f deploy/test-clusterrole.yaml

sleep 2
echo ""
echo ""
echo "[TEST 2] Resource with Signature should be allowed"
kubectl create -f deploy/test-clusterrole.yaml.signed 


sleep 2
echo ""
echo ""
echo "--------------------"
echo " ClusterRoleBinding "
echo "--------------------"
echo "[TEST 1] Resource without Signature should be blocked"
kubectl create -f deploy/test-clusterrolebinding.yaml

sleep 2
echo ""
echo ""
echo "[TEST 2] Resource with Signature should be allowed"
kubectl create -f deploy/test-clusterrolebinding.yaml.signed


sleep 2
echo ""
echo ""
echo "--------------------"
echo "       Secret       "
echo "--------------------"
echo "[TEST 1] Resource without Signature should be blocked"
kubectl create -f deploy/test-secret.yaml -n test-ns

sleep 2
echo ""
echo ""
echo "[TEST 2] Resource with Signature should be allowed"
kubectl create -f deploy/test-secret.yaml.signed -n test-ns


sleep 2
echo ""
echo ""
echo "--------------------"
echo "      ConfigMap     "
echo "--------------------"
echo "[TEST 1] Resource without Signature should be blocked"
kubectl create -f deploy/test-configmap.yaml -n test-ns

sleep 2
echo ""
echo ""
echo "[TEST 2] Resource with Signature should be allowed"
kubectl create -f deploy/test-configmap.yaml.signed -n test-ns


sleep 2
echo ""
echo ""
echo "--------------------"
echo "     Deployment     "
echo "--------------------"
echo "[TEST 1] Resource without Signature should be blocked"
kubectl create -f deploy/test-deployment.yaml -n test-ns

sleep 2
echo ""
echo ""
echo "[TEST 2] Resource with Signature should be allowed"
kubectl create -f deploy/test-deployment.yaml.signed -n test-ns


sleep 2
echo ""
echo ""
echo "[TEST 3] Pod should be created"
while :
do 
  ready=`kubectl get pod -n test-ns | grep test- | awk '{print $2}'`
  if [ "$ready" != "1/1" ]; then
    echo "Pod is not ready..."
    sleep 2
  else
    echo "Pod is ready"
    kubectl get pod -n test-ns
    break
  fi
done

sleep 2
echo ""
echo ""
echo "--------------------"
echo "       Service      "
echo "--------------------"
echo "[TEST 1] Resource without Signature should be blocked"
kubectl create -f deploy/test-service.yaml -n test-ns

sleep 2
echo ""
echo ""
echo "[TEST 2] Resource with Signature should be allowed"
kubectl create -f deploy/test-service.yaml.signed -n test-ns


sleep 2
echo ""
echo ""
echo "--------------------"
echo "   ServiceAccount   "
echo "--------------------"
echo "[TEST 1] Resource without Signature should be blocked"
kubectl create -f deploy/test-serviceaccount.yaml -n test-ns

sleep 2
echo ""
echo ""
echo "[TEST 2] Resource with Signature should be allowed"
kubectl create -f deploy/test-serviceaccount.yaml.signed -n test-ns


sleep 2
echo ""
echo ""
echo "--------------------"
echo "   Kyverno Policy   "
echo "--------------------"
echo "[TEST 1] Resource without Signature should be blocked"
kubectl create -f deploy/test-kyverno-pol.yaml -n test-ns

sleep 2
echo ""
echo ""
echo "[TEST 2] Resource with Signature should be allowed"
kubectl create -f deploy/test-kyverno-pol.yaml.signed -n test-ns

echo ""
echo "Getting Policy..."
kubectl get pol -n test-ns

sleep 2
echo ""
echo ""
echo "-----------------------"
echo " Kyverno ClusterPolicy "
echo "-----------------------"
echo "[TEST 1] Resource without Signature should be blocked"
kubectl create -f deploy/test-kyverno-cpol.yaml 

sleep 2
echo ""
echo ""
echo "[TEST 2] Resource with Signature should be allowed"
kubectl create -f deploy/test-kyverno-cpol.yaml.signed

echo ""
echo "Getting ClusterPolicy..."
kubectl get cpol

sleep 2
echo ""
echo ""
echo "[7] Cleaning test kyverno policies......"
kubectl delete -f deploy/kyverno-policy-validate-rule.yaml
echo ""
echo ""
echo "[8] Cleaning test resources......"
kubectl delete -f deploy/test-clusterrole.yaml.signed -n test-ns
kubectl delete -f deploy/test-clusterrolebinding.yaml.signed
kubectl delete -f deploy/test-configmap.yaml.signed -n test-ns
kubectl delete -f deploy/test-deployment.yaml.signed -n test-ns
kubectl delete -f deploy/test-kyverno-cpol.yaml.signed
kubectl delete -f deploy/test-kyverno-pol.yaml.signed -n test-ns
kubectl delete -f deploy/test-role.yaml.signed -n test-ns
kubectl delete -f deploy/test-rolebinding.yaml.signed -n test-ns
kubectl delete -f deploy/test-secret.yaml.signed -n test-ns
kubectl delete -f deploy/test-service.yaml.signed -n test-ns
kubectl delete -f deploy/test-serviceaccount.yaml.signed -n test-ns

echo ""
echo ""
echo "Test for each Signing types....."
echo "[1] ImageRef"
echo "Creating Kyverno Policy...."
kubectl create -f deploy/kyverno-policy-validate-rule-imageRef.yaml

sleep 3
echo "Creating signed resource...."
kubectl create -f deploy/test-service.yaml -n test-ns

echo "Deleting Kyverno Policy...."
kubectl delete -f deploy/kyverno-policy-validate-rule-imageRef.yaml

echo "Deleting signed resource...."
kubectl delete -f deploy/test-service.yaml -n test-ns


sleep 3
echo ""
echo "[2] Keyless"
kubectl create -f deploy/kyverno-policy-validate-rule-keyless.yaml

sleep 3
echo "Creating signed resource...."
kubectl create -f deploy/test-deployment-keyless.yaml.signed -n test-ns

echo "Deleting Kyverno Policy...."
kubectl delete -f deploy/kyverno-policy-validate-rule-keyless.yaml

echo "Deleting signed resource...."
kubectl delete -f deploy/test-deployment-keyless.yaml.signed -n test-ns


sleep 3
echo ""
echo "[3] GPG"
kubectl create -f deploy/kyverno-policy-validate-rule-no-dryrun-gpg.yaml

sleep 3
echo "Creating signed resource...."
kubectl create -f deploy/test-service-gpg.yaml -n test-ns

echo "Deleting Kyverno Policy...."
kubectl delete -f deploy/kyverno-policy-validate-rule-no-dryrun-gpg.yaml

echo "Deleting signed resource...."
kubectl delete -f deploy/test-service-gpg.yaml -n test-ns


sleep 3
echo ""
echo "[2] Cert"
kubectl create -f deploy/kyverno-policy-validate-rule-no-dryrun-cert.yaml

sleep 3
echo "Creating signed resource...."
kubectl create -f deploy/test-service-cert.yaml.signed -n test-ns

echo "Deleting Kyverno Policy...."
kubectl delete -f deploy/kyverno-policy-validate-rule-no-dryrun-cert.yaml

echo "Deleting signed resource...."
kubectl delete -f deploy/test-service-cert.yaml.signed -n test-ns



sleep 3
echo ""
echo "[2] Multi signatures"
kubectl create -f deploy/kyverno-policy-validate-rule-no-dryrun-multi-sig.yaml

sleep 3
echo "Creating signed resource...."
kubectl create -f deploy/test-service-multi-sig.yaml.signed.signed -n test-ns

echo "Deleting Kyverno Policy...."
kubectl delete -f deploy/kyverno-policy-validate-rule-no-dryrun-multi-sig.yaml

echo "Deleting signed resource...."
kubectl delete -f deploy/test-service-multi-sig.yaml.signed.signed -n test-ns


echo "[9] Deleting Kyverno"
kubectl delete -f $KYVERNO_DIR/config/install.yaml

echo "[10] Deleting test namespace"
kubectl delete ns test-ns