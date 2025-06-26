require 'rails_helper'

RSpec.describe LeadAssigner, type: :service do
  describe '#call' do
    let!(:tech_industry) { create(:tech_industry) }
    let!(:healthcare_industry) { create(:healthcare_industry) }
    let!(:finance_industry) { create(:finance_industry) }

    let!(:user1) { create(:user, :with_tech_industry) }
    let!(:user2) { create(:user, :with_tech_industry, :with_healthcare_industry) }

    let!(:tech_lead) { create(:lead, industry: tech_industry) }
    let!(:healthcare_lead) { create(:lead, industry: healthcare_industry) }

    let(:lead_capacity) {1}

    it 'respects the lead capacity limit' do
      described_class.call(lead_capacity:)

      User.all.each do |user|
        expect(user.leads.count).to be <= lead_capacity
      end
    end

    it 'assigns each lead to at most one user' do
      described_class.call(lead_capacity:)

      Lead.all.each do |lead|
        expect(Lead.where(id: lead.id).where.not(user_id: nil).count).to be <= 1
      end
    end

    it 'assigns leads based on industry speciality' do
      described_class.call(lead_capacity:)

      # The healthcare lead should be assigned to user2 since they're the only one with healthcare industry
      expect(healthcare_lead.reload.user).to eq(user2)

      # The tech lead should be assigned to either user1 to ensure the objective is maximised
      expect(tech_lead.reload.user).to eq(user1)
    end

    context 'when there are no users' do
      before do
        User.destroy_all
      end

      it 'leaves all leads unassigned' do
        described_class.call

        expect(Lead.where.not(user_id: nil).count).to eq(0)
      end
    end

    context 'when there are no leads' do
      before do
        Lead.destroy_all
      end

      it 'completes without error' do
        expect { described_class.call }.not_to raise_error
      end
    end

    context 'when leads exceed total user capacity' do
      let!(:user3) { create(:user, :with_tech_industry) }

      before do
        # Create more leads than can be handled (3 users * 10 capacity = 30 max)
        create_list(:lead, 30, industry: tech_industry)
      end

      it 'assigns leads up to total capacity and leaves some unassigned' do
        described_class.call

        total_assigned = Lead.where.not(user_id: nil).count
        expect(total_assigned).to be <= (User.count * LeadAssigner::LEAD_CAPACITY)

        # Some leads should remain unassigned
        unassigned_count = Lead.where(user_id: nil).count
        expect(unassigned_count).to be > 0
      end
    end

    context 'with custom lead capacity' do
      let!(:user3) { create(:user, :with_tech_industry) }

      before do
        create_list(:lead, 8, industry: tech_industry)
      end

      it 'respects custom capacity limit' do
        custom_capacity = 3
        described_class.call(lead_capacity: custom_capacity)

        User.all.each do |user|
          expect(user.leads.count).to be <= custom_capacity
        end
      end
    end

    context 'when users have no matching industry expertise' do
      let!(:finance_lead) { create(:lead, industry: finance_industry) }

      it 'may leave leads unassigned when no expertise matches' do
        described_class.call

        # Finance lead might not be assigned since no user has finance expertise
        # This tests the algorithm handles non-matching industries gracefully
        expect { described_class.call }.not_to raise_error
      end
    end

    context 'with multiple leads per industry' do
      before do
        create_list(:lead, 3, industry: tech_industry)
        create_list(:lead, 2, industry: healthcare_industry)
      end

      it 'distributes leads optimally based on expertise' do
        described_class.call

        # Tech leads should prefer user1 and user2 (both have tech expertise)
        tech_leads_assigned = Lead.joins(:industry)
                                  .where(industries: { id: tech_industry.id })
                                  .where.not(user_id: nil)

        expect(tech_leads_assigned.count).to be > 0

        # Healthcare leads should prefer user2 (only one with healthcare expertise)
        healthcare_leads_assigned = Lead.joins(:industry)
                                        .where(industries: { id: healthcare_industry.id })
                                        .where(user_id: user2.id)

        expect(healthcare_leads_assigned.count).to be > 0
      end
    end

    context 'edge case: single user, single lead' do
      before do
        User.destroy_all
        Lead.destroy_all

        create(:user, :with_tech_industry)
        create(:lead, industry: tech_industry)
      end

      it 'assigns the lead to the only user' do
        described_class.call

        expect(Lead.first.user).to eq(User.first)
      end
    end

    context 'when solver fails to find solution' do
      before do
        # Mock solver to return an unsuccessful status
        allow_any_instance_of(ORTools::Solver).to receive(:solve).and_return(false)
      end

      it 'handles solver failure gracefully' do
        expect { described_class.call }.not_to raise_error

        # Leads should remain unassigned if solver fails
        expect(Lead.where.not(user_id: nil).count).to eq(0)
      end
    end

    context 'performance test with large dataset' do
      before do
        # Create larger dataset to test performance
        create_list(:user, 20, :with_tech_industry)
        create_list(:lead, 100, industry: tech_industry)
      end

      it 'completes within reasonable time' do
        start_time = Time.current

        described_class.call

        execution_time = Time.current - start_time
        expect(execution_time).to be < 30.seconds # Adjust threshold as needed
      end
    end

    context 'data integrity' do
      it 'does not modify lead count during assignment' do
        initial_lead_count = Lead.count

        described_class.call

        expect(Lead.count).to eq(initial_lead_count)
      end

      it 'does not modify user count during assignment' do
        initial_user_count = User.count

        described_class.call

        expect(User.count).to eq(initial_user_count)
      end

      it 'only modifies the user_id field of leads' do
        lead_attributes_before = Lead.all.map do |lead|
          lead.attributes.except('user_id', 'updated_at')
        end

        described_class.call

        lead_attributes_after = Lead.all.map do |lead|
          lead.attributes.except('user_id', 'updated_at')
        end

        expect(lead_attributes_after).to eq(lead_attributes_before)
      end
    end
  end
end