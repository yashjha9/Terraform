

## Point to be Noted

- Terraform script will create all the resources.
- Manual thing to do is, by logging into the instance and accessing the application by doing curl.
- Login to the Instance of VPC1 and do curl to access/see application running inside the instance of VPC2.
```bash
    curl <private IP of Instance of VPC2>
```
- Need to do same by logging inside the Instance of VPC2 and doing curl
```bash
    curl <private IP of Instance of VPC1>
```


