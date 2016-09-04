class UploadsController < ApplicationController
  def index
    uploads = []
    if(params[:uuids].present?)
      uuids = params[:uuids].split(",")
      uploads = Upload.where(:uuid => uuids).all
    end

    data = uploads.map do |upload|
      {
        :uuid => upload.uuid,
        :name => upload.file_filename,
        :size => upload.file_size,
      }
    end

    render :json => data
  end

  def create
    Upload.create!(upload_params)

    render :json => { :success => true }
  end

  def destroy
    upload = Upload.find_by!(:uuid => params[:id])
    upload.destroy!

    render :json => { :success => true }
  end

  private

  def upload_params
    params.permit(:uuid, :file)
  end
end
