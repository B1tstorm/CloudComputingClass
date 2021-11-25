# Terraform guide

> [Get started tut - aws](https://learn.hashicorp.com/collections/terraform/aws-get-started)    

> [Terraform AWS Registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
---

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

---

## Blöcke{} in .tf Datei

- [resource](https://www.terraform.io/docs/language/resources/index.html)n, dies erlaubt z.B. eine EC2 Instanz zu starten oder ein subnetz zu konfigurieren 
- [module](https://www.terraform.io/docs/language/modules/index.html), eine sammlung oder anleitung von ressourcen. Vereinfacht mehrere schritte zu automatisieren
- input [variable](https://www.terraform.io/docs/language/values/index.html)n sind Variablen die in einer externen Datei liegen und auf welche zugegriffen werden kann um den Code nicht anzufassen. Wie eine config.
- [outputs](https://www.terraform.io/docs/language/values/index.html) values, ausgabe von zur laufzeit gesetzten daten. Z.B.: ID's oder IP's. Kann auch genutzt werden zum teilen der generierten Daten zwischen den ressourcen und modulen.

---

### Verwendete Module um ein VPC aufzubauen
- [aws-vpc-module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest)
