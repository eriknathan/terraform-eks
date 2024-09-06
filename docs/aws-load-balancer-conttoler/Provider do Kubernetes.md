# Provider do Kubernetes

```hcl
provider "kubernetes" {
  host                   = module.eks_cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_cluster.certificate_authority)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks_cluster.cluster_name]
    command     = "aws"
  }
}
```

Esse código configura o **provider do Kubernetes** no Terraform, conectando-o ao cluster EKS criado anteriormente. Ele é usado para permitir que o Terraform se comunique diretamente com o cluster Kubernetes, gerenciando recursos como **pods**, **services**, **deployments**, entre outros. Vamos detalhar os principais elementos:

### Detalhamento do código:

- **provider "kubernetes"**: Define o provedor Kubernetes no Terraform, que é necessário para gerenciar recursos dentro de um cluster Kubernetes.

- **host**: O endereço do endpoint da API do cluster Kubernetes. No caso, ele está sendo obtido a partir do módulo `eks_cluster`, que provavelmente foi configurado anteriormente para criar o cluster EKS. O valor de `cluster_endpoint` é a URL onde o Kubernetes expõe a sua API.

- **cluster_ca_certificate**: Certificado de autoridade (CA) do cluster Kubernetes, necessário para garantir uma conexão segura entre o cliente (neste caso, o Terraform) e o cluster. A função `base64decode()` é usada para decodificar o certificado que foi codificado em Base64, pois esse é o formato padrão quando o Kubernetes retorna esses certificados. Ele também é obtido a partir do módulo `eks_cluster`.

- **exec { ... }**: Bloco que define como o Terraform vai obter um **token de autenticação** para se comunicar com o cluster Kubernetes via AWS. O Kubernetes EKS usa um token para autenticação com o serviço da AWS.
  
  - **api_version**: Especifica a versão da API usada para autenticação. Aqui, está usando a `client.authentication.k8s.io/v1beta1`, uma versão de API de autenticação do cliente do Kubernetes.
  
  - **args**: Argumentos passados para o comando de execução. Neste caso, é utilizado o comando `aws eks get-token`, que é um comando da AWS CLI para obter um token de autenticação do EKS. O argumento `--cluster-name` é usado para especificar o nome do cluster, que também é obtido a partir do módulo `eks_cluster`.

  - **command**: Especifica o comando que será executado, neste caso, o comando `aws`, que está sendo usado para se conectar ao cluster EKS via AWS CLI.

### Fluxo de Execução:

1. O Terraform utiliza o endpoint do cluster e o certificado CA para estabelecer uma conexão segura com a API do Kubernetes.
2. Para autenticar a comunicação, ele executa o comando `aws eks get-token`, que retorna um token para ser usado no Kubernetes.
3. Esse token é então usado para autenticar as solicitações feitas pelo Terraform ao cluster.

### Contexto de uso:
Esse tipo de configuração é comum quando se usa o **EKS (Elastic Kubernetes Service)** na AWS. Ao utilizar o Terraform para gerenciar o cluster, você precisa configurar o provider Kubernetes corretamente para aplicar recursos diretamente no cluster, utilizando o AWS como intermediário para a autenticação e segurança do acesso.