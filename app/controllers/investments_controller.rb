class InvestmentsController < ApplicationController
    before_action :authenticate_user!

    def create
        @startup = Startup.find(params[:startup_id])
        @investment = @startup.investments.build(investment_params)
        @investment.user = current_user

        @investment.save
        redirect_to startup_path(@startup)
    end

    def destroy
        @startup = Startup.find(params[:startup_id])
        @investment = @startup.investments.find(params[:id])
        @investment.destroy

        redirect_to startup_path(@startup)
    end

    private
        def investment_params
            params.require(:investment).permit(:amount, :wallet_amount)
        end
end
