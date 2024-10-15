require 'gtk3'
require_relative 'database'
require_relative 'auth'
require_relative 'modules/gui_utils'

class GUI
  include GuiUtils

  def initialize(db)
    @window = Gtk::Window.new("Телефоны ОАО \"Обеспечение РФЯЦ-ВНИИЭФ\" и ДЗО")
    @window.set_default_size(800, 400)
    @window.set_border_width(10)
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
      address: Gtk::Entry.new,
      office_mobile: Gtk::Entry.new,
      home_phone: Gtk::Entry.new
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
      address: "Адрес установки",
      office_mobile: "Служ. моб.",
      home_phone: "Дом. тел."
    }

    row = 0
    # Create moderator buttons (Save and Delete for admin)
    save_button = Gtk::Button.new(label: "Сохранить")
    delete_button = Gtk::Button.new(label: "Удалить")
    create_button = Gtk::Button.new(label: "+")

    save_button.sensitive = false
    delete_button.sensitive = false # Only admins can delete
    create_button.sensitive = false

    # Create a box for the buttons
    hbox_buttons = Gtk::Box.new(:horizontal, 10)
    hbox_buttons.pack_start(save_button, expand: true, fill: true, padding: 10)
    hbox_buttons.pack_start(delete_button, expand: true, fill: true, padding: 10)
    hbox_buttons.pack_start(create_button, expand: true, fill: true, padding: 10)

    grid.attach(hbox_buttons, 0, row, 2, 1)

    row += 1

    details_fields.each do |label_text, widget|
      localized_label = dictionary[label_text]
      label = Gtk::Label.new(localized_label.to_s)
      widget.editable = false
      widget.can_focus = false
      grid.attach(label, 0, row, 1, 1)
      grid.attach(widget, 1, row, 1, 1)
      row += 1
    end

    # Add event listener for the delete button (Admins only)
    delete_button.signal_connect("clicked") { delete_entry }

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

    # Photo placeholder
    # Create an EventBox to wrap the photo_box
    @photo_event_box = Gtk::EventBox.new

    # Photo placeholder (DrawingArea)
    @photo_box = Gtk::DrawingArea.new
    @photo_box.set_size_request(100, 150)
    @photo_box.override_background_color(:normal, Gdk::RGBA.new(0.9, 0.9, 0.9, 1))

    # Draw the placeholder cross
    @photo_box.signal_connect "draw" do
      cr = @photo_box.window.create_cairo_context
      cr.set_source_rgb(0.6, 0.6, 0.6)
      cr.move_to(0, 0)
      cr.line_to(100, 150)
      cr.move_to(100, 0)
      cr.line_to(0, 150)
      cr.stroke
    end

    # Add photo_box to the EventBox
    @photo_event_box.add(@photo_box)

    # Organize the main layout
    hbox.pack_start(vbox_left, expand: false, fill: false, padding: 10)
    hbox.pack_start(grid, expand: true, fill: true, padding: 10)
    hbox.pack_start(@photo_event_box, expand: false, fill: false, padding: 10)

    phone_entries = []
    i = 0
    # Create a scrollable area for phone entries
    scrolled_window = Gtk::ScrolledWindow.new
    scrolled_window.set_policy(:automatic, :automatic)
    scrolled_window.set_min_content_height(100) # Adjust this value for the desired height
    scrolled_window.set_min_content_width(800) # Adjust this value for the desired width

    # Create a box to hold the dynamic entries for phone numbers
    phones_vbox = Gtk::Box.new(:vertical, 5)

    10.times do
      phone_entries.append([Gtk::Entry.new, Gtk::Entry.new, Gtk::Entry.new, Gtk::Entry.new])
      row_box = Gtk::Box.new(:horizontal, 10)
      row_box.pack_start(phone_entries[i][0], expand: true, fill: true, padding: 5)
      row_box.pack_start(phone_entries[i][1], expand: true, fill: true, padding: 5)
      row_box.pack_start(phone_entries[i][2], expand: true, fill: true, padding: 5)
      row_box.pack_start(phone_entries[i][3], expand: true, fill: true, padding: 5)

      phones_vbox.pack_start(row_box, expand: false, fill: false, padding: 5)
      i += 1
    end

    phone_entries.each do |entry_set|
      entry_set.each do |entry|
        entry.editable = false
        entry.can_focus = false
      end
    end

    # Add the vbox containing entries to the scrolled window
    scrolled_window.add(phones_vbox)

    # Add the scrolled window to the main grid
    grid.attach(scrolled_window, 1, row, 4, 1) # Attach across 4 columns
    row += 1

    grid.show_all

    @auth = Auth.new(db, details_fields, phone_entries, save_button, delete_button, create_button)

    super(department_combo,
          lab_combo,
          subdivision_combo,
          enterprise_combo,
          search_button,
          details_fields,
          fio_entry,
          work_phone_entry,
          phone_entries,
          @photo_event_box,
          db
    )

    # Add event listener for the save button
    save_button.signal_connect("clicked") do
      save_changes(details_fields, phone_entries, @auth.role)
      enterprises = db.search_by("enterprise").append("")
      enterprise_combo.remove_all
      enterprises.each { |enterprise| enterprise_combo.append_text(enterprise) }
    end
    create_button.signal_connect("clicked") do
      create_new_user(details_fields, phone_entries, @auth.role)
      @id = 0
    end

    @window.signal_connect("key_press_event") { |widget, event| @auth.on_key_press(widget, event) }
    @window.add(hbox)
    @window.signal_connect("destroy") { Gtk.main_quit }
  end

  public

  def run
    @window.show_all
    Gtk.main
  end
end