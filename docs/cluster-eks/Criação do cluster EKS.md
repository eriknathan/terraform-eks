# Criação do Cluster EKS

Este código define um recurso no Terraform para criar um cluster Amazon EKS (Elastic Kubernetes Service), que permite executar aplicações baseadas em containers usando o Kubernetes na AWS.

```hcl
resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.project_name}-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  upgrade_policy {
    support_type = "STANDARD"
  }

  vpc_config {
    subnet_ids = [
      var.public_subnet_1a,
      var.public_subnet_1b
    ]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_role_attachment
  ]

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-cluster"
    }
  )
}
```

## Bloco resource `"aws_eks_cluster" "eks_cluster"`

### Atributos principais
1. `name`: Define o nome do cluster EKS. O valor é dinâmico, sendo baseado na variável `var.project_name` concatenada com a string `-cluster`, o que cria um nome personalizado como, por exemplo, `meu-projeto-cluster`.
2. `role_arn`: Referencia o ARN da IAM Role criada anteriormente (`aws_iam_role.eks_cluster_role.arn`). Esta role será usada pelo serviço EKS para gerenciar o cluster e seus recursos. A role precisa ter permissões adequadas, como as fornecidas pela política **AmazonEKSClusterPolicy**.

### Bloco `vpc_config`

```hcl
vpc_config {
  subnet_ids = [
    var.public_subnet_1a,
    var.public_subnet_1b
  ]
  endpoint_private_access = true
  endpoint_public_access  = true
}
```
- `subnet_ids`: Define as subnets em que o cluster será criado. Neste caso, são usadas duas subnets públicas, representadas pelas variáveis var.public_subnet_1a e var.public_subnet_1b. Estas subnets devem estar em diferentes zonas de disponibilidade para garantir alta disponibilidade.
- `endpoint_private_access = true`: Permite o acesso privado ao endpoint do Kubernetes API. Isso significa que o cluster será acessível a partir de instâncias na mesma VPC, mas sem exposição direta à internet.
- `endpoint_public_access = true`: Permite que o endpoint do Kubernetes API seja acessível publicamente pela internet. Geralmente, isso é útil para administrar o cluster de fora da VPC.

### Atributo `depends_on`

```hcl
depends_on = [
  aws_iam_role_policy_attachment.eks_cluster_role_attachment
]
```

- `depends_on`: Esse bloco garante que o cluster só será criado após a IAM Role e a política de role (eks_cluster_role_attachment) serem corretamente configuradas. Sem essa dependência, o Terraform poderia tentar criar o cluster sem as permissões necessárias.

### Bloco `tags`

```hcl
tags = merge(
  var.tags,
  {
    Name = "${var.project_name}-cluster"
  }
)
```

- `tags`: Define tags para o recurso, incluindo uma tag Name com o valor dinâmico ${var.project_name}-cluster. As tags ajudam a identificar e organizar os recursos dentro da AWS. Outras tags são mescladas a partir de var.tags, o que significa que outras tags personalizadas estão sendo adicionadas ao recurso.

# Explicação Geral:

1. **Cluster EKS:** Este código cria um cluster Kubernetes gerenciado pela AWS. Ele será configurado com permissões de IAM através da role associada, e utilizará duas subnets públicas para balanceamento de carga e conectividade. O cluster permitirá tanto o acesso público quanto o privado ao endpoint do Kubernetes API.
2. **VPC e Subnets:** As subnets configuradas no vpc_config garantem que o cluster estará em uma rede gerenciada pela AWS, 
   distribuída entre duas zonas de disponibilidade para maior resiliência e disponibilidade.
3. **Política de Atualização:** A política de atualização do cluster é configurada como "STANDARD", garantindo que o cluster receba atualizações regulares.
4. **Dependências:** O cluster só será criado após a configuração da role e suas políticas, evitando erros relacionados a permissões.