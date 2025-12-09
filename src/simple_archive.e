note
	description: "Simple TAR archive wrapper for ISE etar library"
	author: "Larry Rix"

class
	SIMPLE_ARCHIVE

create
	make

feature {NONE} -- Initialization

	make
			-- Create archive helper.
		do
			files_added := 0
			files_extracted := 0
		end

feature -- Access

	last_error: detachable STRING
			-- Last error message, if any

	files_added: INTEGER
			-- Number of files added in last create operation

	files_extracted: INTEGER
			-- Number of files extracted in last extract operation

feature -- Archive Creation

	create_archive (a_archive_path: STRING; a_files: ARRAY [STRING])
			-- Create new tar archive at `a_archive_path' containing `a_files'.
		require
			archive_path_not_empty: not a_archive_path.is_empty
			files_not_empty: not a_files.is_empty
		local
			l_archive: ARCHIVE
			l_backend: FILE_STORAGE_BACKEND
			l_path: PATH
			i: INTEGER
		do
			last_error := Void
			files_added := 0

			create l_path.make_from_string (a_archive_path)
			create l_backend.make_from_path (l_path)
			create l_archive.make (l_backend)

			l_archive.open_archive

			from i := a_files.lower until i > a_files.upper loop
				create l_path.make_from_string (a_files.item (i))
				l_archive.add_location (l_path)
				if l_archive.has_error then
					last_error := "Error adding: " + a_files.item (i)
				else
					files_added := files_added + 1
				end
				i := i + 1
			end

			l_archive.finalize
		ensure
			error_or_files_added: last_error /= Void or files_added > 0
		end

	create_archive_from_directory (a_archive_path: STRING; a_directory: STRING)
			-- Create new tar archive containing all files from `a_directory'.
		require
			archive_path_not_empty: not a_archive_path.is_empty
			directory_not_empty: not a_directory.is_empty
		local
			l_dir: DIRECTORY
			l_files: ARRAYED_LIST [STRING]
			l_entries: ARRAYED_LIST [PATH]
			l_name: STRING_32
		do
			last_error := Void
			files_added := 0

			create l_dir.make (a_directory)
			if l_dir.exists and then l_dir.is_readable then
				create l_files.make (20)
				l_entries := l_dir.entries
				across l_entries as entry loop
					l_name := entry.name
					if not l_name.same_string (".") and not l_name.same_string ("..") then
						l_files.extend (a_directory + "/" + l_name.to_string_8)
					end
				end
				if not l_files.is_empty then
					create_archive (a_archive_path, l_files.to_array)
				else
					last_error := "Directory is empty: " + a_directory
				end
			else
				last_error := "Cannot read directory: " + a_directory
			end
		end

	add_file_to_archive (a_archive_path: STRING; a_file_path: STRING)
			-- Add `a_file_path' to existing archive at `a_archive_path'.
			-- Note: TAR format doesn't support efficient appending; this creates a new archive.
		require
			archive_path_not_empty: not a_archive_path.is_empty
			file_path_not_empty: not a_file_path.is_empty
		local
			l_existing: ARRAYED_LIST [STRING]
		do
			l_existing := list_archive (a_archive_path)
			l_existing.extend (a_file_path)
			create_archive (a_archive_path, l_existing.to_array)
		end

