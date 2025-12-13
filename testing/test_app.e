note
	description: "Test application for SIMPLE_ARCHIVE"
	author: "Larry Rix"

class
	TEST_APP

create
	make

feature {NONE} -- Initialization

	make
			-- Run the tests.
		do
			create tests
			print ("Running SIMPLE_ARCHIVE tests...%N%N")

			passed := 0
			failed := 0

			run_test (agent tests.test_create_archive, "test_create_archive")
			run_test (agent tests.test_list_archive, "test_list_archive")
			run_test (agent tests.test_extract_archive, "test_extract_archive")
			run_test (agent tests.test_archive_contains, "test_archive_contains")
			run_test (agent tests.test_entry_count, "test_entry_count")
			run_test (agent tests.test_is_valid_archive, "test_is_valid_archive")

			print ("%N========================%N")
			print ("Results: " + passed.out + " passed, " + failed.out + " failed%N")

			if failed > 0 then
				print ("TESTS FAILED%N")
			else
				print ("ALL TESTS PASSED%N")
			end
		end

feature {NONE} -- Implementation

	tests: LIB_TESTS

	passed: INTEGER
	failed: INTEGER

	run_test (a_test: PROCEDURE; a_name: STRING)
			-- Run a single test and update counters.
		local
			l_retried: BOOLEAN
		do
			if not l_retried then
				a_test.call (Void)
				print ("  PASS: " + a_name + "%N")
				passed := passed + 1
			end
		rescue
			print ("  FAIL: " + a_name + "%N")
			failed := failed + 1
			l_retried := True
			retry
		end

end
