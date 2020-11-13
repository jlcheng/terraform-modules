resource "aws_acm_certificate" "target_cert" {
  # README:
  # If this is to be used in cluoudfront, the certificate must be associated with us-east-1
  #  https://medium.com/@Markus.Hanslik/setting-up-an-ssl-certificate-using-aws-and-terraform-198c6fb90743
  #
  # Since this is to be used my us-west-2 load balancer, a custom provider (region) is not specified
  # https://aws.amazon.com/premiumsupport/knowledge-center/associate-acm-certificate-alb-nlb/

  domain_name               = var.sub_domain_name
  subject_alternative_names = var.sub_domain_alternative_names
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = local.tags
}

resource "aws_route53_record" "cert_validation_cname" {
  name    = aws_acm_certificate.target_cert.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.target_cert.domain_validation_options.0.resource_record_type
  zone_id = var.zone_id
  records = [aws_acm_certificate.target_cert.domain_validation_options.0.resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "target_cert" {
  certificate_arn         = aws_acm_certificate.target_cert.arn
  validation_record_fqdns = [aws_route53_record.cert_validation_cname.fqdn]
}
