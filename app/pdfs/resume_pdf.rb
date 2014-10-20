class ResumePdf 
    include Prawn::View
    
  def initialize(profile)
    super()
    @profile = profile
    font "Times-Roman"
    text_content
  end

  PAD_SPACE = 10

  def start_end_helper(item)
    unless item["start_date"]["month"].nil?
      start_month = item["start_date"]["month"].to_s + " / "
    else
      start_month = ""
    end

    start_date= start_month+ item["start_date"]["year"].to_s

    if item["is_current"]
      end_date = "Present"
    else
      unless item["end_date"]["month"].nil?
        end_month = item["end_date"]["month"].to_s  + " / " 
      else
        end_month = ""
      end
      end_date= end_month + item["end_date"]["year"].to_s
    end
    return start_date + " - "+ end_date
  end

  def text_content
    text @profile["first_name"]+" "+@profile["last_name"], size: 24, style: :bold
    pad(PAD_SPACE) {
      text @profile["email_address"], size: 12

      unless @profile["member_url_resources"]["all"].nil?
        @profile["member_url_resources"]["all"].map do |item|
          text item["url"], size: 12
        end
      end
      }

    unless @profile["educations"].nil?
      text "Education", size: 16, style: :bold
      @profile["educations"]["all"].map do |item|
        pad(PAD_SPACE){
          text item["school_name"], size: 14
          pieces = ["degree", "field_of_study"]
          pieces.each do |p|
            unless item[p].nil?
              text item[p], size: 12
            end
          end
          text start_end_helper(item), size: 12
          }
      end
    end

    unless @profile["positions"].nil?
      text "Positions", size: 16, style: :bold
      @profile["positions"]["all"].map do |item|
        pad(PAD_SPACE){
          text item["title"] + " - " + item["company"]["name"], size: 14
          text start_end_helper(item), size: 12
          text item["summary"], size: 10
          }
      end
    end

    unless @profile["projects"].nil?
      text "Projects", size: 16, style: :bold
      @profile["projects"]["all"].map do |item|
        pad(PAD_SPACE){
          text item["name"], size: 14
          text item["url"], size: 12
          text item["description"], size: 10
          }
      end
    end

    unless @profile["skills"].nil?
      text "Skills", size: 16, style: :bold
      @profile["skills"]["all"].map do |item|
        text item["skill"]["name"], size: 12
      end
    end
  end
end
