#!/usr/bin/env ruby

# OpsWorks provisioner for Vagrant
# --------------------------------
# Copyright (c) 2015 PixelCog Inc.
# Licensed under MIT (see LICENSE)

require 'date'
require 'json'
require 'tmpdir'
require 'fileutils'

module OpsWorks

  class OpsWorksError < StandardError; end

  DNA_BASE = {
    "ssh_users" => {
      "1000" => {
        "name" => "vagrant",
        "public_key" => nil,
        "sudoer" => true
      }
    },
    "dependencies" => {
      "gem_binary" => "gem",
      "gems" => {},
      "debs" => {}
    },
    "ec2" => {
      "instance_type" => "vm.vagrant"
    },
    "opsworks_initial_setup" => {
      "swapfile_instancetypes" => ["vm.vagrant"]
    },
    "ebs" => {
      "devices" => {},
      "raids" => {}
    },
    "opsworks" => {
      "activity" => "setup",
      "valid_client_activities" => ["setup"],
      "agent_version" => 0,
      "ruby_version" => "2.0.0",
      "ruby_stack" => "ruby",
      "rails_stack" => {
        "name" => nil
      },
      "stack" => {
        "name" => "Vagrant Stack",
        "elb-load-balancers" => [],
        "rds_instances" => []
      },
      "layers" => {},
      "instance" => {
        "ip" => "127.0.0.1",
        "private_ip" => "127.0.0.1",
        "layers" => []
      }
    },
    "deploy" => {},
    "opsworks_rubygems" => {
      "version" => "2.2.2"
    },
    "opsworks_bundler" => {
      "version" => "1.5.3",
      "manage_package" => nil
    },
    "opsworks_custom_cookbooks" => {
      "enabled" => false,
      "scm" => {
        "type" => "git",
        "repository" => nil,
        "user" => nil,
        "password" => nil,
        "revision" => nil,
        "ssh_key" => nil
      },
      "manage_berkshelf" => nil,
      "recipes" => []
    },
    "chef_environment" => "_default",
    "recipes" => [
      "opsworks_custom_cookbooks::load",
      "opsworks_custom_cookbooks::execute"
    ]
  }

  DNA_DEPLOY_BASE = {
    "deploy_to" => nil,
    "application" => nil,
    "deploying_user" => nil,
    "domains" => [],
    "application_type" => nil,
    "mounted_at" => nil,
    "rails_env" => nil,
    "ssl_support" => false,
    "ssl_certificate" => nil,
    "ssl_certificate_key" => nil,
    "ssl_certificate_ca" => nil,
    "document_root" => nil,
    "restart_command" => "echo 'restarting app'",
    "sleep_before_restart" => 0,
    "symlink_before_migrate" => {},
    "symlinks" => {},
    "database" => {},
    "migrate" => false,
    "auto_bundle_on_deploy" => true,
    "scm" => {
      "scm_type" => "git",
      "repository" => nil,
      "revision" => nil,
      "ssh_key" => nil,
      "user" => nil,
      "password" => nil
    }
  }

  def self.provision(*args)
    if agent_revision < Date.today.prev_month(4)
      warn "Warning: OpsWorks agent version #{agent_version} is over four months old, consider updating..."
    end

    log "Checking dependencies..."
    check_dependencies

    log "Reading input..."
    dna = compile_json expand_paths(args)

    log "Parsing deployments..."
    dna['deploy'].each do |name, app|

      # if repo points to a local path, trick opsworks into receiving it as a git repo
      if app['scm']['repository'] && app['scm']['repository'] !~ /^(?:[a-z]+:)?\/\//i
        if !Dir.exist?(app['scm']['repository'])
          raise OpsWorksError, "Local app '#{name}' could not be found at '#{app['scm']['repository']}'"
        end
        app['scm']['repository'] = prepare_deployment(app['scm']['repository'])
      end
    end

    log "Parsing custom cookbooks..."
    if dna['opsworks_custom_cookbooks']['enabled']
      cookbooks = dna['opsworks_custom_cookbooks']

      # if repo points to a local path, trick opsworks into receiving it as a git repo
      if cookbooks['scm']['repository'] && cookbooks['scm']['repository'] !~ /^(?:[a-z]+:)?\/\//i
        if !Dir.exist?(cookbooks['scm']['repository'])
          raise OpsWorksError, "Local custom cookbooks could not be found at '#{cookbooks['scm']['repository']}'"
        end
        cookbooks['scm']['repository'] = prepare_deployment(cookbooks['scm']['repository'])

        # autodetect berkshelf support
        if cookbooks['manage_berkshelf'].nil?
          berksfile = cookbooks['scm']['repository'].sub(/[\/\\]+$/,'') + '/Berksfile'
          cookbooks['manage_berkshelf'] = File.exist?(berksfile)
        end
      end

      # remove the local cache to force opsworks to update custom cookbooks
      log "Purging local cookbooks cache from '/opt/aws/opsworks/current/site-cookbooks'..."
      FileUtils.rm_rf('/opt/aws/opsworks/current/site-cookbooks/')
    end

    if dna['opsworks']['instance']['hostname']
      log "Setting instance hostname..."
      set_hostname dna['opsworks']['instance']['hostname']
    end

    # run some base recipes if none explicitly provided
    if dna['opsworks_custom_cookbooks']['recipes'].empty?
      dna['opsworks_custom_cookbooks']['recipes']= %w(
        recipe[opsworks_initial_setup]
        recipe[ssh_host_keys]
        recipe[ssh_users]
        recipe[dependencies]
        recipe[ebs]
        recipe[agent_version]
        recipe[opsworks_stack_state_sync]
        recipe[opsworks_cleanup]
      )
    end

    # ensure we don't set the agent version to anything lower than the current version
    dna['opsworks']['agent_version'] = [agent_version, dna['opsworks']['agent_version']].max

    log "Generating dna.json..."
    dna_file = save_json_tempfile dna, 'dna.json'

    log "Running opsworks agent..."

    # AWS currently does not set UTF-8 as default encoding
    system({"LANG" => "POSIX"}, "opsworks-agent-cli run_command -f #{dna_file}")

  rescue OpsWorksError => e
    warn "Error: #{e}"
    exit false
  end

  def self.save_json_tempfile(data, name)
    tmp_dir = Dir.mktmpdir('vagrant-opsworks')
    File.chmod(0755, tmp_dir)

    tmp_file = "#{tmp_dir}/#{name}"
    File.open(tmp_file, 'w') { |f| f.write JSON.pretty_generate(data) }
    File.chmod(0755, tmp_file)

    tmp_file
  end

  def self.log(msg)
    puts msg
  end

  def self.check_dependencies
	if `which yum`.empty?
	  `apt-get -yq install git 2>&1` if `which git`.empty?
	else
	  `yum -q -y install git 2>&1` if `which git`.empty?
	end
  end

  def self.set_hostname(hostname)
    if !File.readlines('/etc/hosts').grep(/(?=[^\.\w-]|$)#{hostname}(?=[^\.\w-]|$)/).any?
      File.open('/etc/hosts', 'a') do |f|
        f.puts "\n127.0.0.1\t#{hostname}.localdomain #{hostname}\n"
      end
    end
    File.write('/etc/hostname', hostname)
    system('hostname', hostname)
  end

  def self.expand_paths(args)
    files = []
    args.each do |file|
      if File.exist?(file)
        files << file
      elsif file.include? '*'
        files += Dir.glob(file)
      else
        raise OpsWorksError, "The file '#{file}' does not appear to exist."
      end
    end
    files
  end

  def self.compile_json(files)
    # combine all json files into one hash, starting with our base hash to
    # provide some sensible defaults
    dna = files.reduce(DNA_BASE) do |dna, file|
      log "Processing '#{file}'..."
      begin
        json = File.read(file).strip || '{}'
        json = JSON.parse(json)
      rescue JSON::ParserError => e
        raise OpsWorksError, "The file '#{file}' does not appear to be valid JSON. (error: #{e})"
      end
      deep_merge(dna, json)
    end

    # ensure each layer has some required fields including instances with both
    # private and public ip addresses
    dna['opsworks']['layers'].each do |name, layer|
      next unless Hash === layer
      layer['name'] ||= name
      layer['elb-load-balancers'] ||= []
      layer['instances'] ||= {}

      next unless Hash === layer['instances']
      layer['instances'].each do |name, instance|
        next unless Hash === instance
        instance['private_ip'] ||= instance['ip']
        instance['ip'] ||= instance['private_ip']
      end
    end

    # merge some default values into each app definition
    dna['deploy'].each do |name, app|
      app.replace deep_merge(DNA_DEPLOY_BASE, app)
      app['application'] ||= name
      app['domains'] << name if app['domains'].empty?
    end

    dna
  end

  def self.prepare_deployment(path)
    tmp_dir = Dir.mktmpdir('vagrant-opsworks')
    File.chmod(0755, tmp_dir)
    FileUtils.cp_r("#{path}/.", tmp_dir)
    Dir.chdir(tmp_dir) do
      `find . -name '.git*' -exec rm -rf {} \\; 2>&1; git init; git add .; git -c user.name='Vagrant' -c user.email=none commit -m 'Create temporary repository for deployment.'`
    end
    tmp_dir
  end

  def self.deep_merge(a, b)
    a.merge(b) { |_, a, b| Hash === a && Hash === b ? deep_merge(a, b) : b }
  end

  def self.agent_version
    File.read('/opt/aws/opsworks/current/REVISION')[/\d\d\d\d\-\d\d-\d\d-\d\d:\d\d:\d\d (\d+)/, 1].to_i
  end

  def self.agent_revision
    date_string = File.read('/opt/aws/opsworks/current/REVISION')[/(\d\d\d\d\-\d\d-\d\d-\d\d:\d\d:\d\d)/, 1]
    raise OpsWorksError, 'Unable to parse agent revision' unless date_string
    DateTime.strptime date_string, '%Y-%m-%d-%H:%M:%S'
  end
end

# automatically run provisioner
if __FILE__ == $0
  STDOUT.sync = true
  OpsWorks.provision *ARGV
end
