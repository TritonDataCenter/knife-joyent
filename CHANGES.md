knife-joyent Changelog
===

## 0.3.2

- GH-55 ssl_verify_peer setting now only accepts ``false`` for disabling cert verification.
- GH-37 Fixes a formatting issue when there are servers without tags

## 0.3.1

- GH-55 Allow disabling SSL certificate verification + tags compatibility for SDC 6.5
- GH-53 Command line arguments now properly takes precidense over config defined in knife.rb

## 0.3.0

- GH-49 Network api support
- GH-37 Request signing using ssh-agent
- GH-30 Server list performance fix
