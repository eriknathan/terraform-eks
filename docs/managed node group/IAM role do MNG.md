# IAM role do MNG

Docs: https://docs.aws.amazon.com/eks/latest/userguide/create-node-role.html

```hcl
 resource "aws_iam_role" "eks_mng_role" {
  name = "${var.project_name}-mng-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-mng-role"
    }
  )
}

# AmazonEKSWorkerNodePolicy: arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
resource "aws_iam_role_policy_attachment" "eks_mng_role_attachment_worker" {
  role       = aws_iam_role.eks_mng_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# AmazonEC2ContainerRegistryReadOnly: arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
resource "aws_iam_role_policy_attachment" "eks_mng_role_attachment_ecr" {
  role       = aws_iam_role.eks_mng_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# AmazonEKS_CNI_Policy: arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
resource "aws_iam_role_policy_attachment" "eks_mng_role_attachment_cni" {
  role       = aws_iam_role.eks_mng_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
```

Esse código define um **role** IAM que será usado pelos **Managed Node Groups (MNG)** no EKS, ou seja, pelos nós de trabalho (worker nodes) que fazem parte do cluster Kubernetes. Ele também anexa políticas importantes a esse role, que concedem as permissões necessárias para que os nós interajam com o EKS, EC2, e o registro de contêineres da AWS (ECR).

### Explicação do Código:

#### 1. Definição do Role IAM para o Managed Node Group:

```hcl
resource "aws_iam_role" "eks_mng_role" {
  name = "${var.project_name}-mng-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-mng-role"
    }
  )
}
```

Este bloco cria um **IAM Role** específico para os nós de trabalho do EKS, com uma política de **assume_role** que permite que a instância EC2 assuma o papel, necessária para que o EKS possa associar os nós ao cluster. O principal deste role é o serviço EC2 (`Service = "ec2.amazonaws.com"`).

- **`name`**: O nome do role é dinamicamente criado com base no nome do projeto (`var.project_name`).
- **`assume_role_policy`**: Define que a política de permissão permite que o serviço EC2 assuma este role.
- **`tags`**: Tags adicionadas ao role para fins de organização.

#### 2. Anexando Políticas ao Role:

##### a) AmazonEKSWorkerNodePolicy

```hcl
resource "aws_iam_role_policy_attachment" "eks_mng_role_attachment_worker" {
  role       = aws_iam_role.eks_mng_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}
```

Essa política dá aos nós de trabalho permissões necessárias para operar em um cluster EKS. Permite que os nós se comuniquem com o plano de controle do EKS.

##### b) AmazonEC2ContainerRegistryReadOnly

```hcl
resource "aws_iam_role_policy_attachment" "eks_mng_role_attachment_ecr" {
  role       = aws_iam_role.eks_mng_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
```

Essa política permite que os nós de trabalho tenham acesso de leitura ao **Amazon Elastic Container Registry (ECR)**, onde estão armazenadas as imagens de contêineres Docker. Isso é necessário para que os nós possam baixar as imagens do registro e rodar os contêineres.

##### c) AmazonEKS_CNI_Policy

```hcl
resource "aws_iam_role_policy_attachment" "eks_mng_role_attachment_cni" {
  role       = aws_iam_role.eks_mng_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
```

Essa política fornece as permissões necessárias para que o plugin **Amazon EKS CNI** (Container Network Interface) gerencie a rede de pods no cluster. Ele garante que os nós possam provisionar e liberar IPs para os pods.

### Conclusão:

- **`aws_iam_role`**: Define o IAM Role que será assumido pelos nós de trabalho do EKS.
- **Políticas anexadas**: Cada política define permissões específicas que os nós precisam:
  - Acessar o plano de controle do EKS.
  - Baixar imagens de contêineres do ECR.
  - Gerenciar a rede de pods no cluster via o EKS CNI.

Esse papel é essencial para permitir que os Managed Node Groups do EKS operem corretamente e interajam com o Kubernetes e outros serviços da AWS.