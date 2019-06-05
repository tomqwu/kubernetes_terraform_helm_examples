resource "kubernetes_deployment" "tiller_deploy" {
  metadata {
    name      = "tiller-deploy"
    namespace = "${var.tiller_namespace}"

    labels {
      name = "${var.helm_service_account_name}"
      app  = "helm"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels {
        name = "${var.helm_service_account_name}"
        app  = "helm"
      }
    }

    template {
      metadata {
        labels {
          name = "${var.helm_service_account_name}"
          app  = "helm"
        }
      }

      spec {
        container {
          image             = "${var.tiller_image}"
          name              = "tiller"
          image_pull_policy = "IfNotPresent"
          command           = ["/tiller"]
          args              = ["--listen=localhost:44134"]

          env {
            name  = "TILLER_NAMESPACE"
            value = "${var.tiller_namespace}"
          }

          env {
            name  = "TILLER_HISTORY_MAX"
            value = "0"
          }

          liveness_probe {
            http_get {
              path = "/liveness"
              port = "44135"
            }

            initial_delay_seconds = "1"
            timeout_seconds       = "1"
          }

          readiness_probe {
            http_get {
              path = "/readiness"
              port = "44135"
            }

            initial_delay_seconds = "1"
            timeout_seconds       = "1"
          }

          #port {
          #  name           = "tiller"
          #  container_port = "44134"
          #}


          #port {
          #  name           = "http"
          #  container_port = "44135"
          #}

          # work around not being able to set automountServiceAccountToken directly
          volume_mount {
            mount_path = "/var/run/secrets/kubernetes.io/serviceaccount"
            name       = "${kubernetes_service_account.tiller.default_secret_name}"
            read_only  = true
          }
        } # container

        volume {
          name = "${kubernetes_service_account.tiller.default_secret_name}"

          secret {
            secret_name = "${kubernetes_service_account.tiller.default_secret_name}"
          }
        }

        service_account_name = "${var.helm_service_account_name}"
      } # spec
    } # template
  } # spec
}

resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "${var.helm_service_account_name}"
    namespace = "${var.tiller_namespace}"
  }
}

resource "kubernetes_cluster_role_binding" "tiller" {
  metadata {
    name = "${var.helm_service_account_name}"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${var.helm_service_account_name}"
    namespace = "${var.tiller_namespace}"
    api_group = ""
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
}
