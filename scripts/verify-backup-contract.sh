#!/usr/bin/env bash

set -euo pipefail

scenario=ci/backup-enabled-values.yaml

if [[ ! -f "$scenario" ]]; then
  echo "::error::$scenario is required by the Redis backup contract"
  exit 1
fi

work_dir=$(mktemp -d)
trap 'rm -rf "$work_dir"' EXIT

helm template contract . --namespace contract-ns > "$work_dir/default.yaml"
helm template contract . --namespace contract-ns -f "$scenario" > "$work_dir/enabled.yaml"

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
assert_value '.spec.jobTemplate.spec.template.spec.containers[0].env[] | select(.name == "RETENTION_DAYS").value' '7' 'backup.retentionDays propagation'
assert_value '.spec.jobTemplate.spec.template.spec.containers[0].env[] | select(.name == "S3_ENDPOINT").value' 'http://garage-storage:3900' 'backup.s3.endpoint propagation'
assert_value '.spec.jobTemplate.spec.template.spec.containers[0].env[] | select(.name == "S3_BUCKET").value' 'corva-redis-backups' 'backup.s3.bucket propagation'
assert_value '.spec.jobTemplate.spec.template.spec.containers[0].env[] | select(.name == "S3_PREFIX").value' 'contract/contract-ns/contract' 'templated backup.s3.prefix propagation'
assert_value '.spec.jobTemplate.spec.template.spec.containers[0].env[] | select(.name == "AWS_ACCESS_KEY_ID").valueFrom.secretKeyRef.name' 'redis-backup-s3' 'access key Secret reference'
assert_value '.spec.jobTemplate.spec.template.spec.containers[0].env[] | select(.name == "AWS_SECRET_ACCESS_KEY").valueFrom.secretKeyRef.name' 'redis-backup-s3' 'secret key Secret reference'

alerts=$(yq eval-all '[select(.kind == "PrometheusRule" and .metadata.labels."app.kubernetes.io/component" == "redis-backup").spec.groups[].rules[].alert] | sort | join(",")' "$work_dir/enabled.yaml")
expected_alerts='RedisBackupRunningTooLong,RedisBackupStale,RedisBackupSuspended'
if [[ "$alerts" != "$expected_alerts" ]]; then
  echo "::error::Expected backup alerts '$expected_alerts', rendered '$alerts'"
  exit 1
fi

echo "Redis backup contract verified"
