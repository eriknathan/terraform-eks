# Deploy da ServiceAccount

```hcl
resource "kubernetes_service_account" "eks_controller_sa" {
  metadata {
    name = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
        "eks.amazonaws.com/role-arn" = aws_iam_role.eks_controller_role.arn
    }
  }
}
```

Este código cria uma **Service Account (SA)** no Kubernetes via Terraform, associando-a a um papel do IAM da AWS. Vamos detalhar os elementos:

### Explicação do código:

- **resource "kubernetes_service_account" "eks_controller_sa"**:
  - Este bloco cria um **Service Account** (SA) no Kubernetes, que será usada pelo AWS Load Balancer Controller (um controlador que gerencia os balanceadores de carga para serviços dentro do EKS).
  
- **metadata { ... }**:
  - Dentro desse bloco, você define as propriedades da Service Account no Kubernetes.

  - **name**: Define o nome da Service Account. Aqui, ela é chamada de `"aws-load-balancer-controller"`, o que indica que será usada para o controlador do AWS Load Balancer.

  - **namespace**: O namespace onde a Service Account será criada, neste caso, `"kube-system"`. O namespace `kube-system` é o local padrão onde os serviços internos e os controladores de sistema do Kubernetes são executados.

  - **annotations**:
    - As anotações (`annotations`) fornecem metadados adicionais para a Service Account. Aqui, a anotação `"eks.amazonaws.com/role-arn"` está associando a SA com um **IAM Role** específico da AWS, necessário para permitir que o Kubernetes assuma o papel e execute ações em nome dessa conta.

    - **"eks.amazonaws.com/role-arn"**: Esta anotação mapeia a Service Account para o IAM Role que foi criado anteriormente (`aws_iam_role.eks_controller_role.arn`). Isso significa que qualquer pod que utilize essa Service Account vai herdar as permissões do IAM Role especificado.

### Fluxo de Funcionamento:

1. **Service Account**: Quando um pod (ou conjunto de pods) usa essa Service Account, ele poderá agir com as permissões do IAM Role associado.
   
2. **IAM Role**: O IAM Role especificado tem permissões para interagir com os recursos AWS (neste caso, pode ser o Load Balancer Controller, que precisa de permissões para criar e gerenciar balanceadores de carga na AWS).

3. **AWS OIDC (OpenID Connect)**: A integração entre Kubernetes e AWS OIDC permite que o Kubernetes autentique diretamente com a AWS usando tokens de identidade. A Service Account mapeada para o IAM Role é autenticada pelo OIDC, utilizando o ARN do papel IAM (IAM Role ARN) configurado.

### Contexto de Uso:
Este código é parte de uma configuração maior para o **AWS Load Balancer Controller** em um cluster EKS. Ele permite que o controlador gerencie balanceadores de carga automaticamente, criando e configurando recursos da AWS (como ELB, ALB) de acordo com as necessidades dos serviços Kubernetes.