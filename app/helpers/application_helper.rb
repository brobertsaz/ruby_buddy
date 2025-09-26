module ApplicationHelper
  def display_name(user)
    user&.profile&.name.presence || user&.email
  end

  def user_initials(user)
    name = display_name(user).to_s
    parts = name.split(/\s+/)
    if parts.length >= 2
      (parts[0][0].to_s + parts[1][0].to_s).upcase
    else
      name[0, 2].to_s.upcase
    end
  end

  def avatar_color_class(user)
    palette = %w[bg-rose-500 bg-emerald-500 bg-indigo-500 bg-amber-500 bg-fuchsia-500 bg-teal-500]
    idx = (user&.id.to_i % palette.length)
    palette[idx]
  end

  # UI Helper Methods
  def section_container(**options)
    classes = "space-y-6 #{options[:class]}"
    content_tag :section, class: classes do
      yield
    end
  end

  def button_primary(text, path = nil, **options)
    classes = "inline-flex items-center gap-2 rounded-lg bg-rose-600 px-4 py-3 text-white font-semibold hover:bg-rose-700 transition-colors shadow-lg #{options[:class]}"

    if path
      link_to text, path, class: classes, **options.except(:class)
    else
      content_tag :button, text, class: classes, **options.except(:class)
    end
  end

  def button_secondary(text, path = nil, **options)
    classes = "inline-flex items-center gap-2 rounded-lg bg-zinc-700 px-4 py-3 text-white font-semibold border border-zinc-600 hover:bg-zinc-600 transition-colors shadow-sm #{options[:class]}"

    if path
      link_to text, path, class: classes, **options.except(:class)
    else
      content_tag :button, text, class: classes, **options.except(:class)
    end
  end

  def button_danger(text, path = nil, **options)
    classes = "inline-flex items-center gap-2 rounded-lg bg-red-600 px-4 py-3 text-white font-semibold hover:bg-red-700 transition-colors shadow-lg #{options[:class]}"

    if path
      link_to text, path, class: classes, **options.except(:class)
    else
      content_tag :button, text, class: classes, **options.except(:class)
    end
  end

  def status_badge(text, type = :default)
    case type
    when :mentor
      classes = "inline-flex items-center rounded-full bg-rose-600 px-3 py-1 text-xs font-bold text-white shadow-lg"
    when :mentee
      classes = "inline-flex items-center rounded-full bg-blue-600 px-3 py-1 text-xs font-bold text-white shadow-lg"
    when :skill
      classes = "inline-flex items-center rounded-full bg-rose-600 text-white text-xs px-3 py-1 shadow-md font-bold"
    when :success
      classes = "inline-flex items-center rounded-full bg-green-600 px-3 py-1 text-xs font-bold text-white shadow-lg"
    when :warning
      classes = "inline-flex items-center rounded-full bg-yellow-600 px-3 py-1 text-xs font-bold text-white shadow-lg"
    when :danger
      classes = "inline-flex items-center rounded-full bg-red-600 px-3 py-1 text-xs font-bold text-white shadow-lg"
    else
      classes = "inline-flex items-center rounded-full bg-zinc-600 px-3 py-1 text-xs font-bold text-white shadow-lg"
    end

    content_tag :span, text, class: classes
  end

  def empty_state(message, icon = "📭")
    content_tag :div, class: "text-center my-12 py-8" do
      content_tag(:div, icon, class: "text-4xl mb-4") +
      content_tag(:p, message, class: "text-zinc-600 font-medium text-lg")
    end
  end

  def responsive_grid(**options)
    classes = "grid sm:grid-cols-2 lg:grid-cols-3 gap-6 #{options[:class]}"
    content_tag :div, class: classes do
      yield
    end
  end
end
