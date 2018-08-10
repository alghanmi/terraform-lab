# Terraform Lab

Terraform lab material to go with the [Introduction to Terraform](http://bit.ly/sgvlug-terraform-intro) presentation. The goal of this presentation is to introduce people to terraform, its concepts and make them comfortable in reading terraform docs and code.

## Lab Order

The lab follows the presentation and moves from one exercise to another. Below is the script for the lab. Note that lab may not make a lot of sense without the presentation ;).

### 1. Setup AWS Credentials

The lab assumes you have an [AWS Credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-config-files.html) file setup with a profile named `sgvlug`. For the purposes of this lab, you should setup your environment to use the `sgvlug` profile and `us-east-1` as the default region. You can use a [script](https://github.com/alghanmi/dotfiles/blob/master/bin/aws-profile-picker.sh) or execute the following commands:

```bash
export AWS_PROFILE sgvlug
export AWS_DEFAULT_REGION us-east-1
```

### 2. Create State Backend and Lock Table

```bash
# Create DynamoDB table
aws dynamodb create-table                                               \
    --table-name sgvlug-terraform-statelock                             \
    --attribute-definitions AttributeName=LockID,AttributeType=S        \
    --key-schema AttributeName=LockID,KeyType=HASH                      \
    --provisioned-throughput ReadCapacityUnits=2,WriteCapacityUnits=2

# Create S3 Bucket
aws s3api create-bucket               \
    --acl private                     \
    --bucket sgvlug-terraform-state   \
    --region us-east-1
```

You should consider setting up default bucket encryption policy and versioning.

### 3. Run Through the Labs

```bash
# Basic Setup (empty state)
cd 01-basic-setup
terraform init
terraform plan
tree -Ca .
cat .terraform/terraform.tfstate
cd ..
```

```bash
# Get some basic information about the account
cd 02-get-account-info
terraform init
terraform plan
terraform apply
cd ..
```

```bash
# Basic Networking setup
cd 03-networking-basic-1
terraform init
terraform plan
terraform apply
cd ..
```

```bash
# Introduce the use of variables and show there is no change in plan
cd 03-networking-basic-2
ln -s ../03-networking-basic-1/.terraform
terraform plan

# Change VPC name in AWS UI
terraform plan
terraform apply

# Destroy network setup to prepare for next lab component
terraform destroy
cd ..
```

```bash
# Use complex variables (and re-generate the networks)
cd 04-networking
terraform init
terraform apply
cd ..
```

```bash
# Use outputs to write a shared state for the networking component
cd 05-networking-output
ln -s ../04-networking/.terraform
terraform apply

# Check the output
terraform output
cd ..
```

```bash
# Deploy EC2 instances on the network that was created
cd 06-instances
terraform init
terraform apply
cd ..
```

### 4. Clean Up

Since AWS costs money, let us destroy what we created

#### Destroy All Resources

```bash
cd 05-networking-output
terraform destroy

cd ../06-instances
terraform destroy
```

#### Delete Lock Table and S3 State backend

```bash
aws dynamodb delete-table --table-name sgvlug-terraform-statelock
aws s3api delete-bucket --bucket sgvlug-terraform-state --region us-east-1
```
