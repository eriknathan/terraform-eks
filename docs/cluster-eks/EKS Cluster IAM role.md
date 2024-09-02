# Cluster EKS - IAM Role

Código do Terraform configura um IAM Role (Função IAM) para um cluster Amazon EKS (Elastic Kubernetes Service) e anexa uma política gerenciada necessária para que o EKS possa operar corretamente. Vamos detalhar cada parte do código e explicar os conceitos envolvidos:

## Bloco aws_iam_role - eks_cluster_role

```hcl
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.project_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-cluster-role"
    }
  )
}
```

### 1. Definição e Propósito

**Recursos:**
- **aws_iam_role:** Este recurso cria uma Função IAM na AWS, que define um conjunto de permissões que entidades (como serviços AWS) podem assumir para realizar ações na infraestrutura.

**Nome da Função:**
- **name = "${var.project_name}-cluster-role":** O nome da função é dinâmico, baseado na variável project_name. Por exemplo, se var. project_name for "myproject", a função será nomeada "myproject-cluster-role".

**Política de Assunção de Função (assume_role_policy):**
- Define quem (qual entidade) pode assumir esta função. Utiliza a função jsonencode para converter a definição da política em 
  JSON.
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Sid": "",
      "Principal": {
        "Service": "eks.amazonaws.com"
      }
    }
  ]
}
```
  - **Componentes da Política:**
    - **Version:** Especifica a versão da política (padrão é "2012-10-17").
    - **Statement:** Lista de declarações de permissões.
    - **Action:** Ação permitida, neste caso, sts:AssumeRole, que permite que a entidade assuma a função.
    - **Effect:** Define o efeito da política, aqui "Allow" (Permitir).
    - **Principal:** Especifica a entidade que pode assumir a função. Aqui, está definido como eks.amazonaws.com, indicando que o serviço Amazon EKS pode assumir esta função.


### 2. O que é uma Policy Attachment?

**IAM Policy Attachment:**
- **Definição:** É o ato de associar uma política de permissões (gerenciada ou inline) a uma entidade IAM (como usuários, grupos ou funções).
- **Objetivo:** Conceder permissões específicas à entidade para que ela possa executar ações na AWS conforme definido pela política.

**AmazonEKSClusterPolicy:**
- **Descrição:** É uma política gerenciada pela AWS que fornece as permissões necessárias para que o Amazon EKS possa gerenciar clusters de Kubernetes na AWS.
- **Permissões Incluídas:** Inclui permissões para criar, modificar e deletar recursos necessários para o funcionamento do cluster EKS, como EC2, VPC, ECR, IAM, entre outros.

---

## Resumo Geral

**Função IAM (aws_iam_role.eks_cluster_role):**
- Cria uma função IAM que o Amazon EKS utilizará para gerenciar o cluster.
- Define uma política de assunção que permite que o serviço EKS assuma essa função.
- Aplica tags para facilitar a identificação e organização. 

**Anexação de Política (aws_iam_role_policy_attachment.eks_cluster_role_attachment):**
- Anexa a política gerenciada AmazonEKSClusterPolicy à função IAM criada.
- Essa política concede as permissões necessárias para o EKS operar corretamente.

**Importância:**
- Esses recursos são essenciais para que o Amazon EKS possa provisionar e gerenciar o cluster Kubernetes na AWS de forma segura e eficiente.
- Garantem que o cluster tenha as permissões necessárias para interagir com outros serviços da AWS sem expor excessivamente os recursos.