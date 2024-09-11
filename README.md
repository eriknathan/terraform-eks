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

# Resumo dos Recursos Criados

### 1. VPC
- **Recurso:** aws_vpc
- **Descrição:** A VPC é a fundação da infraestrutura, uma rede isolada onde os recursos serão criados.
- **CIDR:** Defina o bloco CIDR como 10.0.0.0/16.
- **Relacionamento:** Todas as subnets, gateways, e tabelas de rotas serão criados dentro desta VPC.
- **Configuração:** Habilitar o DNS hostname para facilitar a resolução de nomes dentro da VPC

### 2. Subnets (Privada e Pública)
- **Recurso:** aws_subnet
- **Descrição:** Crie subnets públicas e privadas em diferentes zonas de disponibilidade. Isso permite alta disponibilidade e balanceamento entre regiões.
- **Relacionamento:** As subnets serão associadas à VPC criada no primeiro passo.
- **Tags:** Inclua tags como kubernetes.io/role/internal-elb para subnets privadas e kubernetes.io/role/elb para subnets públicas, para suportar a criação de balanceadores de carga no futuro.

### 3. Internet Gateway (IGW) e Route Table (RTB)
- **Recursos:** aws_internet_gateway e aws_route_table
- **Descrição:** O IGW é necessário para que os recursos na subnet pública tenham acesso à internet.
- **Relacionamento:** O IGW será associado à VPC, e a tabela de rotas pública será configurada para rotear todo o tráfego (0.0.0.0/0) através do IGW.
- **Associação de subnets:** As subnets públicas serão associadas à tabela de rotas pública.

### 4. NAT Gateway e Route Table Privada
- **Recursos:** aws_nat_gateway e aws_route_table
- **Descrição:** O NAT Gateway é usado para permitir que instâncias nas subnets privadas acessem a internet sem estarem diretamente expostas.
- **Relacionamento:** O NAT Gateway será associado a uma subnet pública e vinculado a uma tabela de rotas privada.
- **Associação de subnets:** Cada subnet privada será associada a uma tabela de rotas privada que usa o NAT Gateway para acessar a internet.

### 5. Role IAM para o Cluster EKS
- **Recurso:** aws_iam_role
- **Descrição:** Crie uma role IAM para o cluster EKS, atribuindo a política AmazonEKSClusterPolicy, que concede permissões para o gerenciamento do cluster.
- **Relacionamento:** Esta role será associada ao cluster EKS durante a criação.

### 6.  Criação do Cluster EKS
- **Recurso:** aws_eks_cluster
- **Descrição:** O EKS será o ambiente gerenciado onde seus containers Kubernetes serão executados.
- **Relacionamento:** O cluster usará as subnets públicas e privadas configuradas anteriormente, e a role IAM será associada ao cluster.
- **Complementos:** Inclua add-ons como CoreDNS, kube-proxy, e o CNI da Amazon VPC, fundamentais para o funcionamento do cluster.

### 7. Role IAM para os Nós do EKS
- **Recurso:** aws_iam_role
- **Descrição:** Crie uma role IAM para os nós gerenciados do EKS, atribuindo as políticas AmazonEKSWorkerNodePolicy, AmazonEC2ContainerRegistryReadOnly, e AmazonEKS_CNI_Policy.
- **Relacionamento:** Esta role será atribuída aos nós do EKS para permitir a execução de containers e comunicação com o cluster.
  
### 8. Managed Node Group
- **Recurso:** aws_eks_node_group
- **Descrição:** Configure um grupo de nós gerenciados (Managed Node Group) para o EKS, usando instâncias EC2 Spot.
- **Relacionamento:** O grupo de nós estará associado ao cluster EKS e será provisionado nas subnets privadas.
- **Tamanho e Tipo:** Defina parâmetros como tipo de instância, tamanho desejado, e chaves de acesso remoto.

### 9. OIDC Provider para IAM Roles
- **Recurso:** aws_iam_openid_connect_provider
- **Descrição:** O OIDC provider é necessário para permitir que o EKS utilize roles IAM associadas a contas de serviço no Kubernetes.
- **Relacionamento:** O OIDC provider será associado ao cluster EKS.

### 11.  AWS Load Balancer Controller
- **Recurso:** aws_iam_role, helm_release
- **Descrição:** Instale o AWS Load Balancer Controller para permitir a criação e gerenciamento de load balancers pelo Kubernetes.
- **Relacionamento:** Será criada uma role IAM associada ao serviço, e o Helm será usado para instalar o controller dentro do cluster EKS.
