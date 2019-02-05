class StartupsController < ApplicationController
    before_action :authenticate_user!, only: [:new, :edit, :create, :update, :destroy]

    def index
        @startups = Startup.all
    end

    def show
        @startup = Startup.find(params[:id]);
    end

    def new
        @startup = Startup.new
    end

    def edit
        @startup = Startup.find(params[:id])
    end

    def create
        @startup = Startup.new(startup_params)

        if @startup.save
            redirect_to @startup
        else
            render 'new'
        end
    end

    def update
        @startup = Startup.find(params[:id])
       
        if @startup.update(startup_params)
          redirect_to @startup
        else
          render 'edit'
        end
    end

    def destroy
        @startup = Startup.find(params[:id])
        @startup.destroy

        redirect_to startups_path
    end

    private
        def startup_params
            params.require(:startup).permit(:name, :description)
        end
end
