class AddBaseTables < ActiveRecord::Migration[6.0]
  def change

    create_table :projects do |t|
      t.string :label, null: false, unique: true
      t.string :name
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

    create_table :records do |t|
      t.references :project, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :uploaded_at, null: false
      t.jsonb :data, null: false
      t.string :region_designation, array: true, null: false
    end

    create_table :invalid_uploads do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :uploaded_at, null: false
      t.text :data, null: false
    end

  end
end
