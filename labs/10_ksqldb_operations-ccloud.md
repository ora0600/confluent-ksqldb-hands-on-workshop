# Scale KSQLDB (Confluent Cloud steps)
Scaling in Confluent Cloud is little bit different.
Here we run so called CSU (Confluent Streaming units) with a ksqlDB cluster of 4 CSUs or 8 CSUs or 12 CSUs.
ksqlDB Apps with more than 4 CSUs are configured for HA automatically.
Additional you can have max 3 ksqlDB Apps per cluster.

You can not scale a 4 CSU ksqlDB App to 8 CSU. This is not possible. Instead provision a new ksqlDB App and migrate ksqldb scripts to the new app.

But let us check what is the difference of a 4 CSU ksqlDB App and a 8 ksqlDB App

## ksqDB Editor in Confluent Cloud
```bash
ksql> show properties;
# Output:
{
  "@type": "properties",
  "statementText": "show properties;",
  "properties": [
    {
      "name": "ksql.extension.dir",
      "scope": "KSQL",
      "value": "ext"
    },
    {
      "name": "ksql.streams.cache.max.bytes.buffering",
      "scope": "KSQL",
      "value": "10000000"
    },
    {
      "name": "ksql.security.extension.class",
      "scope": "KSQL",
      "value": null
    },
    {
      "name": "metric.reporters",
      "scope": "KSQL",
      "value": "io.confluent.telemetry.reporter.TelemetryReporter"
    },
    {
      "name": "ksql.transient.prefix",
      "scope": "KSQL",
      "value": "transient_"
    },
    {
      "name": "ksql.streams.producer.request.timeout.ms",
      "scope": "KSQL",
      "value": "300000"
    },
    {
      "name": "ksql.query.status.running.threshold.seconds",
      "scope": "KSQL",
      "value": "300"
    },
    {
      "name": "ksql.streams.default.deserialization.exception.handler",
      "scope": "KSQL",
      "value": "io.confluent.ksql.errors.LogMetricAndContinueExceptionHandler"
    },
    {
      "name": "ksql.output.topic.name.prefix",
      "scope": "KSQL",
      "value": "pksqlc-zgq9z"
    },
    {
      "name": "ksql.query.pull.enable.standby.reads",
      "scope": "KSQL",
      "value": "true"
    },
    {
      "name": "ksql.persistence.default.format.key",
      "scope": "KSQL",
      "value": "KAFKA"
    },
    {
      "name": "ksql.query.persistent.max.bytes.buffering.total",
      "scope": "KSQL",
      "value": "-1"
    },
    {
      "name": "ksql.query.error.max.queue.size",
      "scope": "KSQL",
      "value": "10"
    },
    {
      "name": "ksql.variable.substitution.enable",
      "scope": "KSQL",
      "value": "true"
    },
    {
      "name": "ksql.internal.topic.min.insync.replicas",
      "scope": "KSQL",
      "value": "2"
    },
    {
      "name": "ksql.streams.shutdown.timeout.ms",
      "scope": "KSQL",
      "value": "300000"
    },
    {
      "name": "ksql.streams.ssl.keystore.type",
      "scope": "KSQL",
      "value": "PKCS12"
    },
    {
      "name": "ksql.internal.topic.replicas",
      "scope": "KSQL",
      "value": "3"
    },
    {
      "name": "ksql.insert.into.values.enabled",
      "scope": "KSQL",
      "value": "true"
    },
    {
      "name": "ksql.query.pull.max.allowed.offset.lag",
      "scope": "KSQL",
      "value": "9223372036854775807"
    },
    {
      "name": "ksql.query.pull.max.qps",
      "scope": "KSQL",
      "value": "167"
    },
    {
      "name": "ksql.access.validator.enable",
      "scope": "KSQL",
      "value": "on"
    },
    {
      "name": "ksql.streams.sasl.mechanism",
      "scope": "KSQL",
      "value": "PLAIN"
    },
    {
      "name": "ksql.streams.bootstrap.servers",
      "scope": "KSQL",
      "value": "SASL_SSL://pkc-ep9mm.us-east-2.aws.confluent.cloud:9092"
    },
    {
      "name": "ksql.streams.sasl.jaas.config",
      "scope": "KSQL",
      "value": "[hidden]"
    },
    {
      "name": "ksql.streams.delivery.timeout.ms",
      "scope": "KSQL",
      "value": "1800000"
    },
    {
      "name": "ksql.query.pull.metrics.enabled",
      "scope": "KSQL",
      "value": "true"
    },
    {
      "name": "ksql.create.or.replace.enabled",
      "scope": "KSQL",
      "value": "true"
    },
    {
      "name": "ksql.streams.consumer.request.timeout.ms",
      "scope": "KSQL",
      "value": "300000"
    },
    {
      "name": "ksql.metrics.extension",
      "scope": "KSQL",
      "value": "io.confluent.cloud.ksql.engine.metrics.KsqlMetricsExtensionImpl"
    },
    {
      "name": "ksql.hidden.topics",
      "scope": "KSQL",
      "value": "_confluent.*,__confluent.*,_schemas,__consumer_offsets,__transaction_state,connect-configs,connect-offsets,connect-status,connect-statuses"
    },
    {
      "name": "ksql.cast.strings.preserve.nulls",
      "scope": "KSQL",
      "value": "true"
    },
    {
      "name": "ksql.authorization.cache.max.entries",
      "scope": "KSQL",
      "value": "10000"
    },
    {
      "name": "ksql.pull.queries.enable",
      "scope": "KSQL",
      "value": "true"
    },
    {
      "name": "ksql.lambdas.enabled",
      "scope": "KSQL",
      "value": "true"
    },
    {
      "name": "ksql.streams.retry.backoff.ms",
      "scope": "KSQL",
      "value": "500"
    },
    {
      "name": "ksql.streams.producer.compression.type",
      "scope": "KSQL",
      "value": "snappy"
    },
    {
      "name": "ksql.suppress.enabled",
      "scope": "KSQL",
      "value": "false"
    },
    {
      "name": "ksql.streams.ssl.key.password",
      "scope": "KSQL",
      "value": "[hidden]"
    },
    {
      "name": "ksql.sink.window.change.log.additional.retention",
      "scope": "KSQL",
      "value": "1000000"
    },
    {
      "name": "ksql.readonly.topics",
      "scope": "KSQL",
      "value": "_confluent.*,__confluent.*,_schemas,__consumer_offsets,__transaction_state,connect-configs,connect-offsets,connect-status,connect-statuses"
    },
    {
      "name": "ksql.query.persistent.active.limit",
      "scope": "KSQL",
      "value": "20"
    },
    {
      "name": "ksql.streams.ssl.keystore.password",
      "scope": "KSQL",
      "value": "[hidden]"
    },
    {
      "name": "ksql.streams.producer.acks",
      "scope": "KSQL",
      "value": "all"
    },
    {
      "name": "ksql.streams.producer.retries",
      "scope": "KSQL",
      "value": "2147483647"
    },
    {
      "name": "ksql.persistence.wrap.single.values",
      "scope": "KSQL",
      "value": null
    },
    {
      "name": "ksql.streams.request.timeout.ms",
      "scope": "KSQL",
      "value": "20000"
    },
    {
      "name": "ksql.authorization.cache.expiry.time.secs",
      "scope": "KSQL",
      "value": "30"
    },
    {
      "name": "ksql.query.retry.backoff.initial.ms",
      "scope": "KSQL",
      "value": "15000"
    },
    {
      "name": "ksql.streams.ssl.endpoint.identification.algorithm",
      "scope": "KSQL",
      "value": "https"
    },
    {
      "name": "ksql.streams.num.standby.replicas",
      "scope": "KSQL",
      "value": "0"
    },
    {
      "name": "ksql.streams.security.protocol",
      "scope": "KSQL",
      "value": "SASL_SSL"
    },
    {
      "name": "ksql.query.transient.max.bytes.buffering.total",
      "scope": "KSQL",
      "value": "-1"
    },
    {
      "name": "ksql.schema.registry.url",
      "scope": "KSQL",
      "value": "https://psrc-lq3wm.eu-central-1.aws.confluent.cloud"
    },
    {
      "name": "ksql.properties.overrides.denylist",
      "scope": "KSQL",
      "value": "ksql.streams.num.stream.threads,ksql.suppress.buffer.size,ksql.suppress.enabled"
    },
    {
      "name": "ksql.query.pull.max.concurrent.requests",
      "scope": "KSQL",
      "value": "10"
    },
    {
      "name": "ksql.streams.auto.offset.reset",
      "scope": "KSQL",
      "value": "latest"
    },
    {
      "name": "ksql.connect.url",
      "scope": "KSQL",
      "value": "http://localhost:8083"
    },
    {
      "name": "ksql.service.id",
      "scope": "KSQL",
      "value": "pksqlc-zgq9z"
    },
    {
      "name": "ksql.functions.collect_set.limit",
      "scope": "KSQL",
      "value": "[hidden]"
    },
    {
      "name": "ksql.streams.state.dir",
      "scope": "KSQL",
      "value": "/mnt/data/data/ksql-state"
    },
    {
      "name": "ksql.streams.default.production.exception.handler",
      "scope": "KSQL",
      "value": "io.confluent.ksql.errors.ProductionExceptionHandlerUtil$LogAndContinueProductionExceptionHandler"
    },
    {
      "name": "ksql.streams.ssl.keystore.location",
      "scope": "KSQL",
      "value": "/mnt/sslcerts/pkcs.p12"
    },
    {
      "name": "ksql.query.pull.interpreter.enabled",
      "scope": "KSQL",
      "value": "true"
    },
    {
      "name": "ksql.streams.commit.interval.ms",
      "scope": "KSQL",
      "value": "30000"
    },
    {
      "name": "ksql.query.pull.table.scan.enabled",
      "scope": "KSQL",
      "value": "false"
    },
    {
      "name": "ksql.streams.consumer.default.api.timeout.ms",
      "scope": "KSQL",
      "value": "300000"
    },
    {
      "name": "ksql.streams.replication.factor",
      "scope": "KSQL",
      "value": "3"
    },
    {
      "name": "ksql.streams.topology.optimization",
      "scope": "KSQL",
      "value": "all"
    },
    {
      "name": "ksql.query.retry.backoff.max.ms",
      "scope": "KSQL",
      "value": "900000"
    },
    {
      "name": "ksql.streams.num.stream.threads",
      "scope": "KSQL",
      "value": "1"
    },
    {
      "name": "ksql.timestamp.throw.on.invalid",
      "scope": "KSQL",
      "value": "false"
    },
    {
      "name": "ksql.metrics.tags.custom",
      "scope": "KSQL",
      "value": "logical_cluster_id:lksqlc-q78m6"
    },
    {
      "name": "ksql.persistence.default.format.value",
      "scope": "KSQL",
      "value": null
    },
    {
      "name": "ksql.udfs.enabled",
      "scope": "KSQL",
      "value": "true"
    },
    {
      "name": "ksql.udf.enable.security.manager",
      "scope": "KSQL",
      "value": "true"
    },
    {
      "name": "ksql.connect.worker.config",
      "scope": "KSQL",
      "value": ""
    },
    {
      "name": "ksql.streams.application.server",
      "scope": "KSQL",
      "value": "https://ksql-0.ksql.pksqlc-zgq9z.svc.cluster.local:9199"
    },
    {
      "name": "ksql.streams.ssl.enabled.protocols",
      "scope": "KSQL",
      "value": "TLSv1.2"
    },
    {
      "name": "ksql.streams.producer.max.block.ms",
      "scope": "KSQL",
      "value": "300000"
    },
    {
      "name": "ksql.streams.rocksdb.config.setter",
      "scope": "KSQL",
      "value": "io.confluent.ksql.rocksdb.KsqlBoundedMemoryRocksDBConfigSetter"
    },
    {
      "name": "ksql.functions.collect_list.limit",
      "scope": "KSQL",
      "value": "[hidden]"
    },
    {
      "name": "ksql.udf.collect.metrics",
      "scope": "KSQL",
      "value": "false"
    },
    {
      "name": "ksql.query.pull.thread.pool.size",
      "scope": "KSQL",
      "value": "100"
    },
    {
      "name": "ksql.persistent.prefix",
      "scope": "KSQL",
      "value": "query_"
    },
    {
      "name": "ksql.metastore.backup.location",
      "scope": "KSQL",
      "value": "/mnt/data/data/ksql-command-backups"
    },
    {
      "name": "ksql.streams.metric.reporters",
      "scope": "KSQL",
      "value": "io.confluent.telemetry.reporter.TelemetryReporter"
    },
    {
      "name": "ksql.error.classifier.regex",
      "scope": "KSQL",
      "value": ""
    },
    {
      "name": "ksql.suppress.buffer.size.bytes",
      "scope": "KSQL",
      "value": "-1"
    }
  ],
  "overwrittenProperties": [
    "ksql.streams.auto.offset.reset"
  ],
  "defaultProperties": [
    "ksql.extension.dir",
    "ksql.security.extension.class",
    "ksql.transient.prefix",
    "ksql.query.status.running.threshold.seconds",
    "ksql.persistence.default.format.key",
    "ksql.query.persistent.max.bytes.buffering.total",
    "ksql.query.error.max.queue.size",
    "ksql.variable.substitution.enable",
    "ksql.insert.into.values.enabled",
    "ksql.query.pull.max.allowed.offset.lag",
    "ksql.query.pull.metrics.enabled",
    "ksql.create.or.replace.enabled",
    "ksql.hidden.topics",
    "ksql.cast.strings.preserve.nulls",
    "ksql.authorization.cache.max.entries",
    "ksql.pull.queries.enable",
    "ksql.lambdas.enabled",
    "ksql.suppress.enabled",
    "ksql.sink.window.change.log.additional.retention",
    "ksql.readonly.topics",
    "ksql.streams.producer.retries",
    "ksql.persistence.wrap.single.values",
    "ksql.authorization.cache.expiry.time.secs",
    "ksql.query.retry.backoff.initial.ms",
    "ksql.streams.ssl.endpoint.identification.algorithm",
    "ksql.streams.num.standby.replicas",
    "ksql.query.transient.max.bytes.buffering.total",
    "ksql.streams.auto.offset.reset",
    "ksql.connect.url",
    "ksql.query.pull.interpreter.enabled",
    "ksql.streams.commit.interval.ms",
    "ksql.query.pull.table.scan.enabled",
    "ksql.query.retry.backoff.max.ms",
    "ksql.streams.num.stream.threads",
    "ksql.timestamp.throw.on.invalid",
    "ksql.persistence.default.format.value",
    "ksql.udfs.enabled",
    "ksql.udf.enable.security.manager",
    "ksql.connect.worker.config",
    "ksql.udf.collect.metrics",
    "ksql.query.pull.thread.pool.size",
    "ksql.persistent.prefix",
    "ksql.error.classifier.regex",
    "ksql.suppress.buffer.size.bytes"
  ],
  "warnings": []
}
```
With a 4 CSU ksqlDB App you have a limit of 20 persistant queries and no HA setup.

