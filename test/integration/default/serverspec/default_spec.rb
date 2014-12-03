require 'serverspec'

set :backend, :exec

describe command('which git') do
  its(:stdout) { should match /git/ }
end

describe command('which node') do
  its(:stdout) { should match /node/ }
end
