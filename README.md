# Desafio Técnico -  Zabbix em Ambiente Local com Kubernetes (K3s) e Vagrant

##  Resumo
 O projeto consiste na criação de um ambiente multiplataforma local replicável que simula uma topologia de infraestrutura real. A arquitetura é composta por:
* **Provisionamento:** Duas VMs Linux utilizando a distribuição Ubuntu 22.04 LTS (`ubuntu/jammy64`), gerenciadas programaticamente via Vagrant e Oracle VirtualBox.
* **Topologia de Rede:** Um nó **Control Plane (Master)** configurado no IP `192.168.56.10` e um nó **Worker** operando no IP `192.168.56.11` em uma rede privada isolada.
* **Orquestração:** Cluster Kubernetes funcional configurado através da distribuição leve K3s (Rancher).
* **Aplicação e Banco de Dados:** Implantação da plataforma de monitoramento corporativo **Zabbix 7.0 LTS** (Zabbix Server e Frontend Web baseado em Nginx) totalmente integrada e dependente de um banco de dados relacional **PostgreSQL 16**.

## Passo a Passo
Instruções para executar e validar o ambiente a partir de um clone deste repositório:

**Pré-requisitos:** Certifique-se de ter instalado o Vagrant e o Vitualbox em um SO `Ubuntu >= 24.04`.

  ```bash
  sudo apt-get install virtualbox -y && apt-get install vagrant -y
```
Versões usandas nesse desafio 
| Requisitos || versão |
|:-----|:-------|:--------|
| Oracle VirtualBox |=>| `7.2.6` |
| Vagrant | => |`2.4.9`  

**Inicializando** o provisionamento automatizado das duas máquinas virtuais junto com o deploy do Zabbix executando o comando:
   ```bash
   vagrant up
```

Apos o provisionamento das maquinas e do serviço do Zabbix, insira uma nova entrada na resolução de nomes local no arquivo `/etc/hosts`.

```bash
192.168.56.10 zabbix.local
```
Apos salvar o arquivo, o zabbix estará acessivel do navegador no endereço `http://zabbix.local`. Para acessar o Zabbix basta entrar com os acessos padrões, usuario `Admin` e senha `zabbix`.

## Decisões Técnicas
Inicialmento comecei o teste encima de uma VM no Proxmox, mas a medida que o desafio foi avançando me deparei com alguns empecilhos no acesso principalmente com relação a comunicação do kluster kubernetes (K3s) dentro da VM não fucionou da maneira esperada, sendo assim perdi muito tempo da para fazer a comunicação entre o Master e o Worker funcionarem. Após conseguir, fui para parte da aplicação que será usanda, então decidi fugir do obvio e optei utilizar o Zabbix em kubernetes como aplicação para esse teste.
Automatizei o deploy do Zabbix e ingress, agora sendo inicializado no script de inicialização do master apos a instalação do K3s, assim dispensando qualquer ação manual para excução do projeto.

## Troubleshooting

Durante o desenvolvimento e esteira de testes do ambiente, foram identificados e mitigados os seguintes erros de infraestrutura:

Problema 1: Falha crítica na inicialização da máquina virtual (VERR_SVM_NO_SVM)

    Sintoma: O comando vagrant up falhava no início do processo exibindo o erro do VirtualBox: VBoxManage: error: AMD-V is not available (VERR_SVM_NO_SVM).

    Causa: O ambiente de desenvolvimento host opera sob uma camada de virtualização aninhada (Nested Virtualization) ou as instruções de virtualização de hardware da CPU estavam desativadas/não repassadas pelo hypervisor primário.

    Resolução: Foi realizada a ativação explícita do suporte a recursos de virtualização aninhada nas configurações de processador da máquina mãe e, onde aplicável, a alteração do tipo de CPU para o modo host.

Problema 2: Interrupção de sintaxe e quebra de fluxo no Script de Provisionamento

    Sintoma: O script de automação falhava na etapa final do nó Control Plane com o erro: cp: missing destination file operand after '/var/lib/rancher/k3s/server/node-token'.

    Causa: Má formatação de argumentos ou ausência do parâmetro de destino adequado no comando cp interno do shell script script, impedindo o salvamento correto do token de segurança no diretório compartilhado /vagrant/.

    Resolução: Ajustada a sintaxe do script setup-master.sh para apontar explicitamente o destino de gravação: sudo cp /var/lib/rancher/k3s/server/node-token /vagrant/node-token.

Problema 3: Falha de autenticação do Worker e Erros de Handshake SSL (CA certs / Connection reset)

    Sintoma: O K3s Agent no nó Worker falhava ao tentar iniciar (k3s-agent.service failed). A análise de logs indicava erros contínuos como Failed to validate connection to cluster at https://192.168.56.10:6443: failed to get CA certs: read tcp 127.0.0.1:XXXX->127.0.0.1:6444: read: connection reset by peer.

    Causa: Duas causas correlacionadas agiam aqui:

        O nó Master falhava ou fechava a conexão porque o serviço principal do K3s Server sofria crash inicial ou não escutava na interface correta de rede de comunicação externa.

        O token de autenticação lido pelo Worker continha caracteres de controle ocultos ou quebras de linha (\r\n) inseridas pela manipulação de arquivos compartilhados entre sistemas operacionais diferentes, corrompendo a string de validação TLS.

    Resolução: Foram adicionadas as flags explícitas --bind-address=192.168.56.10 e --advertise-address no instalador do Master para forçar a escuta correta na rede privada. No script do Worker, implementou-se um tratamento rigoroso de higienização de strings através do utilitário tr (TOKEN=$(sudo cat /vagrant/node-token | tr -d '\r\n ')) para expurgar quaisquer resíduos invisíveis antes da tentativa de Handshake.
 ##
 ## Status
  Em densenvolvimento.