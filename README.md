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

#### port forward psql

```sh
kubectl port-forward svc/dbt-postgresql -n dbt-demo 5432
```

## dbt operations

```sh
pdm install
```

### init project

```sh
pdm run dbt init
```

all below commands running in the `./dbt_playground` sub-folder

### make sure the setup is valid

```sh
pdm run dbt debug --profiles-dir .
```

```sh
...

Configuration:
  profiles.yml file [OK found and valid]
  dbt_project.yml file [OK found and valid]

Required dependencies:
 - git [OK found]

Connection:
  host: localhost
  port: 5432
  user: postgres
  database: postgres
  schema: postgres
  search_path: None
  keepalives_idle: 0
  sslmode: None
  Connection test: [OK connection ok]

All checks passed!
```

### run the dbt project

```sh
pdm run dbt run --profiles-dir .
```

```sh
19:50:24  Running with dbt=1.3.0
19:50:24  Partial parse save file not found. Starting full parse.
19:50:25  Found 2 models, 4 tests, 0 snapshots, 0 analyses, 289 macros, 0 operations, 0 seed files, 0 sources, 0 exposures, 0 metrics
19:50:25
19:50:25  Concurrency: 1 threads (target='dev')
19:50:25
19:50:25  1 of 2 START sql table model postgres.my_first_dbt_model ....................... [RUN]
19:50:25  1 of 2 OK created sql table model postgres.my_first_dbt_model .................. [SELECT 2 in 0.14s]
19:50:25  2 of 2 START sql view model postgres.my_second_dbt_model ....................... [RUN]
19:50:25  2 of 2 OK created sql view model postgres.my_second_dbt_model .................. [CREATE VIEW in 0.11s]
19:50:26
19:50:26  Finished running 1 table model, 1 view model in 0 hours 0 minutes and 0.76 seconds (0.76s).
19:50:26
19:50:26  Completed successfully
19:50:26
19:50:26  Done. PASS=2 WARN=0 ERROR=0 SKIP=0 TOTAL=2
```

login to the postgresql to verify the tables

```sh
kubectl run local-postgresql-client --rm --tty -i --restart='Never' --namespace dbt-demo --image docker.io/bitnami/postgresql:14.5.0-debian-11-r21 --env="PGPASSWORD=demo_password" --command -- psql --host dbt-postgresql -U postgres -d postgres -p 5432
```

```sh
postgres=# select * from my_first_dbt_model;
 id
----
  1
(1 rows)
```

### run the test

```sh
pdm run dbt test --profiles-dir .
```

### check data lineage

```sh
pdm run dbt docs generate --profiles-dir .
pdm run dbt docs serve --profiles-dir .
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
- [luchonaveiro/dbt-postgres-tutorial](https://github.com/luchonaveiro/dbt-postgres-tutorial)
