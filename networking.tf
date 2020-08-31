data "vsphere_network" "cfreg" {
  name          = "CFREG Guest Network"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_host_port_group" "portgroup" {
  name                 = "intro-to-cyber"
  host_system_id       = "host-9"
  virtual_switch_name  = vsphere_host_virtual_switch.switch.name
  
  vlan_id = 1
}

data "vsphere_network" "network" {
  name          = vsphere_host_port_group.portgroup.name
  datacenter_id = data.vsphere_datacenter.dc.id

  depends_on = [
    vsphere_host_port_group.portgroup
  ]
}

resource "vsphere_host_virtual_switch" "switch" {
  name           = "IntrovSwitch"
  host_system_id = "host-9"

  network_adapters = ["vmnic1", "vmnic4"]

  active_nics    = ["vmnic1"]
  standby_nics   = ["vmnic4"]
  teaming_policy = "failover_explicit"

  allow_promiscuous      = true
  allow_forged_transmits = false
  allow_mac_changes      = true
}


data "vsphere_virtual_machine" "pfsense_template" {
  name          = "Template-pfSense-key"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "pfsense" {
  name             = "pfsense"
  resource_pool_id = data.vsphere_compute_cluster.cluster1.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = vsphere_folder.folder.path

  num_cpus = 2
  memory   = 4096
  guest_id = "freebsd11_64Guest"

  scsi_type = data.vsphere_virtual_machine.pfsense_template.scsi_type

  
  # THIS IS A HACK 
  # VMware tools API does not properly interface with PAN OS 
  # so it hangs and does not know when it acquires an IP
  # Therefore, YOU CANNOT TRUST THAT PAN OS BOXES ARE PROPERLY
  # CONFIGURED JUST BECAUSE THE PLAN EXECUTES WITHOUT ERRORS.
  # If you change a PAN OS network configuration, manually check that
  # nothing breaks before you commit.
  
  wait_for_guest_net_routable = false

  # create a network interface and put it on the network
  network_interface {
    network_id = data.vsphere_network.cfreg.id
    adapter_type = data.vsphere_virtual_machine.pfsense_template.network_interface_types[0]
  }

  network_interface {
    network_id = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.pfsense_template.network_interface_types[1]
  }

  # the clone keyword is used to duplicate a resource with an ID
  clone {
    template_uuid = data.vsphere_virtual_machine.pfsense_template.id
  }
    
  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.pfsense_template.disks.0.size
    thin_provisioned = data.vsphere_virtual_machine.pfsense_template.disks.0.thin_provisioned
  }
}