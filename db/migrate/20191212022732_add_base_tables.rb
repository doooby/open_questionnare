class AddBaseTables < ActiveRecord::Migration[6.0]
  def change

    create_table :users do |t|
      t.string :login, null: false, unique: true
      t.string :name, null: false
      t.string :language

      t.string :password
      t.string :tokens, array: true, default: []
      t.boolean :enabled, default: true

      t.timestamps
      t.datetime :last_authn
    end

    create_table :questionnaires do |t|
      t.references :user, null: false
      t.datetime :uploaded_at, null: false
      t.jsonb :data, null: false
    end

    create_table :invalid_uploads do |t|
      t.references :user, null: false
      t.datetime :uploaded_at, null: false
      t.text :data, null: false
    end

  end
end
