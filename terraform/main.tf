# Configure the GCP provider
provider "google" {
  project     = "akiva-sandbox"
  region      = "us-central1" 
}

# Create a Compute Engine instance template
resource "google_compute_instance_template" "app_instance_template" {
  name         = "app-instance-template"
  machine_type = "e2-micro"  

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  disk {
    source_image = "ubuntu-os-cloud/ubuntu-2004-focal-v20220712"
    auto_delete       = true
    boot              = true
  }

  network_interface {
    network = "default"
    access_config {
    }
  }

  tags = ["http-server","https-server","web"]
  metadata_startup_script = file("startup-script.sh")  
}

# Create a managed instance group
resource "google_compute_instance_group_manager" "app_instance_group_manager" {
  name        = "app-instance-group-manager"
  base_instance_name = "app-instance"
  zone               = "us-central1-a"
  version {
    instance_template  = google_compute_instance_template.app_instance_template.self_link_unique
  }
  target_size       = 2  # Change to your desired number of instances

  named_port {
    name = "http"
    port = 80
  }
}

# Create a firewall rule to allow incoming traffic on port 80
resource "google_compute_firewall" "allow-http" {
  name    = "allow-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]  # Allow traffic from any source (insecure, consider restricting to specific IP ranges)
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
resource "google_sql_user" "app_db_user" {
  name     = "app-db-user"
  instance = google_sql_database_instance.db_instance.name
  password = "pass"  # Change to a secure password
}