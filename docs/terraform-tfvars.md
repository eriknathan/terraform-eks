# terraform.tfvars

O arquivo `terraform.tfvars` é usado para definir valores para as variáveis do Terraform. Ele é uma maneira prática de fornecer valores específicos para variáveis que foram declaradas em seus arquivos de configuração (`.tf`) no Terraform.

### Propósito do `terraform.tfvars`

- **Configuração de Valores**: Permite que você defina valores para variáveis que são utilizadas em sua configuração Terraform. Isso ajuda a separar a configuração da lógica, tornando seus arquivos mais limpos e fáceis de manter.
- **Customização**: Permite a customização de valores sem a necessidade de modificar diretamente os arquivos principais de configuração.
- **Segurança e Organização**: Mantém informações sensíveis ou específicas do ambiente fora dos arquivos de configuração principais, o que ajuda na organização e segurança.
### Estrutura do Arquivo `terraform.tfvars`

O arquivo `terraform.tfvars` é um arquivo simples de texto no formato de pares chave-valor. Aqui está um exemplo básico:


```hcl
# terraform.tfvars 

cidr_block = "10.0.0.0/16"

public_subnet_1_cidr = "10.0.1.0/24"
public_subnet_2_cidr = "10.0.2.0/24"
private_subnet_1_cidr = "10.0.3.0/24"
private_subnet_2_cidr = "10.0.4.0/24" 

region = "us-east-1"

project_name = "my_project"
```

### Como Funciona

1. **Declaração de Variáveis**: Em seus arquivos de configuração (`.tf`), você declara variáveis usando o bloco `variable`. Por exemplo:
```hcl
variable "cidr_block" {   
	description = "The CIDR block for the VPC"
	type        = string
}

variable "public_subnet_1_cidr" {
	description = "The CIDR block for the first public subnet"
	type        = string
}
 ```

2. **Definição de Valores**: No arquivo `terraform.tfvars`, você define os valores para essas variáveis:

```hcl
cidr_block = "10.0.0.0/16"
public_subnet_1_cidr = "10.0.1.0/24"
```

3. **Carregamento Automático**: Quando você executa comandos Terraform (como `terraform plan` ou `terraform apply`), o Terraform carrega automaticamente o arquivo `terraform.tfvars` se ele estiver na mesma pasta que seus arquivos de configuração. Os valores definidos são usados para substituir os valores padrão ou não definidos para as variáveis.


### Uso Avançado

- **Arquivos Múltiplos**: Você pode ter vários arquivos `.tfvars` (por exemplo, `production.tfvars` e `staging.tfvars`) e especificá-los ao executar comandos Terraform usando o parâmetro `-var-file`:

  bash

  Copiar código

  `terraform apply -var-file="production.tfvars"`

- **Arquivos de Variáveis de Ambiente**: Além de `terraform.tfvars`, você pode definir variáveis através de variáveis de ambiente com prefixo `TF_VAR_` (por exemplo, `TF_VAR_cidr_block`).