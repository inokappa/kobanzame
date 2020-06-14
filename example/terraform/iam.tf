resource "aws_iam_role" "batch-worker" {
  name        = "${var.project}-${terraform.workspace}-batch-worker"
  path        = "/"
  description = "IAM Role for batch-worker ECS Fargate task."

  tags = {
    Environment = terraform.workspace
    Role        = "Batch Worker"
    ManagedBy   = "Terraform"
  }

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "attachement001" {
  role       = aws_iam_role.batch-worker.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "attachement002" {
  role       = aws_iam_role.batch-worker.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "attachement003" {
  role       = aws_iam_role.batch-worker.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_iam_role_policy_attachment" "attachement004" {
  role       = aws_iam_role.batch-worker.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "attachement005" {
  role       = aws_iam_role.batch-worker.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceEventsRole"
}

resource "aws_iam_role_policy_attachment" "attachement006" {
  role       = aws_iam_role.batch-worker.name
  policy_arn = aws_iam_policy.batch-worker.arn
}

resource "aws_iam_policy" "batch-worker" {
  name = "${var.project}-${terraform.workspace}-batch-worker"
  path = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:RunTask",
        "iam:PassRole"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
