# Point to be Noted:

- Terraform script will create all the resources.
- Manually need to log in to the instances of each VPC and need to do curl, to access application running inside the instances of other VPC's.
```bash
  from Instance of VPC1,

  curl <Private IP of Instance 2> --> to access application running inside the Instance of VPC2
  curl <Private IP of Instance 3> --> to access application running inside the Instance of VPC3
```                                                                                                                                                                                         

```bash
 from Instance of VPC2,

 curl <Private IP of Instance 1> --> to access application running inside the Instance of VPC1
 curl <Private IP of Instance 3> --> to access application running inside the Instance of VPC3
```

```bash
  from Instance of VPC3,

  curl <Private IP of Instance 2> --> to access application running inside the Instance of VPC2
  curl <Private IP of Instance 1> --> to access application running inside the Instance of VPC1
```
