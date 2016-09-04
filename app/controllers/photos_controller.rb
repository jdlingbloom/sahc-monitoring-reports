class PhotosController < ApplicationController
  def download
    @photo = Photo.find(params[:id])
    send_file @photo.original_image.download,
      :filename => @photo.original_image_filename,
      :type => @photo.original_image_content_type,
      :disposition => :attachment
  end
end
