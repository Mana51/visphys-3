require 'bundler/setup'
Bundler.require

ActiveRecord::Base.establish_connection

class User < ActiveRecord::Base
    has_secure_password
    validates :name,
        presence: true,
        format: { with: /\A\w+\z/ }
    validates :password,
        length: { in: 5..10 }
end

class SavedSimulation < ActiveRecord::Base
  belongs_to :user

  validates :title, presence: true
  validates :simulation_type, presence: true
  validates :variables, presence: true
end

class SharedSimulation < ActiveRecord::Base
    
end