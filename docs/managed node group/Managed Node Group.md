# Managed Node Group

```hcl
resource "aws_eks_node_group" "eks_managed_node_group" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.project_name}-node-group"
  node_role_arn   = aws_iam_role.eks_mng_role.arn
  subnet_ids      = [
    var.subnet_private_1a,
    var.subnet_private_1b
  ]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_mng_role_attachment_worker,
    aws_iam_role_policy_attachment.eks_mng_role_attachment_ecr,
    aws_iam_role_policy_attachment.eks_mng_role_attachment_cni,
  ]

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-node-groups"
    }
  )  
}
```

Este código cria um **Managed Node Group (MNG)** no Amazon EKS, que é um grupo de instâncias EC2 gerenciado pelo EKS para atuar como nós de trabalho (worker nodes) no cluster. A AWS gerencia o ciclo de vida desses nós, facilitando o processo de atualização e escalonamento.

### Explicação do Código:

#### 1. Definição do Node Group:

```hcl
resource "aws_eks_node_group" "eks_managed_node_group" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.project_name}-node-group"
  node_role_arn   = aws_iam_role.eks_mng_role.arn
  subnet_ids      = [
    var.subnet_private_1a,
    var.subnet_private_1b
  ]
```

- **`cluster_name`**: Nome do cluster EKS ao qual esse grupo de nós será associado. Ele utiliza a variável `var.cluster_name`.
- **`node_group_name`**: Nome do grupo de nós, que é montado dinamicamente com base no nome do projeto (`var.project_name`).
- **`node_role_arn`**: O ARN do IAM Role que será atribuído às instâncias do Node Group. Esse role é essencial para que os nós possam interagir com o EKS, baixar imagens de contêiner e gerenciar a rede.
- **`subnet_ids`**: Especifica as subnets nas quais os nós serão lançados. Aqui, está utilizando subnets privadas (`var.subnet_private_1a` e `var.subnet_private_1b`), indicando que os nós não terão IPs públicos e serão acessíveis apenas dentro da VPC.

#### 2. Configuração de Escalonamento:

```hcl
  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }
```

- **`scaling_config`**: Define a configuração de escalonamento para o grupo de nós. Neste caso:
  - **`desired_size`**: Número desejado de nós no grupo. Aqui, está definido para 1 nó.
  - **`max_size`**: Número máximo de nós que podem ser escalonados no grupo.
  - **`min_size`**: Número mínimo de nós que sempre estarão presentes no grupo.
  
Como todos os valores estão definidos como `1`, o Node Group terá exatamente uma instância EC2.

#### 3. Dependências:

```hcl
  depends_on = [
    aws_iam_role_policy_attachment.eks_mng_role_attachment_worker,
    aws_iam_role_policy_attachment.eks_mng_role_attachment_ecr,
    aws_iam_role_policy_attachment.eks_mng_role_attachment_cni,
  ]
```

- **`depends_on`**: Define que o recurso `aws_eks_node_group` depende da criação e anexação de políticas ao IAM Role. Isso garante que o Node Group só será criado depois que o Role IAM tenha as permissões necessárias.

#### 4. Tags:

```hcl
  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-node-groups"
    }
  )
```

- **`tags`**: Adiciona tags ao Node Group, mesclando as tags padrão com uma específica para identificar o Node Group.

### Conclusão:

Este código configura um Managed Node Group no EKS que irá executar as workloads no cluster Kubernetes. O uso de subnets privadas para os nós oferece mais segurança, pois os nós não são acessíveis pela internet pública. O escalonamento está configurado para manter apenas uma instância EC2, mas isso pode ser ajustado conforme as necessidades do projeto.