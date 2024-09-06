# Deploy do Helm Chart

provider "helm" {
  kubernetes {
    host                   = module.eks_cluster.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_cluster.certificate_authority)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks_cluster.cluster_name]
      command     = "aws"
    }
  }
}

Este código configura o **provider "helm"** no Terraform, que é usado para interagir com o Kubernetes e gerenciar pacotes Helm. O Helm é uma ferramenta de gerenciamento de pacotes para Kubernetes, e essa configuração usa o provider Kubernetes integrado para conectar-se ao cluster EKS e permitir que o Helm instale e gerencie charts dentro desse cluster.

### Detalhes do Código:

#### 1. **provider "helm"**:
   - O provider `helm` é utilizado para instalar, configurar e gerenciar charts Helm no Kubernetes. Aqui, o provider `helm` está sendo configurado para usar as credenciais e endpoint do cluster EKS gerado pelo módulo `eks_cluster`.

#### 2. **kubernetes { ... }**:
   - Dentro do provider `helm`, o bloco `kubernetes` define a conexão entre o Helm e o cluster Kubernetes.
  
#### 3. **host**:
   - Este campo é o **endpoint do cluster Kubernetes**. O valor `module.eks_cluster.cluster_endpoint` refere-se ao endpoint do cluster EKS configurado anteriormente no módulo Terraform chamado `eks_cluster`. Ele é necessário para que o Helm possa se conectar ao cluster Kubernetes.

#### 4. **cluster_ca_certificate**:
   - Este campo é o certificado CA (Certificate Authority) do cluster Kubernetes. Ele é base64 codificado, por isso o uso de `base64decode(module.eks_cluster.certificate_authority)` para decodificar o valor correto e garantir que a conexão seja segura entre o Helm e o cluster.

#### 5. **exec { ... }**:
   - A seção `exec` é usada para executar comandos externos para obter tokens de autenticação que serão usados pelo Helm para autenticar-se com o cluster Kubernetes.

   - **api_version**: Define a versão da API que será usada para autenticação, aqui `client.authentication.k8s.io/v1beta1`.

   - **args**:
     - Este argumento define a lista de comandos que será passada para o cliente AWS (`aws`) para autenticar no cluster EKS. O comando especificado aqui é `eks get-token`, que obtém o token de autenticação para o cluster EKS. O nome do cluster é obtido a partir de `module.eks_cluster.cluster_name`.

   - **command**:
     - Define o comando que será executado, neste caso, é o comando `aws`, que vai rodar os argumentos fornecidos para obter o token de autenticação.

### Resumo do Processo:
1. O **Helm** precisa interagir com o **Kubernetes** (neste caso, um cluster EKS).
2. O **provider Kubernetes** fornece o acesso ao cluster usando o endpoint, o certificado de autoridade (CA) e um token de autenticação obtido via comando AWS (`aws eks get-token`).
3. Esse token permite que o Helm execute comandos de gerenciamento de charts dentro do cluster EKS, como instalar ou remover pacotes Helm (charts).

### Contexto de Uso:
Este código é normalmente usado em automações de deploy para clusters Kubernetes gerenciados pelo **AWS EKS**. Ele facilita a instalação de aplicações Kubernetes usando Helm diretamente via Terraform.

---

# Use Chart Repository

Este código utiliza o Terraform para fazer o deploy do **AWS Load Balancer Controller** no cluster EKS usando o **Helm**. Ele define um recurso do tipo `helm_release` que baixa e instala o chart Helm correspondente ao controlador de load balancer da AWS no cluster Kubernetes, dentro do namespace `kube-system`.

### Detalhes do Código:

#### 1. **`helm_release`**:
   - Este recurso é responsável por instalar e gerenciar um **chart Helm** no Kubernetes. No caso, estamos instalando o **AWS Load Balancer Controller**, um controlador que facilita a criação e gerenciamento de load balancers para serviços no Kubernetes que rodam no EKS.

#### 2. **`name`**:
   - Define o nome do release Helm, neste caso, `aws-load-balancer-controller`. Esse nome será visível no cluster Kubernetes como o nome do release do chart.

#### 3. **`repository`**:
   - Define a URL do repositório Helm de onde o chart será obtido. Aqui, a URL é `https://aws.github.io/eks-charts`, que é o repositório oficial de charts Helm da AWS para EKS.

#### 4. **`chart`**:
   - O nome do chart Helm que será instalado. Neste caso, é o **aws-load-balancer-controller**.

#### 5. **`version`**:
   - A versão específica do chart que será instalada. No exemplo, a versão do controlador é **1.8.2**.

#### 6. **`namespace`**:
   - Define o namespace Kubernetes onde o controlador será instalado. Aqui, o namespace é `kube-system`, que geralmente é usado para componentes importantes do sistema Kubernetes.

#### 7. **`set { ... }`**:
   - A diretiva `set` é usada para passar valores específicos durante a instalação do chart Helm. Isso equivale ao uso de parâmetros `--set` na CLI do Helm.

   - **Primeira diretiva `set`**:
     - **name**: `"clusterName"`
     - **value**: `var.cluster_name`
     - Isso configura o nome do cluster EKS ao qual o AWS Load Balancer Controller será associado. A variável `cluster_name` provavelmente foi definida em outro local no código Terraform.

   - **Segunda diretiva `set`**:
     - **name**: `"serviceAccount"`
     - **value**: `"false"`
     - Define que o controlador não criará uma nova conta de serviço, pois uma conta de serviço já foi criada manualmente (conforme especificado).

   - **Terceira diretiva `set`**:
     - **name**: `"serviceAccount.name"`
     - **value**: `"aws-load-balancer-controller"`
     - **type**: `"string"`
     - Define o nome da conta de serviço existente para ser usada pelo controlador. O nome da conta de serviço foi criado anteriormente com o mesmo nome `aws-load-balancer-controller`.

#### 8. **`values` (comentado)**:
   - Este bloco está comentado no código, mas seria usado para passar um arquivo `values.yaml` com as configurações personalizadas do chart. Se esse bloco fosse descomentado, o Helm usaria as configurações definidas no arquivo `values.yaml`.

### Resumo do Processo:
1. O Terraform usa o **Helm** para instalar o **AWS Load Balancer Controller** no cluster EKS.
2. O chart Helm é obtido a partir do repositório `https://aws.github.io/eks-charts` e é instalado na versão `1.8.2` no namespace `kube-system`.
3. Configurações adicionais como o nome do cluster, o uso de uma conta de serviço existente, e o nome dessa conta são passadas por meio do bloco `set`.

### Contexto de Uso:
Esse código é usado em clusters Kubernetes gerenciados pela AWS (EKS) para permitir a criação e gerenciamento automático de **load balancers** (ALB e NLB) para expor serviços do Kubernetes externamente, utilizando as funcionalidades da AWS.