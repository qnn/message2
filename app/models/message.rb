# encoding: utf-8
class Message < ActiveRecord::Base
  USER_GENDER = %w(Mr. Ms.)

  attr_accessible :name, :gender, :phone_number, :qq_number, :title, :content

  validates_presence_of :name, :gender, :phone_number, :content
  validates_format_of :name, :with => /^[0-9a-zA-Z \p{Han}]{1,30}$/
  validates :gender, :numericality => { :only_integer => true,
    :greater_than_or_equal_to => 0, :less_than => USER_GENDER.length,
    :message => I18n::t("activerecord.errors.models.message.attributes.gender.invalid") }
  validates_format_of :phone_number, :with => /^[0-9\(\)\/\+ \-]{5,20}$/
  validates_format_of :qq_number, :with => /^[0-9]{5,13}$/, :allow_blank => true
  validates :title, :length => { :maximum => 200 }
  validates :content, :length => { :maximum => 20000 }

  make_flaggable :visible_to

  attr_accessor :visible_to

  self.per_page = 10
end

class String
  def gender_index
    Message::USER_GENDER.index(self)
  end
end
