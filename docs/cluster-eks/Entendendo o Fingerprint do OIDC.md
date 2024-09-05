# Entendendo o Fingerprint do OIDC

https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc_verify-thumbprint.html

---

O **OpenID Connect (OIDC)** é um protocolo baseado no OAuth 2.0 que permite a autenticação de usuários e o intercâmbio de informações de identidade de forma segura. Na AWS, o OIDC é utilizado para autenticar identidades de provedores de terceiros (como Google ou GitHub) com o Amazon IAM para facilitar o acesso a recursos da AWS.

Uma parte importante do processo de configuração do OIDC é a verificação do **Thumbprint** ou **Fingerprint** do certificado SSL/TLS do servidor do provedor OIDC. A seguir, vamos entender o que é o Thumbprint e como ele funciona no contexto da autenticação.

## O que é o Fingerprint (Thumbprint)?

O **Fingerprint** ou **Thumbprint** é uma sequência de caracteres que representa uma impressão digital do certificado de um servidor. É obtido aplicando um algoritmo de hash (geralmente SHA-1 ou SHA-256) ao certificado SSL/TLS do servidor OIDC. Essa impressão digital serve para garantir a autenticidade do provedor OIDC ao verificar se as solicitações estão sendo feitas de um servidor confiável.

A AWS usa esse Fingerprint para garantir que a entidade que está se conectando realmente seja o provedor de identidade que você está declarando. Se o Fingerprint não corresponder ao esperado, a conexão será rejeitada.

## Como funciona o Fingerprint no OIDC na AWS?

Quando você configura um provedor de identidade OIDC no **AWS IAM**, a AWS requer que você forneça o Fingerprint do certificado SSL/TLS do servidor OIDC. Esse Fingerprint é utilizado pela AWS para verificar que o provedor de identidade é autêntico.

### Passo a Passo do Processo

1. **Obtendo o Certificado SSL do Provedor OIDC**:
   - O primeiro passo é acessar o domínio OIDC e obter o certificado SSL/TLS. O certificado contém a chave pública do servidor, que é usada para validar a autenticidade do provedor.

2. **Gerando o Fingerprint**:
   - A impressão digital (Fingerprint) é gerada aplicando um algoritmo de hash (geralmente SHA-1 ou SHA-256) no certificado. Essa operação gera uma string de caracteres que é única para o certificado.
   - Exemplo de um Fingerprint SHA-1: `5F:AD:C1:12:A4:B3:9D:6C:F9:4C:7B:A4:6D:5F:A2:AB:8C:3A:F4`

3. **Fornecendo o Fingerprint à AWS**:
   - Ao criar um provedor OIDC no AWS IAM, você deve fornecer o Fingerprint do certificado do provedor. Esse Fingerprint será utilizado pela AWS para verificar todas as conexões futuras com o provedor de identidade.

4. **Verificação pela AWS**:
   - Cada vez que o provedor OIDC faz uma solicitação para a AWS, a AWS compara o Fingerprint do certificado apresentado com o Fingerprint que você configurou no IAM.
   - Se o Fingerprint coincidir, a solicitação é considerada legítima. Caso contrário, a solicitação será rejeitada.

### Por que o Fingerprint é importante?

O Fingerprint é fundamental para garantir a segurança nas conexões entre a AWS e o provedor de identidade OIDC. Ele previne ataques **MITM (Man-in-the-Middle)**, onde um agente malicioso poderia tentar interceptar ou falsificar as comunicações entre o servidor OIDC e a AWS.

---

## Exemplo Prático: Como Gerar e Verificar um Fingerprint

1. **Obter o Certificado SSL/TLS do Provedor OIDC**:
   Para verificar o Fingerprint de um provedor, você pode usar o comando `openssl` para baixar o certificado. Substitua `OIDC_DOMAIN` pelo domínio do provedor OIDC.

   ```bash
   openssl s_client -connect OIDC_DOMAIN:443 -showcerts
   ```

2. **Gerar o Fingerprint (Thumbprint)**:
   Use o comando abaixo para gerar o Thumbprint usando SHA-1 a partir do certificado baixado:

   ```bash
   openssl x509 -in cert.pem -fingerprint -noout
   ```

   Isso retornará algo como:

   ```
   SHA1 Fingerprint=5F:AD:C1:12:A4:B3:9D:6C:F9:4C:7B:A4:6D:5F:A2:AB:8C:3A:F4
   ```

3. **Configurar o Provedor OIDC no IAM**:
   Ao configurar o provedor OIDC no IAM, você fornecerá o Fingerprint gerado para que a AWS possa validar as conexões.

---

## Atualizando o Thumbprint

O Fingerprint pode mudar quando o provedor de identidade OIDC renova ou substitui seu certificado SSL/TLS. É importante manter o Thumbprint atualizado na AWS para garantir que as conexões continuem válidas.

Para atualizar o Thumbprint:

1. **Obtenha o novo Thumbprint do provedor OIDC**.
2. **Atualize o Thumbprint no console IAM**:
   - Vá até o provedor de identidade OIDC no console do IAM.
   - Insira o novo Thumbprint no campo apropriado.

---

## Considerações Finais

A verificação do Fingerprint é uma camada crítica de segurança ao usar provedores OIDC com a AWS. Ela garante que as identidades e permissões atribuídas aos usuários sejam seguras e confiáveis, protegendo contra possíveis ataques e acessos não autorizados.

Manter o Fingerprint atualizado e monitorar possíveis mudanças no certificado SSL do provedor de identidade são práticas essenciais para uma autenticação segura no uso de OIDC.

---

Com essa documentação, você tem uma visão clara de como o Fingerprint no OIDC funciona na AWS e sua importância para garantir a integridade e segurança das conexões.