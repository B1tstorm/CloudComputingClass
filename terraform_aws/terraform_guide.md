# Terraform guide

Initialize the directory
```terraform
terraform init
```

Format, validate the configuration & Overview
```terraform
terraform fmt
terraform validate
terraform plan # macht apply automatisch
```

Create infrastructure
```terraform
terraform apply
```

Inspect state
```terraform
terraform show
```

Inspect output values
```terraform
terraform output
```
>You can use Terraform outputs to connect your Terraform projects with other parts of your infrastructure, or with other Terraform projects. To learn more, follow our in-depth tutorial, 
[Output Data from Terraform.](https://learn.hashicorp.com/tutorials/terraform/outputs?in=terraform/configuration-language)

---

## Rangehensweise:
- Scope: Identifiziere die Infrastruktur fürs Projekt
- Author: Erstelle Konfiguration um die Infrakstruktur zu definieren
- Initialize: Installiere nptwendige TF Provider
- Plan: Überprüfe die änderungen die TF macht
- Apply: Führe die geplanten änderungen duch