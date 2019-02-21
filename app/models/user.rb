class User < ApplicationRecord
  attr_accessor :remember_token

  has_many :teams
  has_many :tournaments, through: :teams

  has_secure_password

  validates :first_name, presence: true
  # validates :last_name, presence: true
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :password, presence: true, on: :create, length: {minimum: 6}

  def admin?
    self.admin
  end

  def self.available_users(tourn_id)
    teams_already_added = Tournament.find(tourn_id).teams.map { |team| team.user_id }
    User.where.not(id: teams_already_added)
  end

  #Returns the hash digest of the given string.
  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns random token for remember me cookie
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def forget
    update_attribute(:remember_digest,  nil)
  end

  # Returns true if the given token matches the digest
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def tournaments_played
    # tournaments ids from past tournaments played in
    # team-playoffs ids from
    # just for kob tournaments now (lookup just user_id in Team)
    Team.where(user_id: self.id, playoffs: true).map do |team|
      tourn = Tournament.find_by_id(team.tournament_id)
      points = tourn.points_earned_kob
      place = team.place.to_i
      points_earned = points[place - 1]
      { tourn_name: tourn.name, tourn_id: tourn.id, tourn_date: tourn.date, place: place, points: points_earned }
    end
  end
end
