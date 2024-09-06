# IAM role do Controller

```hcl
resource "aws_iam_role" "eks_controller_role" {
  name = "${var.project_name}-aws-load-balancer-controller"

assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.${data.aws_region.current.name}.amazonaws.com/id/${local.oidc}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.${data.aws_region.current.name}.amazonaws.com/id/${local.oidc}:sub": "system:serviceaccount:default:my-service-account",
          "oidc.eks.${data.aws_region.current.name}.amazonaws.com/id/${local.oidc}:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-aws-load-balancer-controller"
    }
  )
}

resource "aws_iam_role_policy_attachment" "eks_controller_role_attachment" {
  role       = aws_iam_role.eks_controller_role.name
  policy_arn = aws_iam_policy.eks_controller_policy.arn
}
```

Esse código cria um **Role IAM** para o **AWS Load Balancer Controller** no Amazon EKS e associa a ele uma política de permissões (IAM Policy) criada anteriormente, permitindo que o Load Balancer Controller interaja com outros serviços da AWS em nome do cluster EKS. Vamos detalhar como funciona:

### Explicação do Código:

#### 1. Definição do Role IAM:

```hcl
resource "aws_iam_role" "eks_controller_role" {
  name = "${var.project_name}-aws-load-balancer-controller"

  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.${data.aws_region.current.name}.amazonaws.com/id/${local.oidc}"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "oidc.eks.${data.aws_region.current.name}.amazonaws.com/id/${local.oidc}:sub": "system:serviceaccount:default:my-service-account",
            "oidc.eks.${data.aws_region.current.name}.amazonaws.com/id/${local.oidc}:aud": "sts.amazonaws.com"
          }
        }
      }
    ]
  }
  EOF
```

- **`name`**: Define o nome do IAM Role com base no nome do projeto (`project_name`), garantindo que o nome seja descritivo e único para o AWS Load Balancer Controller.

- **`assume_role_policy`**: Este é o bloco de política que permite ao serviço EKS assumir o papel (Role) usando a identidade OIDC (OpenID Connect).

  - **Principal (Federated)**: Define quem pode assumir o Role. Aqui, o **OpenID Connect Provider (OIDC)** é especificado para que as entidades no cluster EKS possam assumir esse Role. O OIDC é criado quando o cluster EKS é provisionado, e o código usa as variáveis `account_id`, `region`, e `oidc` para configurar dinamicamente o provider correto.

  - **Action**: Define que a ação permitida é `sts:AssumeRoleWithWebIdentity`, que é a ação necessária para usar identidades OIDC para assumir o Role.

  - **Condition**: Impõe condições adicionais sobre quem pode assumir o Role:
    - O campo `sub` restringe que o `ServiceAccount` do Kubernetes (no namespace `default`) associado ao controlador de load balancer possa assumir o Role.
    - O campo `aud` verifica se a audiência é `sts.amazonaws.com`, que é uma exigência para a autenticação OIDC na AWS.

#### 2. Tags:

```hcl
  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-aws-load-balancer-controller"
    }
  )
```

- **`tags`**: Assim como em outros recursos, o Role é marcado com tags para facilitar a identificação e gerenciamento. Aqui, ele recebe o nome `${var.project_name}-aws-load-balancer-controller`.

#### 3. Anexando a Política IAM ao Role:

```hcl
resource "aws_iam_role_policy_attachment" "eks_controller_role_attachment" {
  role       = aws_iam_role.eks_controller_role.name
  policy_arn = aws_iam_policy.eks_controller_policy.arn
}
```

- **`role`**: Aqui, o Role criado anteriormente (`eks_controller_role`) é associado a uma política. O nome do Role é obtido do bloco `aws_iam_role.eks_controller_role`.

- **`policy_arn`**: Refere-se à política IAM que foi definida anteriormente no código. Neste caso, é a política `AmazonEKSWorkerNodePolicy` que contém as permissões necessárias para o Load Balancer Controller.

### Como Funciona:

1. **OIDC Integration**: O **AWS Load Balancer Controller** roda dentro do cluster EKS e utiliza o OpenID Connect (OIDC) para autenticação. Para que ele tenha as permissões necessárias para interagir com os recursos da AWS, como os balanceadores de carga, ele precisa de um IAM Role que permita essa interação. Essa configuração permite que o controlador assuma o Role usando a identidade OIDC.

2. **AssumeRole Policy**: A política de `AssumeRole` especifica que o controlador de load balancer, rodando no namespace e ServiceAccount `default:my-service-account`, pode assumir esse Role via OIDC.

3. **IAM Policy Attachment**: Finalmente, o Role recebe permissões específicas para gerenciar os recursos da AWS necessários ao Load Balancer Controller, através da política IAM que foi definida em um passo anterior.

### Resumo:

Este código cria e configura um Role IAM específico para o AWS Load Balancer Controller dentro de um cluster EKS. Ele utiliza OIDC para permitir que o controlador autentique e utilize esse Role, e associa as permissões adequadas (como controle de balanceadores de carga) através de políticas IAM anexadas ao Role. Isso garante que o controlador tenha as permissões necessárias para funcionar corretamente no ambiente EKS.

---

# Explicação detalhada o Assume Role:

Bloco `assume_role_policy` no contexto da criação de um **IAM Role** para o AWS Load Balancer Controller. Esse bloco é responsável por definir quem pode assumir o papel e quais condições devem ser atendidas. Vamos desmembrar isso com mais detalhes.

