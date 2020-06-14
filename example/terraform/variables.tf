variable settings {
  type = map(string)

  default = {
    "default.log_retention_in_days" = "90"
    "dev.log_retention_in_days"     = "90"
    "prd.log_retention_in_days"     = "90"

    "default.vpc.cidr_block" = "172.16.0.0/16"
    "dev.vpc.cidr_block"     = "172.16.0.0/16"
    "prd.vpc.cidr_block"     = "172.24.0.0/16"
  }
}

variable project {
  default = "kobanzame-sample"
}
