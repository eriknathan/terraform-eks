# locals.tf

O arquivo locals.tf no Terraform é usado para **definir variáveis locais que podem ser reutilizadas em diferentes partes do código.** As variáveis locais são úteis quando você precisa definir valores que serão referenciados múltiplas vezes em diferentes recursos ou módulos, mas que não precisam ser passados como variáveis de entrada.

## Exemplo

```hcl
locals {
  tags = {
    Departament  = "DevOps"
    Organization = "Infraesturuta e Operação"
    Project      = "ecs-iac-tf"
    Enviroment   = "Development"
    Author       = "Erik Nathan - @eriknathan"
  }
}
```

### O que esse código faz:

- **Definição de Tags:** O bloco locals define uma variável local chamada tags que é um mapa de chave-valor. Esse mapa contém informações que podem ser usadas para aplicar tags em vários recursos na infraestrutura.

### Chaves e Valores:

- **Departament: "DevOps"** Especifica o departamento responsável.
- **Organization: "Infraestrutura e Operação"** — Identifica a organização ou equipe.
- **Project: "eks-iac-tf"** — Nome do projeto relacionado à infraestrutura como código (IaC) para EKS (Elastic Kubernetes Service).
- **Enviroment: "Development"** — Define o ambiente, como Desenvolvimento, Produção, etc.
- **Author: "Erik Nathan - @eriknathan"** — O autor do código ou responsável pelo recurso.

## Como utilizar locals:

Depois de definir uma variável local, você pode usá-la em outros arquivos de configuração Terraform. Por exemplo, ao criar recursos no AWS, você poderia referenciar local.tags para aplicar as tags a esses recursos:

```hcl
resource "aws_instance" "example" {
  ami           = "ami-123456"
  instance_type = "t2.micro"

  tags = local.tags
}
```
