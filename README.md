# dbt-playground <!-- omit in toc -->

**dbt** (Data Build Tool) is an open-source Python application that uses modular SQL queries to allow data engineers and analysts to transform data in their warehouses.

In this repo, we are using the [Kubernetes](https://kubernetes.io/) to deploy the Postgresql instances.

## prerequisites

- [Rancher Desktop](https://github.com/rancher-sandbox/rancher-desktop): `1.4.1`
- Kubernetes: `v1.24.3`
- kubectl `v1.23.3`
- Helm: `v3.9.0`
- [pdm](https://github.com/pdm-project/pdm): `2.2.1`

## setup

tl;dr: `./scripts/up.sh`

### namespace

```sh
kubectl create namespace dbt-demo --dry-run=client -o yaml | kubectl apply -f -
```

### postgresql

follow the [bitnami postgresql chart](https://github.com/bitnami/charts/tree/master/bitnami/postgresql) to install postgresql

```sh
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update bitnami
```

#### create instances

```sh
helm upgrade --install dbt-postgresql bitnami/postgresql -n dbt-demo -f postgresql/values.yaml
```

## cleanup

tl;dr: `./scripts/down.sh`

```sh
helm uninstall dbt-postgresql -n dbt-demo
kubectl delete pvc --all -n dbt-demo
kubectl delete namespace dbt-demo
```

## references

- [Getting hands-on with DBT — Data Build Tool](https://towardsdatascience.com/getting-hands-on-with-dbt-data-build-tool-a157d4151bbc)
