locals {
  ecs_widgets = [
    {
      type = "metric"
      properties = {
        title   = "ECS CPU (%)"
        region  = var.region
        view    = "timeSeries"
        stat    = "Average"
        period  = 60
        metrics = [["AWS/ECS", "CPUUtilization", "ClusterName", var.cluster_name, "ServiceName", var.service_name]]
      }
    },
    {
      type = "metric"
      properties = {
        title   = "ECS Memory (%)"
        region  = var.region
        view    = "timeSeries"
        stat    = "Average"
        period  = 60
        metrics = [["AWS/ECS", "MemoryUtilization", "ClusterName", var.cluster_name, "ServiceName", var.service_name]]
      }
    }
  ]

  alb_widgets_all = [
    {
      type = "metric"
      properties = {
        title   = "ALB requests"
        region  = var.region
        view    = "timeSeries"
        stat    = "Sum"
        period  = 60
        metrics = [["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix]]
      }
    },
    {
      type = "metric"
      properties = {
        title   = "ALB response time (seconds)"
        region  = var.region
        view    = "timeSeries"
        stat    = "Average"
        period  = 60
        metrics = [["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.alb_arn_suffix]]
      }
    },
    {
      type = "metric"
      properties = {
        title   = "5XX errors from the app"
        region  = var.region
        view    = "timeSeries"
        stat    = "Sum"
        period  = 60
        metrics = [["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", var.alb_arn_suffix]]
      }
    },
    {
      type = "metric"
      properties = {
        title  = "Healthy and unhealthy targets"
        region = var.region
        view   = "timeSeries"
        stat   = "Average"
        period = 60
        metrics = [
          ["AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", var.target_group_arn_suffix, "LoadBalancer", var.alb_arn_suffix],
          ["AWS/ApplicationELB", "UnHealthyHostCount", "TargetGroup", var.target_group_arn_suffix, "LoadBalancer", var.alb_arn_suffix]
        ]
      }
    }
  ]

  rds_widgets_all = [
    {
      type = "metric"
      properties = {
        title   = "RDS CPU (%)"
        region  = var.region
        view    = "timeSeries"
        stat    = "Average"
        period  = 60
        metrics = [["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.db_identifier]]
      }
    },
    {
      type = "metric"
      properties = {
        title   = "RDS connections"
        region  = var.region
        view    = "timeSeries"
        stat    = "Average"
        period  = 60
        metrics = [["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", var.db_identifier]]
      }
    }
  ]

  log_widgets = [
    {
      type = "log"
      properties = {
        title  = "Latest container logs"
        region = var.region
        view   = "table"
        query  = "SOURCE '${var.log_group_name}' | fields @timestamp, @message | sort @timestamp desc | limit 50"
      }
    }
  ]

  # keep ALB and RDS widgets only when their values are given
  alb_widgets = [for w in local.alb_widgets_all : w if var.alb_arn_suffix != ""]
  rds_widgets = [for w in local.rds_widgets_all : w if var.db_identifier != ""]

  widgets = concat(local.ecs_widgets, local.alb_widgets, local.rds_widgets, local.log_widgets)

  # place the widgets in 2 columns automatically
  placed = [
    for i, w in local.widgets : merge(w, {
      x      = (i % 2) * 12
      y      = floor(i / 2) * 6
      width  = 12
      height = 6
    })
  ]
}

resource "aws_cloudwatch_dashboard" "this" {
  dashboard_name = var.dashboard_name
  dashboard_body = jsonencode({ widgets = local.placed })
}