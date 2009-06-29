class CreateMembers < ActiveRecord::Migration
	def self.up
		create_table :members do |t|
			t.integer :twitter_id
			t.string :screen_name
			t.string :token
			t.string :secret
			t.string :profile_image_url
			t.timestamps
		end
		add_index :members, :twitter_id, :unique => true
		add_index :members, :screen_name, :unique => true
	end

	def self.down
		remove_index :members, :twitter_id
		remove_index :members, :screen_name
		drop_table :members
	end
end
