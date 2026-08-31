#!/usr/bin/env bash

set -euo pipefail

scenario=ci/backup-enabled-values.yaml
timezone_scenario=testdata/backup-timezone-values.yaml
kube_version=1.27.0

if [[ ! -f "$scenario" || ! -f "$timezone_scenario" ]]; then
  echo "::error::$scenario and $timezone_scenario are required by the Redis backup contract"
  exit 1
fi

work_dir=$(mktemp -d)
trap 'rm -rf "$work_dir"' EXIT

helm template contract . --namespace contract-ns --kube-version "$kube_version" > "$work_dir/default.yaml"
helm template contract . --namespace contract-ns --kube-version "$kube_version" -f "$scenario" -f "$timezone_scenario" --set backup.prometheusRule.enabled=true > "$work_dir/enabled.yaml"
helm template contract . --namespace contract-ns --kube-version "$kube_version" -f "$scenario" -f ci/network-policy-values.yaml > "$work_dir/network-policy.yaml"

assert_count() {
  local expected=$1
  local expression=$2
  local description=$3
  local actual

  actual=$(yq eval-all "[$expression] | length" "$work_dir/enabled.yaml")
  if [[ "$actual" != "$expected" ]]; then
    echo "::error::Expected $expected $description, rendered $actual"
    exit 1
  fi
}

default_backup_resources=$(yq eval-all '[select(.kind == "CronJob" or .kind == "PrometheusRule") | select(.metadata.labels."app.kubernetes.io/component" == "redis-backup")] | length' "$work_dir/default.yaml")
if [[ "$default_backup_resources" != 0 ]]; then
  echo "::error::Backup resources must remain opt-in; default values rendered $default_backup_resources resource(s)"
  exit 1
fi

assert_count 1 'select(.kind == "CronJob" and .metadata.labels."app.kubernetes.io/component" == "redis-backup")' 'Redis backup CronJob'
assert_count 1 'select(.kind == "PrometheusRule" and .metadata.labels."app.kubernetes.io/component" == "redis-backup")' 'Redis backup PrometheusRule'

cronjob="$work_dir/cronjob.yaml"
yq eval 'select(.kind == "CronJob" and .metadata.labels."app.kubernetes.io/component" == "redis-backup")' "$work_dir/enabled.yaml" > "$cronjob"

assert_value() {
  local expression=$1
  local expected=$2
  local description=$3
  local actual

  actual=$(yq eval -r "$expression" "$cronjob")
  if [[ "$actual" != "$expected" ]]; then
    echo "::error::$description: expected '$expected', rendered '$actual'"
    exit 1
  fi
}

assert_value '.spec.schedule' '17 3 * * *' 'backup.schedule propagation'
assert_value '.spec.timeZone' 'UTC' 'backup.timeZone propagation'
assert_value '.metadata.labels.ownership' 'platform' 'extraLabels propagation to backup CronJob'
assert_value '.spec.jobTemplate.metadata.labels.ownership' 'platform' 'extraLabels propagation to backup Job'
assert_value '.spec.jobTemplate.spec.template.metadata.labels.ownership' 'platform' 'extraLabels propagation to backup Pod'
assert_value '.spec.jobTemplate.spec.template.spec.containers[0].env[] | select(.name == "REDIS_PORT").value' '6381' 'derived backup.redis.port propagation'
assert_value '.spec.jobTemplate.spec.template.spec.containers[0].env[] | select(.name == "RETENTION_DAYS").value' '7' 'backup.retentionDays propagation'
assert_value '.spec.jobTemplate.spec.template.spec.containers[0].env[] | select(.name == "S3_ENDPOINT").value' 'http://garage-storage:3900' 'backup.s3.endpoint propagation'
assert_value '.spec.jobTemplate.spec.template.spec.containers[0].env[] | select(.name == "S3_BUCKET").value' 'corva-redis-ha-backups' 'backup.s3.bucket propagation'
assert_value '.spec.jobTemplate.spec.template.spec.containers[0].env[] | select(.name == "S3_PREFIX").value' 'contract/contract-ns/contract' 'templated backup.s3.prefix propagation'
assert_value '.spec.jobTemplate.spec.template.spec.containers[0].env[] | select(.name == "AWS_ACCESS_KEY_ID").valueFrom.secretKeyRef.name' 'redis-ha-backup-s3' 'access key Secret reference'
assert_value '.spec.jobTemplate.spec.template.spec.containers[0].env[] | select(.name == "AWS_SECRET_ACCESS_KEY").valueFrom.secretKeyRef.name' 'redis-ha-backup-s3' 'secret key Secret reference'

network_policy_cronjob="$work_dir/network-policy-cronjob.yaml"
yq eval 'select(.kind == "CronJob" and .metadata.labels."app.kubernetes.io/component" == "redis-backup")' "$work_dir/network-policy.yaml" > "$network_policy_cronjob"
network_policy_backup_app=$(yq eval -r '.spec.jobTemplate.spec.template.metadata.labels.app' "$network_policy_cronjob")
if [[ "$network_policy_backup_app" != "redis-ha-backup" ]]; then
  echo "::error::Backup pod must not match the Redis Service and NetworkPolicy selector; rendered app label '$network_policy_backup_app'"
  exit 1
