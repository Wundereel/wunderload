# == Schema Information
#
# Table name: jobs
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  title         :string
#  notes         :text
#  music         :string
#  names_in_reel :text
#  share_emails  :text
#  status        :integer          default(0)
#

class Job < ActiveRecord::Base
  belongs_to :user
  has_many :files, class_name: 'JobFile', dependent: :destroy
  has_one :purchase
  accepts_nested_attributes_for :files

  # validate :files_not_empty, on: [:add_videos, :add_info]
  # validates :title, presence: true, on: [:add_info]

  enum status: {
    empty: 0,
    videos_added: 1,
    information_added: 2,
    complete: 3
  }

  include AASM
  aasm column: :status, enum: true, whiny_transitions: false do
    state :empty, initial: true
    state :videos_added
    state :information_added
    state :complete

    event :add_videos do
      transitions from: :empty, to: :videos_added do
        guard do
          if files.length > 0
            true
          else
            errors[:files] << 'Select at least one video for your reel!'
            false
          end
        end
      end
    end

    event :add_information do
      transitions from: :videos_added, to: :information_added do
        guard do
          if !title.nil? && title.length > 0
            true
          else
            errors[:title] << 'Give us a title for your reel!'
            false
          end
        end
      end
    end

    event :add_payment do
      transitions from: :information_added, to: :complete do
        guard do
          purchase.finished?
        end
      end
    end
  end

  def next_status
    {
      'empty' =>  'videos_added',
      'videos_added' =>  'information_added',
      'information_added' => 'complete'
    }[status]
  end

  def next_step
    {
      'empty' =>  'add_videos',
      'videos_added' =>  'add_information',
      'information_added' => 'add_payment',
      'add_payment' => 'complete'
    }[status]
  end

  def files_not_empty
    return if files.length > 0
    errors[:files] << 'Select at least one video for your reel!'
  end
end
