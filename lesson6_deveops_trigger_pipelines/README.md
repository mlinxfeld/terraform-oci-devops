# FoggyKitchen OCI DevOps Service with Terraform 

## LESSON 6 - Adding OCI DevOps Trigger - Automating Build and Deploy Pipelines

In the sixth lesson of the OCI DevOps Service course deployed with Terraform, you will further enhance your DevOps project by adding the OCI DevOps Trigger resource. This step focuses on automating the triggering of the Build and Deploy Pipelines based on push operations to the OCI DevOps Repository's main branch.

By implementing the provided Terraform code, you will configure the Trigger resource to monitor the OCI DevOps Repository. Each commit made to the main branch of the GitHub repository, which is replicated and mirrored in the DevOps Repository, will automatically trigger the Build Pipeline. As a result, the Deploy Pipeline will be initiated in cascade.

This automation eliminates the need for an SRE engineer or any manual intervention to trigger the pipelines. Instead, the pipelines become fully dependent on the changes delivered by developers via Pull Requests merged into the main branch. This streamlines the entire DevOps process and enables seamless integration between development and deployment.

With the addition of the OCI DevOps Trigger, your DevOps project becomes fully automated, relying on the continuous delivery of changes to the repositories. Each push operation will trigger the Build Pipeline, which, upon successful completion, will automatically cascade into the Deploy Pipeline. This ensures that your application deployments stay up to date with the latest changes made by the development team.

![](terraform-oci-devops-lesson6.png)

## Deploy Using Oracle Resource Manager

1. Click [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?region=home&zipUrl=https://github.com/mlinxfeld/terraform-oci-devops/releases/latest/download/terraform-oci-devops-lesson6.zip)

    If you aren't already signed in, when prompted, enter the tenancy and user credentials.

2. Review and accept the terms and conditions.

3. Select the region where you want to deploy the stack.

4. Follow the on-screen prompts and instructions to create the stack.

5. After creating the stack, click **Terraform Actions**, and select **Plan**.

6. Wait for the job to be completed, and review the plan.

    To make any changes, return to the Stack Details page, click **Edit Stack**, and make the required changes. Then, run the **Plan** action again.

7. If no further changes are necessary, return to the Stack Details page, click **Terraform Actions**, and select **Apply**. 

## Deploy Using the Terraform CLI

### Clone of the repo
Now, you'll want a local copy of this repo. You can make that with the commands:

Clone the repo from github by executing the command as follows and then go to proper subdirectory:

```
Martin-MacBook-Pro:~ martinlinxfeld$ git clone https://github.com/mlinxfeld/terraform-oci-devops.git

Martin-MacBook-Pro:~ martinlinxfeld$ cd terraform-oci-devops/

Martin-MacBook-Pro:terraform-oci-devops martinlinxfeld$ cd lesson6_deveops_trigger_pipelines

```

### Prerequisites
Create environment file with TF_VARs:

```
Martin-MacBook-Pro:lesson6_deveops_trigger_pipelines martinlinxfeld$ vi setup_oci_tf_vars.sh

export TF_VAR_tenancy_ocid="ocid1.tenancy.oc1..aaaaaaaasbkty(...)heqzzxn7pe64ksbia"
export TF_VAR_compartment_ocid="ocid1.compartment.oc1..aaaaaaaaiyy4srmrb32(...)ytywiucgbcp5ext6e4ahjewa"
export TF_VAR_user_ocid="ocid1.user.oc1..aaaaaaaaob4qbf27(...)uunizjie4his4vgh3jx5jxa"
export TF_VAR_fingerprint="85:ee:(...)37:b8:0d:0f:ea"
export TF_VAR_private_key_path="/home/opc/.oci/oci_api_key.pem"
export TF_VAR_region="eu-frankfurt-1"
export TF_VAR_github_pat_vault_secret_id="ocid1.vaultsecret.oc1.eu-frankfurt-1.amaaaaaadngk4gia426(...)ygv5x6ooa"
export TF_VAR_ocir_vault_secret_id="ocid1.vaultsecret.oc1.eu-frankfurt-1.amaaaaaadngk4giavvri7prkglx7gy5ip73q4(...)anih3lqfxhoa"

Martin-MacBook-Pro:lesson6_deveops_trigger_pipelines martinlinxfeld$ source setup_oci_tf_vars.sh
```

### Create the Resources
Run the following commands:

```
Martin-MacBook-Pro:lesson6_deveops_trigger_pipelines martinlinxfeld$ terraform init
    
Martin-MacBook-Pro:lesson6_deveops_trigger_pipelines martinlinxfeld$ terraform plan

Martin-MacBook-Pro:lesson6_deveops_trigger_pipelines martinlinxfeld$ terraform apply
```

### Destroy the Deployment
When you no longer need the deployment, you can run this command to destroy the resources:

```
Martin-MacBook-Pro:lesson6_deveops_trigger_pipelines martinlinxfeld$ terraform destroy
```

