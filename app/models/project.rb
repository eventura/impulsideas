class Project < ActiveRecord::Base
  belongs_to :user
  has_many :contributions, dependent: :destroy

  validates :short_description, presence: true, length: { minimum: 2 }
  validates :funding_goal, presence: true, numericality: { greater_than: 0 }
  validates :funding_duration, presence: true, numericality: {greater_than: 0, less_than: 91}

  def total_contributed
    Contribution
      .where(project_id: self.id, payment_status: 'ACTIVE')
      .group(:project_id)
      .sum(:amount)
      .values[0].to_f
  end

  def total_contributors
   contributions
    .where(payment_status: 'ACTIVE')
    .select('DISTINCT(user_id)').count
  end

  def time_left
    funding_duration - ((Time.now - created_at)/1.day).round
  end

  def funding_percentage
    return 0.0 unless funding_goal.to_f > 0
    ((total_contributed.to_f / funding_goal.to_f) * 100)
  end
end
