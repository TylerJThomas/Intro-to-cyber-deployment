terraform {
  required_providers {
    vsphere = {
      version = ">= 1.21.1"
    }
  }
}

provider "vsphere" {
  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "CyberRange"
}

data "vsphere_datastore" "datastore" {
  name          = "vmDiskStore1"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "cluster1" {
  name          = "Cluster1"
  datacenter_id = data.vsphere_datacenter.dc.id
}