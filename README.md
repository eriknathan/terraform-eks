# terraform-eks

## Provisionando um EKS na AWS com Terraform

Este projeto permite provisionar um cluster EKS (Amazon Elastic Kubernetes Service) na AWS utilizando Terraform. Você pode configurá-lo sem clonar este repositório, apenas criando um arquivo `main.tf` na sua máquina com o conteúdo especificado abaixo.

## Como usar

1. **Crie o arquivo `main.tf`**:

Na sua máquina, crie um arquivo chamado `main.tf` com o seguinte conteúdo:

```hcl
module "eks" {
  source       = "github.com/eriknathan/terraform-eks.git?ref=main"

  cidr_block   = "10.0.0.0/16"          # Defina o bloco CIDR da VPC
  project_name = "nomedoprojeto"        # Nome do projeto
  region       = "us-east-1"            # Região AWS onde o EKS será provisionado
  tags         = local.tags             # Tags de identificação dos recursos
}

terraform {
  backend "s3" {
    bucket = "s3-bucket-tf"          # Nome do bucket S3 para armazenar o estado do Terraform
    key    = "eks/terraform.tfstate" # Caminho para o arquivo de estado dentro do bucket S3
    region = "us-east-1"             # Região AWS onde o bucket S3 está localizado
  }
}

locals {
  tags = {
    Departament  = "DevOps"                             # Departamento responsável
    Organization = "Infrastructure and Operations"      # Organização ou equipe
    Project      = "Nome do projeto"                            # Nome do projeto
    Enviroment   = "Development"                        # Ambiente (Desenvolvimento, Homologação, Produção)
    Author       = "Usuário"                            # Autor do projeto
  }
}
```

2. **Configurar o backend**:

O estado do Terraform será armazenado em um bucket S3. Certifique-se de configurar corretamente as informações do bucket e a região no bloco `backend "s3"`. O estado é necessário para rastrear mudanças e gerenciar a infraestrutura com o Terraform.

### Variáveis

- `cidr_block`: O bloco CIDR para a VPC na qual o cluster EKS será criado.
- `project_name`: O nome do projeto, usado para nomear os recursos.
- `region`: A região AWS onde o cluster será provisionado.
- `tags`: Tags que serão aplicadas aos recursos para facilitar a identificação.

### Backend do Terraform

O bloco `backend "s3"` define onde o estado do Terraform será armazenado. Nesse caso, o estado será salvo em um bucket S3 especificado, garantindo que você possa colaborar com outros usuários ou executar o Terraform em múltiplos ambientes de maneira consistente.

### Tags de Recursos

As `tags` são úteis para organizar e identificar recursos na AWS. Neste exemplo, você pode personalizar as tags no bloco `locals`, alterando o nome do departamento, organização, projeto, ambiente, e autor.

### Iniciando o Terraform

Após configurar o arquivo `main.tf`, você pode iniciar e aplicar a configuração do Terraform com os seguintes comandos:

```bash
# Inicialize o Terraform
terraform init

# Visualize o plano de execução
terraform plan

# Aplique as mudanças para provisionar o EKS
terraform apply
```
---
