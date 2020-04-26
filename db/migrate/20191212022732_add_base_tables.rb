class AddBaseTables < ActiveRecord::Migration[6.0]
  def change

    create_table :projects do |t|
      t.string :label, null: false, unique: true
      t.string :name
      t.boolean :public
      t.timestamps
    end

    create_table :users do |t|
      t.references :project, foreign_key: true, index: true
      t.string :login, null: false
      t.index [:project_id, :login], unique: true
      t.string :name, null: false
      t.string :language

      t.string :password
      t.string :tokens, array: true, default: []
      t.boolean :enabled, default: true
      t.jsonb :admission

      t.timestamps
      t.datetime :last_authn
      t.bigint :created_by
    end

    create_table :questionnaires do |t|
      t.references :project, null: false, foreign_key: true
      t.string :label, null: false, unique: true
      t.timestamps
    end

    create_table :questionnaire_configs do |t|
      t.references :questionnaire, null: false, foreign_key: true
      t.string :label, null: false
      t.index [:project_id, :label], unique: true
      t.integer :version, null: false, default: 0
      t.string :csv_data, null: false
      t.timestamps
    end

    create_table :records do |t|
      t.references :questionnaire, null: false, foreign_key: true
      t.integer :version, null: false
      t.references :user, null: false, foreign_key: true
      t.datetime :uploaded_at, null: false
      t.jsonb :data, null: false
    end

    create_table :invalid_uploads do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :uploaded_at, null: false
      t.text :data, null: false
    end

  end
end
