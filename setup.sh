#!/bin/bash
test -z $PASSWORD && (echo "set the password for tarball download before running this script: export PASSWORD=<password from pdf>"; exit 1)
export MACNAME=$(uname -n)
export SOLUTIONS=LFD459/SOLUTIONS
wget https://cm.lf.training/LFD459/LFD459_V1.36.1_SOLUTIONS.tar.xz --user=LFtraining --password=$PASSWORD
tar xf LFD459_V1.36.1_SOLUTIONS.tar.xz

test $MACNAME = cp && export SCRIPT=k8scp || export SCRIPT=k8sWorker
cp $SOLUTIONS/s_02/$SCRIPT.sh .
cp $SOLUTIONS/s_03/local-repo-setup.sh .
bash $SCRIPT.sh | tee setup.out

if [ $MACNAME = cp ]; then
  kubectl taint node cp node-role.kubernetes.io/control-plane-
  sudo apt-get update
  sudo apt-get install -y podman
  kubectl create -f $SOLUTIONS/s_03/easyregistry.yaml
  . local-repo-setup.sh
  podman build -t $repo/simpleapp $SOLUTIONS/s_03
  podman push $repo/simpleapp
elif [ $MACNAME = worker ]; then
  echo "to complete setup of this node, copy the worker join command from /home/student/setup.out on the CP node and run it as root here."
  echo "Then, run '. local-repo-setup.sh' to configure this node with access to the local registry"
fi
