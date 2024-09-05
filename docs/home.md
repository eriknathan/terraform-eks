1. VPC
   Recurso: aws_vpc

Descrição: A VPC é a fundação da infraestrutura, uma rede isolada onde os recursos serão criados.
CIDR: Defina o bloco CIDR como 10.0.0.0/16.
Relacionamento: Todas as subnets, gateways, e tabelas de rotas serão criados dentro desta VPC.
Configuração: Habilitar o DNS hostname para facilitar a resolução de nomes dentro da VPC.
2. Subnets (Privada e Pública)
   Recurso: aws_subnet

Descrição: Crie subnets públicas e privadas em diferentes zonas de disponibilidade. Isso permite alta disponibilidade e balanceamento entre regiões.
Relacionamento: As subnets serão associadas à VPC criada no primeiro passo.
Tags: Inclua tags como kubernetes.io/role/internal-elb para subnets privadas e kubernetes.io/role/elb para subnets públicas, para suportar a criação de balanceadores de carga no futuro.
3. Internet Gateway (IGW) e Route Table (RTB)
   Recursos: aws_internet_gateway e aws_route_table

Descrição: O IGW é necessário para que os recursos na subnet pública tenham acesso à internet.
Relacionamento: O IGW será associado à VPC, e a tabela de rotas pública será configurada para rotear todo o tráfego (0.0.0.0/0) através do IGW.
Associação de subnets: As subnets públicas serão associadas à tabela de rotas pública.
4. NAT Gateway e Route Table Privada
   Recursos: aws_nat_gateway e aws_route_table

Descrição: O NAT Gateway é usado para permitir que instâncias nas subnets privadas acessem a internet sem estarem diretamente expostas.
Relacionamento: O NAT Gateway será associado a uma subnet pública e vinculado a uma tabela de rotas privada.
Associação de subnets: Cada subnet privada será associada a uma tabela de rotas privada que usa o NAT Gateway para acessar a internet.
5. Bastion Host (EC2)
   Recurso: aws_instance

Descrição: Um bastion host será usado para testar a conectividade com a rede pública e fornecer acesso SSH seguro para a VPC.
Relacionamento: Será colocado em uma subnet pública e será usado para acessar recursos nas subnets privadas.
6. Role IAM para o Cluster EKS
   Recurso: aws_iam_role

Descrição: Crie uma role IAM para o cluster EKS, atribuindo a política AmazonEKSClusterPolicy, que concede permissões para o gerenciamento do cluster.
Relacionamento: Esta role será associada ao cluster EKS durante a criação.
7. Criação do Cluster EKS
   Recurso: aws_eks_cluster

Descrição: O EKS será o ambiente gerenciado onde seus containers Kubernetes serão executados.
Relacionamento: O cluster usará as subnets públicas e privadas configuradas anteriormente, e a role IAM será associada ao cluster.
Complementos: Inclua add-ons como CoreDNS, kube-proxy, e o CNI da Amazon VPC, fundamentais para o funcionamento do cluster.
8. Role IAM para os Nós do EKS
   Recurso: aws_iam_role

Descrição: Crie uma role IAM para os nós gerenciados do EKS, atribuindo as políticas AmazonEKSWorkerNodePolicy, AmazonEC2ContainerRegistryReadOnly, e AmazonEKS_CNI_Policy.
Relacionamento: Esta role será atribuída aos nós do EKS para permitir a execução de containers e comunicação com o cluster.
9. Managed Node Group
   Recurso: aws_eks_node_group

Descrição: Configure um grupo de nós gerenciados (Managed Node Group) para o EKS, usando instâncias EC2 Spot.
Relacionamento: O grupo de nós estará associado ao cluster EKS e será provisionado nas subnets privadas.
Tamanho e Tipo: Defina parâmetros como tipo de instância, tamanho desejado, e chaves de acesso remoto.
10. OIDC Provider para IAM Roles
    Recurso: aws_iam_openid_connect_provider

Descrição: O OIDC provider é necessário para permitir que o EKS utilize roles IAM associadas a contas de serviço no Kubernetes.
Relacionamento: O OIDC provider será associado ao cluster EKS.
11. AWS Load Balancer Controller
    Recurso: aws_iam_role, helm_release

Descrição: Instale o AWS Load Balancer Controller para permitir a criação e gerenciamento de load balancers pelo Kubernetes.
Relacionamento: Será criada uma role IAM associada ao serviço, e o Helm será usado para instalar o controller dentro do cluster EKS.
