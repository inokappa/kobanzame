RSpec.describe Kobanzame::Report do
  before do
    result = [[1000000000100, 10.1, 200.621],
              [1000000000101, 90.3, 100.123],
              [1000000000110, 87.3, 99.456]]
    params = { 'task_id' => 'xxxxxxxx', 'docker_name' => 'foo' }
    @repo = Kobanzame::Report.new(result, params)
  end

  it 'get duration' do
    expect = { "duration"=>10, "unit"=>"ms" }
    expect(@repo.duration).to eq expect
  end

  it 'get cpu_usage' do
    expect = { "average"=>62.567, "max"=>90.3, "unit"=>"%" }
    expect(@repo.cpu_usage).to eq expect
  end

  it 'get memory_used' do
    expect = { "average"=>133.4, "max"=>200.621, "unit"=>"MiB" }
    expect(@repo.memory_used).to eq expect
  end

  it 'get Text Report' do
    expect = "REPORT TaskID: xxxxxxxx Duration: 10ms, Memory Used: 133.4MiB(ave)/200.621MiB(max), CPU Usage: 62.567%(ave)/90.3%(max)"
    expect(@repo.text).to eq expect
  end

  it 'get JSON Report' do
    expect = '{"report":{"duration":{"duration":10,"unit":"ms"},"memory_used":{"average":133.4,"max":200.621,"unit":"MiB"},"cpu_usage":{"average":62.567,"max":90.3,"unit":"%"}},"task_id":"xxxxxxxx","docker_name":"foo"}'
    expect(@repo.json).to eq expect
  end
end
