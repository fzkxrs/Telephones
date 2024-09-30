module GuiUtils
  def initialize(department_combo,
                 lab_combo,
                 subdivision_combo,
                 enterprise_combo,
                 search_button,
                 details_fields,
                 fio_entry,
                 work_phone_entry,
                 grid,
                 row,
                 db
  )
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

      # Clear previous phone/fax/modem/mgr entries if any
      grid.children.each do |child|
        grid.remove(child) if child.is_a?(Gtk::ScrolledWindow)
      end

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

        # Create a scrollable area for phone entries
        scrolled_window = Gtk::ScrolledWindow.new
        scrolled_window.set_policy(:automatic, :automatic)
        scrolled_window.set_min_content_height(100) # Adjust this value for the desired height
        scrolled_window.set_min_content_width(800)  # Adjust this value for the desired width

        # Create a box to hold the dynamic entries for phone numbers
        phones_vbox = Gtk::Box.new(:vertical, 5)

        res.each do |phone_entry_data|
          phone_entry = Gtk::Entry.new
          phone_entry.text = phone_entry_data["phone"].to_s
          fax_entry = Gtk::Entry.new
          fax_entry.text = phone_entry_data["fax"].to_s
          modem_entry = Gtk::Entry.new
          modem_entry.text = phone_entry_data["modem"].to_s
          mgr_entry = Gtk::Entry.new
          mgr_entry.text = phone_entry_data["mg"].to_s

          # Add each set of entries as a row
          row_box = Gtk::Box.new(:horizontal, 10)
          row_box.pack_start(phone_entry, expand: true, fill: true, padding: 5)
          row_box.pack_start(fax_entry, expand: true, fill: true, padding: 5)
          row_box.pack_start(modem_entry, expand: true, fill: true, padding: 5)
          row_box.pack_start(mgr_entry, expand: true, fill: true, padding: 5)

          phones_vbox.pack_start(row_box, expand: false, fill: false, padding: 5)
        end

        # Add the vbox containing entries to the scrolled window
        scrolled_window.add(phones_vbox)

        # Add the scrolled window to the main grid
        grid.attach(scrolled_window, 1, row, 4, 1) # Attach across 4 columns
        row += 1

        grid.show_all  # Update and show everything in the grid
      else
        # Display a message dialog to inform the user
        dialog = Gtk::MessageDialog.new(
          parent: @window,
          flags: :destroy_with_parent,
          type: :info,
          buttons_type: :close,
          message: "Не найдено совпадений по номеру телефона, ФИО или подразделениям"
        )
        dialog.run
        dialog.destroy
      end
    end
  end
end