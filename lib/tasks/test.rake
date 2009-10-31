
task :demo_proxy_login => :environment do
	puts "demo_proxy_login: Starting..."

	member = Member.find(:last)
	puts ".. using member #{member.screen_name}"
	twoauth = TwitterOauth.new(member.token, member.secret)

	puts ".. .. getting friends:"
	twoauth.dump_friends
	
	puts ".. .. getting followers:"
	twoauth.dump_followers
	
	puts "demo_proxy_login: Done."
end





