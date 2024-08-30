# Subnets

https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet

## Conceito de Subnets Públicas e Privadas

### 1. Subnet Pública
Uma subnet pública é uma rede dentro da VPC que tem acesso direto à Internet. Isso é geralmente alcançado através de um Internet Gateway (IGW) que conecta a VPC à Internet. As instâncias e recursos dentro da subnet pública podem se comunicar com a Internet e receber tráfego de entrada diretamente da Internet.

#### Características:
- **Acesso à Internet:** Recursos na subnet pública podem enviar e receber tráfego da Internet.
- **Roteamento:** A tabela de rotas da subnet pública deve ter uma rota para o Internet Gateway.
- **Usos Comuns:** Servidores web, load balancers, e outros recursos que precisam ser acessíveis externamente.
 
```hcl
resource "aws_subnet" "eks_subnet_public_1a" {
   vpc_id                  = aws_vpc.eks_vpc.id
   cidr_block              = cidrsubnet(var.cidr_block, 8, 1)
   availability_zone       = "us-east-1a"
   map_public_ip_on_launch = true

   tags = merge(
      local.tags,
      {
         Name = "kubelabz-subnet-1a-tf"
      }
   )
}

resource "aws_subnet" "eks_subnet_public_1b" {
   vpc_id                  = aws_vpc.eks_vpc.id
   cidr_block              = cidrsubnet(var.cidr_block, 8, 2)
   availability_zone       = "us-east-1b"
   map_public_ip_on_launch = true

   tags = merge(
      local.tags,
      {
         Name = "kubelabz-subnet-1b-tf"
      }
   )
}
```
- **eks_subnet_public_1a e eks_subnet_public_1b** são duas subnets públicas em uma VPC.
- **cidr_block** define o intervalo de IPs para cada subnet.
- **availability_zone** especifica onde cada subnet será criada, ajudando na distribuição geográfica.
- **map_public_ip_on_launch** garante que instâncias na subnet tenham IPs públicos automaticamente.
- **tags** ajudam a categorizar e identificar as subnets para gerenciamento fácil.

Essas configurações garantem que as instâncias na subnet pública possam acessar a Internet e sejam facilmente identificáveis e organizadas dentro da VPC.

### Detalhamento da Função cidrsubnet
A função cidrsubnet é usada para calcular blocos CIDR menores a partir de um bloco CIDR maior. Aqui está como ela funciona:

**cidrsubnet(prefix, new_bits, netnum):**
- **prefix:** O bloco CIDR original da VPC ou do maior bloco do qual você está derivando subnets. No seu caso, var.cidr_block deve 
ser um bloco CIDR maior que abrange todas as suas subnets, como 10.0.0.0/16.
- **new_bits:** O número de bits a serem adicionados ao bloco CIDR para criar subnets menores. No seu exemplo, 8 adiciona 8 bits ao 
  prefixo original, o que cria blocos CIDR /24 (ou seja, cada subnet terá um bloco CIDR de /24 a partir de um bloco maior).
- **netnum:** O número da subnet a ser calculada. 0 seria a primeira subnet, 1 a segunda, e assim por diante. No seu exemplo, 1 e 2 
  indicam duas subnets diferentes.

**Exemplo de Cálculo**

**Se var.cidr_block for *10.0.0.0/16*, e você usa cidrsubnet(var.cidr_block, 8, 1):**
- Bloco CIDR Original: 10.0.0.0/16
- Prefixo Adicional: 8 bits
- Número da Subnet: 1

Isso resulta em 10.0.1.0/24 para a primeira subnet pública (eks_subnet_public_1a).

**Para cidrsubnet(var.cidr_block, 8, 2):**

- Número da Subnet: 2

Isso resulta em 10.0.2.0/24 para a segunda subnet pública (eks_subnet_public_1b).

---

### 2. Subnet Privada
Uma subnet privada é uma rede dentro da VPC que não tem acesso direto à Internet. Os recursos dentro de uma subnet privada não 
podem se comunicar diretamente com a Internet, mas podem acessar a Internet através de um NAT Gateway ou NAT Instance se for necessário.

#### Características:
- **Sem Acesso Direto à Internet:** Recursos na subnet privada não podem se comunicar diretamente com a Internet.
- **Roteamento:** A tabela de rotas da subnet privada não tem uma rota direta para o Internet Gateway, mas pode ter uma rota para 
  um NAT Gateway para acessar a Internet de forma indireta.
- **Usos Comuns:** Bancos de dados, servidores de aplicações, e outros recursos que não precisam ser acessíveis diretamente da Internet.

