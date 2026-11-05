# DEMO W8 — CỐ Ý CHƯA AN TOÀN. KHÔNG MERGE VÀO MAIN.
# Security Group mở cổng 22 cho toàn Internet, để chứng minh Checkov chặn từ PR (CKV_AWS_24).
resource "aws_security_group" "insecure_demo" {
  name        = "${var.project_name}-insecure-demo"
  description = "Demo W8 - mo SSH cho toan Internet"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "SSH tu moi noi"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
