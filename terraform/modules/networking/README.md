# Networking Module

This module creates the minimal V1 networking baseline for Data Platform Demo.

It includes:

- VPC
- Public subnet
- Private subnet
- Internet Gateway
- Optional VPC endpoints

VPC endpoints are disabled by default because interface endpoints add cost. When `enable_vpc_endpoints` is true, the module can create endpoints for S3, CloudWatch Logs, Secrets Manager, STS, Glue, and KMS. S3 uses a gateway endpoint attached to the VPC default route table; the other services use interface endpoints in the private subnet with private DNS enabled.

It intentionally does not create NAT Gateways, multi-AZ topology, or advanced networking controls in V1.
