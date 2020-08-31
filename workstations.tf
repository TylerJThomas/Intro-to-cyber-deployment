data "vsphere_virtual_machine" "windows10_template" {
  name          = var.workstation_template
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "workstations" {
  count  =  var.workstation_count
  name   = "workstation-${format("%02d", count.index+1)}"

  resource_pool_id = data.vsphere_compute_cluster.cluster1.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  folder   = vsphere_folder.folder.path

  scsi_type = data.vsphere_virtual_machine.windows10_template.scsi_type
  firmware = data.vsphere_virtual_machine.windows10_template.firmware

  num_cpus = var.workstation_cpus
  memory   = var.workstation_ram
  
  guest_id = "windows9_64Guest"

  depends_on = [
    vsphere_virtual_machine.pfsense, 
  ]

  # create a network interface and put it on the network
  network_interface {
    network_id = data.vsphere_network.network.id
  }

  # the clone keyword is used to duplicate a resource with an ID
  clone {
    template_uuid = data.vsphere_virtual_machine.windows10_template.id
  }
  
  disk {
    label = "disk0"
    size  = data.vsphere_virtual_machine.windows10_template.disks.0.size
    thin_provisioned = data.vsphere_virtual_machine.windows10_template.disks.0.thin_provisioned
  }
}