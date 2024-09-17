require 'gtk3'

class GUI
  def initialize
    @window = Gtk::Window.new("Телефоны ОАО \"Обеспечение РФЯЦ-ВНИИЭФ\" и ДЗО")
    @window.set_default_size(800, 400)
    @window.set_border_width(10)

    # Main layout container (Horizontal Box)
    hbox = Gtk::Box.new(:horizontal, 10)

    # Left side (Search Section)
    vbox_left = Gtk::Box.new(:vertical, 5)

    # Search Fields
    search_label = Gtk::Label.new("Поиск")
    vbox_left.pack_start(search_label, expand: false, fill: false, padding: 10)

    enterprise_combo = Gtk::ComboBoxText.new
    enterprise_combo.append_text("Предприятие")
    vbox_left.pack_start(enterprise_combo, expand: false, fill: false, padding: 10)

    subdivision_combo = Gtk::ComboBoxText.new
    subdivision_combo.append_text("Подразделение")
    vbox_left.pack_start(subdivision_combo, expand: false, fill: false, padding: 10)

    department_combo = Gtk::ComboBoxText.new
    department_combo.append_text("Отдел/Группа")
    vbox_left.pack_start(department_combo, expand: false, fill: false, padding: 10)

    lab_combo = Gtk::ComboBoxText.new
    lab_combo.append_text("Лаборатория")
    vbox_left.pack_start(lab_combo, expand: false, fill: false, padding: 10)

    fio_entry = Gtk::Entry.new
    fio_entry.set_placeholder_text("ФИО")
    vbox_left.pack_start(fio_entry, expand: false, fill: false, padding: 10)

    work_phone_entry = Gtk::Entry.new
    work_phone_entry.set_placeholder_text("Служебный телефон")
    vbox_left.pack_start(work_phone_entry, expand: false, fill: false, padding: 10)

    search_button = Gtk::Button.new(label: "Поиск")
    vbox_left.pack_start(search_button, expand: false, fill: false, padding: 10)

    # Right side (Details Section)
    grid = Gtk::Grid.new
    grid.column_spacing = 10
    grid.row_spacing = 5

    # Labels and entries for right side fields
    details_fields = {
      "Предприятие" => Gtk::Entry.new,
      "Подразделение" => Gtk::Entry.new,
      "Отдел/Группа" => Gtk::Entry.new,
      "Лаборатория" => Gtk::Entry.new,
      "ФИО/Служба" => Gtk::Entry.new,
      "Должность" => Gtk::Entry.new
    }

    row = 0
    details_fields.each do |label_text, widget|
      label = Gtk::Label.new(label_text)
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

    # Add additional fields below the table
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

    # Add the photo placeholder
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

    # Organize everything in the main layout
    hbox.pack_start(vbox_left, expand: false, fill: false, padding: 10)
    hbox.pack_start(grid, expand: true, fill: true, padding: 10)
    hbox.pack_start(photo_box, expand: false, fill: false, padding: 10)

    @window.add(hbox)

    @window.signal_connect("destroy") { Gtk.main_quit }
  end

  def run
    @window.show_all
    Gtk.main
  end
end