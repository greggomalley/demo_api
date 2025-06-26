class Api::V1::LeadsController < ApplicationController
  allow_unauthenticated_access

  def index
    @leads = Lead.all.order(:name)
    render json: @leads, include: [ :industry, :user ]
  end

  def create
    @lead = Lead.new(lead_params)
    if @lead.save
      render json: @lead,  include: [:industry, :user], status: :created
    else
      render json: @lead.errors, status: :unprocessable_entity
    end
  end

  def assign
    LeadAssigner.call(lead_capacity: 2)
    render json: Lead.all.order(:name), include: [ :industry, :user ]
  end

  def destroy
    @lead = Lead.find(params[:id])
    @lead.destroy
  end

  private

  def lead_params
    params.require(:lead).permit(:name, :email, :message, :industry_id)
  end
end
