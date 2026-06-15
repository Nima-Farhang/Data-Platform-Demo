# Logging Module

This module creates the reusable platform CloudWatch logging baseline.

It owns platform-level log groups only:

- `/aws/<project>-<environment>/platform`
- `/aws/<project>-<environment>/deployments`
- `/aws/<project>-<environment>/products`

The products log group is a shared base exported for product repositories. This module does not create product-specific Lambda, Glue, API Gateway, or IoT alarms.

The module also creates generic platform error-count metric filters and alarms for platform/deployment logs plus a deployment failure placeholder metric alarm. Alarm actions are optional and can be wired later with `alarm_actions`.
