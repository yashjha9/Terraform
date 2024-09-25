# Point to be Noted

- Terraform Script will create all the resources.
- Manually need to login to the Provider Private instance and install apache2 inside it and delete NAT Gateway.
- Manually Login to the Consumer Private Instance and do curl,
```
curl <dns of VPC EndPoint>
```
- With this, application running inside the Provider Private instance can be accessed securely from Consumer Private Instance.
