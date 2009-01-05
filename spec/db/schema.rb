ActiveRecord::Schema.define(:version => 0) do
  create_table :users, :force => true do |t|
    t.column :name, :string
    t.column :required_url, :string
    t.column :blank_url, :string
    t.column :nil_url, :string
  end
end
