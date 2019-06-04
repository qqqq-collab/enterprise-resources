locals {
  postgres_url = "${var.postgres_url}"
  redis_url = "redis://${aws_elasticache_cluster.redis.cache_nodes.0.address}:${aws_elasticache_cluster.redis.cache_nodes.0.port}"
}
