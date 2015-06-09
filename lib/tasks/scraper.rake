namespace :scraper do
	desc "fetch posts from 3Taps for CraigsList since the last anchor"
	task scrape: :environment do
	require 'open-uri'
	require 'json'
	require 'mathn'
	anchor_value = 2209601378
	auth_token = "1b9df10b526e6f785dfdc940a414ffae"
	polling_url = "http://polling.3taps.com/poll"
	hipster_locs = ["USA-MIA-MIB", "USA-MIA-FOR", "USA-MIA-MIF", "USA-MIA-DEE", "USA-MIA-DOM", "USA-MIA-NOC", "USA-MIA-SOC", "USA-MIA-WYN", "USA-MIA-GAL", "USA-MIA-IDL", "USA-MIA-LAS", "USA-MIA-LAB", "USA-MIA-MID","USA-MIA-RIO", "USA-MIA-SAI", "USA-MIA-TAR", "USA-MIA-VIC"]
	#Grab data until up to date
	ftl_city_key = "USA-MIA-FOR"
	miami_city_key = "USA-MIA-MIF"

	first_anchor_value = Anchor.first.value
	city_keys = [miami_city_key, ftl_city_key]
	city_keys.count.times do |i|
		loop do 

			# Specify request params
			# To get a new anchor change the date in the url to a unix time for todays date(without time)
			# http://polling.3taps.com/anchor?auth_token=1b9df10b526e6f785dfdc940a414ffae&timestamp=1432598400
			params = {
				auth_token: auth_token,
				anchor:  Anchor.first.value, 
				source: "CRAIG",
				category_group: "RRRR",
				category: "RHFR",
				'location.city' =>  city_keys[i],
				retvals: "location,external_url,heading,body,timestamp,price,images,annotations"
			}


			# Prepare API Request
			uri = URI.parse(polling_url)
			uri.query = URI.encode_www_form(params)

			# Get the data at the URI built abov
			result = JSON.parse(open(uri).read)
			
			# Iterate over each item that was returned to save the items in the database
			result["postings"].each do | posting |
				@post = Post.new
				@post.heading = posting["heading"]
				@post.body = posting["body"]
				@post.price = posting["price"]
				loc = Location.find_by(code: posting["location"]["locality"]) if posting["location"]["locality"].present?
				@post.neighborhood = loc.name unless loc == nil 
				@post.external_url = posting["external_url"] if posting["external_url"].present?
				if hipster_locs.include? posting["location"]["locality"]
					puts "hip hip hip"
					@post.is_hipster = "YES" 
				end
				@post.timestamp = posting["timestamp"]
				@post.bedrooms = posting["annotations"]["bedrooms"] if posting["annotations"]["bedrooms"].present?
				@post.bathrooms = posting["annotations"]["bathrooms"] if posting["annotations"]["bathrooms"].present? 
				@post.sqft = posting["annotations"]["sqft"] if posting["annotations"]["sqft"].present? 
				@post.cats = posting["annotations"]["cats"] if posting["annotations"]["cats"].present? 	
				@post.dogs = posting["annotations"]["dogs"] if posting["annotations"]["dogs"].present?
				@post.w_d_in_unit = posting["annotations"]["w_d_in_unit"] if posting["annotations"]["w_d_in_unit"].present?
				# Save post
				@post.save
				unless loc == nil
					if(@post.sqft.to_i > 0 && @post.price.to_i > 0) 
						ppsf = PricePerSqft.new 
						ppsf.price = @post.price.to_d
						ppsf.sqft = @post.sqft.to_d
						ppsf.value = ppsf.price / ppsf.sqft
						ppsf.location = loc
						unless ppsf.value < 0.03 
							unless ppsf.value > 5.0
								ppsf.save
								p city_keys[i]
							end
						end
					end
				end
				puts @post.id
				# Iterate the images an add a record in the images table for each one
				if posting["images"].present?
					posting["images"].each do |img|
						@image = Image.new
						@image.url = img["full"]
						@image.post = @post 
						@image.save

					end # End images.each
				end # End images.present? 
			end # End Postings Each 
			a = Anchor.first
			a.value = result["anchor"]
			a.save
			puts Anchor.first.value
			break if result["postings"].empty?
		end # End loop
		a = Anchor.first
		a.value = anchor_value
		a.save
	end #end cities.times


  end #end Task

  desc "Destroy all Posting Data"
  task destroy_all_posts: :environment do
  	Post.destroy_all
  end

  desc "Save neighborhood data in reference table"
  task scrape_neighborhoods: :environment do
  	require 'open-uri'
  	require 'json'

  	auth_token = "1b9df10b526e6f785dfdc940a414ffae"
  	location_url = "http://reference.3taps.com/locations"


	# Specify request params 
	params = {
		auth_token: auth_token,
		level: "locality",
		metro: "USA-MIA"
	}


	# Prepare API Request
	uri = URI.parse(location_url)
	uri.query = URI.encode_www_form(params)

	# Get the data at the URI built abov
	result = JSON.parse(open(uri).read)

	result["locations"].each do |location|
		@location = Location.new
		@location.code = location["code"]
		@location.name = location["short_name"]
		puts "#{@location.code}: #{@location.name}"
		@location.save
		end
	end

	desc "Destroy all Location Table Data"
	task destroy_all_locations: :environment do
		Location.destroy_all
	end

	desc "Destroy all Entries over 10 days old"
	task destroy_old_data: :environment do
		posts = Post.where(:created_at < 2.days.ago)
		posts.each do |post|
			if post.created_at < 2.days.ago 
				post.destroy 
			end
		end
	end
	
	desc "Destroy all Entries over 10 days old"
	task destroy_old_ppsf: :environment do
		PricePerSqft.destroy_all
	end
	

	desc "Set Anchor"
	task set_anchor: :environment do
		a = Anchor.first
		a.value = 2209601378
		a.save
	end
end
