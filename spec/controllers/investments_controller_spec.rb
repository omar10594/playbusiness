require 'rails_helper'

RSpec.describe InvestmentsController, type: :controller do
    fixtures :startups, :users

    describe "POST create" do
        context "without an authenticated user" do
            it "redirects to login page" do
                post :create, params: { startup_id: startups(:one), investment: { amount: 10000 } }
                expect(response).to redirect_to(new_user_session_path)
            end
        end

        context "with an authenticated user" do
            before(:each) do
                sign_in users(:one)
            end

            it "saves the new startup in the database" do
                params = {
                    startup_id: startups(:one),
                    :investment => {
                        :amount => 10000
                    }
                }
                expect{
                    post :create, params: params
                }.to change(Investment, :count).by(1)
            end

            it "redirects to the startup page" do
                startup = startups(:one)
                params = {
                    startup_id: startup,
                    :investment => {
                        :amount => 10000
                    }
                }
                post :create, params: params
                expect(response).to redirect_to(startup)
            end
        end
    end

    describe "DELETE destroy" do
        fixtures :investments

        context "without an authenticated user" do
            it "redirects to login page" do
                delete :destroy, params: { startup_id: startups(:one), id: investments(:one) }
                expect(response).to redirect_to(new_user_session_path)
            end
        end

        context "with an authenticated user" do
            before(:each) do
                sign_in users(:one)
            end

            it "delete the startup from the database" do
                expect{
                    delete :destroy, params: { startup_id: startups(:one), id: investments(:one) }
                }.to change(Investment, :count).by(-1)
            end

            it "redirects to the startups page" do
                delete :destroy, params: { startup_id: startups(:one), id: investments(:one) }
                expect(response).to redirect_to(startups(:one))
            end
        end
    end
end
