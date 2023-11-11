class TransfersController < ApplicationController
  def create
    create_transfer_command = CreateTransferCommand.new(params)

    CreateBulkTransfers.new(create_transfer_command).create

    render json: {status: "ok"}, status: :created
  rescue StandardError => error
    render status: :unprocessable_entity if error.is_a?(InsufficientBalanceError)
  end
end
