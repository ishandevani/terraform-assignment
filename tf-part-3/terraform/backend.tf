terraform {
  backend "s3" {
    bucket = "tfstate-bucketabc-2026" # Replace with your bucket name
    key    = "part3/ecs-flask-express/terraform.tfstate"
    region = "ap-south-1"
  }
}
