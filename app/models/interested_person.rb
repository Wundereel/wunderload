class InterestedPerson < ActiveRecord::Base
  validates :email, presence: true, uniqueness: true, format: /.+@.+\..+/i
end
