class FixActiveStorageBlobsServiceName < ActiveRecord::Migration[8.1]
  def up
    if ActiveRecord::Base.connection.table_exists?(:active_storage_blobs)
      # Update any active storage blobs that are pointing to a service other than 'local'
      ActiveRecord::Base.connection.execute(
        "UPDATE active_storage_blobs SET service_name = 'local' WHERE service_name IS NULL OR service_name != 'local'"
      )
    end
  end

  def down
    # No-op
  end
end
