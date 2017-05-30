class ReportsController < ApplicationController
  def index
    @reports = Report.order(:created_at => :desc).all
  end

  def show
    @report = Report.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render :json => @report }
    end
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
    if(params[:new_uploads])
      flash.now[:notice] = "New photos added. Update captions below."
    end

    @report = Report.find(params[:id])
  end

  def update
    @report = Report.find(params[:id])
    save!
    @report.reload
    if(@report.upload_progress == "pending")
      redirect_to(edit_report_path(@report))
    else
      flash[:notice] = "Successfully saved changes."
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
      photo_aspect_ratio = 4.0 / 3.0
      signature_margin = 2

      header_signature_height = 12
      header_font_size = 8
      header_padding = 8
      header_height = header_signature_height + signature_margin + (header_font_size * 2) + header_padding

      footer_signature_height = 24
      footer_font_size = 8
      footer_padding = 8
      if(@report.extra_signatures.present?)
        footer_height = (footer_signature_height + signature_margin + footer_font_size) * @report.extra_signatures.length
      else
        footer_height = footer_font_size + footer_padding
      end

      pdf.font "Times-Roman"
      pdf.font_size 10
      pdf.line_width = 0.5

      photo_num = 1
      @report.photos.in_groups_of(6, false).each_with_index do |page_photos, page_index|
        pdf.start_new_page if(page_index > 0)

        pdf.bounding_box([0, pdf.bounds.height], :width => pdf.bounds.width, :height => header_height) do
          pdf.font_size header_font_size
          pdf.define_grid(:columns => 12, :rows => 1, :row_gutter => 0, :column_gutter => 10)

          pdf.grid([0, 0], [0, 3]).bounding_box do
            pdf.move_down header_signature_height
            pdf.stroke_horizontal_rule
            pdf.move_down signature_margin
            pdf.text "Signature of photographer", :single_line => true, :overflow => :shrink_to_fit
            pdf.text "#{@report.photographer_name}, SAHC", :single_line => true, :overflow => :shrink_to_fit
          end

          pdf.grid([0, 4], [0, 5]).bounding_box do
            pdf.move_down header_signature_height
            pdf.stroke_horizontal_rule
            pdf.move_down signature_margin
            pdf.text "Date"
          end

          pdf.grid([0, 6], [0, 11]).bounding_box do
            photo_dates = @report.photo_dates
            if(photo_dates.length == 1)
              pdf.text "All photos taken on #{l(photo_dates.keys.first, :format => :short)}", :align => :right
            else
              date_texts = []
              photo_dates.each do |date, range|
                date_texts << "Photos #{range.first}-#{range.last} taken on #{l(date, :format => :short)}"
              end
              pdf.text date_texts.join("\n"), :align => :right, :overflow => :shrink_to_fit
            end
          end
        end

        puts "HEIGHT: #{pdf.bounds.height.inspect}"
        pdf.bounding_box([0, pdf.bounds.height - header_height], :width => pdf.bounds.width, :height => pdf.bounds.height - (header_height + footer_height)) do
          pdf.font_size 10

          cols = 3
          pdf.define_grid(:columns => cols, :rows => 2, :gutter => 10)
          page_photos.each_with_index do |photo, index|
            row = (index / cols.to_f).floor
            col = index % cols

            pdf.grid(row, col).bounding_box do
              if(photo.image? && photo.image.file.last_modified)
                puts "HEIGHT: #{pdf.bounds.height.inspect}"
                pdf.image photo.image.default.file.to_tempfile, :fit => [pdf.bounds.width, pdf.bounds.width / photo_aspect_ratio], :position => :center
              end
              pdf.rectangle [0, pdf.cursor], pdf.bounds.width, 6
              pdf.fill
              pdf.move_down 1
              pdf.font("Helvetica") do
                pdf.text "#{l(photo.taken_at, :format => :long_tz) if(photo.taken_at)} Lat=#{photo.latitude_rounded} Lon=#{photo.longitude_rounded} Alt=#{photo.altitude_feet}ft MSL WGS-84", :color => "ffffff", :size => 5, :align => :center
              end
              pdf.move_down 3
              pdf.text_box "Photo #{photo_num}: #{photo.caption_cleaned}", :at => [0, pdf.cursor], :width => pdf.bounds.width, :overflow => :shrink_to_fit
            end

            photo_num += 1
          end
        end
      end

      pdf.page_count.times do |i|
        pdf.go_to_page(i + 1)
        pdf.bounding_box([0, footer_height], :width => pdf.bounds.width, :height => footer_height) do
          pdf.font_size footer_font_size

          rows = 1
          property_name_column = 1
          property_name_padding = footer_padding
          if(@report.extra_signatures.present?)
            rows = @report.extra_signatures.length
            property_name_column = 6
            property_name_padding = footer_signature_height + signature_margin
          end
          last_row = rows - 1
          pdf.define_grid(:columns => 12, :rows => rows, :row_gutter => 0, :column_gutter => 10)

          if(@report.extra_signatures.present?)
            @report.extra_signatures.each_with_index do |extra_signature, row|
              pdf.grid([row, 0], [row, 3]).bounding_box do
                pdf.move_down footer_signature_height
                pdf.stroke_horizontal_rule
                pdf.move_down signature_margin
                pdf.text extra_signature, :single_line => true, :overflow => :shrink_to_fit
              end

              pdf.grid([row, 4], [row, 5]).bounding_box do
                pdf.move_down footer_signature_height
                pdf.stroke_horizontal_rule
                pdf.move_down signature_margin
                pdf.text "Date"
              end
            end
          end

          pdf.grid([last_row, property_name_column], [last_row, 10]).bounding_box do
            pdf.move_down property_name_padding
            pdf.text "<b>#{@report.property_name.upcase}</b> PROPERTY 2016 #{@report.type.upcase} PHOTOS", :align => :center, :inline_format => true, :single_line => true, :overflow => :shrink_to_fit
          end

          pdf.grid([last_row, 11], [last_row, 11]).bounding_box do
            pdf.move_down property_name_padding
            pdf.text "#{i + 1} of #{pdf.page_count}", :align => :right
          end
        end
      end
    end

    send_data(pdf.render, :type => :pdf)
  end

  private

  def save!
    @report.assign_attributes(report_params)
    @report.save!
  end

  def report_params
    params.require(:report).permit([
      :type,
      :property_name,
      :monitoring_year,
      :photographer_name,
      { :extra_signatures => [] },
      { :upload_uuids => [] },
      {
        :photos_attributes => [
          :id,
          :caption,
          :upload_uuid,
          :_destroy,
        ],
      }
    ])
  end
end
