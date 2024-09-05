# Criação do OIDC provider

Esse código configura o OIDC (OpenID Connect) para o cluster EKS na AWS, permitindo que o cluster use o serviço de autenticação OIDC.

```hcl
data "tls_certificate" "eks_oidc_tls_certificate" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks_oidc" {
  client_id_list  = [
    "sts.amazonaws.com"
  ]
  thumbprint_list = [data.tls_certificate.eks_oidc_tls_certificate.certificates[0].sha1_fingerprint]
  url             = data.tls_certificate.eks_oidc_tls_certificate.url

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-identity-providers-oidc"
    }
  )
}
```


### 1. `data "tls_certificate" "eks_oidc_tls_certificate"`
- Esse bloco de dados utiliza o recurso `tls_certificate` para buscar o certificado TLS do endpoint OIDC do cluster EKS.
- **`url`**: Obtém o URL do emissor OIDC a partir do atributo `identity` do cluster EKS. Isso acessa a URL que o EKS usará para autenticar com OIDC.
  
Este recurso coleta o certificado SSL/TLS do provedor OIDC, o que é necessário para garantir a autenticação segura entre o AWS IAM e o provedor.

### 2. `resource "aws_iam_openid_connect_provider" "eks_oidc"`
- **`client_id_list`**: Especifica quais clientes podem fazer chamadas para a API de token STS (Security Token Service). No caso, `"sts.amazonaws.com"` permite ao cluster EKS assumir permissões do IAM.
- **`thumbprint_list`**: Contém a lista de fingerprints (impressões digitais) dos certificados SSL/TLS dos servidores OIDC. Neste caso, o valor é obtido dinamicamente através do hash SHA-1 do certificado que foi recuperado no bloco de dados anterior.
  - **`data.tls_certificate.eks_oidc_tls_certificate.certificates[0].sha1_fingerprint`** obtém a impressão digital do certificado TLS.
- **`url`**: URL do servidor OIDC que o EKS usará para autenticação, extraído do dado `tls_certificate`.

### Como Funciona:
1. **Certificado TLS**: O bloco `data "tls_certificate"` obtém o certificado TLS do emissor OIDC do EKS.
2. **Fingerprint**: O hash SHA-1 do certificado TLS é usado para preencher o campo `thumbprint_list`, que será usado pelo AWS IAM para garantir que o emissor OIDC é confiável.
3. **Provedor OIDC**: O recurso `aws_iam_openid_connect_provider` configura o provedor OIDC no IAM com o Fingerprint, URL e clientes permitidos.

### O que é OIDC no EKS?
O OIDC permite que o Amazon EKS delegue permissões a workloads que rodam dentro do cluster. Ele facilita o uso de ServiceAccounts no Kubernetes, vinculando permissões IAM aos serviços dentro do cluster de forma segura, sem a necessidade de usar chaves de acesso.

---

### Explicação dos Componentes:
- **OIDC**: Protocolo para autenticação de usuários e identidade de aplicativos.
- **Fingerprint (Thumbprint)**: Impressão digital do certificado TLS, usada para garantir que o servidor OIDC seja legítimo.
- **IAM OpenID Connect Provider**: Recurso que permite à AWS autenticar identidades externas usando OIDC, necessário para vincular permissões IAM a ServiceAccounts no Kubernetes.

Este código completa a configuração necessária para permitir que o cluster EKS se comunique de forma segura com o serviço de autenticação OIDC.