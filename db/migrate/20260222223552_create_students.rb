class CreateStudents < ActiveRecord::Migration[8.1]
  def change
    create_table :students do |t|
      t.string :first_name
      t.string :last_name
      t.string :code

      t.timestamps
    end
  end
end