fi

haproxy_backup_ingress=$(yq eval-all '[select(.kind == "NetworkPolicy" and .metadata.name == "contract-redis-ha-haproxy-network-policy").spec.ingress[].from[]?.podSelector.matchLabels | select(.release == "contract" and .app == "redis-ha-backup" and .component == "redis-backup")] | length' "$work_dir/network-policy.yaml")
if [[ "$haproxy_backup_ingress" != "1" ]]; then
  echo "::error::HAProxy NetworkPolicy must allow the backup pod; rendered $haproxy_backup_ingress matching ingress rule(s)"
  exit 1
fi

haproxy_backup_port=$(yq eval -r 'select(.kind == "NetworkPolicy" and .metadata.name == "contract-redis-ha-haproxy-network-policy").spec.ingress[] | select(.from[0].podSelector.matchLabels.app == "redis-ha-backup").ports[0].port' "$work_dir/network-policy.yaml")
if [[ "$haproxy_backup_port" != "6382" ]]; then
  echo "::error::HAProxy NetworkPolicy must allow backup traffic on haproxy.containerPort; rendered '$haproxy_backup_port'"
  exit 1
fi

alerts=$(yq eval-all '[select(.kind == "PrometheusRule" and .metadata.labels."app.kubernetes.io/component" == "redis-backup").spec.groups[].rules[].alert] | sort | join(",")' "$work_dir/enabled.yaml")
expected_alerts='RedisBackupRunningTooLong,RedisBackupStale,RedisBackupSuspended'
if [[ "$alerts" != "$expected_alerts" ]]; then
  echo "::error::Expected backup alerts '$expected_alerts', rendered '$alerts'"
  exit 1
fi

backup_rule="$work_dir/backup-rule.yaml"
yq eval 'select(.kind == "PrometheusRule" and .metadata.labels."app.kubernetes.io/component" == "redis-backup")' "$work_dir/enabled.yaml" > "$backup_rule"
backup_rule_ownership=$(yq eval -r '.metadata.labels.ownership' "$backup_rule")
if [[ "$backup_rule_ownership" != "platform" ]]; then
  echo "::error::extraLabels must propagate to the backup PrometheusRule; rendered '$backup_rule_ownership'"
  exit 1
fi
running_alert_expr=$(yq eval -r '.spec.groups[].rules[] | select(.alert == "RedisBackupRunningTooLong").expr' "$backup_rule")
if [[ "$running_alert_expr" != *'kube_job_owner'* || "$running_alert_expr" == *'kube_job_labels'* ]]; then
  echo "::error::RedisBackupRunningTooLong must select Jobs through kube_job_owner instead of kube_job_labels"
  exit 1
fi

if helm template contract . --namespace contract-ns -f "$scenario" -f ci/backup-haproxy-tls-values.yaml > "$work_dir/tls.yaml" 2>&1; then
  echo "::error::backup.enabled with haproxy.tls.enabled must fail until backup TLS support is implemented"
  exit 1
fi

if helm template contract . --namespace contract-ns --kube-version 1.26.0 -f "$scenario" -f "$timezone_scenario" > "$work_dir/timezone.yaml" 2>&1; then
  echo "::error::backup.timeZone must fail for Kubernetes versions before 1.27"
  exit 1
fi

long_fullname_a='redis-ha-backup-uniqueness-test-name-000000000001'
long_fullname_b='redis-ha-backup-uniqueness-test-name-000000000002'
helm template contract-a . --namespace contract-ns --kube-version "$kube_version" -f "$scenario" --set backup.prometheusRule.enabled=true --set fullnameOverride="$long_fullname_a" > "$work_dir/long-name-a.yaml"
helm template contract-b . --namespace contract-ns --kube-version "$kube_version" -f "$scenario" --set backup.prometheusRule.enabled=true --set fullnameOverride="$long_fullname_b" > "$work_dir/long-name-b.yaml"
backup_name_a=$(yq eval -r 'select(.kind == "CronJob" and .metadata.labels."app.kubernetes.io/component" == "redis-backup").metadata.name' "$work_dir/long-name-a.yaml")
backup_name_b=$(yq eval -r 'select(.kind == "CronJob" and .metadata.labels."app.kubernetes.io/component" == "redis-backup").metadata.name' "$work_dir/long-name-b.yaml")
if [[ "$backup_name_a" == "$backup_name_b" || ${#backup_name_a} -gt 52 || ${#backup_name_b} -gt 52 || "$backup_name_a" != *-backup || "$backup_name_b" != *-backup ]]; then
  echo "::error::Long Redis HA fullnames must produce distinct CronJob-safe backup names ending in -backup"
  exit 1
fi

echo "Redis backup contract verified"
