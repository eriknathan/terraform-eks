# vpc

## O que é uma VPC?
A VPC (Virtual Private Cloud) é uma rede virtual isolada dentro da nuvem da AWS. Ela permite que você defina uma rede privada onde pode lançar recursos como instâncias EC2, bancos de dados, e outros serviços AWS. Dentro de uma VPC, você tem controle sobre aspectos como endereçamento IP, sub-redes, tabelas de roteamento, gateways de internet, e segurança de rede (grupos de segurança e ACLs).


- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc


## Como criar uma VPC no Terraform usando o código fornecido:

Aqui está uma explicação detalhada do código:

```hcl
resource "aws_vpc" "eks_vpc" {
  cidr_block       = "10.0.0.0/16"

  tags = merge(
    local.tags,
    {
      Name = "vpc-${var.project_name}-ecs-tf"
    }
  )
}
```

## Passo a Passo:

### 1. Bloco resource "aws_vpc" "eks_vpc":

- O bloco resource define que você está criando um recurso AWS do tipo VPC (aws_vpc).
- "eks_vpc" é o nome lógico dado a essa VPC dentro do Terraform. Esse nome é usado para referenciar a VPC em outros recursos do Terraform.

### 2. cidr_block = "10.0.0.0/16":

- O bloco CIDR (Classless Inter-Domain Routing) define o intervalo de endereços IP que a VPC usará. No exemplo, 10.0.0.0/16 significa que a VPC terá um espaço de endereços IP que vai de 10.0.0.0 a 10.0.255.255, permitindo até 65.536 endereços IP.

### 3. tags = merge(...):

- O bloco tags aplica tags à VPC para organização e gestão.
- merge(local.tags, { Name = "vpc-${var.project_name}-ecs-tf" }) combina as tags locais definidas no locals.tf com uma nova tag Name que é única para essa VPC. A tag Name usa o nome do projeto (var.project_name) para criar um nome descritivo.

## Considerações para Implementação:

### 1. Definição de Variáveis:

No código, var.project_name é usado, que deve ser definido como uma variável em algum lugar no seu código Terraform, normalmente em um arquivo variables.tf:

```hcl
variable "project_name" {
  description = "Nome do projeto"
  type        = string
}
```

### 2. Uso de Locals:

As tags locais são definidas no locals.tf e estão sendo combinadas com a tag Name. Isso garante que todas as tags comuns sejam aplicadas junto com a tag específica Name.

### 3. Execução no Terraform:

Após definir a VPC no Terraform, você deve rodar os seguintes comandos para criar a infraestrutura:

```bash
terraform init    # Inicializa o projeto, baixando os providers e preparando o ambiente.
terraform plan    # Gera e mostra um plano de execução, descrevendo as ações que o Terraform fará.
terraform apply   # Aplica as mudanças descritas no plano, criando a VPC na AWS.
```

## Resumo:
- A VPC é uma rede virtual isolada na AWS, que você configura para controlar a comunicação entre seus recursos.
- O código fornecido cria uma VPC com um CIDR de 10.0.0.0/16 e aplica tags para facilitar a gestão.
- Para usar esse código, você precisa garantir que as variáveis e locais necessários estejam corretamente definidos em seu projeto Terraform.






