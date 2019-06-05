env:
    open: 
        STORAGE: amazon
        STORAGE_AMAZON_BUCKET: ${chartmuseum_s3_bucket_name}
        STORAGE_AMAZON_REGION: ${chartmuseum_s3_region}
        DEBUG: ${chartmuseum_enable_debug}
        DISABLE_API: false
        DISABLE_METRICS: false
        ALLOW_OVERWRITE: ${chartmuseum_allow_overwrite}

replica:
    annotations:
        iam.amazonaws.com/role: ${chartmuseum_s3_svc_role}

ingress:
    enabled: true
    annotations:
        kubernetes.io/ingress.class: alb
        alb.ingress.kubernetes.io/scheme: internal
        alb.ingress.kubernetes.io/tags: Environment=${env_name},App=chartmuseum
        alb.ingress.kubernetes.io/healthcheck-path: /
        alb.ingress.kubernetes.io/certificate-arn: ${aws_acm_certificate_arn}
        alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS": 443}, {"HTTP": 80}]'
        alb.ingress.kubernetes.io/inbound-cidrs: ${aws_alb_ingress_cidr}
        alb.ingress.kubernetes.io/actions.ssl-redirect: '{"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'
    hosts:
        - name: ${chartmuseum_host_name}
          path: /*
    extraPaths:
        - path: /*
          service: ssl-redirect
          port: use-annotation
            
service:
    type: NodePort
