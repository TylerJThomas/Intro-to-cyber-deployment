variable "workstation_count" {
    type = number
    default = 7
}

variable "workstation_template" {
    type = string
    default = "Template-win10-intro"
}

variable "folder_name" {
    type = string
    default = "Intro-to-cyber"
}

variable "student_username" {
    type = string
    default = "vsphere.local\\Intro_user"
    // password = Ab3z_H3cking_Angels
}

variable "workstation_cpus" {
    type = number
    default = 2
}

variable "workstation_ram" {
    type = number
    default = 8192
}