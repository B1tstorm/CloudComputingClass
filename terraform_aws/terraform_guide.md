# Terraform guide

Initialize the directory
```terraform
terraform init
```

Format, validate the configuration & Overview
```terraform
terraform fmt
terraform validate
terraform plan
```

Create infrastructure
```terraform
terraform apply
```

Inspect state
```terraform
terraform show
```

---

## Rangehensweise:
- Scope: Identifiziere die Infrastruktur fürs Projekt
- Author: Erstelle Konfiguration um die Infrakstruktur zu definieren
- Initialize: Installiere nptwendige TF Provider
- Plan: Überprüfe die änderungen die TF macht
- Apply: Führe die geplanten änderungen duch