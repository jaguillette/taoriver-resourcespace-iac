# What am I doing that isn't in IAC?

- Need to import the existing ebs volume at a minimum with this command, after running `terraform init`:
    ```
    terraform import TERRAFORM_IDENTIFIER AWS_ID
    ```