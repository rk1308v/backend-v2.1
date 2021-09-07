require 'rails_helper'

RSpec.describe User, :type => :model do
  let(:user) { FactoryGirl.build(:user) }

  context 'validations' do
    it { expect(user).to validate_uniqueness_of(:telephone) }
  end
end
