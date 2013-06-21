class Message < ActiveRecord::Base
  attr_accessible :content, :gender, :name, :phone_number, :qq_number, :title
end
