require "rexml/document"

class ReportsController < ApplicationController
  def new
  end

  def upload
    @uploads = []
    params[:uploads].each do |upload|
      case(File.extname(upload.original_filename))
      when ".kmz"
        extract_zip(upload)
      when ".jpg"
        extract_jpg(upload)
      else
        raise "Unknown extension"
      end
    end
  end

  def create
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
          pdf.text "#{params[:photographer]}, SAHC"
        end

        pdf.grid([0, 4], [0, 5]).bounding_box do
          pdf.move_down 12
          pdf.stroke_horizontal_rule
          pdf.move_down 2
          pdf.text "Date"
        end

        pdf.grid([0, 6], [0, 11]).bounding_box do
          pdf.text "All photos taken on 01/28/2016", :align => :right
          pdf.text "unless otherwise noted", :align => :right
        end
      end

      pdf.bounding_box([0, pdf.bounds.height - header_height], :width => pdf.bounds.width, :height => pdf.bounds.height - (header_height + footer_height)) do
        cols = 3
        pdf.define_grid(:columns => cols, :rows => 2, :gutter => 10)
        params[:uploads].each_with_index do |(id, upload), index|
          row = (index / cols.to_f).floor
          col = index % cols

          pdf.grid(row, col).bounding_box do
            pdf.image StringIO.new(Base64.decode64(upload[:image])), :width => pdf.bounds.width
            pdf.rectangle [0, pdf.cursor], pdf.bounds.width, 6
            pdf.fill
            pdf.move_down 1
            pdf.font("Helvetica") do
              pdf.text "1/28/2016 10:34:12 AM (-5.0 hrs) Dir=WSW Lat=35.59554 Lon=-82.78207 Alt=3852ft MSL WGS-84", :color => "ffffff", :size => 5, :align => :center
            end
            pdf.move_down 3
            pdf.text_box "Photo #{index + 1}: #{upload[:caption]}", :at => [0, pdf.cursor], :width => pdf.bounds.width, :overflow => :shrink_to_fit
          end
        end
      end

      pdf.page_count.times do |i|
        pdf.go_to_page(i + 1)
        pdf.bounding_box([0, footer_height], :width => pdf.bounds.width, :height => footer_height) do
          pdf.define_grid(:columns => 12, :rows => 1, :gutter => 10)

          pdf.grid([0, 2], [0, 9]).bounding_box do
            pdf.move_down 8
            pdf.text "<b>#{params[:property].upcase}</b> PROPERTY 2016 MONITORING PHOTOS", :align => :center, :inline_format => true
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
end
