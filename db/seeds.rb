pass = '0Oo0Oo'
ApplicationRecord.transaction do
  demo = Project.create! label: 'demo', name: 'DEMO Project'
  demo.users.create login: 'admin', password: pass, name: 'Admin'
  demo.users.create login: 'collector', password: pass, name: 'Collector'
end
