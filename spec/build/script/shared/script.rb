shared_examples_for 'compiled script' do
  include SpecHelpers::Shell

  let(:code) { [] }
  let(:cmds) { [] }

  subject { Travis::Build.script(data).compile }

  # it 'output' do
  #   puts subject
  # end

  it 'can be compiled' do
    expect { subject }.to_not raise_error
  end

  it 'includes the expected shell code' do
    code.each do |code|
      should include code
    end
  end

  it 'includes the expected travis_cmds' do
    cmds.each do |cmd|
      should include_shell cmd
    end
  end
end

shared_examples_for 'a build script sexp' do
  it_behaves_like 'a script with travis env vars sexp'
  it_behaves_like 'a script with env vars sexp' do
    let(:env_type) { 'env' }
  end
  it_behaves_like 'a script with env vars sexp' do
    let(:env_type) { 'global_env' }
  end

  it 'does not initiate debug phase' do
    should_not include_sexp [:raw, "travis_debug"]
    should_not include_sexp [:raw, "travis_debug --quiet"]
  end

  it_behaves_like 'show system info'
  it_behaves_like 'validates config'
  it_behaves_like 'paranoid mode on/off'
  it_behaves_like 'disables OpenSSH roaming'
  it_behaves_like 'fix ps4'
  it_behaves_like 'fix etc/hosts'
  it_behaves_like 'fix resolve.conf'
  it_behaves_like 'put localhost first in etc/hosts'
  it_behaves_like 'starts services'
  it_behaves_like 'build script stages'

  it 'calls travis_result' do
    should include_sexp [:raw, 'travis_result $?']
  end
end

shared_examples_for 'a debug script' do
  it 'initiates debug phase' do
    should include_sexp [:raw, "travis_debug"]
  end

  context 'when debug_options sets "quiet" => true' do
    before { payload[:job][:debug_options].merge!({ quiet: true }) }

    it 'initiates debug phase' do
      should include_sexp [:raw, "travis_debug --quiet"]
    end

    it 'does not run default script phase' do
      should_not include_sexp [:cmd, "rake", :echo=>true, :timing=>true]
    end
  end

  it 'resets build status' do
    should include_sexp [:echo, "This is a debug build. The build result is reset to its previous value, \\\"failed\\\".", ansi: :yellow]
  end
end
