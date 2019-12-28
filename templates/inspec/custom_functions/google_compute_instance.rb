def disk_count
  @disks&.count
end

def tag_count
  @tags&.items&.count
end

def network_interfaces_count
  @network_interfaces&.count
end

# TBD: Below few methods are present to make the tests simpler e.g. avoid looping over arrays etc.
#     but passing index arguments from the inspec test would be better

def first_network_interface_nat_ip_exists
  !@network_interfaces[0]&.access_configs[0]&.nat_ip.nil?
end

def first_network_interface_name
  @network_interfaces[0].access_configs[0].name
end

def first_network_interface_type
  @network_interfaces[0].access_configs[0].type.downcase
end

def first_disks_source_name
  disks_source_name(0)
end

def first_disks_first_license
  disks_license(0, 0)
end

def second_disks_device_name
  return '' if @disks[1].nil? || !defined?(@disks[1].device_name) || @disks[1].device_name.nil?
  disks[1].device_name
end

def second_disks_source_name
  disks_source_name(1)
end

def second_disks_first_license
  disks_license(1, 0)
end

# helper method for retrieving a disk source basename
def disks_source_name(index = 0)
  return '' if @disks[index].nil? || !defined?(@disks[index].source) || @disks[index].source.nil?
  @disks[index].source.split('/').last
end

# helper method for retrieving a disk license string
def disks_license(disk_index = 0, license_index = 0)
  return '' if @disks[disk_index].nil? || !defined?(@disks[disk_index].licenses[license_index]) || @disks[disk_index].licenses[license_index].nil?
  @disks[disk_index].licenses[license_index].downcase
end

def machine_size
  return '' if !defined?(@machine_type) || @machine_type.nil?
  @machine_type.split('/').last
end

# helper for returning label keys to perform checks
def labels_keys
  return [] if !defined?(@labels) || @labels.nil?
  @labels.items.keys
end

# helper for returning label values to perform checks
def labels_values
  return [] if !defined?(@labels) || @labels.nil?
  @labels.items.values
end

def label_value_by_key(label_key)
  return [] if !defined?(@labels) || @labels.nil?
  @labels.items[label_key]
end

def metadata_keys
  return [] if !defined?(@metadata) || @metadata.nil?
  @metadata.item[:items].map { |m| m[:key] }
end

def metadata_values
  return [] if !defined?(@metadata) || @metadata.nil?
  @metadata.item[:items].map { |m| m[:value] }
end

def metadata_value_by_key(metadata_key)
  return [] if !defined?(@metadata) || @metadata.nil?
  @metadata.item[:items].each do |item|
    if item[:key] == metadata_key
      return item[:value]
    end
  end
  []
end

def service_account_scopes
  # note instances can have only one service account defined
  return [] if @service_accounts[0].nil? || !defined?(@service_accounts[0].scopes) || @service_accounts[0].scopes.nil?
  @service_accounts[0].scopes
end

def block_project_ssh_keys
  return false if !defined?(@metadata.items) || @metadata.items.nil?
  @metadata.items.each do |element|
    return true if element.key=='block-project-ssh-keys' and element.value.casecmp('true').zero?
    return true if element.key=='block-project-ssh-keys' and element.value=='1'
  end
  false
end

def has_serial_port_disabled?
  return false if !defined?(@metadata.items) || @metadata.items.nil?
  @metadata.items.each do |element|
    return true if element.key=='serial-port-enable' and element.value.casecmp('false').zero?
    return true if element.key=='serial-port-enable' and element.value=='0'
  end
  false
end

def has_disks_encrypted_with_csek?
  return false if !defined?(@disks) || @disks.nil?
  @disks.each do |disk|
    return false if !defined?(disk.disk_encryption_key)
    return false if disk.disk_encryption_key.nil?
    return false if !defined?(disk.disk_encryption_key.sha256)
    return false if disk.disk_encryption_key.sha256.nil?
  end
  true
end