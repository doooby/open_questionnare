pass = '0Oo0Oo'

ApplicationRecord.transaction do

  demo = Project.create! label: 'demo', name: 'DEMO Project'
  demo.users.create login: 'admin', password: pass, name: 'Admin'
  demo.users.create login: 'collector', password: pass, name: 'Collector'

  happiness = demo.questionnaires.create 'happiness'
  happiness.configs.create label: 'meta', csv_data: <<-CSV_DATA
current_version,1
  CSV_DATA
  happiness.configs.create label: 'fields',
      csv_data: File.read(happiness.code_dir.join 'v1_fields.csv')

end
