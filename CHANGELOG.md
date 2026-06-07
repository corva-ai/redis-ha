# Changelog

All notable changes to this Helm chart will be documented in this file.

This project follows [Conventional Commits](https://www.conventionalcommits.org/) and uses [release-please](https://github.com/googleapis/release-please) to automate version bumps and changelog entries. Each merge to `main` may open or update a release pull request; merging that PR triggers [chart-releaser-action](https://github.com/helm/chart-releaser-action) to package the chart, create a tagged GitHub Release, and update the Helm repository index on the `gh-pages` branch.

Releases prior to the introduction of this changelog (chart versions ≤ `4.35.10`) are recorded in the project's [git history](https://github.com/corva-ai/redis-ha/commits/main) and inherited from the upstream [DandyDeveloper/charts](https://github.com/DandyDeveloper/charts) repository. The breaking-change notes below were carried over from the upstream chart's `README.md`.

## Historical breaking changes (inherited from upstream)

## [5.0.0](https://github.com/corva-ai/redis-ha/compare/5.1.0...5.0.0) (2026-06-07)


### Features

* Add ability to define priorityClassName globally ([#279](https://github.com/corva-ai/redis-ha/issues/279)) ([61dbe86](https://github.com/corva-ai/redis-ha/commit/61dbe860a2519e70033de651a59593ba2de8e8ac))
* add prometheus rules support ([bed9947](https://github.com/corva-ai/redis-ha/commit/bed9947ac5b096933155834e3695eaa63dcd86de))
* alpine image support by config-init ([#4](https://github.com/corva-ai/redis-ha/issues/4)) ([40fa206](https://github.com/corva-ai/redis-ha/commit/40fa20645c6707d015647e5032aff0d64cb7ffa3))
* **configs.tpl:** add redispatch, tcp-smart-connect, and tcp-smart-accept options to HAProxy configuration for improved connection handling ([3d24bd7](https://github.com/corva-ai/redis-ha/commit/3d24bd7193ef853d31bb4766889e37622f642280))
* **README.md, templates, values.yaml:** update image tags and add HAProxy global config support ([330a338](https://github.com/corva-ai/redis-ha/commit/330a33815049ad82190777e59167191f2e93fe36))
* **redis-ha:** add containerSecurityContext to redis-exporter container ([#236](https://github.com/corva-ai/redis-ha/issues/236)) ([169cad7](https://github.com/corva-ai/redis-ha/commit/169cad792a9193844990ac6b355f7b27b607d6fb))
* **redis-ha:** add high availability Redis setup with HAProxy ([82cd3b0](https://github.com/corva-ai/redis-ha/commit/82cd3b009e0a2911a93b08820d466c7905826913))
* **redis-ha:** Add tls ports to netpol if defined ([#313](https://github.com/corva-ai/redis-ha/issues/313)) ([d4f5cee](https://github.com/corva-ai/redis-ha/commit/d4f5ceefcf946e53d0c9f174209ee04056e46e1e))
* **redis:** enhance failover handling with preStop hooks ([a8ed8de](https://github.com/corva-ai/redis-ha/commit/a8ed8defcff3191eb318026205e46cd1a69015ba))
* **values.yaml:** update HAProxy timeout settings for improved idle connection handling ([6527599](https://github.com/corva-ai/redis-ha/commit/6527599902cf05c3f950e51ed5bfb8c8e40fbba9))


### Bug Fixes

* haproxy init image if missing sh ([#2](https://github.com/corva-ai/redis-ha/issues/2)) ([5ec8cc6](https://github.com/corva-ai/redis-ha/commit/5ec8cc6d99c4c4093a3b891444d0f33ea998910c))
* move sysctl parameters documentation in values.yaml ([399641e](https://github.com/corva-ai/redis-ha/commit/399641ec472e44c6201ca79ad89ed625ddf3b018))
* publishNotReadyAddresses K8s version check ([#242](https://github.com/corva-ai/redis-ha/issues/242)) ([f2f71d5](https://github.com/corva-ai/redis-ha/commit/f2f71d5c8f97b1021ec2c99858da5f6eceafe153))
* **redis-ha:** add apiVersion/kind to volumeClaimTemplates ([#284](https://github.com/corva-ai/redis-ha/issues/284)) ([1ce6651](https://github.com/corva-ai/redis-ha/commit/1ce665106d221585503694057e319b9e6364292f))
* **redis-ha:** match pdb selectors with sts selectors ([#315](https://github.com/corva-ai/redis-ha/issues/315)) ([48189ab](https://github.com/corva-ai/redis-ha/commit/48189ab00d40ce80c349c7ce74ab85fb6b818e33))
* **redis-ha:** Support haproxy config with redisport = 0 ([#311](https://github.com/corva-ai/redis-ha/issues/311)) ([697cba5](https://github.com/corva-ai/redis-ha/commit/697cba5525ad9fdf591c9fe266f9f7625a197536))
* **templates:** add validation for redis and sentinel password fields to ensure required values are provided when authentication is enabled ([88806ce](https://github.com/corva-ai/redis-ha/commit/88806ce8bcc3033c21403b88d681ae2d596c2224))
* **templates:** correct conditional checks for redis and sentinel ports to ensure proper TLS configuration ([88806ce](https://github.com/corva-ai/redis-ha/commit/88806ce8bcc3033c21403b88d681ae2d596c2224))
* use supported version of kindest/node ([#347](https://github.com/corva-ai/redis-ha/issues/347)) ([7569ac7](https://github.com/corva-ai/redis-ha/commit/7569ac7e65166ba5dad859d49f853bf014bf6532))


### Miscellaneous Chores

* force next release to 5.0.0 ([e82f26f](https://github.com/corva-ai/redis-ha/commit/e82f26fa17ff588756701b0f2ae460afa8673b22))

## [5.1.0](https://github.com/corva-ai/redis-ha/compare/5.0.1...5.1.0) (2026-06-07)


### Features

* alpine image support by config-init ([#4](https://github.com/corva-ai/redis-ha/issues/4)) ([40fa206](https://github.com/corva-ai/redis-ha/commit/40fa20645c6707d015647e5032aff0d64cb7ffa3))

## [5.0.1](https://github.com/corva-ai/redis-ha/compare/5.0.0...5.0.1) (2026-06-06)


### Bug Fixes

* haproxy init image if missing sh ([#2](https://github.com/corva-ai/redis-ha/issues/2)) ([5ec8cc6](https://github.com/corva-ai/redis-ha/commit/5ec8cc6d99c4c4093a3b891444d0f33ea998910c))

## [5.0.0](https://github.com/corva-ai/redis-ha/compare/4.35.10...5.0.0) (2026-05-19)


### Features

* **configs.tpl:** add redispatch, tcp-smart-connect, and tcp-smart-accept options to HAProxy configuration for improved connection handling ([3d24bd7](https://github.com/corva-ai/redis-ha/commit/3d24bd7193ef853d31bb4766889e37622f642280))
* **README.md, templates, values.yaml:** update image tags and add HAProxy global config support ([330a338](https://github.com/corva-ai/redis-ha/commit/330a33815049ad82190777e59167191f2e93fe36))
* **redis-ha:** add high availability Redis setup with HAProxy ([82cd3b0](https://github.com/corva-ai/redis-ha/commit/82cd3b009e0a2911a93b08820d466c7905826913))
* **redis:** enhance failover handling with preStop hooks ([a8ed8de](https://github.com/corva-ai/redis-ha/commit/a8ed8defcff3191eb318026205e46cd1a69015ba))
* **values.yaml:** update HAProxy timeout settings for improved idle connection handling ([6527599](https://github.com/corva-ai/redis-ha/commit/6527599902cf05c3f950e51ed5bfb8c8e40fbba9))


### Bug Fixes

* **templates:** add validation for redis and sentinel password fields to ensure required values are provided when authentication is enabled ([88806ce](https://github.com/corva-ai/redis-ha/commit/88806ce8bcc3033c21403b88d681ae2d596c2224))
* **templates:** correct conditional checks for redis and sentinel ports to ensure proper TLS configuration ([88806ce](https://github.com/corva-ai/redis-ha/commit/88806ce8bcc3033c21403b88d681ae2d596c2224))


### Miscellaneous Chores

* force next release to 5.0.0 ([e82f26f](https://github.com/corva-ai/redis-ha/commit/e82f26fa17ff588756701b0f2ae460afa8673b22))

### 4.21.0 — Kubernetes deprecation (PSP → seccompProfile)

This version introduced the deprecation of PodSecurityPolicy and added `seccompProfile` fields to the security contexts (introduced in Kubernetes 1.19). See <https://kubernetes.io/docs/tutorials/security/seccomp/>.

As a result, from this version onwards Kubernetes versions older than 1.19 will fail to install without removing `.Values.containerSecurityContext.seccompProfile` and `.Values.haproxy.containerSecurityContext.seccompProfile` (if HAProxy is enabled). The 4.35.x fork now enforces this via `Chart.yaml: kubeVersion: ">= 1.25.0-0"`, so the breakage is no longer reachable on supported clusters.

### 4.0.0 — HAProxy sidecar prometheus-exporter removed

Starting with chart version `4.x`, the standalone HAProxy sidecar prometheus-exporter was removed in favour of the embedded [HAProxy metrics endpoint](https://github.com/haproxy/haproxy/tree/master/contrib/prometheus-exporter). When upgrading from a `3.x` release, drop any `haproxy.exporter` settings from your values file and configure `haproxy.metrics` instead.

### 3.0.0 — Redis management strategy simplified; RBAC removed

The 3.x line simplified the failover/election strategy so the chart could use the official [redis](https://hub.docker.com/_/redis/) images without bespoke RBAC. When upgrading from `>=2.0.1` to `>=3.0.0`, the stale `Role`, `RoleBinding`, and `ServiceAccount` objects left over from the 2.x line must be deleted manually — `helm upgrade` does not remove them.

### 4.14.9 — HAProxy port keys renamed (potential breaking change)

Introduced the ability to change the HAProxy Deployment container port independently of the Redis port. Two keys moved:

- Container port in `redis-haproxy-deployment.yaml` changed from `redis.port` to `haproxy.containerPort` (default `6379`).
- Service port in `redis-haproxy-service.yaml` changed from `redis.port` to `haproxy.servicePort` (default `6379`).

If you previously overrode `redis.port` to reroute HAProxy, migrate that override to `haproxy.containerPort` / `haproxy.servicePort`.
