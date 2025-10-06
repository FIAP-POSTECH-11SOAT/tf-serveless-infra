# Projeto Terraform: API Gateway, Cognito, Lambdas e VPC Link para EKS

Este projeto utiliza Terraform para provisionar uma infraestrutura AWS composta por API Gateway, Cognito, funções Lambda e VPC Link para integração com EKS.

## Estrutura

- **API Gateway**: Gerencia endpoints REST para integração com Lambdas e EKS.
- **Cognito**: Autenticação e autorização de usuários.
- **Lambdas**: Funções serverless para processamento backend.
- **VPC Link**: Permite que o API Gateway acesse recursos privados no EKS.

## Lambdas Implementadas

-`login` → autentica usuários existentes via Cognito e retorna tokens JWT.
- `register` → cadastra novos usuários no Cognito e armazena dados complementares no banco.
- `register-anonymous` → cria perfis temporários anônimos, permitindo navegação ou pedidos sem login formal.
- `ping` → teste de funcionamento das rotas protegidas.

## Pré-requisitos

- [Terraform](https://www.terraform.io/downloads.html) instalado
- AWS CLI configurado
- Permissões adequadas na AWS

## Comandos Terraform

```bash
# Inicializa o diretório do Terraform
terraform init

# Visualiza o plano de execução
terraform plan

# Aplica as alterações na infraestrutura
terraform apply

# Destroi os recursos provisionados
terraform destroy
```

### 📄 Variáveis Necessárias (terraform.tfvars)

As seguintes variáveis devem ser configuradas manualmente:

```hcl
vpc_link_target_nlb_arn     = "arn:aws:elasticloadbalancing:REGION:ACCOUNT_ID:loadbalancer/net/NOME_DO_NLB/ID"
vpc_link_backend_base_url   = "https://DNS-NAME-DO-NLB"
```

> 💡 Essas informações podem ser encontradas no **console da AWS**:
> **EC2 → Load Balancers → [seu NLB] → Detalhes**
>
> * `vpc_link_target_nlb_arn`: ARN do Load Balancer
> * `vpc_link_backend_base_url`: URL base (DNS name do NLB precedido por `https://`)