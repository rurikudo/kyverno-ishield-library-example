# kyverno-ishield-library-example

This is a test for manifest verification using IntegrityShield library.
Please use Kyverno code below.
```
Git: git@github.com:rurikudo/kyverno.git
Branch: dev/yaml-signing-sigstore
```

## How to run test
### Clone test code
```
git clone git@github.com:rurikudo/kyverno-ishield-library-example.git
```
### Prepare Kyverno images and install.yaml
1. Clone Kyverno fork repo
```
git clone git@github.com:rurikudo/kyverno.git
git checkout -b  yaml-signing-vr origin/yaml-signing-vr
```

2. Build images
```
 make docker-build-kyverno-local
 make docker-build-initContainer-local
```
3. Prepare install.yml
```
make release
```
and, replace images with yours.

### Set Parameter
1. get absolute path of kyverno dir
```
$ pwd                                       
/home/repo/kyverno
```
2. set env variable
```
$ export KYVERNO_DIR=/home/repo/kyverno
```
### Run test
```
cd /home/repo/kyverno-ishield-library-example 
./auto_run.sh
./auto_run_no_dryrun.sh
```
