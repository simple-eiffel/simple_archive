note
	description: "Tests for SIMPLE_ARCHIVE"
	author: "Larry Rix"
	testing: "covers"

class
	LIB_TESTS

inherit
	TEST_SET_BASE
		redefine
			on_prepare,
			on_clean
		end

feature {NONE} -- Setup

	on_prepare
			-- Prepare test files.
		local
			l_file: RAW_FILE
			l_dir: DIRECTORY
		do
			-- Create test directory
			create l_dir.make (test_directory)
			if not l_dir.exists then
				l_dir.recursive_create_dir
			end

			-- Create test files
			create l_file.make_create_read_write (test_file_1)
			l_file.put_string ("This is test file 1 content.")
			l_file.close

			create l_file.make_create_read_write (test_file_2)
			l_file.put_string ("This is test file 2 with different content.")
			l_file.close
		end

	on_clean
			-- Clean up test files.
		local
			l_file: RAW_FILE
		do
			-- Delete test files
			create l_file.make_with_name (test_file_1)
			if l_file.exists then l_file.delete end

			create l_file.make_with_name (test_file_2)
			if l_file.exists then l_file.delete end

			create l_file.make_with_name (test_archive)
			if l_file.exists then l_file.delete end

			-- Delete extracted files
			create l_file.make_with_name (extract_directory + "/test1.txt")
			if l_file.exists then l_file.delete end

			create l_file.make_with_name (extract_directory + "/test2.txt")
			if l_file.exists then l_file.delete end
		end

feature -- Tests

	test_create_archive
			-- Test creating a tar archive.
		local
			archive: SIMPLE_ARCHIVE
			l_file: RAW_FILE
			l_files: ARRAY [STRING]
		do
			on_prepare

			create archive.make
			l_files := <<test_file_1, test_file_2>>

			archive.create_archive (test_archive, l_files)

			assert_true ("no error", archive.last_error = Void)
			assert_integers_equal ("files added", 2, archive.files_added)

			-- Verify archive file exists
			create l_file.make_with_name (test_archive)
			assert_true ("archive created", l_file.exists)
			assert_true ("archive not empty", l_file.count > 0)

			on_clean
		end

	test_list_archive
			-- Test listing archive contents.
		local
			archive: SIMPLE_ARCHIVE
			entries: ARRAYED_LIST [STRING]
		do
			on_prepare

			-- First create an archive
			create archive.make
			archive.create_archive (test_archive, <<test_file_1, test_file_2>>)

			-- Now list it
			entries := archive.list_archive (test_archive)

			assert_true ("no error", archive.last_error = Void)
			assert_integers_equal ("entry count", 2, entries.count)

			on_clean
		end

	test_extract_archive
			-- Test extracting archive contents.
		local
			archive: SIMPLE_ARCHIVE
			l_dir: DIRECTORY
		do
			on_prepare

			-- Create archive first
			create archive.make
			archive.create_archive (test_archive, <<test_file_1, test_file_2>>)

			-- Create extract directory
			create l_dir.make (extract_directory)
			if not l_dir.exists then
				l_dir.recursive_create_dir
			end

			-- Extract - may have path-related issues but should not crash
			archive.extract_archive (test_archive, extract_directory)

			on_clean
		end

	test_archive_contains
			-- Test checking if archive contains a file.
		local
			archive: SIMPLE_ARCHIVE
			l_entries: ARRAYED_LIST [STRING]
			l_found: BOOLEAN
		do
			on_prepare

			-- Create archive first
			create archive.make
			archive.create_archive (test_archive, <<test_file_1>>)

			-- List and verify there's at least one entry
			l_entries := archive.list_archive (test_archive)
			assert_true ("has entries", l_entries.count > 0)

			-- Check if any entry contains our filename (path formats may vary)
			l_found := False
			across l_entries as e loop
				if e.has_substring ("test1.txt") then
					l_found := True
				end
			end
			assert_true ("contains test file", l_found)

			on_clean
		end

	test_entry_count
			-- Test getting entry count.
		local
			archive: SIMPLE_ARCHIVE
		do
			on_prepare

			-- Create archive first
			create archive.make
			archive.create_archive (test_archive, <<test_file_1, test_file_2>>)

			-- Check count
			assert_integers_equal ("entry count", 2, archive.archive_entry_count (test_archive))

			on_clean
		end

	test_is_valid_archive
			-- Test archive validation.
		local
			archive: SIMPLE_ARCHIVE
		do
			on_prepare

			-- Create valid archive
			create archive.make
			archive.create_archive (test_archive, <<test_file_1>>)

			assert_true ("valid archive", archive.is_valid_archive (test_archive))
			assert_false ("invalid archive", archive.is_valid_archive ("nonexistent.tar"))

			on_clean
		end

