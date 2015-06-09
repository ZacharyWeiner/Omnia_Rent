class Location < ActiveRecord::Base
	has_many :price_per_sqft
end
