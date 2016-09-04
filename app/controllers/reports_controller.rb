require "rexml/document"

class ReportsController < ApplicationController
  def index
    @reports = Report.all
  end

  def show
    @report = Report.find(params[:id])
  end

  def new
    @report = Report.new(:monitoring_year => Date.today.year)
  end

  def create
    @report = Report.new
    save!
    redirect_to(edit_report_path(@report))
  rescue ActiveRecord::RecordInvalid
    render(:action => "new")
  end

  def edit
    @report = Report.find(params[:id])
  end

  def update
    @report = Report.find(params[:id])
    save!
    if(params[:upload_uuids])
      redirect_to(edit_report_path(@report))
    else
      redirect_to(report_path(@report))
    end
  rescue ActiveRecord::RecordInvalid
    render(:action => "edit")
  end

  def destroy
    @report = Report.find(params[:id])
    @report.destroy

    flash[:notice] = "Successfully deleted #{@report.display_name} monitoring report"
    redirect_to(reports_path)
  end

  def download
    @report = Report.find(params[:id])

    pdf = Prawn::Document.new(:page_layout => :landscape, :margin => 18) do |pdf|
      header_height = 40
      footer_height = 20

      pdf.font "Times-Roman"
      pdf.font_size 10

      pdf.bounding_box([0, pdf.bounds.height], :width => pdf.bounds.width, :height => header_height) do
        pdf.define_grid(:columns => 12, :rows => 1, :gutter => 10)

        pdf.grid([0, 0], [0, 3]).bounding_box do
          pdf.move_down 12
          pdf.stroke_horizontal_rule
          pdf.move_down 2
          pdf.text "Signature of photographer"
          pdf.text "#{@report.photographer_name}, SAHC"
        end

        pdf.grid([0, 4], [0, 5]).bounding_box do
          pdf.move_down 12
          pdf.stroke_horizontal_rule
          pdf.move_down 2
          pdf.text "Date"
        end

        pdf.grid([0, 6], [0, 11]).bounding_box do
          pdf.text "All photos taken on #{l(@report.photos_date, :format => :short) if(@report.photos_date)}", :align => :right
          pdf.text "unless otherwise noted", :align => :right
        end
      end

      pdf.bounding_box([0, pdf.bounds.height - header_height], :width => pdf.bounds.width, :height => pdf.bounds.height - (header_height + footer_height)) do
        cols = 3
        pdf.define_grid(:columns => cols, :rows => 2, :gutter => 10)
        @report.photos.each_with_index do |photo, index|
          row = (index / cols.to_f).floor
          col = index % cols

          pdf.grid(row, col).bounding_box do
            pdf.image photo.image.download, :fit => [pdf.bounds.width, pdf.bounds.height - 80], :position => :center
            pdf.rectangle [0, pdf.cursor], pdf.bounds.width, 6
            pdf.fill
            pdf.move_down 1
            pdf.font("Helvetica") do
              pdf.text "#{l(photo.taken_at, :format => :long_tz) if(photo.taken_at)} Dir=#{photo.image_direction_heading} Lat=#{photo.latitude_rounded} Lon=#{photo.longitude_rounded} Alt=#{photo.altitude_feet}ft MSL WGS-84", :color => "ffffff", :size => 5, :align => :center
            end
            pdf.move_down 3
            pdf.text_box "Photo #{index + 1}: #{photo.caption}", :at => [0, pdf.cursor], :width => pdf.bounds.width, :overflow => :shrink_to_fit
          end
        end
      end

      pdf.page_count.times do |i|
        pdf.go_to_page(i + 1)
        pdf.bounding_box([0, footer_height], :width => pdf.bounds.width, :height => footer_height) do
          pdf.define_grid(:columns => 12, :rows => 1, :gutter => 10)

          pdf.grid([0, 2], [0, 9]).bounding_box do
            pdf.move_down 8
            pdf.text "<b>#{@report.property_name.upcase}</b> PROPERTY 2016 MONITORING PHOTOS", :align => :center, :inline_format => true
          end

          pdf.grid([0, 10], [0, 11]).bounding_box do
            pdf.move_down 8
            pdf.text "#{i + 1} of #{pdf.page_count}", :align => :right
          end
        end
      end
    end

    send_data(pdf.render, :type => :pdf)
  end

  private

  def extract_zip(upload)
    coder = HTMLEntities.new
    Zip::File.open(upload.tempfile) do |zip_file|
      doc = REXML::Document.new(zip_file.glob("doc.kml").first.get_input_stream.read)
      zip_file.glob("files/*.jpg").each do |file|
        description = doc.elements.to_a("/kml/Document/Placemark/description").find do |description|
          description.text.include?(file.name)
        end

        description = REXML::Document.new("<root>#{description.text}</root>")
        subtitle = coder.decode(description.elements["//div[@id='com.miocool.mapplus.subtitle']"].text.strip)

        begin
          image = Tempfile.new
          image.binmode
          image.write(file.get_input_stream.read)
          image.rewind

          exif = EXIFR::JPEG.new(image)
          image.rewind

          @uploads << {
            :image => Base64.encode64(image.read),
            :name => File.basename(file.name),
            :caption => subtitle,
            :exif => exif,
          }
        ensure
          image.close
        end
      end
    end
  end

  def extract_jpg(upload)
    exif = EXIFR::JPEG.new(upload.tempfile)
    upload.tempfile.rewind

    @uploads << {
      :image => Base64.encode64(upload.tempfile.read),
      :name => File.basename(upload.original_filename),
      :caption => "",
      :exif => exif,
    }
  end

  private

  def save!
    @report.assign_attributes(report_params)
    @report.save!
  end

  def report_params
    params.require(:report).permit([
      :property_name,
      :monitoring_year,
      :photographer_name,
      { :upload_uuids => [] },
      {
        :photos_attributes => [
          :id,
          :caption,
          :_destroy,
        ],
      }
    ])
  end
end
