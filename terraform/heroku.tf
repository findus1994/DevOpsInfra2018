# Create Heroku apps for staging and production
resource "heroku_app" "ci" {
  name   = "${var.app_prefix}-app-ci"
  region = "eu"
  config_vars = {
    JAVA_TOOL_OPTIONS = "-Xmx300m"
  }
}


resource "heroku_app" "staging" {
  name   = "${var.app_prefix}-app-staging"
  region = "eu"
}


resource "heroku_app" "production" {
  name   = "${var.app_prefix}-app-production"
  region = "eu"
}

resource "heroku_pipeline" "pipeline" {
  name = "${var.pipeline_name}"
}

resource "heroku_addon" "ci" {
  app  = "${heroku_app.ci.name}"
  plan = "hostedgraphite"
}

resource "heroku_addon" "staging" {
  app  = "${heroku_app.staging.name}"
  plan = "hostedgraphite"
}

resource "heroku_addon" "production" {
  app  = "${heroku_app.production.name}"
  plan = "hostedgraphite"
}

# Couple apps to different pipeline stages
resource "heroku_pipeline_coupling" "ci" {
  app      = "${heroku_app.ci.name}"
  pipeline = "${heroku_pipeline.pipeline.id}"
  stage    = "development"
}

# Couple apps to different pipeline stages
resource "heroku_pipeline_coupling" "staging" {
  app      = "${heroku_app.staging.name}"
  pipeline = "${heroku_pipeline.pipeline.id}"
  stage    = "staging"
}

resource "heroku_pipeline_coupling" "production" {
  app      = "${heroku_app.production.name}"
  pipeline = "${heroku_pipeline.pipeline.id}"
  stage    = "production"
}
