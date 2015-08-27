#!/usr/bin/env ruby
require 'json'
require 'fileutils'

dea_apps_json = '/var/vcap/data/dea_next/db/instances.json'
root_apps = '/root/apps'
depot_dir = '/var/vcap/data/warden/depot'

unless File.exist?(dea_apps_json)
  exit
end

puts "Updating #{root_apps}"
applications = JSON.load(File.read(dea_apps_json))

# Mkdir root_apps
FileUtils.mkdir_p root_apps
# Clean up root_apps
Dir.glob("#{root_apps}/*").each do |app|
  if File.symlink?(app) && File.readlink(app).start_with?(depot_dir)
    FileUtils.remove_file app
  end
end

applications['instances'].each do |instance|
  if instance['warden_container_path']
    app_symlink = File.join root_apps, "#{instance['application_name']}-#{instance['instance_index']}-#{instance['warden_handle']}"
    FileUtils.symlink instance['warden_container_path'], app_symlink
  end
end
