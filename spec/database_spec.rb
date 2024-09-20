require_relative '../lib/database'

RSpec.describe Database do
  let(:db_config) { YAML.load_file('config/database.yml')['test'] }
  let(:db) { Database.new(db_config) }

  before(:all) do
    db.setup_test_data
  end

  it 'returns the correct employee information' do
    result = db.search_employee( 'Company A', 'Dept 1', 'Group A', 'Lab 1', 'John Doe', 12345)
    expect(result).to_not be_nil
    expect(result.first['enterprise']).to eq('Company A')
    expect(result.first['department']).to eq('Dept 1')
  end

  it 'handles no results gracefully' do
    result = db.search_employee('Non Existent', nil, nil, nil, nil, nil)
    expect(result.count).to eq(0)
  end
end