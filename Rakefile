
# first is default
BOXES = %w( ubuntu1404 ubuntu1204 centos7mini ).freeze

# namespace for each provider
provider_builder = lambda do |provider|
  namespace provider do
    desc "Build a box for #{provider} using packer (default: #{BOXES.first})"
    task :build, [:box] do | t, args| build_box box_arg(args), provider; end

    desc "Install a #{provider} box with vagrant (default: #{BOXES.first})"
    task :install, [:box] do | t, args| install_box box_arg(args), provider; end

    desc "Remove an installed vagrant box for #{provider} (default: #{BOXES.first})"
    task :remove, [:box] do | t, args| remove_box box_arg(args), provider; end

    desc "Build all boxes for #{provider} using packer"
    task 'build-all' do BOXES.each { |box| build_box box, provider }; end

    desc "Install all #{provider} boxes with vagrant"
    task 'install-all' do BOXES.each { |box| install_box box, provider }; end

    desc "Remove all #{provider} boxes from vagrant"
    task 'remove-all' do BOXES.each { |box| remove_box box, provider }; end
  end
end

provider_builder.call(:virtualbox)
provider_builder.call(:vmware)

desc "Remove compiled assets and cached files"
task :clean do
  if ENV['OS'] == 'Windows_NT'
    sh "rm 'build/*.box' -Recurse -Force -ErrorAction SilentlyContinue"
  else
    sh 'rm -f build/*.box'
  end
end
task :clear do
  if ENV['OS'] == 'Windows_NT'
    sh 'rm packer_cache -Force -Recurse -ErrorAction SilentlyContinue'
  else 
    sh 'rm -rf packer_cache'
  end
end

# shortcuts to virtualbox tasks with no namespace
task :build, [:box] => 'virtualbox:build'
task :install, [:box] => 'virtualbox:install'
task :remove, [:box] => 'virtualbox:remove'

# build a box for the specified provider
def build_box(box, provider)
  log "Building #{box} for #{provider}"
  file = "build/#{box}-opsworks-#{provider}.box"
  # sh "rm -f build/#{box}-opsworks-#{provider}.box && packer build -only=#{provider}-iso template/#{box}.json"
  File.delete(file) if File.exist?(file)
  sh "packer build -only=#{provider}-iso template/#{box}.json"
end

# build a box with vagrant
def install_box(box, provider)
  file = "build/#{box}-opsworks-#{provider}.box"
  build_box(box, provider) unless File.exists?(file)

  log "Installing #{box}-opsworks for #{provider} with vagrant"
  sh "vagrant box add #{file} --force --name=#{box}-opsworks"
end

# remove a box from vagrant
def remove_box(box, provider)
  log "Removing #{box} for #{provider}"
  provider = 'vmware_desktop' if provider.to_s == 'vmware'
  sh "vagrant box remove #{box} --provider=#{provider}"
end

# validate input for tasks with optional parameters
def box_arg(args)
  abort "Invalid box provided" if args[:box] && !BOXES.include?(args[:box])
  args[:box] || BOXES.first
end

def log(msg)
  puts "==> Rake: #{msg}"
end
