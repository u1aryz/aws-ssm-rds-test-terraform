resource "aws_security_group" "postgres_sg" {
  name        = "${var.app_name}-postgres-sg"
  description = "Allow postgres access"
  vpc_id      = module.vpc.vpc_id
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.app_name}-db-subnet-group"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_rds_cluster" "postgres" {
  cluster_identifier = "${var.app_name}-postgres"
  engine             = "aurora-postgresql"
  engine_mode        = "provisioned"
  engine_version     = "14.6"
  availability_zones = data.aws_availability_zones.available.names
  database_name      = "sample_db"

  # Use Secrets Manager
  master_username             = "sample_user"
  manage_master_user_password = true

  vpc_security_group_ids = [aws_security_group.postgres_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name

  # destroyですぐ消せるようにする
  deletion_protection = false
  skip_final_snapshot = true
}

resource "aws_rds_cluster_instance" "postgres_instance" {
  count              = 1
  identifier         = "${var.app_name}-postgres-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.postgres.cluster_identifier
  instance_class     = "db.t3.medium"
  engine             = "aurora-postgresql"
  engine_version     = "14.6"
}
