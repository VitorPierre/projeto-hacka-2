module ApplicationHelper
  def user_avatar(user, size: "w-10 h-10", text_size: "text-sm")
    if user.avatar.attached?
      image_tag user.avatar, class: "#{size} rounded-full object-cover border border-aprende-secondary"
    else
      content_tag :div, class: "#{size} bg-aprende-bg rounded-full flex items-center justify-center text-aprende-primary font-bold border border-aprende-secondary" do
        content_tag :span, user.name&.first&.upcase || "?", class: text_size
      end
    end
  end

  def user_preferences_display(user, truncated: false)
    if user.preferences.present?
      text = truncated ? truncate(user.preferences, length: 120) : user.preferences
      "\"#{text}\""
    else
      "Este usuário ainda não informou seus objetivos/preferências."
    end
  end

  def format_ai_response(text)
    return "" if text.blank?

    # 1. Escape HTML for absolute security against malicious injection
    escaped = ERB::Util.html_escape(text).to_s

    # 2. Parse inline styles (bold, italic)
    escaped.gsub!(/\*\*(.*?)\*\*/, '<strong class="font-bold text-aprende-text">\1</strong>')
    escaped.gsub!(/\*(.*?)\*/, '<em class="italic text-aprende-text">\1</em>')

    # 3. Line-by-line stateful parsing to group structures correctly
    lines = escaped.split(/\r?\n/)
    html_blocks = []
    
    current_type = nil # can be: nil, :paragraph, :ul, :ol
    accumulated_lines = []

    # Helper to flush the active block to the HTML blocks array
    flush_block = lambda do
      return if accumulated_lines.empty?

      case current_type
      when :paragraph
        para_text = accumulated_lines.join(" ")
        html_blocks << "<p class=\"text-aprende-text leading-relaxed mb-4 last:mb-0\">#{para_text}</p>"
      when :ul
        items_html = accumulated_lines.map { |item| "<li class=\"text-aprende-text leading-relaxed\">#{item}</li>" }.join
        html_blocks << "<ul class=\"list-disc pl-6 mb-4 flex flex-col gap-1.5\">#{items_html}</ul>"
      when :ol
        items_html = accumulated_lines.map { |item| "<li class=\"text-aprende-text leading-relaxed\">#{item}</li>" }.join
        html_blocks << "<ol class=\"list-decimal pl-6 mb-4 flex flex-col gap-1.5\">#{items_html}</ol>"
      end

      accumulated_lines = []
      current_type = nil
    end

    lines.each do |line|
      stripped = line.strip

      if stripped.blank?
        flush_block.call
        next
      end

      # Headers
      if stripped.start_with?("### ")
        flush_block.call
        title = stripped.sub("### ", "")
        html_blocks << "<h4 class=\"text-base font-bold text-aprende-text mt-4 mb-2 first:mt-0\">#{title}</h4>"
      elsif stripped.start_with?("## ")
        flush_block.call
        title = stripped.sub("## ", "")
        html_blocks << "<h3 class=\"text-lg font-bold text-aprende-text mt-6 mb-3 first:mt-0\">#{title}</h3>"
      elsif stripped.start_with?("# ")
        flush_block.call
        title = stripped.sub("# ", "")
        html_blocks << "<h2 class=\"text-xl font-bold text-aprende-text mt-6 mb-3 first:mt-0\">#{title}</h2>"

      # Unordered Lists
      elsif stripped.match?(/^[\-\*]\s+(.*)/)
        item_text = stripped.sub(/^[\-\*]\s+/, "")
        if current_type != :ul
          flush_block.call
          current_type = :ul
        end
        accumulated_lines << item_text

      # Ordered Lists
      elsif stripped.match?(/^\d+\.\s+(.*)/)
        item_text = stripped.sub(/^\d+\.\s+/, "")
        if current_type != :ol
          flush_block.call
          current_type = :ol
        end
        accumulated_lines << item_text

      # Regular paragraph lines
      else
        if current_type == :ul || current_type == :ol
          if line.start_with?(" ")
            accumulated_lines[-1] = "#{accumulated_lines[-1]} #{stripped}"
          else
            flush_block.call
            current_type = :paragraph
            accumulated_lines << stripped
          end
        else
          if current_type != :paragraph
            flush_block.call
            current_type = :paragraph
          end
          accumulated_lines << stripped
        end
      end
    end

    flush_block.call

    html_blocks.join("\n").html_safe
  end
end

