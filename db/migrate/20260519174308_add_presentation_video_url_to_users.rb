class AddPresentationVideoUrlToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :presentation_video_url, :string
  end
end
