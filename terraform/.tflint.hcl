plugin "google" {
  source  = "github.com/terraform-linters/tflint-ruleset-google"
  version = "0.30.0"
  enabled = true
}

config {
  # sprawdza wszystkie moduły rekurencyjnie
  call_module_type = "all"
}

rule "terraform_naming_convention" {
  enabled = true
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = false  # mamy description, ale nie wszędzie — można włączyć
}
