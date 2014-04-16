class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
        t.string :user_id
      t.string :atoken
      t.string :asecret
      t.string :profile
      t.timestamps
    end
  end
end
