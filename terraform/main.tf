# Configure the GCP provider
provider "google" {
  project     = "akiva-sandbox"
  region      = "us-central1" 
}

# Create a Compute Engine instance template
resource "google_compute_instance_template" "app_instance_template" {
  name         = "app-instance-template"
  machine_type = "e2-micro"  

  disk {
    image = "debian-cloud/debian-10"
  }

  network_interface {
    network = "default"
  }

  metadata_startup_script = file("startup-script.sh")  # Provide your startup script
}

# Create a managed instance group
resource "google_compute_instance_group_manager" "app_instance_group_manager" {
  name        = "app-instance-group-manager"
  base_instance_name = "app-instance"
  instance_template = google_compute_instance_template.app_instance_template.id
  target_size       = 2  # Change to your desired number of instances

  named_port {
    name = "http"
    port = 80
  }
}
# Create a Cloud SQL instance (PostgreSQL)
resource "google_sql_database_instance" "db_instance" {
  name             = "app-db-instance"
  database_version = "POSTGRES_13"  # Change to your desired PostgreSQL version
  region           = "us-central1"  # Change to your desired region

  settings {
    tier = "db-f1-micro"  # Change to your desired machine type for PostgreSQL
  }
}

# Create a Cloud SQL database (PostgreSQL)
resource "google_sql_database" "app_database" {
  name     = "app-database"
  instance = google_sql_database_instance.db_instance.name
}

# Create a Cloud SQL user (PostgreSQL)
#resource "google_sql_user" "app_db_user" {
#  name     = "app-db-user"
#  instance = google_sql_database_instance.db_instance.name
#  password = "your-password"  # Change to a secure password
#  roles    = ["cloudsqlsuperuser", "cloudsqlreplica"]
#}