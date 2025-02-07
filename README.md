# AWS Bedrock Chat Application

A chat application built with AWS Bedrock and Chainlit, providing an interactive conversational interface powered by AWS's language models with department-specific knowledge bases.

## 🌟 Features

- Interactive chat interface using Chainlit
- Integration with AWS Bedrock for natural language processing
- Department-specific knowledge bases (HR and Finance)
- Vector search capabilities using OpenSearch Serverless
- Infrastructure as Code using Terraform

## 🛠️ Technologies

- Python 3.11+
- AWS Bedrock
- AWS OpenSearch Serverless
- Terraform
- Chainlit
- Poetry (dependency management)
- Python-dotenv
- AWS S3
- AWS IAM

## 📋 Prerequisites

- Python 3.11 or higher
- AWS account with Bedrock access
- AWS credentials configured
- Poetry installed
- Terraform installed

## 🚀 Getting Started

1. Clone the repository:

```bash
git clone https://github.com/yourusername/aws-bedrock-chat.git
cd aws-bedrock-chat
```

2. Install dependencies using Poetry:

```bash
poetry install
```

3. Deploy infrastructure using Terraform:

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

4. Create a `.env` file in the `src/aws_bedrock_chat` directory with the following variables:
```env
FLOW_ID=<your-bedrock-flow-id>
FLOW_ALIAS_ID=<your-bedrock-flow-alias-id>
```

5. Run the application:
```bash
poetry run chainlit run src/aws_bedrock_chat/app.py
```

## 🏗️ Project Structure

```
aws-bedrock-chat/
├── src/
│   └── aws_bedrock_chat/
│       ├── app.py                 # Main application entry point
│       ├── .env                         # Environment variables (not in repo)
├── terraform/
│   ├── modules/
│   │   ├── bedrock-agent/        # Bedrock agent configuration
│   │   ├── iam/                  # IAM roles and policies
│   │   ├── knowledge-base/       # Knowledge base setup
│   │   ├── opensearch/          # OpenSearch configuration
│   │   └── s3/                  # S3 bucket setup
│   ├── main.tf                  # Main Terraform configuration
│   ├── variables.tf             # Terraform variables
│   └── providers.tf             # Provider configuration
├── .gitignore
├── README.md
├── chainlit.md                  # Chainlit welcome screen
└── pyproject.toml              # Poetry configuration
```

## 💻 Usage

Once the application is running, you can:
1. Open your browser and navigate to the local Chainlit interface
2. Start chatting with the AI assistant
3. Query department-specific knowledge bases (HR or Finance)
4. The application will process your messages through AWS Bedrock and return responses

## ⚙️ Configuration

The application uses the following environment variables:
- `AWS_REGION`: Your AWS region
- `FLOW_ID`: Your AWS Bedrock Flow ID
- `FLOW_ALIAS_ID`: Your AWS Bedrock Flow Alias ID

Infrastructure configuration is managed through Terraform variables in the `terraform/variables.tf` file.