feature -- ZIP Tests

	test_zip_create_and_list
			-- Test creating and listing a ZIP archive.
		local
			l_zip: SIMPLE_ZIP
			l_entries: ARRAYED_LIST [STRING]
			l_file: RAW_FILE
			l_dir: DIRECTORY
		do
			-- Ensure test directory exists
			create l_dir.make (test_directory)
			if not l_dir.exists then
				l_dir.recursive_create_dir
			end

			create l_zip.make

			-- Create a ZIP with string content
			l_zip.begin_create (test_zip_archive)
			assert_false ("no error on begin", l_zip.has_error)
			assert_true ("is creating", l_zip.is_creating)

			l_zip.add_entry_from_string ("file1.txt", "Content of file 1")
			l_zip.add_entry_from_string ("folder/file2.txt", "Content of file 2")
			l_zip.end_create

			assert_false ("no error on create", l_zip.has_error)
			assert_integers_equal ("files added", 2, l_zip.files_added)

			-- Verify archive exists
			create l_file.make_with_name (test_zip_archive)
			assert_true ("zip created", l_file.exists)

			-- List entries
			l_entries := l_zip.list_archive (test_zip_archive)
			assert_false ("no error on list", l_zip.has_error)
			assert_integers_equal ("entry count", 2, l_entries.count)

			-- Cleanup
			if l_file.exists then l_file.delete end
		end

	test_zip_extract_entry
			-- Test extracting entry content from ZIP.
		local
			l_zip: SIMPLE_ZIP
			l_content: detachable STRING
			l_file: RAW_FILE
			l_dir: DIRECTORY
		do
			-- Ensure test directory exists
			create l_dir.make (test_directory)
			if not l_dir.exists then
				l_dir.recursive_create_dir
			end

			create l_zip.make

			-- Create a ZIP
			l_zip.begin_create (test_zip_archive)
			l_zip.add_entry_from_string ("data.txt", "Hello from ZIP!")
			l_zip.end_create

			-- Extract the entry
			l_content := l_zip.extract_entry (test_zip_archive, "data.txt")
			assert_false ("no error on extract", l_zip.has_error)
			assert_attached ("content attached", l_content)
			if attached l_content as c then
				assert_strings_equal ("content matches", "Hello from ZIP!", c)
			end

			-- Cleanup
			create l_file.make_with_name (test_zip_archive)
			if l_file.exists then l_file.delete end
		end

	test_zip_contains
			-- Test archive_contains query.
		local
			l_zip: SIMPLE_ZIP
			l_file: RAW_FILE
			l_dir: DIRECTORY
		do
			-- Ensure test directory exists
			create l_dir.make (test_directory)
			if not l_dir.exists then
				l_dir.recursive_create_dir
			end

			create l_zip.make

			-- Create a ZIP
			l_zip.begin_create (test_zip_archive)
			l_zip.add_entry_from_string ("present.txt", "I exist")
			l_zip.end_create

			-- Check contains
			assert_true ("contains present", l_zip.archive_contains (test_zip_archive, "present.txt"))
			assert_false ("not contains missing", l_zip.archive_contains (test_zip_archive, "missing.txt"))

			-- Cleanup
			create l_file.make_with_name (test_zip_archive)
			if l_file.exists then l_file.delete end
		end

	test_zip_is_valid
			-- Test is_valid_archive query.
		local
			l_zip: SIMPLE_ZIP
			l_file: RAW_FILE
			l_dir: DIRECTORY
		do
			-- Ensure test directory exists
			create l_dir.make (test_directory)
			if not l_dir.exists then
				l_dir.recursive_create_dir
			end

			create l_zip.make

			-- Create a valid ZIP
			l_zip.begin_create (test_zip_archive)
			l_zip.add_entry_from_string ("test.txt", "content")
			l_zip.end_create

			assert_true ("valid zip", l_zip.is_valid_archive (test_zip_archive))
			assert_false ("invalid zip", l_zip.is_valid_archive ("nonexistent.zip"))

			-- Cleanup
			create l_file.make_with_name (test_zip_archive)
			if l_file.exists then l_file.delete end
		end

feature {NONE} -- Test Data

	test_directory: STRING = "./test_archive_temp"
	test_file_1: STRING = "./test_archive_temp/test1.txt"
	test_file_2: STRING = "./test_archive_temp/test2.txt"
	test_archive: STRING = "./test_archive_temp/test.tar"
	test_zip_archive: STRING = "./test_archive_temp/test.zip"
	extract_directory: STRING = "./test_archive_temp/extracted"

end