O `assume_role_policy` no **AWS IAM Role** define a política que controla **quem** ou **o quê** pode assumir o papel. Isso é usado para permitir que um serviço, usuário ou entidade assuma temporariamente esse Role e execute ações que exigem permissões adicionais.

No código abaixo:

```hcl
resource "aws_iam_role" "eks_controller_role" {
  name = "${var.project_name}-aws-load-balancer-controller"

  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.${data.aws_region.current.name}.amazonaws.com/id/${local.oidc}"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "oidc.eks.${data.aws_region.current.name}.amazonaws.com/id/${local.oidc}:sub": "system:serviceaccount:default:my-service-account",
            "oidc.eks.${data.aws_region.current.name}.amazonaws.com/id/${local.oidc}:aud": "sts.amazonaws.com"
          }
        }
      }
    ]
  }
  EOF
```

#### 1. **Effect: "Allow"**

- **Effect** define a ação que será permitida ou negada. Aqui, o efeito é **"Allow"**, ou seja, essa política permite que certas ações sejam executadas (neste caso, a ação de assumir o Role).
  
#### 2. **Principal: Federated**

A chave **Principal** especifica **quem** pode assumir o Role. Neste caso, o campo **Federated** é utilizado porque estamos lidando com autenticação de uma entidade federada via **OIDC (OpenID Connect)**.

```json
"Principal": {
  "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.${data.aws_region.current.name}.amazonaws.com/id/${local.oidc}"
}
```

- **Federated**: O campo **Federated** indica que quem vai assumir este Role é uma entidade federada, neste caso, uma identidade OIDC associada ao cluster EKS. O **OIDC provider** é a ponte entre o serviço da AWS e o cluster EKS, permitindo que o controlador do balanceador de carga (que está rodando como um pod dentro do Kubernetes) autentique-se na AWS e assuma o Role.

- **`${data.aws_caller_identity.current.account_id}`**: Isso refere-se ao **ID da conta AWS** onde o cluster EKS está rodando. Essa variável dinâmica ajuda a vincular o OIDC Provider correto.
  
- **`${data.aws_region.current.name}`**: Refere-se à **região AWS** onde o cluster EKS está operando, garantindo que o OIDC Provider seja corretamente configurado de acordo com a região.

- **`${local.oidc}`**: Esse campo contém o **ID OIDC** específico do cluster EKS. O **OIDC provider** é uma URL exclusiva gerada para cada cluster EKS. Esse valor é obtido no momento da criação do cluster.

#### 3. **Action: sts:AssumeRoleWithWebIdentity**

```json
"Action": "sts:AssumeRoleWithWebIdentity"
```

- A ação **`sts:AssumeRoleWithWebIdentity`** permite que uma entidade autenticada via **Web Identity** (no caso, OIDC) assuma o Role. Essa ação é específica para identidades federadas, como as que utilizam o OIDC.

- Quando um pod dentro do cluster EKS faz uma chamada para a AWS, ele vai autenticar usando um token OIDC e, em seguida, solicitará à AWS que assuma o Role com essa ação. Se todas as condições forem atendidas, o pod conseguirá assumir o Role e executar as permissões associadas a ele.

#### 4. **Condition: StringEquals**

```json
"Condition": {
  "StringEquals": {
    "oidc.eks.${data.aws_region.current.name}.amazonaws.com/id/${local.oidc}:sub": "system:serviceaccount:default:my-service-account",
    "oidc.eks.${data.aws_region.current.name}.amazonaws.com/id/${local.oidc}:aud": "sts.amazonaws.com"
  }
}
```

O bloco **Condition** adiciona condições específicas que devem ser verdadeiras para que o Role possa ser assumido. No caso, temos duas condições importantes:

- **`sub`**: Este campo (`subject`) define **qual entidade OIDC específica** pode assumir o Role. No exemplo, a entidade permitida é o **ServiceAccount `my-service-account`** dentro do **namespace `default`** no cluster Kubernetes. Isso significa que apenas o controlador do balanceador de carga (ou outro serviço rodando com esse ServiceAccount) pode autenticar-se e assumir o Role.
  
  A estrutura `"system:serviceaccount:default:my-service-account"` é uma forma de indicar a identidade de um pod Kubernetes rodando com o ServiceAccount chamado `my-service-account` no namespace `default`.

- **`aud`**: Este campo refere-se à **audiência do token OIDC**. No caso, a audiência precisa ser `sts.amazonaws.com`, que é o serviço de Token Security da AWS (STS). Isso garante que o token foi gerado para autenticação na AWS, adicionando uma camada extra de segurança.

#### 5. **Por que isso é necessário?**

O **OIDC (OpenID Connect)** permite que entidades dentro de um cluster EKS autentiquem-se na AWS usando identidades Web. Isso é especialmente útil para serviços como o **AWS Load Balancer Controller**, que precisa de permissões para interagir com recursos da AWS (como criar balanceadores de carga), mas é gerenciado como um pod dentro do cluster Kubernetes.

Como os pods dentro do Kubernetes não têm identidades IAM "diretas", eles usam OIDC para emitir tokens que podem ser validados pela AWS. Esse processo cria uma integração segura e escalável entre o cluster Kubernetes e a infraestrutura AWS.

### Resumo:

O **`assume_role_policy`** é a peça-chave para permitir que o controlador de balanceador de carga, rodando como um pod dentro do Kubernetes, assuma permissões específicas na AWS. Utilizando o OIDC, o pod pode autenticar-se e assumir o IAM Role, desde que as condições, como o uso do `ServiceAccount` correto e o público do token, sejam atendidas. Isso permite que o controlador interaja com os recursos AWS de maneira segura, controlada e escalável.