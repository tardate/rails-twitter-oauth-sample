
task :demo_proxy_login => :environment do
	puts "demo_proxy_login: Starting..."

	member = Member.find(:last)
	puts ".. using member #{member.screen_name}"
	twoauth = TwitterOauth.new(member.token, member.secret)

	puts ".. .. getting friends:"
	friends = twoauth.friends
	friends.each do |friend|
		puts ".. .. .. #{friend['screen_name']}"
	end
	
	puts "demo_proxy_login: Done."
end





