class Message < ActiveRecord::Base
  USER_GENDER = %w(Mr. Ms.)
  attr_accessible :name, :gender, :phone_number, :qq_number, :title, :content

  validates_presence_of :name, :gender, :phone_number, :content
  validates :name, :length => { :maximum => 30 }
  validates :gender, :numericality => { :only_integer => true,
    :greater_than_or_equal_to => 0, :less_than => USER_GENDER.length,
    :message => "is not valid" }
  validates :phone_number, :length => { :maximum => 20, :minimum => 5, :allow_blank => true }
  validates :qq_number, :length => { :maximum => 13, :minimum => 5, :allow_blank => true }
  validates :title, :length => { :maximum => 200 }
  validates :content, :length => { :maximum => 20000 }

  make_flaggable :visible_to

  attr_accessor :visible_to
end

class String
  def gender_index
    Message::USER_GENDER.index(self)
  end
end
