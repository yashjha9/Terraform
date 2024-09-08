
# Terraform

Terraform is a most popular Infrastructure as a Code (IaC) tool. Terraform is used to Provision and setup infrastructure on a Cloud Platform.

To setup servers/VM’s, and deploy applications inside those VM’s, terraform will help to create those infrastructures using terraform file, terraform file has .tf extension.

It reduces manual Tasks.








## Steps to Install Terraform

Using Ubuntu platform to install Terraform.

Run the below command to install unzip,

```bash
  sudo apt update && sudo apt install unzip -y
```

Download the binary file of Terraform

```bash
  wget https://releases.hashicorp.com/terraform/1.9.4/terraform_1.9.4_linux_amd64.zip
```

Unzip the binary

```bash
  unzip terraform_1.9.4_linux_amd64.zip
```

Move Terraform file to bin folder

```bash
 sudo mv terraform /usr/local/bin/
```
To check Terraform version, use below command -

```bash
 terraform -v
```
