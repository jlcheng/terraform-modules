# Summary

Creates an SSL certificate for a subdomain, using your existing Route 53 zone to validate ownership
of said subdomain. Not tested with apex domains.

Inputs: See variables.tf

Creates:

    - A single aws_acm_certificate for the sub_domain and sub_domain_alternative_names.

	
	
	
   
   
