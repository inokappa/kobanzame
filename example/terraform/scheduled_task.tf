resource "aws_cloudwatch_event_rule" "batch-worker2" {
  name                = "${var.project}-${terraform.workspace}-batch-worker-for-fargate"
  description         = "Scheduled Task for ${var.project}-${terraform.workspace}-batch-worker"
  schedule_expression = "cron(30 0 ? * * *)"
  is_enabled          = true
}

resource "aws_cloudwatch_event_target" "batch-worker2" {
  target_id = "${var.project}-${terraform.workspace}-batch-worker2"
  arn       = aws_ecs_cluster.batch-worker.arn
  rule      = aws_cloudwatch_event_rule.batch-worker2.name
  role_arn  = aws_iam_role.batch-worker.arn
  input     = file("files/task-overrides/batch-worker.json")

  ecs_target {
    launch_type         = "FARGATE"
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.batch-worker2.arn
    platform_version    = "LATEST"
    network_configuration {
      subnets = [
        aws_subnet.application-a.id,
        aws_subnet.application-c.id,
      ]
      security_groups = [
        aws_security_group.common.id
      ]
      assign_public_ip = true
    }
  }
}
