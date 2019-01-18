class AddMeetingCanceledToEvents < ActiveRecord::Migration[5.2]
  def up
    add_column :events, :canceled, :boolean, default: false

    canceled = ActiveRecord::Base.connection.execute("SELECT id FROM events WHERE payload LIKE '%canceled\"_true%'")
    canceled.each do |e_id|
      ActiveRecord::Base.connection.execute("UPDATE events SET canceled = 1 WHERE id = #{e_id['id']}")
    end
  end

  def down
    remove_column :events, :canceled, :boolean
  end
end
