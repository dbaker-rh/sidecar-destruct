# sidecar-destruct

## What is this?

Q. What is this?

A. It's a simple system to permit a pod to self-destruct by means
of a sidecar container.

Q. Why?

A. Kubernetes has a well developed concept of nodeSelector (simple) or
nodeAffinity (more complex) to determine where pods will be scheduled.

However, under nodeAffinity there are only vague and future looking
mentions of `requiredDuringSchedulingRequiredDuringExecution` such as
in https://github.com/kubernetes/kubernetes/issues/96149

For my personal kubernetes cluster I have various pods that run based 
on USB devices being available.  It's easy to schedule the pods to run
based on where the USB is, or wait until a corresponding USB device
is plugged in.  It's hard to force those pods to fail and wait to
reschedule (e.g. on a different node) if the USB device gets 
disconnected.

This small hack solves that problem.


## How do I use it?

See https://github.com/kubernetes-sigs/node-feature-discovery for an easy way to automatically
label nodes based on what USB devices are connected.  

ClusterRole, ClusterRoleBinding need to be installed cluster wide.  Rename if you wish.

Role, RoleBinding, ServiceAccount need to be installed in your specific namespace.  Rename, again, if you want.

See the sample deploy/deployment.yaml for how to configure your sidecar container and add the pertinent bits to your own pod.


See the sample udev rules file for creating hardlinks (which can be passed in) based on USB ident
rather than sequential discovery.  This is particularly important for multiple tty devices, such
as both zigbee and zwave radios in different USB controllers.



## Use Cases

Any time you want to schedule, and then unschedule a pod from running
based on node labels.

* Presence / absence of removable devices
* Time based labelling (e.g. resources become available for use during non peak hours)
* ...



## Base Images

Using Fedora, or others, we can install kubectl via package manager.

However -- for the sake of running this on my micro cluster, I've put a high priority on tiny images.

* Alpine -- 60MB  
* Fedora (minimal) -- 190MB  
* Fedora (regular) -- 320MB  

So, for the time being, I'm using alpine.


## TODO

Create multi-arch images for amd64/arm64; my cluster is a mix of intel, amd and rPi nodes.

Tidy stuff up


## Questions?

Ask me.


