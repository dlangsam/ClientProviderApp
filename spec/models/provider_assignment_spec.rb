require 'rails_helper'

RSpec.describe ProviderAssignment, type: :model do
  describe 'associations' do
    it 'belongs to a provider' do
      assignment = create(:provider_assignment)
      expect(assignment.provider).to be_a(Provider)
    end

    it 'belongs to a client' do
      assignment = create(:provider_assignment)
      expect(assignment.client).to be_a(Client)
    end
  end

  describe 'validations' do
    subject { build(:provider_assignment) }

    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    describe 'plan' do
      it 'is required' do
        subject.plan = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:plan]).to be_present
      end

      it 'defaults to basic' do
        assignment = ProviderAssignment.new(provider: create(:provider), client: create(:client))
        assignment.save!
        expect(assignment.plan).to eq('basic')
      end
    end

    describe 'uniqueness' do
      it 'prevents duplicate provider-client assignments' do
        provider = create(:provider)
        client = create(:client)
        create(:provider_assignment, provider: provider, client: client)

        duplicate = build(:provider_assignment, provider: provider, client: client)
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:provider_id]).to include('has already been taken')
      end

      it 'allows same client with different providers' do
        client = create(:client)
        create(:provider_assignment, client: client)

        assignment2 = build(:provider_assignment, client: client)
        expect(assignment2).to be_valid
      end
    end
  end

  describe 'enum' do
    it 'defines basic and premium plans' do
      assignment = create(:provider_assignment)

      assignment.plan = :basic
      expect(assignment.basic?).to be true
      expect(assignment.premium?).to be false

      assignment.plan = :premium
      expect(assignment.premium?).to be true
      expect(assignment.basic?).to be false
    end

    it 'provides bang methods to change plan' do
      assignment = create(:provider_assignment, plan: :basic)

      assignment.premium!
      expect(assignment.plan).to eq('premium')
      expect(assignment.reload.plan).to eq('premium')
    end
  end
end
