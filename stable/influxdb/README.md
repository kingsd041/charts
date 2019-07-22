# influxdb-relay

A Helm chart to deploy an influxdb-relay kubernetes deployment.

##  An Open-Source Time Series Database

[InfluxDB](https://github.com/influxdata/influxdb) is an open source time series database built by the folks over at [InfluxData](https://influxdata.com) with no external dependencies. It's useful for recording metrics, events, and performing analytics.

[influxdb-relay](https://github.com/influxdata/influxdb-relay) is a relay service that can be deployed in front of several InfluxDB instances. It will relay writes to those several instances, making any writes to the databases eventually consistent. It can therefore allow for some form of HA without investing in an Enterprise InfluxDB clustered solution.

## Quickstart

Clone this repository then `helm install --name foo --namsespace bar <path/to/chart>`. 

## Introduction

This chart bootstraps an influxdb-relay deployment and service on a Kubernetes cluster using the Helm Package manager.

## Prerequisites

- Kubernetes 1.8+

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
$ git clone git@github.com:ahibbitt/charts.git
$ helm install --name my-release charts/influxdb-relay
```

The command deploys influxdb-relay on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release --purge
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The default configuration values for this chart are listed in `values.yaml`. 

The [full image documentation](https://hub.docker.com/ahibbitt/influxdb-relay) contains more information about running influxdb-relay in docker.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```bash
$ helm install --name my-release \
  --set service.udp_enabled=true,podAntiAffinity.enabled=true \
    charts/influxdb-relay
```

The above command enables the service to send both TCP and UDP traffic to the pod(s) and turns on AntiAffinity, spreading the pods across kubernetes nodes where possible.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml charts/influxdb-relay
```

> **Tip**: You can use the default [values.yaml](values.yaml)
