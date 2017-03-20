Kubernetes for Digital Rebar
============================ 

Please see http://rebar.digital for details.

Status
------

Kargo-based install of Kubernetes with dashboard and examples.

Objective
---------

Decompose Kubernetes installation into composable units so that each role is stand alone.  For now, we are using Ansible primarily to perform functions, but individual roles could be replaced with other DSLs or even directly with bash instructions.

The goal of the decomposition is to isolate individual services as much as possible.  Variables passed into each role should be specific to those needed for that function.

Defaults: see group_vars/*.yml - many of these vars are injected through attributes.

Design Decisions
----------------

The following items are recognized as principles for the Kompos8 scripts:

  1. To streamline development, Kompos8 will require SystemD.
  #. For Ansible, we will avoid using unneeded variables and default() in the plays.  We would rather have them fail quickly when information is missing.

Architecture Requirements
-------------------------

  1. Do not comingle services but allow them to co-exist
  #. Must be multi-node

Naming & Conventions
--------------------

Kompos8 is a play on "composate" with the K (for Kubernetes or k8s) substituted for C and 8 (for 8 in k8s) substituted for ate.  The idea is to have a composable install.

Variables in the workload should be nested and generally follow:

  * k8s. for kubernetes items with additional grouping
  * cluster. for cluster items
  * provider. for provider (e.g. cloud) items
  * rebar. for rebar specific items
  * user. for Kubernetes user items (account is the service account)


Kubernetes Add-ons
==================

DigitalRebar provides the additional Kubernetes services and add-ons.
The following barclamps enhance and extend an existing Kubernetes
deployment.

#  ElasticSearch, Fluentd, Kibana logging (efk-logging)

This is a log search and aggregation system for all containers in the 
system including the Kuberenetes components.  Remaining production
concern is persistent storage for ES.

#  Prometheus-based Monitoring (prometheus-monitoring)

This is a monitoring system using Prometheus.  This deploys Prometheus and
sets up some initial dashboards in Grafana as well.

**NOTE**: Choose either Prometheus or Heapster, not both.  Both can run.

#  Heapster-based Monitoring (heapster-monitoring)

This is a monitoring system using Heapster.  This deploys Heapster and
sets up some initial dashboards in Grafana as well.

**NOTE**: Choose either Prometheus or Heapster, not both.  Both can run.

# Helm

This deploys the Helm management system (non-classic).  This sets up
the helm client on the master and starts the Tiller system in the 
cluster.

# DEIS

Using Helm, this will deploy and start the Deis Workflow components.


# Openstack 

Using https://github.com/att-comdev/openstack-helm, the system will
deploy a ceph cluster and other components inside a running Kubernetes
cluster.

