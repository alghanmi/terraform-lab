# Terraform Lab

Terraform lab material to go with the [Introduction to Terraform](http://bit.ly/sgvlug-terraform-intro) presentation. The goal of this presentation is to introduce people to terraform, its concepts and make them comfortable in reading terraform docs and code.

## Lab Order

The lab follows the presentation and moves from one exercise to another. Below is the script for the lab. Note that lab may not make a lot of sense without the presentation ;).

### 1. Setup AWS Credentials

The lab assumes you have an [AWS Credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-config-files.html) file setup with a user _profile_. For the purposes of this lab, you should setup your environment to use this profile you created and `us-west-2` as the default region. Execute the following commands:

```bash
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity | jq --raw-output '.Account')
export AWS_USER=$(aws sts get-caller-identity | jq --raw-output '.Arn' | awk -F'/' '{ print $2 }')
export AWS_DEFAULT_REGION us-west-2
```

### 2. Create State Backend and Lock Table
In this lab, we will be using DynamoDB for locking and S3 to keep our state. S3 bucket names need to be globally unique, keep that in mind when creating your bucket below. Therefore, we will be appending the AWS account ID to the bucket.

```sh
# Create DynamoDB table
aws dynamodb create-table                                               \
    --table-name tflab-terraform-statelock                              \
    --attribute-definitions AttributeName=LockID,AttributeType=S        \
    --key-schema AttributeName=LockID,KeyType=HASH                      \
    --provisioned-throughput ReadCapacityUnits=2,WriteCapacityUnits=2

# Create S3 Bucket
aws s3api create-bucket                                                    \
    --acl private                                                          \
    --region $AWS_DEFAULT_REGION                                           \
    --create-bucket-configuration LocationConstraint="$AWS_DEFAULT_REGION" \
    --bucket tflab-terraform-statelock-${AWS_ACCOUNT_ID}

# Enable bucket versioning
aws s3api put-bucket-versioning                          \
    --bucket tflab-terraform-statelock-${AWS_ACCOUNT_ID} \
    --versioning-configuration Status=Enabled

# Enable bucket encryption
aws s3api put-bucket-encryption                          \
    --bucket tflab-terraform-statelock-${AWS_ACCOUNT_ID} \
    --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'
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
aws dynamodb delete-table --table-name tflab-terraform-statelock
aws s3api delete-bucket --bucket tflab-terraform-statelock-${AWS_ACCOUNT_ID} --region $AWS_DEFAULT_REGION
```
