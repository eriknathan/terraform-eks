# Nat Gateway e Elastic IP

## O que é um Elastic IP (EIP)?
É um endereço IP público e estático que você pode associar a instâncias EC2, gateways NAT (NGW), ou outros recursos dentro de uma VPC na AWS.
- **Persistência:** Ao contrário de um IP público dinâmico, que pode mudar quando uma instância é parada e iniciada, o EIP mantém o mesmo endereço IP mesmo que a instância ou o recurso associado seja reiniciado.
- **Uso com Gateways NAT (NGWs):** EIPs são frequentemente associados a NAT Gateways (NGWs), permitindo que instâncias em subnets privadas possam acessar a internet.

## Bloco aws_eip

```hcl
resource "aws_eip" "eks_ngw_eip_1a" {
  domain = "vpc"

  tags = merge(
    local.tags,
    {
      Name = "${var.project_name}-eip-1a"
    }
  )
}

resource "aws_eip" "eks_ngw_eip_1b" {
  domain = "vpc"

  tags = merge(
    local.tags,
    {
      Name = "${var.project_name}-eip-1b"
    }
  )
}
```

- **Definição:** Similar ao bloco anterior, este bloco cria um segundo EIP para a VPC.
- **domain** = "vpc": Especifica que o EIP será utilizado dentro de uma VPC.
- **tags:** A tag Name é atribuída como ${var.project_name}-eip-1b, seguindo o mesmo padrão de nomenclatura.

---

## O que é um Nat Gateway?

**NAT Gateway (NGW):** É um serviço da AWS que permite que instâncias em subnets privadas possam se conectar à internet ou a outros serviços fora da VPC, mas sem permitir conexões não solicitadas vindas de fora.

- **Função:** Ele age como um intermediário, roteando o tráfego de saída de subnets privadas para a internet usando um Elastic IP público, mas mantendo as instâncias privadas seguras, sem expô-las diretamente à internet.
- **Uso em Subnets Privadas:** NAT Gateways são geralmente colocados em subnets públicas, mas são usados por subnets privadas. As subnets privadas roteiam seu tráfego de saída para a internet através desses NAT Gateways.

## Bloco aws_nat_gateway

```hcl
resource "aws_nat_gateway" "eks_ngw_1a" {
  allocation_id = aws_eip.eks_ngw_eip_1a.id
  subnet_id     = aws_subnet.eks_subnet_public_1a.id

  tags = merge(
    local.tags,
    {
      Name = "${var.project_name}-ngw-1a"
    }
  )
}
```
- **Definição:** Este bloco cria um NAT Gateway (eks_ngw_1a) em uma subnet pública na AWS.
- **allocation_id:** Refere-se ao ID do Elastic IP (eks_ngw_eip_1a) que será associado a este NAT Gateway. Isso garante que o NAT Gateway tenha um IP público fixo para comunicação com a internet.
subnet_id: Especifica o ID da subnet pública (eks_subnet_public_1a) onde o NAT Gateway será implantado.
- **tags:** Aplica tags ao NAT Gateway para facilitar sua identificação, utilizando a tag Name com o valor ${var.project_name}
  -ngw-1a.

```hcl
resource "aws_nat_gateway" "eks_ngw_1b" {
  allocation_id = aws_eip.eks_ngw_eip_1b.id
  subnet_id     = aws_subnet.eks_subnet_public_1b.id

  tags = merge(
    local.tags,
    {
      Name = "${var.project_name}-ngw-1b"
    }
  )
}
```
- **Definição:** Este bloco cria um segundo NAT Gateway (eks_ngw_1b), desta vez em outra subnet pública (eks_subnet_public_1b).
- **allocation_id:** Refere-se ao ID do segundo Elastic IP (eks_ngw_eip_1b), que será associado a este NAT Gateway.
- **subnet_id:** Especifica o ID da subnet pública (eks_subnet_public_1b) onde o segundo NAT Gateway será implantado.
**tags:** Aplica tags ao segundo NAT Gateway, com a tag Name definida como ${var.project_name}-ngw-1b.






