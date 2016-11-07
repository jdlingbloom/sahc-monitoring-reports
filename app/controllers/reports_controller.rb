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
      header_height = 40
      footer_height = 20

      pdf.font "Times-Roman"
      pdf.font_size 10

      photo_num = 1
      @report.photos.in_groups_of(6, false).each_with_index do |page_photos, page_index|
        pdf.start_new_page if(page_index > 0)

        pdf.bounding_box([0, pdf.bounds.height], :width => pdf.bounds.width, :height => header_height) do
          pdf.define_grid(:columns => 12, :rows => 1, :gutter => 10)

          if(page_index == 0)
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
          end

          pdf.grid([0, 6], [0, 11]).bounding_box do
            pdf.text "All photos taken on #{l(@report.photos_date, :format => :short) if(@report.photos_date)}", :align => :right
            pdf.text "unless otherwise noted", :align => :right
          end
        end

        pdf.bounding_box([0, pdf.bounds.height - header_height], :width => pdf.bounds.width, :height => pdf.bounds.height - (header_height + footer_height)) do
          cols = 3
          pdf.define_grid(:columns => cols, :rows => 2, :gutter => 10)
          page_photos.each_with_index do |photo, index|
            row = (index / cols.to_f).floor
            col = index % cols

            pdf.grid(row, col).bounding_box do
              if(photo.image? && photo.image.file.last_modified)
                pdf.image photo.image.default.file.to_tempfile, :fit => [pdf.bounds.width, pdf.bounds.height - 69.6], :position => :center
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
          :upload_uuid,
          :_destroy,
        ],
      }
    ])
  end
end
