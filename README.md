
# Terraform

Terraform is an Infrastructure as Code tool.
The better way to provision cloud infrastructure, is to codify the entire provisioning process, means writing and executing the code for provisioning the infrastructure resources.

With IAC, user can manage Infrastructure component.

Terraform is a popular IaC tool, which is specifically useful as an Infrastructure Provisioning Tool.
Terraform is a free and open source tool which is developed by Hashicorp.


IaC can be broadly classified into 3 types:

- Configuration Management tools:- These tools are commonly used to install and manage software on existing Infrastructure resources such as servers, db, etc.
This tools maintains standard structure of code,
These are designed to run on multiple remote resources at once.

Ansible comes under Configuration Management Tool.

- Server Templating tools:- These are tools like docker, vagrant, packer which can be used to create a custom image of VM or a container.
These images already contains all the required software and dependencies on them.
Due to this, it can eliminate need of installing software after a VM, or a container is deployed.
Most common examples for server templated images are VM images such as those that are offered on OSboxes.org, custom images in Amazon AWS, and docker images on docker.
These tools promotes immutable infrastructure, which means once VM or container is deployed, it is designed to remain unchanged.
If changes to be made to the image, instead of updating running instances like in case of ansible, update the image and redeploy a new instance using updated image.

- Provisioning tools:-  These tools are used to provision infrastructure components using a simple declarative code.Terraform is vendor agnostic and supports provider plugins for almost all cloud providers.



Biggest advantage of Terraform is its ability to deploy infrastructure across multiple platforms including private and public cloud.

Terraform manages infrastructure on so many different kinds of platforms with help of Providers.
A providers helps Terraform to manage third party platforms through their API.
Providers enables Terraform to manage cloud platform such as AWS, GCP, Azure.

Terraform supports 1000’s of providers and can work with almost every Infrastructure platform.

Terraform uses HCL, Hashicorp Configuration Language, which is simple declarative language to define infrastructure resources to be provisioned as blocks of code.

Terraform always makes sure that Desired State should match the Current State.


Terraform works in 3 phases, Init, Plan and Apply.

- During Init phase, Terraform initialize the project,  and identifies providers to be used for target env.

- During Plan phase, Terraform drafts a plan to get to the target state.

- During Apply phase, Terraform makes a necessary changes required on target environment.




## Steps to Install Terraform

Using Ubuntu platform to install Terraform.

Run the below command to install unzip,

```bash
  sudo apt update && sudo apt install unzip -y
```

Download the binary file of Terraform

```bash
  wget https://releases.hashicorp.com/terraform/1.9.7/terraform_1.9.7_linux_amd64.zip
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



