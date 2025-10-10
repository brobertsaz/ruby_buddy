require 'rails_helper'

RSpec.describe "Home", type: :request do
  describe "GET /" do
    context "when not authenticated" do
      it "returns success" do
        get root_path
        expect(response).to have_http_status(:success)
      end

      it "renders the index template" do
        get root_path
        expect(response).to render_template(:index)
      end

      it "displays the home page content" do
        get root_path
        expect(response.body).to include("Ruby Pair")
      end
    end

    context "when authenticated" do
      let(:user) { create(:user, :mentee) }
      
      before { sign_in user }

      it "returns success" do
        get root_path
        expect(response).to have_http_status(:success)
      end

      it "renders the index template" do
        get root_path
        expect(response).to render_template(:index)
      end

      it "displays the home page content" do
        get root_path
        expect(response.body).to include("Ruby Pair")
      end
    end
  end
end
