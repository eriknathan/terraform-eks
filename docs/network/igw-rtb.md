# Internet Gateawy e Route Table

Internet Gateway (IGW) e uma Tabela de Rotas (RTB) associada a uma VPC para permitir que o tráfego da internet possa alcançar instâncias dentro dessa VPC.

## Internet Gateway

```hcl
resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = merge(
    local.tags,
    {
      Name = "${var.project_name}-igw"
    }
  )
}
```

- **Definição:** Cria um Internet Gateway (IGW) e o associa à VPC especificada.
- **vpc_id:** Este é o ID da VPC à qual o IGW será associado, obtido do recurso aws_vpc.eks_vpc.
- **tags:** Adiciona tags ao IGW, facilitando sua identificação. A tag Name segue o padrão ${var.project_name}-igw, onde var.project_name é uma variável definida anteriormente.

### O que é um IGW?
Internet Gateway (IGW): É um componente que permite que instâncias em uma VPC tenham acesso à internet. Ele funciona como uma ponte entre a VPC e a internet, roteando o tráfego de entrada e saída.
- Tráfego de Saída: Permite que instâncias dentro da VPC façam solicitações à internet.
- Tráfego de Entrada: Permite que respostas da internet alcancem as instâncias na VPC, se as regras de segurança permitirem.

## Route Table

```hcl
resource "aws_route_table" "eks_public_route_table" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }

  tags = merge(
    local.tags,
    {
      Name = "${var.project_name}-route-table-public"
    }
  )
}
```

- **Definição:** Cria uma Tabela de Rotas (RTB) e define rotas específicas para direcionar o tráfego dentro da VPC.
- **vpc_id:** Especifica a VPC à qual esta Tabela de Rotas está associada.
- **Bloco route:**
  - **cidr_block = "0.0.0.0/0":** Esta rota direciona todo o tráfego (representado por 0.0.0.0/0) para fora da VPC.
  - **gateway_id = aws_internet_gateway.eks_igw.id:** Especifica que o tráfego deve ser direcionado para o Internet Gateway (IGW) criado anteriormente, permitindo que o tráfego vá para a internet.
  - **tags:** Adiciona tags à Tabela de Rotas, com a tag Name seguindo o padrão ${var.project_name}-route-table-public.

### O que é uma RTB?
- **Route Table (RTB) ou Tabela de Rotas:** É um componente que contém um conjunto de regras (rotas) que determinam como o tráfego de rede deve ser roteado dentro de uma VPC.
- **Rota para o IGW:** Neste caso, a Tabela de Rotas está configurada para direcionar todo o tráfego destinado à internet (0.0.0.0/0) para o Internet Gateway. Isso significa que qualquer instância associada a essa tabela de rotas poderá se comunicar com a internet, desde que esteja em uma subnet pública.


## aws_route_table_association

```hcl
resource "aws_route_table_association" "eks_rtb_assoc_1a" {
subnet_id      = aws_subnet.eks_subnet_public_1a.id
route_table_id = aws_route_table.eks_public_route_table.id
}

resource "aws_route_table_association" "eks_rtb_assoc_private_1a" {
  subnet_id      = aws_subnet.eks_subnet_private_1a.id
  route_table_id = aws_route_table.eks_private_route_table_1a.id
}

```

- **Definição:** Este bloco associa uma subnet (eks_subnet_public/private_1a) a uma Tabela de Rotas (eks_public_route_table).
- **subnet_id:** Especifica o ID da subnet pública eks_subnet_public_1a que será associada à Tabela de Rotas.
- **route_table_id:** Especifica o ID da Tabela de Rotas eks_public_route_table à qual a subnet será associada.

```hcl
resource "aws_route_table_association" "eks_rtb_assoc_1b" {
subnet_id      = aws_subnet.eks_subnet_public_1b.id
route_table_id = aws_route_table.eks_public_route_table.id
}

resource "aws_route_table_association" "eks_rtb_assoc_private_1b" {
  subnet_id      = aws_subnet.eks_subnet_private_1b.id
  route_table_id = aws_route_table.eks_private_route_table_1b.id
}
```

- **Definição:** Similar ao bloco anterior, este bloco associa a subnet eks_subnet_public/private_1b à mesma Tabela de Rotas 
  pública (eks_public_route_table).
- **subnet_id:** Especifica o ID da subnet pública eks_subnet_public_1b.
- **route_table_id:** Especifica o ID da Tabela de Rotas eks_public_route_table.

### O que são essas associações?
Essas associações (aws_route_table_association) são cruciais para definir como o tráfego de rede dentro de cada subnet será roteado. Ao associar uma subnet a uma Tabela de Rotas, você está dizendo que todo o tráfego de rede dessa subnet deve seguir as regras definidas na Tabela de Rotas.

### Resumo
- **Associações de Tabelas de Rotas:** As associações aws_route_table_association conectam subnets a uma Tabela de Rotas específica. Isso garante que o tráfego dentro das subnets siga as rotas definidas, como a rota para o Internet Gateway (IGW) que permite o acesso à internet.
- **Funcionalidade:** No caso desse código, ao associar as subnets públicas eks_subnet_public_1a e eks_subnet_public_1b à Tabela de Rotas eks_public_route_table, essas subnets passam a ter acesso à internet, conforme a rota para 0.0.0.0/0 definida na Tabela de Rotas.
