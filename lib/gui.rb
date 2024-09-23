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
    enterprises = db.search_by("enterprise").append("")
    enterprises.each { |enterprise| enterprise_combo.append_text(enterprise) }
    vbox_left.pack_start(enterprise_label, expand: false, fill: false, padding: 0)
    vbox_left.pack_start(enterprise_combo, expand: false, fill: false, padding: 10)

    # Subdivision Label and ComboBox
    subdivision_label = Gtk::Label.new("Подразделение")
    subdivision_combo = Gtk::ComboBoxText.new
    subdivision_combo.sensitive = false # Initially set subdivision combo to insensitive
    vbox_left.pack_start(subdivision_label, expand: false, fill: false, padding: 0)
    vbox_left.pack_start(subdivision_combo, expand: false, fill: false, padding: 10)


    # Department Label and ComboBox
    department_label = Gtk::Label.new("Отдел/Группа")
    department_combo = Gtk::ComboBoxText.new
    department_combo.sensitive = false
    vbox_left.pack_start(department_label, expand: false, fill: false, padding: 0)
    vbox_left.pack_start(department_combo, expand: false, fill: false, padding: 10)

    # Lab Label and ComboBox
    lab_label = Gtk::Label.new("Лаборатория")
    lab_combo = Gtk::ComboBoxText.new
    lab_combo.sensitive = false
    vbox_left.pack_start(lab_label, expand: false, fill: false, padding: 0)
    vbox_left.pack_start(lab_combo, expand: false, fill: false, padding: 10)

    department_combo.signal_connect('changed') do
      lab_combo.remove_all
      # Enable subdivision_combo when an enterprise is selected
      if department_combo.active_text && !department_combo.active_text.empty?
        labs = db.search_by_arg("lab", "department", department_combo.active_text).append("")
        labs.each { |lab| lab_combo.append_text(lab) }
        lab_combo.sensitive = true # Enable the lab combo
      else
        lab_combo.sensitive = false
      end
    end

    subdivision_combo.signal_connect('changed') do
      department_combo.remove_all
      lab_combo.remove_all
      # Enable department_combo when an enterprise is selected
      if subdivision_combo.active_text && !subdivision_combo.active_text.empty?
        departments = db.search_by_arg("department", "subdivision", subdivision_combo.active_text).append("")
        departments.each { |department| department_combo.append_text(department) }
        department_combo.sensitive = true # Enable the department combo
      else
        department_combo.sensitive = false
      end
    end

    enterprise_combo.signal_connect('changed') do
      subdivision_combo.remove_all
      department_combo.remove_all
      lab_combo.remove_all
      # Enable subdivision_combo when an enterprise is selected
      if enterprise_combo.active_text && !enterprise_combo.active_text.empty?
        subdivisions = db.search_by_arg("subdivision", "enterprise", enterprise_combo.active_text).append("")
        subdivisions.each { |subdivision| subdivision_combo.append_text(subdivision) }
        subdivision_combo.sensitive = true # Enable the subdivision combo
      else
        subdivision_combo.sensitive = false
      end
    end

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
      enterprise: Gtk::Entry.new,
      subdivision: Gtk::Entry.new,
      department: Gtk::Entry.new,
      lab: Gtk::Entry.new,
      fio: Gtk::Entry.new,
      position: Gtk::Entry.new,
      corp_inner_tel: Gtk::Entry.new,
      inner_tel: Gtk::Entry.new,
      email: Gtk::Entry.new,
      address: Gtk::Entry.new
    }

    dictionary = {
      enterprise: "Предприятие",
      subdivision: "Департамент",
      department: "Отдел/Группа",
      lab: "Лаборатория",
      fio: "ФИО",
      position: "Должность",
      corp_inner_tel: "Корп. внутр. тел",
      inner_tel: "Внутр. тел. по предприятию",
      email: "E-mail",
      address: "Адрес установки"
    }

    row = 0
    details_fields.each do |label_text, widget|
      localized_label = dictionary[label_text]
      label = Gtk::Label.new(localized_label.to_s)
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

    search_button.signal_connect('clicked') do
      # Gather the search input values from the ComboBoxes and Entries
      fio_value = fio_entry.text.empty? ? nil : fio_entry.text
      enterprise_value = enterprise_combo.active_text == "Предприятие" ? nil : enterprise_combo.active_text
      subdivision_value = subdivision_combo.active_text == "Подразделение" ? nil : subdivision_combo.active_text
      department_value = department_combo.active_text == "Отдел/Группа" ? nil : department_combo.active_text
      lab_value = lab_combo.active_text == "Лаборатория" ? nil : lab_combo.active_text
      position_value = "" # If there's an entry for position, fetch its text or set it to nil
      corp_inner_tel_value = work_phone_entry.text.empty? ? nil : work_phone_entry.text.to_i

      # Call the search_employee method with the gathered values
      res = @db.search_employee(
        enterprise_value,
        subdivision_value,
        department_value,
        lab_value,
        fio_value,
        corp_inner_tel_value
      )

      # Populate the details fields with the result if available
      if res&.any?
        details_fields[:enterprise]&.text = res[0]["enterprise"] || ""
        details_fields[:subdivision]&.text = res[0]["subdivision"] || ""
        details_fields[:department]&.text = res[0]["department"] || ""
        details_fields[:lab]&.text = res[0]["lab"] || ""
        details_fields[:fio]&.text = res[0]["fio"] || ""
        details_fields[:position]&.text = res[0]["position"] || ""
        details_fields[:corp_inner_tel]&.text = res[0]["corp_inner_tel"] || ""
        details_fields[:inner_tel]&.text = res[0]["inner_tel"] || ""
        details_fields[:email]&.text = res[0]["email"] || ""
        details_fields[:address]&.text = res[0]["address"] || ""
        phone_entry.text = res[0]["phone"]
        fax_entry.text = res[0]["fax"]
        modem_entry.text = res[0]["phone"]
        mgr_entry.text = res[0]["phone"]
        # Fill in other fields like phones, fax, etc., based on the result.
      else
        # Display a message dialog to inform the user
        dialog = Gtk::MessageDialog.new(
          parent: @window,
          flags: :destroy_with_parent,
          type: :info,
          buttons_type: :close,
          message: "Не найдено совпадений по номеру телефона, фио или подразделениям"
        )
        dialog.run
        dialog.destroy
      end
    end

    @window.add(hbox)
    @window.signal_connect("destroy") { Gtk.main_quit }
  end

  public

  def run
    @window.show_all
    Gtk.main
  end
end