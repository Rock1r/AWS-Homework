output "key" {
    value     = module.key_pairs.private_key
    sensitive = true
}