data "aws_caller_identity" "self" {}
data "template_file" "batch-worker" {
  template = "${file("files/task-definitions/batch-worker.template.json")}"

  vars = {
    container-name            = "batch-worker"
    container-image           = "${data.aws_caller_identity.self.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/${var.project}/worker:${terraform.workspace}"
    kobanzame-container-name  = "kobanzame"
    kobanzame-container-image = "${data.aws_caller_identity.self.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/${var.project}/kobanzame:${terraform.workspace}"
    awslogs-group             = aws_cloudwatch_log_group.batch-worker.name
    _env                      = terraform.workspace
  }
}

resource "aws_ecs_cluster" "batch-worker" {
  name = "${var.project}-${terraform.workspace}-batch-worker"
}

resource "aws_ecs_task_definition" "batch-worker2" {
  family                   = "${var.project}-${terraform.workspace}-batch-worker"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  container_definitions    = data.template_file.batch-worker.rendered
  task_role_arn            = aws_iam_role.batch-worker.arn
  execution_role_arn       = aws_iam_role.batch-worker.arn
}

resource "aws_cloudwatch_log_group" "batch-worker" {
  name              = "${var.project}-${terraform.workspace}-batch-worker"
  retention_in_days = lookup(var.settings, "${terraform.workspace}.log_retention_in_days")

  tags = {
    Environment = terraform.workspace
    Role        = "Log Transfer"
  }
}
