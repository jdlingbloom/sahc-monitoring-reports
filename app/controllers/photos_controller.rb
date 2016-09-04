class PhotosController < ApplicationController
  def download
    @photo = Photo.find(params[:id])
    send_file @photo.image.download,
      :filename => @photo.image_filename,
      :type => @photo.image_content_type,
      :disposition => :attachment
  end
end
