note
	description: "[
		Simple ZIP archive operations using minizip-ng library (v4.0.10).

		Creating ZIP files:
			create zip.make
			zip.create_archive ("output.zip", <<"file1.txt", "file2.txt">>)

		Extracting ZIP files:
			zip.extract_archive ("input.zip", "destination_dir")

		Listing contents:
			entries := zip.list_archive ("input.zip")

		In-memory operations (for XLSX support):
			zip.begin_create ("output.zip")
			zip.add_entry_from_string ("path/in/zip.xml", xml_content)
			zip.end_create
	]"
	author: "Larry Rix"

class
	SIMPLE_ZIP

create
	make

feature {NONE} -- Initialization

	make
			-- Create ZIP helper.
		do
			files_added := 0
			files_extracted := 0
			create last_error.make_empty
		end

feature -- Access

	last_error: STRING
	files_added: INTEGER
	files_extracted: INTEGER

feature -- Status Report

	has_error: BOOLEAN
		do
			Result := not last_error.is_empty
		end

feature -- Archive Creation (In-memory)

	begin_create (a_archive_path: STRING)
			-- Begin creating a new ZIP archive.
		require
			archive_path_not_empty: not a_archive_path.is_empty
			not_already_creating: not is_creating
		local
			l_c_path: C_STRING
		do
			last_error.wipe_out
			files_added := 0
			create l_c_path.make (a_archive_path)
			current_zip := c_zip_open (l_c_path.item)
			if current_zip = default_pointer then
				last_error := "Cannot create ZIP file: " + a_archive_path
			end
		ensure
			creating_or_error: is_creating or has_error
		end

	add_entry_from_string (a_entry_name: STRING; a_content: STRING)
			-- Add entry with string content to current ZIP.
		require
			is_creating: is_creating
			entry_name_not_empty: not a_entry_name.is_empty
			content_not_void: a_content /= Void
		local
			l_c_name: C_STRING
			l_c_content: C_STRING
		do
			create l_c_name.make (a_entry_name)
			create l_c_content.make (a_content)
			if c_zip_add_entry (current_zip, l_c_name.item, l_c_content.item, a_content.count) = 0 then
				files_added := files_added + 1
			else
				last_error := "Error adding entry: " + a_entry_name
			end
		end

	end_create
			-- Finish creating the ZIP archive.
		require
			is_creating: is_creating
		do
			c_zip_close (current_zip)
			current_zip := default_pointer
		ensure
			not_creating: not is_creating
		end

	is_creating: BOOLEAN
		do
			Result := current_zip /= default_pointer
		end

feature -- Archive Listing

	list_archive (a_archive_path: STRING): ARRAYED_LIST [STRING]
			-- List all entries in archive.
		require
			archive_path_not_empty: not a_archive_path.is_empty
		local
			l_unz: POINTER
			l_filename: STRING
			l_status: INTEGER
			l_c_path: C_STRING
		do
			last_error.wipe_out
			create Result.make (10)
			create l_c_path.make (a_archive_path)
			l_unz := c_unzip_open (l_c_path.item)
			if l_unz = default_pointer then
				last_error := "Cannot open ZIP file: " + a_archive_path
			else
				from l_status := c_unzip_go_to_first (l_unz) until l_status /= 0 loop
					l_filename := c_unzip_get_current_filename (l_unz)
					if not l_filename.is_empty then
						Result.extend (l_filename)
					end
					l_status := c_unzip_go_to_next (l_unz)
				end
				c_unzip_close (l_unz)
			end
		ensure
			result_not_void: Result /= Void
		end

	extract_entry (a_archive_path: STRING; a_entry_name: STRING): detachable STRING
			-- Extract specific entry content as string.
		require
			archive_path_not_empty: not a_archive_path.is_empty
			entry_name_not_empty: not a_entry_name.is_empty
		local
			l_unz: POINTER
			l_c_path: C_STRING
			l_c_name: C_STRING
		do
			last_error.wipe_out
			create l_c_path.make (a_archive_path)
			l_unz := c_unzip_open (l_c_path.item)
			if l_unz = default_pointer then
				last_error := "Cannot open ZIP file: " + a_archive_path
			else
				create l_c_name.make (a_entry_name)
				if c_unzip_locate_file (l_unz, l_c_name.item) = 0 then
					Result := c_unzip_read_current_file (l_unz)
				else
					last_error := "Entry not found: " + a_entry_name
				end
				c_unzip_close (l_unz)
			end
		end

	archive_contains (a_archive_path: STRING; a_entry_name: STRING): BOOLEAN
			-- Does archive contain an entry?
		require
			archive_path_not_empty: not a_archive_path.is_empty
			entry_name_not_empty: not a_entry_name.is_empty
		local
			l_unz: POINTER
			l_c_path: C_STRING
			l_c_name: C_STRING
		do
			create l_c_path.make (a_archive_path)
			l_unz := c_unzip_open (l_c_path.item)
			if l_unz /= default_pointer then
				create l_c_name.make (a_entry_name)
				Result := c_unzip_locate_file (l_unz, l_c_name.item) = 0
				c_unzip_close (l_unz)
			end
		end

	is_valid_archive (a_archive_path: STRING): BOOLEAN
			-- Is this a valid ZIP archive?
		require
			archive_path_not_empty: not a_archive_path.is_empty
		local
			l_unz: POINTER
			l_c_path: C_STRING
		do
			create l_c_path.make (a_archive_path)
			l_unz := c_unzip_open (l_c_path.item)
			Result := l_unz /= default_pointer
			if Result then
				c_unzip_close (l_unz)
			end
		end

