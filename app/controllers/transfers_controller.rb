class TransfersController < ApplicationController
  def create
    Rails.logger.info("Bulk transfer has started! Account: #{params[:organization_name]}")
    create_transfer_command = CreateTransferCommand.new(params)

    CreateBulkTransfers.new(create_transfer_command).create

    render json: {status: "ok"}, status: :created
  rescue StandardError => error
    return render status: :not_found if error.is_a?(BankAccountNotFoundError)

    render status: :unprocessable_entity , json: { error: error.message }
  end
end
