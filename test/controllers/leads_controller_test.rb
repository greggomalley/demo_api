require "test_helper"

class LeadsControllerTest < ActionDispatch::IntegrationTest
  test "should get Api::V1::Leads" do
    get leads_Api::V1::Leads_url
    assert_response :success
  end
end
