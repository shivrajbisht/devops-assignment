ami_id	= "ami-0f58b397bc5c1f2e8"
environment	= "dev"
owner	= "Shivraj"

prevent_destroy_instance = "app-server"

instances = {
  "web-server" = {
    instance_type = "t3a.small"
    key_name      = "ssb-web-key"
    root_volume = {
      type = "gp3"
      size = 20
    }
  }

  "app-server" = {
    instance_type = "t3a.large"
    key_name      = "ssb-app-key"
    root_volume = {
      type = "gp3"
      size = 30
    }
  }

  "caching-server" = {
    instance_type = "t3a.medium"
    key_name      = "ssb-cache-key"
    root_volume = {
      type = "gp2"
      size = 25
    }
  }

  "monitoring-server" = {
    instance_type = "t4g.medium"
    key_name      = "ssb-monitoring-key"
    root_volume = {
      type = "gp3"
      size = 20
    }
  }

  "db-server" = {
    instance_type = "t3.medium"
    key_name      = "ssb-db-key"
    root_volume = {
      type = "io1"
      size = 50
    }
  }
}
