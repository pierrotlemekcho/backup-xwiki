variable "xwiki_backup_path" {
  type = string
  description = "Le dossier contenant les sauvegardes a remonter"
}

variable "do_token" {}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = "${var.do_token}"
}

# Create a new SSH key
resource "digitalocean_ssh_key" "xwiki" {
  name       = "Terraform Example"
  public_key = "${trimspace(file("xwiki_ssh_key.pub"))}"
}

# Create a new Droplet using the SSH key
resource "digitalocean_droplet" "xwiki" {
  image    = "ubuntu-18-04-x64"
  name     = "xwiki"
  region   = "fra1"
  size     = "s-2vcpu-4gb"
  ssh_keys = ["${digitalocean_ssh_key.xwiki.fingerprint}"]

  # Quand la machine est cree on "attend" 2 minutes (120 secondes) qu'elle demare et on fait tourner le playbook ansible qui installe le wiki
  # C'est le fichier xwiki-plyabook.xml qui contient les taches ansibles pour installer xwiki, remonter les base de donees
  # Et copier les fichiers de config et de data
  provisioner "local-exec" {
    command = "sleep 120; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u root --private-key ./xwiki_ssh_key -i '${digitalocean_droplet.xwiki.ipv4_address},' --extra-vars='xwiki_backup_path=${var.xwiki_backup_path}' xwiki-playbook.yml"
  }
}

# On affiche l'url du wiki pour pouvoir aller verifier que l'installation s'est bien deroulee
output "xwiki_url" {
  value = "http://${digitalocean_droplet.xwiki.ipv4_address}:8080/xwiki"
}
