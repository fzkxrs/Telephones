require 'gtk3'

class GUI
  def initialize
    @window = Gtk::Window.new("Телефоны ОАО")
    @window.set_default_size(800, 600)
    @window.signal_connect("destroy") { Gtk.main_quit }

    # Create a grid layout for the entire window
    grid = Gtk::Grid.new
    @window.add(grid)

    # Create Menu bar
    create_menu_bar(grid)

    # Create the left side (search section)
    create_search_panel(grid)

    # Create the right side (details section)
    create_details_panel(grid)

    @window.show_all
  end

  def create_menu_bar(grid)
    menu_bar = Gtk::MenuBar.new
    file_menu = Gtk::Menu.new
    phone_menu = Gtk::Menu.new

    file_item = Gtk::MenuItem.new(label: "File")
    phone_item = Gtk::MenuItem.new(label: "Phone")

    file_item.set_submenu(file_menu)
    phone_item.set_submenu(phone_menu)

    menu_bar.append(file_item)
    menu_bar.append(phone_item)

    grid.attach(menu_bar, 0, 0, 2, 1)
  end

  def create_search_panel(grid)
    vbox_left = Gtk::Box.new(:vertical, 10)
    frame = Gtk::Frame.new("Поиск")
    frame.add(vbox_left)

    # Предприятие (Company)
    vbox_left.pack_start(Gtk::Label.new("Предприятие:"), expand: false, fill: false, padding: 5)
    @company_combo = Gtk::ComboBoxText.new
    @company_combo.append_text("Company A")
    @company_combo.append_text("Company B")
    vbox_left.pack_start(@company_combo, expand: false, fill: false, padding: 5)

    # Подразделение (Department)
    vbox_left.pack_start(Gtk::Label.new("Подразделение:"), expand: false, fill: false, padding: 5)
    @department_combo = Gtk::ComboBoxText.new
    @department_combo.append_text("Department 1")
    @department_combo.append_text("Department 2")
    vbox_left.pack_start(@department_combo, expand: false, fill: false, padding: 5)

    # Отдел/Группа (Group)
    vbox_left.pack_start(Gtk::Label.new("Отдел/Группа:"), expand: false, fill: false, padding: 5)
    @group_entry = Gtk::Entry.new
    vbox_left.pack_start(@group_entry, expand: false, fill: false, padding: 5)

    # Лаборатория (Lab)
    vbox_left.pack_start(Gtk::Label.new("Лаборатория:"), expand: false, fill: false, padding: 5)
    @lab_entry = Gtk::Entry.new
    vbox_left.pack_start(@lab_entry, expand: false, fill: false, padding: 5)

    # ФИО (Full Name)
    vbox_left.pack_start(Gtk::Label.new("ФИО:"), expand: false, fill: false, padding: 5)
    @name_entry = Gtk::Entry.new
    vbox_left.pack_start(@name_entry, expand: false, fill: false, padding: 5)

    # Служебный телефон (Work Phone)
    vbox_left.pack_start(Gtk::Label.new("Служебный телефон:"), expand: false, fill: false, padding: 5)
    @phone_entry = Gtk::Entry.new
    vbox_left.pack_start(@phone_entry, expand: false, fill: false, padding: 5)

    # Search Button
    search_button = Gtk::Button.new(label: "Поиск")
    search_button.signal_connect "clicked" do
      # Add search functionality here
    end
    vbox_left.pack_start(search_button, expand: false, fill: false, padding: 10)

    grid.attach(frame, 0, 1, 1, 1)
  end

  def create_details_panel(grid)
    vbox_right = Gtk::Box.new(:vertical, 10)
    frame = Gtk::Frame.new
    frame.add(vbox_right)

    # Предприятие (Company)
    vbox_right.pack_start(Gtk::Label.new("Предприятие:"), expand: false, fill: false, padding: 5)
    @company_details = Gtk::Entry.new
    vbox_right.pack_start(@company_details, expand: false, fill: false, padding: 5)

    # Подразделение (Department)
    vbox_right.pack_start(Gtk::Label.new("Подразделение:"), expand: false, fill: false, padding: 5)
    @department_details = Gtk::Entry.new
    vbox_right.pack_start(@department_details, expand: false, fill: false, padding: 5)

    # Other fields...
    fields = ["Отдел/Группа", "Лаборатория", "ФИО/Служба", "Должность"]
    fields.each do |field|
      vbox_right.pack_start(Gtk::Label.new("#{field}:"), expand: false, fill: false, padding: 5)
      vbox_right.pack_start(Gtk::Entry.new, expand: false, fill: false, padding: 5)
    end

    # Telephone/Fax Table
    table = Gtk::Grid.new
    table.set_column_spacing(5)
    vbox_right.pack_start(table, expand: false, fill: false, padding: 5)

    ["Телефон", "Факс", "Модем", "М/г"].each_with_index do |label, index|
      table.attach(Gtk::Label.new(label), index, 0, 1, 1)
      table.attach(Gtk::Entry.new, index, 1, 1, 1)
    end

    grid.attach(frame, 1, 1, 1, 1)
  end

  def run
    Gtk.main
  end
end