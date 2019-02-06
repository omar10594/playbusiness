require 'rails_helper'

RSpec.describe StartupsController, type: :controller do
    fixtures :startups, :users

    describe "GET index" do
        it "assigns @startups" do
            get :index
            expect(assigns(:startups)).to contain_exactly(startups(:one), startups(:two))
        end

        it "renders the index template" do
            get :index
            expect(response).to render_template :index
        end
    end

    describe "GET show" do
        it "assigns the startup requested to @startup" do
            get :show, params: { id: startups(:one) }
            expect(assigns(:startup)).to eq(startups(:one))
        end

        it "renders the show template" do
            get :show, params: { id: startups(:one) }
            expect(response).to render_template :show
        end
    end

    describe "GET new" do
        context "without an authenticated user" do
            it "redirects to login page" do
                get :new
                expect(response).to redirect_to(new_user_session_path)
            end
        end

        context "with an authenticated user" do
            before(:each) do
                sign_in users(:one)
            end

            it "assigns a new Startup to @startup" do
                get :new
                expect(assigns(:startup)).to be_a_new(Startup)
            end

            it "renders the new template" do
                get :new
                expect(response).to render_template :new
            end
        end
    end

    describe "GET edit" do
        context "without an authenticated user" do
            it "redirects to login page" do
                get :edit, params: { id: startups(:one) }
                expect(response).to redirect_to(new_user_session_path)
            end
        end

        context "with an authenticated user" do
            before(:each) do
                sign_in users(:one)
            end

            it "assigns the startup to edit to @startup" do
                get :edit, params: { id: startups(:one) }
                expect(assigns(:startup)).to eq(startups(:one)) 
            end

            it "renders the edit template" do
                get :edit, params: { id: startups(:one) }
                expect(response).to render_template :edit
            end
        end
    end

    describe "POST create" do
        context "without an authenticated user" do
            it "redirects to login page" do
                post :create, params: { startup: { :name => 'Some Startup' } }
                expect(response).to redirect_to(new_user_session_path)
            end
        end

        context "with an authenticated user" do
            before(:each) do
                sign_in users(:one)
            end

            context "with valid attributes" do
                it "saves the new startup in the database" do
                    expect {
                        post :create, params: { startup: { name: 'Some Startup' } }
                    }.to change(Startup, :count).by(1)
                end

                it "redirects to the startups page" do 
                    post :create, params: { startup: { name: 'Some Startup' } }
                    expect(response).to redirect_to assigns(:startup)
                end
            end

            context "with invalid attributes" do
                it "does not save the new startup in the database" do
                    expect{
                        post :create, params: { startup: { name: 'short' } }
                    }.to_not change(Startup, :count)
                end

                it "render the new template" do
                    post :create, params: { startup: { name: 'short' } }
                    expect(response).to render_template :new
                end
            end
        end
    end

    describe "PUT update" do
        context "without an authenticated user" do
            it "redirects to login page" do
                post :update, params: { id: startups(:one), startup: { :name => 'Name updated' } }
                expect(response).to redirect_to(new_user_session_path)
            end
        end

        context "with an authenticated user" do
            before(:each) do
                sign_in users(:one)
            end

            context "with valid attributes" do
                it "update the startup in the database" do
                    newName = 'Name Updated'
                    startup = startups(:one)
                    put :update, params: { id: startup, startup: { :name => newName } }
                    startup.reload
                    expect(startup.name).to eq(newName)
                end

                it "redirects to the startup page" do
                    put :update, params: { id: startups(:one), startup: { :name => 'Name Updated' } }
                    expect(response).to redirect_to startups(:one)
                end
            end

            context "with invalid attributes" do
                it "does not update the startup in the database" do
                    newName = 'short'
                    startup = startups(:one)
                    put :update, params: { id: startup, startup: { :name => newName } }
                    startup.reload
                    expect(startup.name).not_to eq(newName)
                end

                it "render the edit template" do
                    put :update, params: { id: startups(:one), startup: { :name => 'short' } }
                    expect(response).to render_template :edit
                end
            end
        end
    end

    describe "DELETE destroy" do
        context "without an authenticated user" do
            it "redirects to login page" do
                delete :destroy, params: { id: startups(:two) }
                expect(response).to redirect_to(new_user_session_path)
            end
        end

        context "with an authenticated user" do
            before(:each) do
                sign_in users(:one)
            end

            it "delete the startup from the database" do
                expect{
                    delete :destroy, params: { id: startups(:one) }
                }.to change(Startup, :count).by(-1)
            end

            it "redirects to the startups page" do
                delete :destroy, params: { id: startups(:one) }
                expect(response).to redirect_to startups_path
            end
        end
    end
end
