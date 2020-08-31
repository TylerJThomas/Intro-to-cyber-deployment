data "vsphere_role" "student_role" {
  label = "Virtual machine user (sample)"
}

resource "vsphere_folder" "folder" {
  path          = var.folder_name
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_entity_permissions" "perms" {
  entity_id = vsphere_folder.folder.id
  entity_type = "Folder"
  permissions {
    user_or_group = var.student_username
    propagate = true
    is_group = false
    role_id = data.vsphere_role.student_role.id
  }
}