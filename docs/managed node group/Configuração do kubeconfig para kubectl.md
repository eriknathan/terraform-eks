# Configuração do kubeconfig para kubectl

Introdução do Kubectl: https://aluno.mateusmuller.me/76886-kubernetes-do-basico-ao-avancado/1820596-introducao-ao-kubectl

Esta documentação descreve como configurar o **kubectl** para interagir com um cluster EKS (Amazon Elastic Kubernetes Service) usando o comando `aws eks update-kubeconfig`. Vamos passar pelas etapas de configuração e uso.

### Pré-requisitos
- **AWS CLI** configurado com permissões para acessar o EKS.
- **kubectl** instalado na máquina local.
- Cluster EKS criado e em execução.

### 1. Atualizando o Kubeconfig com o EKS

O primeiro passo para configurar o acesso ao cluster EKS é gerar ou atualizar o arquivo `kubeconfig`, que o `kubectl` usará para se conectar ao cluster. O comando utilizado para isso é:

```bash
$ aws eks update-kubeconfig --region us-east-1 --name kubelabz-eks
```

#### Explicação:
- **`--region us-east-1`**: Especifica a região onde o cluster EKS está localizado. Substitua `us-east-1` pela região correspondente ao seu cluster.
- **`--name kubelabz-eks`**: O nome do cluster EKS que você deseja configurar no kubeconfig. Certifique-se de substituir `kubelabz-eks` pelo nome do seu cluster.

##### O que esse comando faz:
- Ele adiciona o contexto do cluster EKS ao arquivo `kubeconfig`, que geralmente fica em `~/.kube/config`.
- A mensagem de sucesso confirma que o contexto foi adicionado: 
  ```bash
  Added new context arn:aws:eks:us-east-1:828692866750:cluster/kubelabz-eks to /home/usuario/.kube/config
  ```

Agora o arquivo `kubeconfig` está configurado e pronto para ser usado pelo `kubectl` para se conectar ao cluster EKS.

### 2. Selecionando o Contexto do Cluster

Após configurar o arquivo `kubeconfig`, é importante garantir que o `kubectl` esteja apontando para o contexto correto (cluster correto). Isso é feito com o comando:

```bash
$ kubectl config use-context arn:aws:eks:us-east-1:828692866750:cluster/kubelabz-eks
```

#### Explicação:
- **`use-context`**: Esse comando troca o contexto para o cluster EKS especificado.
- **`arn:aws:eks:us-east-1:828692866750:cluster/kubelabz-eks`**: O contexto que você está selecionando, que foi adicionado pelo comando `aws eks update-kubeconfig`.

A saída confirmará que o contexto foi trocado com sucesso:
```bash
Switched to context "arn:aws:eks:us-east-1:828692866750:cluster/kubelabz-eks".
```

### 3. Verificando os Pods no Cluster EKS

Agora que o contexto está definido corretamente, você pode usar comandos do `kubectl` para interagir com o cluster. Um exemplo básico é listar todos os pods no cluster:

```bash
$ kubectl get po -A
```

#### Explicação:
- **`get po`**: Lista todos os pods no cluster.
- **`-A`**: O parâmetro `-A` exibe os pods em todos os namespaces.

##### Exemplo de saída:

```bash
NAMESPACE     NAME                       READY   STATUS    RESTARTS   AGE
kube-system   coredns-586b798467-fd8jc   0/1     Pending   0          76s
kube-system   coredns-586b798467-xqrjt   0/1     Pending   0          76s
```

### Possíveis Problemas:
- **`STATUS Pending`**: Isso pode indicar que o cluster ainda está provisionando os recursos necessários (como nós do cluster) ou que há um problema com os recursos de computação alocados.

### Resumo:
1. Use `aws eks update-kubeconfig` para adicionar o contexto do cluster ao kubeconfig.
2. Selecione o contexto do cluster com `kubectl config use-context`.
3. Execute comandos `kubectl` para interagir com o cluster, como listar pods com `kubectl get po -A`.

Com isso, você pode interagir com seu cluster EKS diretamente do terminal usando o `kubectl`.