# Comandos Terraform

# Init
```bash
terraform init
```

Quando você executa o comando `terraform init`, o Terraform realiza uma série de ações para preparar o ambiente de trabalho, permitindo que você comece a gerenciar sua infraestrutura. Aqui estão os principais passos que acontecem durante a execução desse comando:

1. **Download de Providers**
O Terraform verifica o bloco *required_providers* no seu arquivo de configuração (.tf) para identificar quais providers são necessários.
Em seguida, ele baixa esses providers (plugins) do Terraform Registry ou de outras fontes configuradas. Isso inclui a versão específica dos providers definida no código.
Os providers são armazenados localmente no diretório .terraform dentro do diretório de trabalho.
2. **Inicialização do Backend**
Se você estiver usando um backend configurado (por exemplo, S3 para armazenar o estado remoto), o Terraform vai inicializar essa configuração. O backend é onde o estado da infraestrutura será armazenado.
O estado pode ser armazenado localmente ou remotamente, dependendo da configuração.
3. **Validação da Configuração**
O Terraform valida as configurações básicas para garantir que os arquivos de configuração estão corretos e que todos os providers necessários estão disponíveis.
4. **Criação do Diretório .terraform**
Um diretório oculto chamado .terraform é criado no seu diretório de trabalho. Ele contém os arquivos e plugins necessários para a operação do Terraform, como os providers baixados.
5. **Plugins de Core e Backend**
O Terraform inicializa plugins internos necessários para o funcionamento básico do Terraform e para a comunicação com o backend configurado.
6. **Verificação de Lock de Providers**
O Terraform cria ou atualiza o arquivo terraform.lock.hcl, que contém informações sobre as versões dos providers usados no projeto. Isso ajuda a garantir que todos na equipe usem as mesmas versões, evitando problemas de compatibilidade.

# Plan

```bash
terraform plan
```

1. Comando terraform plan
O comando terraform plan é utilizado para criar e visualizar um plano de execução. Ele gera uma lista detalhada das ações que o Terraform vai realizar para alcançar o estado desejado da infraestrutura, conforme definido nos arquivos de configuração.

### O que acontece quando você executa terraform plan:
- Análise do Código: O Terraform lê e analisa os arquivos de configuração (.tf) para entender quais recursos precisam ser criados, modificados ou destruídos.
- Comparação de Estados: O Terraform compara o estado atual da infraestrutura (armazenado no estado Terraform) com o estado desejado (definido no código).
- Geração do Plano: Ele gera um plano mostrando todas as mudanças que serão feitas, como a criação de novos recursos, a modificação de recursos existentes ou a destruição de recursos que não são mais necessários.
- Segurança: O terraform plan permite que você revise o plano antes de aplicá-lo, reduzindo o risco de mudanças indesejadas ou erros.

Exemplo de saída:

```bash
Terraform will perform the following actions:

  # aws_vpc.eks_vpc will be created
  + resource "aws_vpc" "eks_vpc" {
      ...
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

- Nota: Plan: 1 to add, 0 to change, 0 to destroy indica que o Terraform vai adicionar 1 recurso, não vai modificar nenhum e não vai destruir nenhum.

# Apply

```bash
terraform apply
```

O comando terraform apply é usado para aplicar o plano de execução gerado pelo terraform plan, ou seja, ele faz as mudanças na infraestrutura para que ela corresponda ao estado desejado definido nos arquivos de configuração.

### O que acontece quando você executa terraform apply:
- Execução do Plano: O terraform apply aplica as mudanças necessárias para criar, modificar ou destruir recursos conforme descrito no plano gerado.
- Interação: Se você não especificar um plano previamente gerado, o terraform apply executa implicitamente o terraform plan e pergunta se você deseja continuar com as mudanças propostas.
- Atualização do Estado: Após a aplicação bem-sucedida das mudanças, o Terraform atualiza o arquivo de estado (terraform.tfstate) para refletir o novo estado da infraestrutura.

Exemplo de saída:

```bash
Terraform will perform the following actions:

  # aws_vpc.eks_vpc will be created
  + resource "aws_vpc" "eks_vpc" {
      ...
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

```
