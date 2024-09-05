# Alterando regra de HTTPS para API server

Este código cria uma regra de segurança para o cluster EKS, permitindo o tráfego HTTPS (porta 443) de entrada (ingress) de qualquer lugar.

```hcl
resource "aws_security_group_rule" "eks_cluster_sg_rule" {
  type      = "ingress"
  from_port = 433
  to_port   = 433
  protocol  = "tcp"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
  description       = "Liberando o Trafego HTTPS para qualquer local"
}
```

## Recurso aws_security_group_rule

1. `type = "ingress":`Esta regra é do tipo ingress, o que significa que permite o tráfego entrante no cluster. Há dois tipos possíveis para uma regra de segurança: ingress (entrada) e egress (saída).

2. `from_port = 443 e to_port = 443:` Define a porta de origem e a porta de destino, ambas sendo 443, que é a porta padrão para o protocolo HTTPS (tráfego seguro).

3. `protocol = "tcp":` Define que o protocolo utilizado para a comunicação será o TCP (Transmission Control Protocol).

4. `cidr_blocks = ["0.0.0.0/0"]:` Permite tráfego de qualquer endereço IP na internet, pois 0.0.0.0/0 abrange todos os endereços IPv4. Isso significa que qualquer um, de qualquer local, pode acessar o cluster na porta 443, o que pode ser um risco de segurança, dependendo do caso.

5. `security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id:` Define o ID do Security Group ao qual essa regra será aplicada. O Security Group usado é o que está associado ao cluster EKS criado anteriormente. O ID é extraído de vpc_config[0].cluster_security_group_id, que é parte da configuração de rede do cluster.

6. `description = "Liberando o Trafego HTTPS para qualquer local":` Um comentário ou descrição que explica o propósito da regra, neste caso, a liberação de tráfego HTTPS para qualquer endereço IP.

# Explicação Geral:

Este código cria uma regra de segurança para o EKS Cluster, permitindo que qualquer um na internet se conecte ao cluster via HTTPS. Isso é útil para garantir que o cluster possa ser acessado publicamente por administradores ou outros serviços através de um endpoint HTTPS seguro. Contudo, essa configuração deve ser usada com cuidado, pois abre o tráfego para qualquer endereço IP, o que pode apresentar riscos de segurança se o cluster não estiver protegido adequadamente.








