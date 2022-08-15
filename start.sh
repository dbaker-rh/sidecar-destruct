#!/bin/bash
#
# Script to run in a sidecar container to monitor node labels for 
# containers that need USB devices to run.
#
# Pods can easily launch based on node labels created by something
# like node-feature-discovery, but it's not as simple to kill the
# pod if a USB device is removed.
#
# This script needs to know:
# - it's own namespace and pod name
#   * could be determined from /var/run/secrets/kubernetes.io/serviceaccount/namespace
#   * could be determined from $( hostname ) inside the container
# - the node it's running on
#   * easiest (?) to be passed in with env -> valueFrom -> fieldRef
#   * could be obtained from kubectl get -n namespace pod/POD to watch spec
# - the label used to admit the pod
#   * easiest to be passed in as constant
#   * could be scraped from "get pod" by parsing nodeSelector
#
#
# Service Account Permissions
# - kubectl get nodes ..... <-- requires: get, list
#
# we could shrink to just get "kubectl get node/NODEHOST ..." but
# doing that loses node selectors that overly complicates our logic
#


# Set defaults, if not defined (e.g. in container's env spec)
SLEEPTIME="${SLEEPTIME:-10}"
VERBOSE="${VERBOSE:-0}"
NODELABEL="${NODELABEL:-feature.node.kubernetes.io/usb-ff_1a86_7523.present}"
NODEVALUE="${NODEVALUE:-true}"


# If these are not defined, we cannot continue
if [ -z "$NODEHOST" ]; then
    echo '$NODEHOST is not defined; cannot continue; sleeping'
    sleep infinity
fi

if [ -z "$NAMESPACE" ]; then
    echo '$NAMESPACE is not defined; cannot continue; sleeping'
    sleep infinity
fi
if [ -z "$PODNAME" ]; then
    echo '$PODNAME is not defined; cannot continue; sleeping'
    sleep infinity
fi


echo 'Self destruct pod starting at' $( date)

echo "SLEEPTIME: $SLEEPTIME"
echo "NAMESPACE: $NAMESPACE"
echo "PODNAME:   $PODNAME"
echo "NODEHOST:  $NODEHOST"
echo "NODELABEL: $NODELABEL"
echo "NODEVALUE: $NODEVALUE"
echo "VERBOSE:   $VERBOSE"
echo


# TODO: if verbose.
echo --- first run ---
date

echo kubectl get nodes --no-headers -o=custom-columns=NAME:metadata.name   \
        -l "$NODELABEL"="$NODEVALUE" --field-selector metadata.name="$NODEHOST"
kubectl get nodes --no-headers -o=custom-columns=NAME:metadata.name   \
        -l "$NODELABEL"="$NODEVALUE" --field-selector metadata.name="$NODEHOST"
# /verbose

while true; do

   sleep $SLEEPTIME
   date

   # Run command, capturing how many lines (0 or 1) returned
   FOUND=$( 
     kubectl get nodes --no-headers -o=custom-columns=NAME:metadata.name   \
             -l "$NODELABEL"="$NODEVALUE" --field-selector metadata.name="$NODEHOST" | wc -l 
   )

   if [ "$FOUND" -eq 1 ]; then
      echo "label in place; sleeping"
      continue
   fi


   # else self descruct

   # todo: show labels if verbose

   echo 'LABEL missing; self destruct'
   echo kubectl -n $NAMESPACE delete pod/$PODNAME
   kubectl -n $NAMESPACE delete pod/$PODNAME


done