feature -- Archive Extraction

	extract_archive (a_archive_path: STRING; a_destination: STRING)
			-- Extract all files from `a_archive_path' to `a_destination'.
		require
			archive_path_not_empty: not a_archive_path.is_empty
			destination_not_empty: not a_destination.is_empty
		local
			l_archive: ARCHIVE
			l_backend: FILE_STORAGE_BACKEND
			l_path: PATH
			l_dest_dir: DIRECTORY
			l_old_dir: STRING_32
			l_env: EXECUTION_ENVIRONMENT
		do
			last_error := Void
			files_extracted := 0

			create l_dest_dir.make (a_destination)
			if not l_dest_dir.exists then
				l_dest_dir.recursive_create_dir
			end

			create l_path.make_from_string (a_archive_path)
			create l_backend.make_from_path (l_path)
			create l_archive.make (l_backend)

			l_archive.add_unarchiver (create {FILE_UNARCHIVER})
			l_archive.add_unarchiver (create {DIRECTORY_UNARCHIVER})

			create l_env
			l_old_dir := l_env.current_working_path.name
			l_env.change_working_path (create {PATH}.make_from_string (a_destination))

			l_archive.open_unarchive
			l_archive.unarchive

			l_env.change_working_path (create {PATH}.make_from_string (l_old_dir))

			if l_archive.has_error then
				last_error := "Error extracting archive"
			end
		end

	extract_file (a_archive_path: STRING; a_file_name: STRING; a_destination: STRING)
			-- Extract specific file `a_file_name' from archive to `a_destination'.
		require
			archive_path_not_empty: not a_archive_path.is_empty
			file_name_not_empty: not a_file_name.is_empty
			destination_not_empty: not a_destination.is_empty
		local
			l_archive: ARCHIVE
			l_backend: FILE_STORAGE_BACKEND
			l_path: PATH
			l_unarchiver: SELECTIVE_FILE_UNARCHIVER
		do
			last_error := Void
			files_extracted := 0

			create l_path.make_from_string (a_archive_path)
			create l_backend.make_from_path (l_path)
			create l_archive.make (l_backend)

			create l_unarchiver.make (a_file_name, a_destination)
			l_archive.add_unarchiver (l_unarchiver)

			l_archive.open_unarchive
			l_archive.unarchive

			if l_unarchiver.file_extracted then
				files_extracted := 1
			else
				last_error := "File not found in archive: " + a_file_name
			end
		end

feature -- Archive Listing

	list_archive (a_archive_path: STRING): ARRAYED_LIST [STRING]
			-- List all entries in archive at `a_archive_path'.
		require
			archive_path_not_empty: not a_archive_path.is_empty
		local
			l_archive: ARCHIVE
			l_backend: FILE_STORAGE_BACKEND
			l_path: PATH
			l_lister: LISTING_UNARCHIVER
		do
			last_error := Void
			create Result.make (10)

			create l_path.make_from_string (a_archive_path)
			create l_backend.make_from_path (l_path)
			create l_archive.make (l_backend)

			create l_lister.make (Result)
			l_archive.add_unarchiver (l_lister)

			l_archive.open_unarchive
			l_archive.unarchive

			if l_archive.has_error then
				last_error := "Error listing archive"
			end
		ensure
			result_not_void: Result /= Void
		end

	archive_contains (a_archive_path: STRING; a_file_name: STRING): BOOLEAN
			-- Does archive contain a file named `a_file_name'?
		require
			archive_path_not_empty: not a_archive_path.is_empty
			file_name_not_empty: not a_file_name.is_empty
		local
			l_entries: ARRAYED_LIST [STRING]
		do
			l_entries := list_archive (a_archive_path)
			across l_entries as entry loop
				if entry.same_string (a_file_name) then
					Result := True
				end
			end
		end

	archive_entry_count (a_archive_path: STRING): INTEGER
			-- Number of entries in archive.
		require
			archive_path_not_empty: not a_archive_path.is_empty
		do
			Result := list_archive (a_archive_path).count
		end

feature -- Status Report

	is_valid_archive (a_archive_path: STRING): BOOLEAN
			-- Is `a_archive_path' a valid tar archive?
		require
			archive_path_not_empty: not a_archive_path.is_empty
		local
			l_file: RAW_FILE
			l_dummy: ARRAYED_LIST [STRING]
		do
			create l_file.make_with_name (a_archive_path)
			if l_file.exists and then l_file.is_readable then
				l_dummy := list_archive (a_archive_path)
				Result := last_error = Void
			end
		end

end
