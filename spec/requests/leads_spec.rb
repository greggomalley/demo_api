require 'rails_helper'

RSpec.describe "Leads", type: :request do
  describe "POST /api/v1/leads/assign" do
    let!(:tech_industry) { create(:tech_industry) }
    let!(:healthcare_industry) { create(:healthcare_industry) }
    let!(:finance_industry) { create(:finance_industry) }

    let!(:user1) { create(:user, :with_tech_industry) }
    let!(:user2) { create(:user, :with_tech_industry, :with_healthcare_industry) }

    let!(:tech_lead) { create(:lead, industry: tech_industry) }
    let!(:healthcare_lead) { create(:lead, industry: healthcare_industry) }

    it "returns a successful response" do
      post "/api/v1/leads/assign"
      expect(response).to have_http_status(:ok)
      expect(Lead.where(user: nil).count).to eq(0)
    end
  end
end
