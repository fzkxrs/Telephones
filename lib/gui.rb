require 'gtk3'
require_relative './database'

class GUI
  def initialize(db)
    @window = Gtk::Window.new("Телефоны ОАО \"Обеспечение РФЯЦ-ВНИИЭФ\" и ДЗО")
    @window.set_default_size(800, 400)
    @window.set_border_width(10)
    @window.set_margin_top(10)
    @window.set_margin_bottom(10)
    @window.set_margin_start(10)
    @window.set_margin_end(10)
    @db = db

    # Main layout container (Horizontal Box)
    hbox = Gtk::Box.new(:horizontal, 10)

    # Left side (Search Section)
    vbox_left = Gtk::Box.new(:vertical, 5)

    # Search Fields Label
    search_label = Gtk::Label.new("Поиск")
    vbox_left.pack_start(search_label, expand: false, fill: false, padding: 10)

    # Enterprise Label and ComboBox
    enterprise_label = Gtk::Label.new("Предприятие")
    enterprise_combo = Gtk::ComboBoxText.new
    enterprises = ["Компания A", "Компания B", "Компания C"] # Example values
    enterprises.each { |enterprise| enterprise_combo.append_text(enterprise) }
    vbox_left.pack_start(enterprise_label, expand: false, fill: false, padding: 0)
    vbox_left.pack_start(enterprise_combo, expand: false, fill: false, padding: 10)

    # Subdivision Label and ComboBox
    subdivision_label = Gtk::Label.new("Подразделение")
    subdivision_combo = Gtk::ComboBoxText.new
    subdivisions = ["Подразделение 1", "Подразделение 2", "Подразделение 3"] # Example values
    subdivisions.each { |subdivision| subdivision_combo.append_text(subdivision) }
    vbox_left.pack_start(subdivision_label, expand: false, fill: false, padding: 0)
    vbox_left.pack_start(subdivision_combo, expand: false, fill: false, padding: 10)

    # Department Label and ComboBox
    department_label = Gtk::Label.new("Отдел/Группа")
    department_combo = Gtk::ComboBoxText.new
    departments = ["Отдел 1", "Группа 1", "Отдел 2"] # Example values
    departments.each { |department| department_combo.append_text(department) }
    vbox_left.pack_start(department_label, expand: false, fill: false, padding: 0)
    vbox_left.pack_start(department_combo, expand: false, fill: false, padding: 10)

    # Lab Label and ComboBox
    lab_label = Gtk::Label.new("Лаборатория")
    lab_combo = Gtk::ComboBoxText.new
    labs = ["Лаборатория 1", "Лаборатория 2", "Лаборатория 3"] # Example values
    labs.each { |lab| lab_combo.append_text(lab) }
    vbox_left.pack_start(lab_label, expand: false, fill: false, padding: 0)
    vbox_left.pack_start(lab_combo, expand: false, fill: false, padding: 10)

    # Other fields (FIO, phone number, etc.)
    fio_entry = Gtk::Entry.new
    fio_entry.placeholder_text = "ФИО"
    vbox_left.pack_start(fio_entry, expand: false, fill: false, padding: 10)

    work_phone_entry = Gtk::Entry.new
    work_phone_entry.placeholder_text = "Служебный телефон"
    vbox_left.pack_start(work_phone_entry, expand: false, fill: false, padding: 10)

    search_button = Gtk::Button.new(label: "Поиск")
    vbox_left.pack_start(search_button, expand: false, fill: false, padding: 10)

    # Right side (Details Section)
    grid = Gtk::Grid.new
    grid.column_spacing = 10
    grid.row_spacing = 5

    # Labels and entries for right side fields
    details_fields = {
      "Предприятие": Gtk::Entry.new,
      "Подразделение": Gtk::Entry.new,
      "Отдел/Группа": Gtk::Entry.new,
      "Лаборатория": Gtk::Entry.new,
      "ФИО/Служба": Gtk::Entry.new,
      "Должность": Gtk::Entry.new
    }

    row = 0
    details_fields.each do |label_text, widget|
      label = Gtk::Label.new(label_text)
      widget.editable = false
      widget.can_focus = false
      grid.attach(label, 0, row, 1, 1)
      grid.attach(widget, 1, row, 1, 1)
      row += 1
    end

    # Table for phone numbers
    phone_label = Gtk::Label.new("Телефон")
    fax_label = Gtk::Label.new("Факс")
    modem_label = Gtk::Label.new("Модем")
    mgr_label = Gtk::Label.new("М/г")

    grid.attach(phone_label, 1, row, 1, 1)
    grid.attach(fax_label, 2, row, 1, 1)
    grid.attach(modem_label, 3, row, 1, 1)
    grid.attach(mgr_label, 4, row, 1, 1)
    row += 1

    # Entries for phone numbers (Phone/Fax/Modem/Mgr)
    phone_entry = Gtk::Entry.new
    fax_entry = Gtk::Entry.new
    modem_entry = Gtk::Entry.new
    mgr_entry = Gtk::Entry.new

    grid.attach(phone_entry, 1, row, 1, 1)
    grid.attach(fax_entry, 2, row, 1, 1)
    grid.attach(modem_entry, 3, row, 1, 1)
    grid.attach(mgr_entry, 4, row, 1, 1)
    row += 1

    # Additional fields below the table
    corp_internal_label = Gtk::Label.new("Корп. внутр. тел.")
    corp_internal_entry = Gtk::Entry.new
    grid.attach(corp_internal_label, 0, row, 1, 1)
    grid.attach(corp_internal_entry, 1, row, 1, 1)
    row += 1

    internal_tel_label = Gtk::Label.new("Внутр. тел. по предприятию")
    internal_tel_entry = Gtk::Entry.new
    grid.attach(internal_tel_label, 0, row, 1, 1)
    grid.attach(internal_tel_entry, 1, row, 1, 1)
    row += 1

    email_label = Gtk::Label.new("e-mail")
    email_entry = Gtk::Entry.new
    grid.attach(email_label, 0, row, 1, 1)
    grid.attach(email_entry, 1, row, 1, 1)
    row += 1

    install_address_label = Gtk::Label.new("Адрес установки")
    install_address_entry = Gtk::Entry.new
    grid.attach(install_address_label, 0, row, 1, 1)
    grid.attach(install_address_entry, 1, row, 1, 1)

    # Photo placeholder
    photo_box = Gtk::DrawingArea.new
    photo_box.set_size_request(100, 150)
    photo_box.override_background_color(:normal, Gdk::RGBA.new(0.9, 0.9, 0.9, 1))
    photo_box.signal_connect "draw" do
      cr = photo_box.window.create_cairo_context
      cr.set_source_rgb(0.6, 0.6, 0.6)
      cr.move_to(0, 0)
      cr.line_to(100, 150)
      cr.move_to(100, 0)
      cr.line_to(0, 150)
      cr.stroke
    end

    # Organize the main layout
    hbox.pack_start(vbox_left, expand: false, fill: false, padding: 10)
    hbox.pack_start(grid, expand: true, fill: true, padding: 10)
    hbox.pack_start(photo_box, expand: false, fill: false, padding: 10)

