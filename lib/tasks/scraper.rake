namespace :scraper do
	desc "fetch posts from 3Taps for CraigsList since the last anchor"
	task scrape: :environment do
		require 'open-uri'
		require 'json'

		auth_token = "1b9df10b526e6f785dfdc940a414ffae"
		polling_url = "http://polling.3taps.com/poll"

	#Grab data until up to date
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
			'location.city' => "USA-MIA-MIF",
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
			loc = Location.find_by(code: posting["location"]["locality"])
			@post.neighborhood = loc.name unless loc == nil 
			@post.external_url = posting["external_url"]
			@post.timestamp = posting["timestamp"]

			@post.bedrooms = posting["annotations"]["bedrooms"] if posting["annotations"]["bedrooms"].present?
			@post.bathrooms = posting["annotations"]["bathrooms"] if posting["annotations"]["bathrooms"].present? 
			@post.sqft = posting["annotations"]["sqft"] if posting["annotations"]["sqft"].present? 
			@post.cats = posting["annotations"]["cats"] if posting["annotations"]["cats"].present? 	
			@post.dogs = posting["annotations"]["dogs"] if posting["annotations"]["dogs"].present?
			@post.w_d_in_unit = posting["annotations"]["w_d_in_unit"] if posting["annotations"]["w_d_in_unit"].present?
			# Save post
			@post.save 

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
		Anchor.first.update(value: result["anchor"])
		puts Anchor.first.value
		break if result["postings"].empty?
	end # End loop
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
end