feature {NONE} -- Implementation

	current_zip: POINTER

feature {NONE} -- C Externals

	c_zip_open (a_path: POINTER): POINTER
		external
			"C inline use %"zip.h%""
		alias
			"return (EIF_POINTER) zipOpen((const char*)$a_path, APPEND_STATUS_CREATE);"
		end

	c_zip_add_entry (a_zip: POINTER; a_name: POINTER; a_content: POINTER; a_size: INTEGER): INTEGER
		external
			"C inline use %"zip.h%", <string.h>"
		alias
			"[
				int result = 0;
				zip_fileinfo zi;
				memset(&zi, 0, sizeof(zi));
				result = zipOpenNewFileInZip((zipFile)$a_zip, (const char*)$a_name, &zi,
					NULL, 0, NULL, 0, NULL, Z_DEFLATED, Z_DEFAULT_COMPRESSION);
				if (result == ZIP_OK) {
					result = zipWriteInFileInZip((zipFile)$a_zip, (const void*)$a_content, (unsigned)$a_size);
					zipCloseFileInZip((zipFile)$a_zip);
				}
				return (EIF_INTEGER) result;
			]"
		end

	c_zip_close (a_zip: POINTER)
		external
			"C inline use %"zip.h%""
		alias
			"zipClose((zipFile)$a_zip, NULL);"
		end

	c_unzip_open (a_path: POINTER): POINTER
		external
			"C inline use %"unzip.h%""
		alias
			"return (EIF_POINTER) unzOpen((const char*)$a_path);"
		end

	c_unzip_close (a_unz: POINTER)
		external
			"C inline use %"unzip.h%""
		alias
			"unzClose((unzFile)$a_unz);"
		end

	c_unzip_go_to_first (a_unz: POINTER): INTEGER
		external
			"C inline use %"unzip.h%""
		alias
			"return (EIF_INTEGER) unzGoToFirstFile((unzFile)$a_unz);"
		end

	c_unzip_go_to_next (a_unz: POINTER): INTEGER
		external
			"C inline use %"unzip.h%""
		alias
			"return (EIF_INTEGER) unzGoToNextFile((unzFile)$a_unz);"
		end

	c_unzip_locate_file (a_unz: POINTER; a_name: POINTER): INTEGER
		external
			"C inline use %"unzip.h%""
		alias
			"return (EIF_INTEGER) unzLocateFile((unzFile)$a_unz, (const char*)$a_name, 0);"
		end

	c_unzip_get_current_filename (a_unz: POINTER): STRING
		external
			"C inline use %"unzip.h%", <string.h>"
		alias
			"[
				char filename[512];
				unz_file_info info;
				memset(filename, 0, sizeof(filename));
				if (unzGetCurrentFileInfo((unzFile)$a_unz, &info, filename, sizeof(filename)-1,
					NULL, 0, NULL, 0) == UNZ_OK) {
					return RTMS(filename);
				}
				return RTMS("");
			]"
		end

	c_unzip_read_current_file (a_unz: POINTER): STRING
		external
			"C inline use %"unzip.h%", <stdlib.h>, <string.h>"
		alias
			"[
				unz_file_info info;
				char* buffer;
				int bytes_read;
				EIF_REFERENCE result;
				if (unzGetCurrentFileInfo((unzFile)$a_unz, &info, NULL, 0, NULL, 0, NULL, 0) != UNZ_OK)
					return RTMS("");
				buffer = (char*) malloc(info.uncompressed_size + 1);
				if (!buffer) return RTMS("");
				memset(buffer, 0, info.uncompressed_size + 1);
				if (unzOpenCurrentFile((unzFile)$a_unz) != UNZ_OK) { free(buffer); return RTMS(""); }
				bytes_read = unzReadCurrentFile((unzFile)$a_unz, buffer, (unsigned)info.uncompressed_size);
				unzCloseCurrentFile((unzFile)$a_unz);
				if (bytes_read < 0) { free(buffer); return RTMS(""); }
				buffer[bytes_read] = 0;
				result = RTMS_EX(buffer, bytes_read);
				free(buffer);
				return result;
			]"
		end

end