# #{    # Add search button action
#      search_button.signal_connect('clicked') do
#       search = [enterprise_combo.active_text, subdivision_combo.active_text, fio_entry.text]
#       res = db.search_employee(search)
#
#       if res.any?
#         details_fields.each { |key, value| value.text = res[0]['enterprise'] }
#       else
#         puts "No results found"
#       end
#     end
# }
    search_button.signal_connect('clicked') do
      # Gather the search input values from the ComboBoxes and Entries
      fio_value = fio_entry.text.empty? ? nil : fio_entry.text
      enterprise_value = enterprise_combo.active_text == "Предприятие" ? nil : enterprise_combo.active_text
      subdivision_value = subdivision_combo.active_text == "Подразделение" ? nil : subdivision_combo.active_text
      department_value = department_combo.active_text == "Отдел/Группа" ? nil : department_combo.active_text
      lab_value = lab_combo.active_text == "Лаборатория" ? nil : lab_combo.active_text
      position_value = "" # If there's an entry for position, fetch its text or set it to nil
      corp_inner_tel_value = work_phone_entry.text.empty? ? nil : work_phone_entry.text.to_i
      inner_tel_value = nil # Add a field for internal_tel if needed and extract its value

      # Call the search_employee method with the gathered values
      res = @db.search_employee(
        fio_value,
        enterprise_value,
        subdivision_value,
        department_value,
        lab_value,
        position_value,
        corp_inner_tel_value,
        inner_tel_value
      )

      # Populate the details fields with the result if available
      if res.any?
        details_fields["Предприятие"].text = res[0]["enterprise"] || ""
        details_fields["Подразделение"].text = res[0]["department"] || ""
        details_fields["Отдел/Группа"].text = res[0]["group"] || ""
        details_fields["Лаборатория"].text = res[0]["lab"] || ""
        details_fields["ФИО/Служба"].text = res[0]["fio"] || ""
        details_fields["Должность"].text = res[0]["position"] || ""
        # Fill in other fields like phones, fax, etc., based on the result.
      else
        puts "No results found"
      end
    end

    @window.add(hbox)
    @window.signal_connect("destroy") { Gtk.main_quit }
  end

  def run
    @window.show_all
    Gtk.main
  end
end