Now, create a new ksqlDB APP WITH 8 CSU (OPTIONALLY) and run the same command:
```bash
ksql> show properties;
# Output
{
  "@type": "properties",
  "statementText": "show properties;",
  "properties": [
    {
      "name": "ksql.extension.dir",
      "scope": "KSQL",
      "value": "ext"
    },
    {
      "name": "ksql.streams.cache.max.bytes.buffering",
      "scope": "KSQL",
      "value": "10000000"
    },
    {
      "name": "ksql.security.extension.class",
      "scope": "KSQL",
      "value": null
    },
    {
      "name": "metric.reporters",
      "scope": "KSQL",
      "value": "io.confluent.telemetry.reporter.TelemetryReporter"
    },
    {
      "name": "ksql.transient.prefix",
      "scope": "KSQL",
      "value": "transient_"
    },
    {
      "name": "ksql.streams.producer.request.timeout.ms",
      "scope": "KSQL",
      "value": "300000"
    },
    {
      "name": "ksql.query.status.running.threshold.seconds",
      "scope": "KSQL",
      "value": "300"
    },
    {
      "name": "ksql.streams.default.deserialization.exception.handler",
      "scope": "KSQL",
      "value": "io.confluent.ksql.errors.LogMetricAndContinueExceptionHandler"
    },
    {
      "name": "ksql.output.topic.name.prefix",
      "scope": "KSQL",
      "value": "pksqlc-nwo93"
    },
    {
      "name": "ksql.query.pull.enable.standby.reads",
      "scope": "KSQL",
      "value": "true"
    },
    {
      "name": "ksql.persistence.default.format.key",
      "scope": "KSQL",
      "value": "KAFKA"
    },
    {
      "name": "ksql.query.persistent.max.bytes.buffering.total",
      "scope": "KSQL",
      "value": "-1"
    },
    {
      "name": "ksql.query.error.max.queue.size",
      "scope": "KSQL",
      "value": "10"
    },
    {
      "name": "ksql.variable.substitution.enable",
      "scope": "KSQL",
      "value": "true"
    },
    {
      "name": "ksql.internal.topic.min.insync.replicas",
      "scope": "KSQL",
      "value": "2"
    },
    {
      "name": "ksql.streams.shutdown.timeout.ms",
      "scope": "KSQL",
      "value": "300000"
    },
    {
      "name": "ksql.streams.ssl.keystore.type",
      "scope": "KSQL",
      "value": "PKCS12"
    },
    {
      "name": "ksql.internal.topic.replicas",
      "scope": "KSQL",
      "value": "3"
    },
    {
      "name": "ksql.insert.into.values.enabled",
      "scope": "KSQL",
      "value": "true"
    },
    {
      "name": "ksql.query.pull.max.allowed.offset.lag",
      "scope": "KSQL",
      "value": "9223372036854775807"
    },
    {
      "name": "ksql.query.pull.max.qps",
      "scope": "KSQL",
      "value": "167"
    },
    {
      "name": "ksql.access.validator.enable",
      "scope": "KSQL",
      "value": "on"
    },
    {
      "name": "ksql.streams.sasl.mechanism",
      "scope": "KSQL",
      "value": "PLAIN"
    },
    {
      "name": "ksql.streams.bootstrap.servers",
      "scope": "KSQL",
      "value": "SASL_SSL://pkc-ep9mm.us-east-2.aws.confluent.cloud:9092"
    },
    {
      "name": "ksql.streams.sasl.jaas.config",
      "scope": "KSQL",
      "value": "[hidden]"
    },
    {
      "name": "ksql.streams.delivery.timeout.ms",
      "scope": "KSQL",
      "value": "1800000"
    },
    {
      "name": "ksql.query.pull.metrics.enabled",
      "scope": "KSQL",
      "value": "true"
    },
    {
      "name": "ksql.create.or.replace.enabled",
      "scope": "KSQL",
      "value": "true"
    },
    {
      "name": "ksql.streams.consumer.request.timeout.ms",
      "scope": "KSQL",
      "value": "300000"
    },
    {
      "name": "ksql.metrics.extension",
      "scope": "KSQL",
      "value": "io.confluent.cloud.ksql.engine.metrics.KsqlMetricsExtensionImpl"
    },
    {
      "name": "ksql.hidden.topics",
      "scope": "KSQL",
      "value": "_confluent.*,__confluent.*,_schemas,__consumer_offsets,__transaction_state,connect-configs,connect-offsets,connect-status,connect-statuses"
    },
    {
      "name": "ksql.cast.strings.preserve.nulls",
      "scope": "KSQL",
      "value": "true"
    },
    {
      "name": "ksql.authorization.cache.max.entries",
      "scope": "KSQL",
      "value": "10000"
    },
    {
      "name": "ksql.pull.queries.enable",
      "scope": "KSQL",
      "value": "true"
    },
    {
      "name": "ksql.lambdas.enabled",
      "scope": "KSQL",
      "value": "true"
    },
    {
      "name": "ksql.streams.retry.backoff.ms",
      "scope": "KSQL",
      "value": "500"
    },
    {
      "name": "ksql.streams.producer.compression.type",
      "scope": "KSQL",
      "value": "snappy"
    },
    {
      "name": "ksql.suppress.enabled",
      "scope": "KSQL",
      "value": "false"
    },
    {
      "name": "ksql.streams.ssl.key.password",
      "scope": "KSQL",
      "value": "[hidden]"
    },
    {
      "name": "ksql.sink.window.change.log.additional.retention",
      "scope": "KSQL",
      "value": "1000000"
    },
    {
      "name": "ksql.readonly.topics",
      "scope": "KSQL",
      "value": "_confluent.*,__confluent.*,_schemas,__consumer_offsets,__transaction_state,connect-configs,connect-offsets,connect-status,connect-statuses"
    },
    {
      "name": "ksql.query.persistent.active.limit",
      "scope": "KSQL",
      "value": "20"
    },
    {
      "name": "ksql.streams.ssl.keystore.password",
      "scope": "KSQL",
      "value": "[hidden]"
    },
    {
      "name": "ksql.streams.producer.acks",
      "scope": "KSQL",
      "value": "all"
    },
    {
      "name": "ksql.streams.producer.retries",
      "scope": "KSQL",
      "value": "2147483647"
    },
    {
      "name": "ksql.persistence.wrap.single.values",
      "scope": "KSQL",
      "value": null
    },
    {
      "name": "ksql.streams.request.timeout.ms",
      "scope": "KSQL",
      "value": "20000"
    },
    {
      "name": "ksql.authorization.cache.expiry.time.secs",
      "scope": "KSQL",
      "value": "30"
    },
    {
      "name": "ksql.query.retry.backoff.initial.ms",
      "scope": "KSQL",
      "value": "15000"
    },
    {
      "name": "ksql.streams.ssl.endpoint.identification.algorithm",
      "scope": "KSQL",
      "value": "https"
    },
    {
      "name": "ksql.streams.num.standby.replicas",
      "scope": "KSQL",
      "value": "1"
    },
    {
      "name": "ksql.streams.security.protocol",
      "scope": "KSQL",
      "value": "SASL_SSL"
    },
    {
      "name": "ksql.query.transient.max.bytes.buffering.total",
      "scope": "KSQL",
      "value": "-1"
    },
    {
      "name": "ksql.schema.registry.url",
      "scope": "KSQL",
      "value": "https://psrc-lq3wm.eu-central-1.aws.confluent.cloud"
    },
    {
      "name": "ksql.properties.overrides.denylist",
      "scope": "KSQL",
      "value": "ksql.streams.num.stream.threads,ksql.suppress.buffer.size,ksql.suppress.enabled"
    },
    {
      "name": "ksql.query.pull.max.concurrent.requests",
      "scope": "KSQL",
      "value": "10"
    },
    {
      "name": "ksql.streams.auto.offset.reset",
      "scope": "KSQL",
      "value": "latest"
    },
    {
      "name": "ksql.connect.url",
      "scope": "KSQL",
      "value": "http://localhost:8083"
    },
    {
      "name": "ksql.service.id",
      "scope": "KSQL",
      "value": "pksqlc-nwo93"
    },
    {
      "name": "ksql.functions.collect_set.limit",
      "scope": "KSQL",
      "value": "[hidden]"
    },
    {
      "name": "ksql.streams.state.dir",
      "scope": "KSQL",
      "value": "/mnt/data/data/ksql-state"
    },
    {
      "name": "ksql.streams.default.production.exception.handler",
      "scope": "KSQL",
      "value": "io.confluent.ksql.errors.ProductionExceptionHandlerUtil$LogAndContinueProductionExceptionHandler"
    },
    {
      "name": "ksql.streams.ssl.keystore.location",
      "scope": "KSQL",
      "value": "/mnt/sslcerts/pkcs.p12"
    },
    {
      "name": "ksql.query.pull.interpreter.enabled",
      "scope": "KSQL",
      "value": "true"
    },
    {
      "name": "ksql.streams.commit.interval.ms",
      "scope": "KSQL",
      "value": "30000"
    },
    {
      "name": "ksql.query.pull.table.scan.enabled",
      "scope": "KSQL",
      "value": "false"
    },
    {
      "name": "ksql.streams.consumer.default.api.timeout.ms",
      "scope": "KSQL",
      "value": "300000"
    },
    {
      "name": "ksql.streams.replication.factor",
      "scope": "KSQL",
      "value": "3"
    },
    {
      "name": "ksql.streams.topology.optimization",
      "scope": "KSQL",
      "value": "all"
    },
    {
      "name": "ksql.query.retry.backoff.max.ms",
      "scope": "KSQL",
      "value": "900000"
    },
    {
      "name": "ksql.streams.num.stream.threads",
      "scope": "KSQL",
      "value": "1"
    },
    {
      "name": "ksql.timestamp.throw.on.invalid",
      "scope": "KSQL",
      "value": "false"
    },
    {
      "name": "ksql.metrics.tags.custom",
      "scope": "KSQL",
      "value": "logical_cluster_id:lksqlc-ro2y9"
    },
    {
      "name": "ksql.persistence.default.format.value",
      "scope": "KSQL",
      "value": null
    },
    {
      "name": "ksql.udfs.enabled",
      "scope": "KSQL",
      "value": "true"
    },
    {
      "name": "ksql.udf.enable.security.manager",
      "scope": "KSQL",
      "value": "true"
    },
    {
      "name": "ksql.connect.worker.config",
      "scope": "KSQL",
      "value": ""
    },
    {
      "name": "ksql.streams.application.server",
      "scope": "KSQL",
      "value": "https://ksql-1.ksql.pksqlc-nwo93.svc.cluster.local:9199"
    },
    {
      "name": "ksql.streams.ssl.enabled.protocols",
      "scope": "KSQL",
      "value": "TLSv1.2"
    },
    {
      "name": "ksql.streams.producer.max.block.ms",
      "scope": "KSQL",
      "value": "300000"
    },
    {
      "name": "ksql.streams.rocksdb.config.setter",
      "scope": "KSQL",
      "value": "io.confluent.ksql.rocksdb.KsqlBoundedMemoryRocksDBConfigSetter"
    },
    {
      "name": "ksql.functions.collect_list.limit",
      "scope": "KSQL",
      "value": "[hidden]"
    },
    {
      "name": "ksql.udf.collect.metrics",
      "scope": "KSQL",
      "value": "false"
    },
    {
      "name": "ksql.query.pull.thread.pool.size",
      "scope": "KSQL",
      "value": "100"
    },
    {
      "name": "ksql.persistent.prefix",
      "scope": "KSQL",
      "value": "query_"
    },
    {
      "name": "ksql.metastore.backup.location",
      "scope": "KSQL",
      "value": "/mnt/data/data/ksql-command-backups"
    },
    {
      "name": "ksql.streams.metric.reporters",
      "scope": "KSQL",
      "value": "io.confluent.telemetry.reporter.TelemetryReporter"
    },
    {
      "name": "ksql.error.classifier.regex",
      "scope": "KSQL",
      "value": ""
    },
    {
      "name": "ksql.suppress.buffer.size.bytes",
      "scope": "KSQL",
      "value": "-1"
    }
  ],
  "overwrittenProperties": [
    "ksql.streams.auto.offset.reset"
  ],
  "defaultProperties": [
    "ksql.extension.dir",
    "ksql.security.extension.class",
    "ksql.transient.prefix",
    "ksql.query.status.running.threshold.seconds",
    "ksql.persistence.default.format.key",
    "ksql.query.persistent.max.bytes.buffering.total",
    "ksql.query.error.max.queue.size",
    "ksql.variable.substitution.enable",
    "ksql.insert.into.values.enabled",
    "ksql.query.pull.max.allowed.offset.lag",
    "ksql.query.pull.metrics.enabled",
    "ksql.create.or.replace.enabled",
    "ksql.hidden.topics",
    "ksql.cast.strings.preserve.nulls",
    "ksql.authorization.cache.max.entries",
    "ksql.pull.queries.enable",
    "ksql.lambdas.enabled",
    "ksql.suppress.enabled",
    "ksql.sink.window.change.log.additional.retention",
    "ksql.readonly.topics",
    "ksql.streams.producer.retries",
    "ksql.persistence.wrap.single.values",
    "ksql.authorization.cache.expiry.time.secs",
    "ksql.query.retry.backoff.initial.ms",
    "ksql.streams.ssl.endpoint.identification.algorithm",
    "ksql.query.transient.max.bytes.buffering.total",
    "ksql.streams.auto.offset.reset",
    "ksql.connect.url",
    "ksql.query.pull.interpreter.enabled",
    "ksql.streams.commit.interval.ms",
    "ksql.query.pull.table.scan.enabled",
    "ksql.query.retry.backoff.max.ms",
    "ksql.streams.num.stream.threads",
    "ksql.timestamp.throw.on.invalid",
    "ksql.persistence.default.format.value",
    "ksql.udfs.enabled",
    "ksql.udf.enable.security.manager",
    "ksql.connect.worker.config",
    "ksql.udf.collect.metrics",
    "ksql.query.pull.thread.pool.size",
    "ksql.persistent.prefix",
    "ksql.error.classifier.regex",
    "ksql.suppress.buffer.size.bytes"
  ],
  "warnings": []
}
```
With a 8 CSU ksqlDB App you have still a limit of 20 persistant queries and HA is enabled.
The difference is:
* 8 CSU with standby replicas: ksql.streams.num.standby.replicas = 1
* 8 CSU can handle ~double throughput of 4 CSU ksqlDB Apps
* (12 CSU would serve tripple throughput of 4 CSU )

## Sizing guideline
Based on your setup, please monitor persistent queries. You do that by switching to consumer monitoroning and watch consumer lag, this is main driver to activate sclaing.

Please have a look [how to scale](https://docs.ksqldb.io/en/latest/operate-and-deploy/capacity-planning/#scaling-ksqldb)

End lab10

[go back to Agenda](https://github.com/ora0600/confluent-ksqldb-hands-on-workshop/blob/master/README.md#hands-on-agenda-and-labs)

