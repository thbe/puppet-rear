require 'spec_helper'
describe 'rear' do

  context 'with default values for all parameters' do
    it { should contain_class('rear') }
  end
end


require 'spec_helper'

describe 'rear', :type => :class do

  context 'with defaults for all parameters' do
    it { should contain_class('rear') }
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      let(:params) {
        {
          :output_url => 'nfs://192.168.1.20/srv/rear/domain',
          :backup_url => 'nfs://192.168.1.20/srv/rear/domain',
          :ssh_root_password => 'Recover!1234',
          :schedule => 'weekly'
        }
      }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('rear') }
      it { is_expected.to contain_class('rear::params') }
      it { is_expected.to contain_class('rear::package') }
      it { is_expected.to contain_class('rear::config') }
      it { is_expected.to contain_class('rear::service') }

      it { is_expected.to contain_package('rear').with_ensure('installed') }

      it { is_expected.to contain_file('/etc/rear/local.conf').with_ensure('file') }

      it { is_expected.to contain_file('/etc/cron.d/rear').with_ensure('file') }

      it 'should generate valid content for local.config' do
        content = catalogue.resource('file', '/etc/rear/local.conf').send(:parameters)[:content]
        expect(content).to match('Recover!1234')
      end

      case facts[:operatingsystem]
      when 'RedHat'
      when 'OracleLinux'
      when 'CentOS'
      when 'Scientific'
      end

      case facts[:osfamily]
      when 'RedHat'
        if facts[:operatingsystemmajrelease] != '7'
          it { is_expected.to contain_warning('The current operating system is not supported!') }
        end
      else
        it { is_expected.to contain_warning('The current operating system is not supported!') }
      end
    end
  end
end